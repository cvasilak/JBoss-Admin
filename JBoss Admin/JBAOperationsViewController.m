/*
 * JBoss Admin
 * Copyright Christos Vasilakis, and individual contributors
 * See the copyright.txt file in the distribution for a full
 * listing of individual contributors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "JBAOperationsViewController.h"
#import "JBAOperationExecViewController.h"

#import "JBAManagementModel.h"
#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "DefaultCell.h"
#import "SVProgressHUD.h"

@interface JBAOperationsViewController()<JBARefreshable>

-(void)displayEditorForOperation:(JBAOperation *)operation;

@end

@implementation JBAOperationsViewController {
    NSArray *_operations;
    
    NSArray *_genericOps;
    
    BOOL _filterGeneric;
}

@synthesize path = _path;

-(void)dealloc {
    DLog(@"JBAOperationsViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBAOperationsViewController viewDidLoad");

    self.title = @"Operations";
    
    //private static final String[] genericOps = {"add", "read-operation-description", "read-resource-description", "read-operation-names"};
    _genericOps = @[@"add", @"read-operation-description", @"read-resource-description", @"read-operation-names"];
    
    // Check if user requested to see generic operations
    // raise a flag so that the operation names received from 
    // the server are filtered and display only generic operations
    if ([(self.path)[[self.path count]-1] isEqualToString:@"*"])
        _filterGeneric = YES;
    
    [self refresh];
    
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_operations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];    
    
    DefaultCell *cell = [DefaultCell cellForTableView:tableView];
    
    JBAOperation *operation = _operations[row];

    cell.textLabel.text = operation.name;
    cell.imageView.image =[UIImage imageNamed:@"operations.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    __block JBAOperation *operation = _operations[row];
    
    if (operation.descr == nil) {
        // first time clicked, need to retrieve operation info
        DLog(@"not operation information found, perfoming read-operation-description");
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        
        NSDictionary *params = 
            @{@"operation": @"read-operation-description",
             @"address": (self.path == nil?@[@"/"]: self.path),
             @"name": operation.name};
        
        [[JBAOperationsManager sharedManager]
            postJBossRequestWithParams:params
                success:^(NSDictionary *JSON) {
                 [SVProgressHUD dismiss];
                 
                    operation.descr = JSON[@"description"];

                    NSMutableArray *parameters = [[NSMutableArray alloc] init];
                    
                    NSDictionary *reqParams = JSON[@"request-properties"];
                    
                    for (NSString *name in [reqParams allKeys]) {
                        NSDictionary *info = reqParams[name];
                        
                        JBAOperationParameter *param = [[JBAOperationParameter alloc] init];
                        param.name = name;
                        param.type = [JBAManagementModel 
                                      typeFromString:info[@"type"][@"TYPE_MODEL_VALUE"]];                                        
                        
                        // for LIST type extract the type of object the list holds
                        if (param.type == LIST) {
                            param.valueType = [JBAManagementModel 
                                               typeFromString:info[@"value-type"][@"TYPE_MODEL_VALUE"]];                                        
                        }
                        
                        param.descr = info[@"description"];
                        
                        // Initialize operation parameters
                        // see: https://docs.jboss.org/author/display/AS71/Description+of+the+Management+Model
                        
                        // nillable – boolean
                        // true if null is a valid value. If not present, false is the default.
                        param.nillable = info[@"nillable"] == nil? NO: [info[@"nillable"] boolValue]; 
                        
                        // required – boolean
                        // Only relevant to parameters. true if the parameter must be present in the request object used to invoke 
                        // the operation; false if it can omitted. If not present, true is the default
                        param.required = info[@"required"] == nil? YES: [info[@"required"] boolValue];
                        
                        // default value if present
                        param.defaultValue = info[@"default"];
                        
                        // default false for boolean values when defaultValue is nil
                        if (param.type == BOOLEAN)
                            param.value = (param.defaultValue == nil? @NO: param.defaultValue);
                        else 
                            param.value = param.defaultValue;
                        
                        [parameters addObject:param];
                    }
                    
                    [parameters sortUsingSelector:@selector(compare:)];
                    // sort by required parameter set
                    [parameters sortUsingSelector:@selector(compareRequired:)];

                    // for "add" operation insert a fake parameter that denotes the resource path
                    if ([operation.name isEqualToString:@"add"]) {
                        JBAOperationParameter *param = [[JBAOperationParameter alloc] init];
                        //extract the child type from path (e.g. "/deployment=" )
                        NSString *basePath = (self.path)[[self.path count]-2];
                        
                        param.name = [NSString stringWithFormat:@"%@=<name>/", basePath];
                        param.type = STRING;
                        param.descr = [NSString stringWithFormat:@"Resource name for the new %@", basePath];
                        param.required = YES;
                        
                        param.isAddParameter = YES;
                        
                        // insert it at the top of the list
                        [parameters insertObject:param atIndex:0];
                    }
                    
                    operation.parameters = parameters;
                    
                    NSDictionary *repParams = JSON[@"reply-properties"];
                    
                    if (repParams[@"type"] != nil) { // for void operation "type" is-non-existant
                        JBAOperationReply *reply= [[JBAOperationReply alloc] init];
                        reply.type = [JBAManagementModel
                                      typeFromString:repParams[@"type"][@"TYPE_MODEL_VALUE"]];                                        

                        operation.reply = reply;
                    }
                    
                    [self displayEditorForOperation:operation];
                    
             } failure:^(NSError *error) {
                 [SVProgressHUD dismiss];
                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                 message:[error localizedDescription]
                                                                delegate:nil 
                                                       cancelButtonTitle:@"Bummer"
                                                       otherButtonTitles:nil];
                 [alert show];
                 
             }
             ];
        
    } else {
        [self displayEditorForOperation:operation];
    }
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions
- (void)refresh {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

    NSDictionary *params = 
        @{@"operation": @"read-operation-names",
         @"address": (self.path == nil?@[@"/"]: self.path)};
    
    [[JBAOperationsManager sharedManager]
     postJBossRequestWithParams:params
     success:^(NSArray *names) {
         [SVProgressHUD dismiss];
         
         names = [names sortedArrayUsingSelector:@selector(compare:)];
         
         NSMutableArray *operations = [[NSMutableArray alloc] init];
         
         for (NSString *name in names) {
             // if generic operations is requested filter out non-generic operations
             if (_filterGeneric && ![_genericOps containsObject:name])
                 continue;
             
             // remove "add" operation for non-generic operations
             if (!_filterGeneric && [name isEqualToString:@"add"])
                 continue;
             
             JBAOperation *operation = [[JBAOperation alloc] init];
             operation.name = name;
             operation.path = self.path;
             
             [operations addObject:operation];
         }
         
         _operations = operations;
         
         [self.tableView reloadData];
         
     } failure:^(NSError *error) {
         [SVProgressHUD dismiss];
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                         message:[error localizedDescription]
                                                        delegate:nil 
                                               cancelButtonTitle:@"Bummer"
                                               otherButtonTitles:nil];
         [alert show];

     }
     ];
}

-(void)displayEditorForOperation:(JBAOperation *)operation {
    // reset values prior of edit to dismiss any previous values
    for (NSUInteger i = 0; i < [operation.parameters count]; i++) {
        JBAOperationParameter *parameter = (operation.parameters)[i];
        
        if (parameter.type == BOOLEAN) 
            parameter.value = (parameter.defaultValue == nil? @NO: parameter.defaultValue);
        else
            parameter.value = parameter.defaultValue;
    }

    JBAOperationExecViewController *editorController = [[JBAOperationExecViewController alloc] initWithStyle:UITableViewStyleGrouped];
    editorController.operation = operation;
    
    [self.navigationController pushViewController:editorController animated:YES];
}

@end
