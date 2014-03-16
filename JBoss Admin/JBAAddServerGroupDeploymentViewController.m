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

#import "JBAAddServerGroupDeploymentViewController.h"
#import "JBADeploymentsViewController.h"

#import "JBAOperationsManager.h"

#import "SubtitleCell.h"
#import "SVProgressHUD.h"
#import "UIActionSheet+BlockExtensions.h"

@implementation JBAAddServerGroupDeploymentViewController {
    NSArray *_names;
    NSMutableDictionary *_deployments;
    
    NSIndexPath *_lastIndexPath;
}

@synthesize parentNavController = _parentNavController;
@synthesize group = _group;
@synthesize existingDeployments = _existingDeployments;

-(void)dealloc {
    DLog(@"JBAAddServerGroupDeploymentViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBAAddServerGroupDeploymentViewController viewDidLoad");
    
    self.title = @"Content Repository";

    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;

    UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(addToServerGroup)];
    
    self.navigationItem.rightBarButtonItem = nextButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO; // initially disable it cause nothing is checked
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [[JBAOperationsManager sharedManager] 
     fetchDeploymentsFromServerGroup:nil withSuccess:^(NSMutableDictionary *deployments) {
         [SVProgressHUD dismiss];
     
         // check if content repository is empty
         if ([deployments count] == 0) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                             message:@"No deployments found on domain's content repository!"
                                                            delegate:nil 
                                                   cancelButtonTitle:@"Bummer"
                                                   otherButtonTitles:nil];
             [alert show];
             return;
         } 
         
         // filter out existing deployments in the group
         for (NSString *deployment in [deployments allKeys]) {
             if ([self.existingDeployments containsObject:deployment]) {
                 [deployments removeObjectForKey:deployment];
             }
         }
         
         // check if all content is deployed on this server group
         if (self.existingDeployments != nil && [deployments count] == 0) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                             message:@"All existing deployments are deployed on this server group!"
                                                            delegate:nil 
                                                   cancelButtonTitle:@"Bummer"
                                                   otherButtonTitles:nil];
             [alert show];
         } else {
             _deployments = deployments;
             _names = [[deployments allKeys] sortedArrayUsingSelector:@selector(compare:)];
             
             [self.tableView reloadData];
         }
        
     } andFailure:^(NSError *error) {
         [SVProgressHUD dismiss];
        
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                         message:[error localizedDescription]
                                                        delegate:nil 
                                               cancelButtonTitle:@"Bummer"
                                               otherButtonTitles:nil];
         [alert show];
     }];
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
    
    NSString *name = _names[row];
    cell.textLabel.text = name;
    
    NSUInteger oldRow = [_lastIndexPath row];
    cell.accessoryType = (row == oldRow && _lastIndexPath != nil) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger newRow = [indexPath row];
    NSInteger oldRow = (_lastIndexPath != nil) ? [_lastIndexPath row] : -1;
    
    if (newRow != oldRow) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        _lastIndexPath = indexPath;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions
- (void)addToServerGroup {
    NSString *deploymentName = _names[[_lastIndexPath row]];
    NSMutableDictionary *deploymentInfo = _deployments[deploymentName];

    UIActionSheet *yesno =
        [[UIActionSheet alloc]
            initWithTitle:@"Please choose deployment operation:"
            completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                if (buttonIndex == 0 /* Add to Group and Enable */ 
                ||  buttonIndex == 1 /* Add to Group */) {
                    
                    BOOL enable = (buttonIndex == 0? YES: NO);
                    deploymentInfo[@"enabled"] = @(enable);
                    
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                    
                    [[JBAOperationsManager sharedManager]
                     addDeploymentContentWithHash:
                     deploymentInfo[@"content"][0][@"hash"][@"BYTES_VALUE"]
                     andName:deploymentInfo[@"name"]
                     toServerGroups:[NSMutableArray arrayWithObject:self.group]
                     enable:enable
                     withSuccess:^(void) {
                         
                         [SVProgressHUD 
                          showSuccessWithStatus:[NSString stringWithFormat:@"Successfully Added%@", (enable? @" and Enabled!":@"!")]];
                         
                         [self dismissViewControllerAnimated:YES completion:nil];
                         
                         // ok inform JBADeploymentsViewController of the 
                         // new deployment so it can update model and table view
                         NSNotification *notification = [NSNotification notificationWithName:@"DeploymentAddedNotification" object:deploymentInfo];
                         [[NSNotificationCenter defaultCenter] postNotification:notification];

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
            destructiveButtonTitle: @"Add to Group and Enable"
            otherButtonTitles:@"Add to Group", nil
         ];
    
    [yesno showInView:self.view];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
