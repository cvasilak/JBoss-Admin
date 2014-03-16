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

#import "JBADomainServerGroupsViewController.h"
#import "JBADeploymentsViewController.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "SubtitleCell.h"
#import "SVProgressHUD.h"
#import "UIActionSheet+BlockExtensions.h"

@interface JBADomainServerGroupsViewController()<JBARefreshable>

@end

@implementation JBADomainServerGroupsViewController {
    NSArray *_names;
    NSMutableDictionary *_groups;
    
    NSMutableArray *_selectedGroups;
}

@synthesize groupSelectionMode = _groupSelectionMode;
@synthesize deploymentToAdd = _deploymentToAdd;

-(void)dealloc {
    DLog(@"JBADomainServerGroupsViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBADomainServerGroupsViewController viewDidLoad");
    
    if (self.groupSelectionMode) {
        _selectedGroups = [[NSMutableArray alloc] init];
        
        self.title = @"Choose Group";
        UIBarButtonItem *addToGroupsButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered
                                                                                 target:self action:@selector(addToGroups)];
        self.navigationItem.rightBarButtonItem = addToGroupsButtonItem;
        self.navigationItem.rightBarButtonItem.enabled = NO; // initially disable it cause nothing is checked

        UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered
                                                                            target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelButtonItem;

        
    } else {
        self.title = @"Server Groups";
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        [self setRefreshControl:refreshControl];
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [self refresh];
    }
    
    [self refresh];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBADomainServerGroupsViewController viewWillAppear");
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_names count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];

    SubtitleCell *cell = [SubtitleCell cellForTableView:tableView];
    
    cell.accessoryType = (self.groupSelectionMode? UITableViewCellAccessoryNone: UITableViewCellAccessoryDisclosureIndicator);
    
    NSString *name = [_names objectAtIndex:row];
    cell.textLabel.text = name;
    cell.detailTextLabel.text = [[_groups objectForKey:name] objectForKey:@"profile"];

    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    NSString *group = [_names objectAtIndex:row];
    
    if (self.groupSelectionMode) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [_selectedGroups removeObject:group];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            [_selectedGroups addObject:group];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }

        self.navigationItem.rightBarButtonItem.enabled = ([_selectedGroups count] == 0? NO: YES);

    } else {
        JBADeploymentsViewController *deploymentsController = [[JBADeploymentsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        deploymentsController.mode = SERVER_MODE;
        deploymentsController.group = group;
        
        [self.navigationController pushViewController:deploymentsController animated:YES];

        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Actions
-(void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)refresh {
    [[JBAOperationsManager sharedManager]
     fetchDomainGroupInfoWithSuccess:^(NSMutableDictionary *groups) {
         [SVProgressHUD dismiss];
         
         if (self.groupSelectionMode) { // filter out groups that already contain the deployment
             for (NSDictionary *groupName in [groups allKeys]) {
                 id deployments = [[groups objectForKey:groupName] objectForKey:@"deployment"];
                 
                 if (![deployments isKindOfClass:[NSNull class]]) { // enter only if group contains deployments
                     if ([[deployments allKeys] containsObject:[self.deploymentToAdd objectForKey:@"name"]]) {
                         [groups removeObjectForKey:groupName];
                     }
                 }
             }
         }
         
         if ([groups count] == 0) { // already assigned, inform user
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                             message:[NSString stringWithFormat:@"%@ is already assigned to all server groups.", [self.deploymentToAdd objectForKey:@"name"]]
                                                            delegate:nil 
                                                   cancelButtonTitle:@"Bummer"
                                                   otherButtonTitles:nil];
             [alert show];
         } else {
             _groups = groups; 
             _names = [[_groups allKeys] sortedArrayUsingSelector:@selector(compare:)];
             [self.tableView reloadData];
             
             [self.refreshControl endRefreshing];
         }
         
     } andFailure:^(NSError *error) {
         [SVProgressHUD dismiss];
         [self.refreshControl endRefreshing];
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                         message:[error localizedDescription]
                                                        delegate:nil 
                                               cancelButtonTitle:@"Bummer"
                                               otherButtonTitles:nil];
         [alert show];
     }];
}

- (void)addToGroups {
    UIActionSheet *yesno = [[UIActionSheet alloc]
                            initWithTitle:@"Please choose deployment operation:"
                            completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                                if (buttonIndex == 0 /* Add to Group(s) and Enable */ 
                                 || buttonIndex == 1 /* Add to Group(s) */) {
                             
                                    BOOL enable = (buttonIndex == 0? YES: NO);

                                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                                    
                                    [[JBAOperationsManager sharedManager]
                                     addDeploymentContentWithHash:
                                        [[[[_deploymentToAdd objectForKey:@"content"] objectAtIndex:0] objectForKey:@"hash"] objectForKey:@"BYTES_VALUE"]
                                     andName:[_deploymentToAdd objectForKey:@"name"]
                                     toServerGroups:_selectedGroups
                                     enable:enable
                                     withSuccess:^(void) {

                                         [SVProgressHUD 
                                          showSuccessWithStatus:[NSString stringWithFormat:@"Successfully Added%@", (enable? @" and Enabled!":@"!")]];
                                         
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                         
                                     } andFailure:^(NSError *error) {
                                         [SVProgressHUD dismiss];
                                         
                                         UIAlertView *oops = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                        message:[error localizedDescription]
                                                                                       delegate:nil 
                                                                              cancelButtonTitle:@"Bummer"
                                                                              otherButtonTitles:nil];
                                         [oops show];
                                     }];
                                }
                                
                            }
                            
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle: @"Add to Group(s) and Enable"
                            otherButtonTitles:@"Add to Group(s)", nil];
    
    [yesno showInView:self.view];
    
}

@end
