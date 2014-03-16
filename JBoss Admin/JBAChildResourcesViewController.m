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

#import "JBAChildResourcesViewController.h"
#import "JBAProfileController.h"
#import "JBAOperationsViewController.h"

#import "JBAManagementModel.h"
#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "SVProgressHUD.h"

#import "DefaultCell.h"
#import "SubtitleCell.h"
#import "ButtonCell.h"

// Table Sections
typedef NS_ENUM(NSUInteger, JBAChildTypesTableSections) {
    JBATableChildResourcesSection,
    JBATableGenericOpsSection,
    JBATableChildTypesNumSections
};

@interface JBAChildResourcesViewController()<JBARefreshable>

@end

@implementation JBAChildResourcesViewController {
    NSArray *_names;
    BOOL _hasGenericOperations;
}

@synthesize path = _path;
@synthesize node = _node;

-(void)dealloc {
    DLog(@"JBAChildResourcesViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBAChildResourcesViewController viewDidLoad");

    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    self.title = self.node.name;
    
    [self refresh];
    
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return JBATableChildTypesNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case JBATableChildResourcesSection:
            return [_names count] > 0? @"Child Resources": nil;
        default:
            return nil;        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case JBATableChildResourcesSection:
            return [_names count];
        case JBATableGenericOpsSection:
            return _hasGenericOperations? 1: 0;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    id cell;
    
    switch (section) {
        case JBATableChildResourcesSection:
        {

            NSString *name = _names[row];
            
            if ([name isEqualToString:@"<undefined>"]) {
                DefaultCell *undefinedCell = [DefaultCell cellForTableView:tableView];                
                undefinedCell.textLabel.font = [UIFont italicSystemFontOfSize:16];
                undefinedCell.textLabel.textAlignment = NSTextAlignmentCenter;
                undefinedCell.textLabel.text = name;
                
                cell = undefinedCell;
            } else {
                
                SubtitleCell *childrenTypeCell = [SubtitleCell cellForTableView:tableView];
                childrenTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                childrenTypeCell.textLabel.text = name;                
                
                cell = childrenTypeCell;
            }
            
            break;
        }
        case JBATableGenericOpsSection:
        {
            ButtonCell *operationsCell = [ButtonCell cellForTableView:tableView];
            
            operationsCell.imageView.image = [UIImage imageNamed:@"operations.png"];
            operationsCell.textLabel.font = [UIFont italicSystemFontOfSize:16];
            operationsCell.textLabel.textAlignment = NSTextAlignmentCenter;
            operationsCell.textLabel.text = @"Generic Operations";
            operationsCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            cell = operationsCell;
            
            break;
        }

    }
    
    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];    
    
    switch (section) {
        case JBATableChildResourcesSection:
        {
            NSString *name = _names[row];
            
            // do nothing for undefined
            if ([name isEqualToString:@"<undefined>"])
                return;
            
            NSMutableArray *next = [[NSMutableArray alloc] initWithArray:self.path];
            [next addObject:self.node.name];
            [next addObject:name];
            
            JBAProfileController *controller = [[JBAProfileController alloc] initWithStyle:UITableViewStyleGrouped];
            
            controller.path = next;
            controller.title = name;
            
            [self.navigationController pushViewController:controller animated:YES];
            
            break;
        }
        case JBATableGenericOpsSection:
        {
            NSMutableArray *next = [[NSMutableArray alloc] initWithArray:self.path];
            [next addObject:self.node.name];            
            [next addObject:@"*"];
            
            JBAOperationsViewController *opsController = [[JBAOperationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            opsController.path = next;
            
            [self.navigationController pushViewController:opsController animated:YES];
            
            break;
        }
    }
}

#pragma mark - Actions
-(void)refresh {
    _hasGenericOperations = NO;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

    // will identify the child resources of this child type
    // Note: we reload here in case an "add" happened down the road
    NSDictionary *childNamesParams = @{@"operation": @"read-children-names",
                           @"address": (self.path==nil? @[@"/"]: self.path), 
                           @"child-type": self.node.name};
    
    [[JBAOperationsManager sharedManager]
     postJBossRequestWithParams:childNamesParams
     success:^(NSArray *childNames) {
         
         _names = [childNames sortedArrayUsingSelector:@selector(compare:)];
         self.node.value = _names;

         // append child-type name and the star for "read-operation-names"
         NSMutableArray *genericOpsPath = [[NSMutableArray alloc] initWithArray:self.path];
         [genericOpsPath addObject:self.node.name];
         [genericOpsPath addObject:@"*"];

         NSDictionary *genericOpsParams =  @{@"operation": @"read-operation-names",
                 @"address": genericOpsPath};

         [[JBAOperationsManager sharedManager]
          postJBossRequestWithParams:genericOpsParams
          success:^(NSArray *names) {
              [SVProgressHUD dismiss];

              // operations found, check if they contain
              // generic add
              for (NSString *name in names) {
                  if ([name isEqualToString:@"add"]) {
                      _hasGenericOperations = YES;
                      break;
                  }
              }

              // if no generic operations found and children resources
              // are empty inform as "undefined"
              if (!_hasGenericOperations && [_names count] == 0) {
                  _names = @[@"<undefined>"];                  
              }
              
              [self.tableView reloadData];
              
          } failure:^(NSError *error) {
              [SVProgressHUD dismiss];
              
              // empty operation list
              if ([error.domain isEqualToString:@"jboss-admin"]) {
                  // if no children resources found inform as "undefined"
                  if ([_names count] == 0) {
                      _names = @[@"<undefined>"];
                      
                  }

                 [self.tableView reloadData]; 
                  
                  return;                  
              }
             
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                              message:[error localizedDescription]
                                                             delegate:nil 
                                                    cancelButtonTitle:@"Bummer"
                                                    otherButtonTitles:nil];
              [alert show];
          }
          ]; 
         
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
@end
