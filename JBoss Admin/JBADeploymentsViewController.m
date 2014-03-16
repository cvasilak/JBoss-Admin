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

#import "JBADeploymentsViewController.h"
#import "JBAAddDeploymentViewController.h"
#import "JBAAddServerGroupDeploymentViewController.h"
#import "JBADomainServerGroupsViewController.h"
#import "CommonUtil.h"
#import "JBAOperationsManager.h"

#import "JBAAppDelegate.h"

#import "SubtitleCell.h"
#import "DefaultCell.h"
#import "ButtonCell.h"
#import "SVProgressHUD.h"
#import "UIActionSheet+BlockExtensions.h"
#import "UIView+ParentView.h"

typedef NS_ENUM(NSUInteger, JBADeploymentsTableSections) {
    JBADeploymentTableListSection,
    JBADeploymentTableAddSection,
    JBADeploymentNumSections
};

@interface JBADeploymentsViewController()

- (void)addContentButtonTapped;

@end

@implementation JBADeploymentsViewController {
    NSMutableArray *_names;
    NSMutableDictionary *_deployments;
}

@synthesize mode = _mode;
@synthesize group = _group;

-(void)dealloc {
    DLog(@"JBADeploymentsViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  	DLog(@"JBADeploymentsViewController viewDidLoad");
    
    if (self.mode == DOMAIN_MODE)
        self.title = @"Repository";
    else 
        self.title = @"Deployments";        
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [[JBAOperationsManager sharedManager] 
     fetchDeploymentsFromServerGroup:self.group withSuccess:^(NSMutableDictionary *deployments) {
        [SVProgressHUD dismiss];
        
        _deployments = deployments;
        _names = [NSMutableArray arrayWithArray:[deployments allKeys]];
        [_names sortUsingSelector:@selector(compare:)];
        
        [self.tableView reloadData];
        
    } andFailure:^(NSError *error) {
        [SVProgressHUD dismiss];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:[error localizedDescription]
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deploymentAdded:) name:@"DeploymentAddedNotification" object:nil];
    
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return JBADeploymentNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == JBADeploymentTableAddSection)
        return 1;
    
    return [_names count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    id cell;
    
    switch (section) {
            case JBADeploymentTableListSection:
            {
                NSString *deploymentName = _names[row];
                NSMutableDictionary *deploymentInfo = _deployments[deploymentName];

                SubtitleCell *deploymentCell = [SubtitleCell cellForTableView:tableView];

                UIButton *button;
                
                if (deploymentCell.accessoryView == nil) {
                    button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
                    
                    deploymentCell.accessoryView = button;
                } else {
                    button = (UIButton *)deploymentCell.accessoryView;
                }

                if (self.mode == STANDALONE_MODE || self.mode == SERVER_MODE) {
                    // check deployment status and set indicator image
                    if ([deploymentInfo[@"enabled"] boolValue] == YES) {  // deployment is "enabled"
                        deploymentCell.imageView.image = [UIImage imageNamed:@"up.png"];
                        
                        UIImage *buttonDisableImage = [UIImage imageNamed:@"disable.png"];
                        [button setBackgroundImage:buttonDisableImage forState:UIControlStateNormal];
                        button.frame = CGRectMake(0.0, 0.0, 70, 27);                                                                        
                        [button setTitle:@"Disable" forState:UIControlStateNormal];
                        [button addTarget:self action:@selector(enableDisableButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                        
                    } else {  // deployment is "disabled"
                        deploymentCell.imageView.image = [UIImage imageNamed:@"down.png"];   
                        
                        UIImage *buttonEnableImage = [UIImage imageNamed:@"enable.png"];
                        [button setBackgroundImage:buttonEnableImage forState:UIControlStateNormal];
                        button.frame = CGRectMake(0.0, 0.0, 70, 27);                                                
                        [button setTitle:@"Enable" forState:UIControlStateNormal];
                        [button addTarget:self action:@selector(enableDisableButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                        
                    }
                
                } else if (self.mode == DOMAIN_MODE) {
                    UIImage *buttonEnableImage = [UIImage imageNamed:@"add.png"];
                    [button setBackgroundImage:buttonEnableImage forState:UIControlStateNormal];
                    button.frame = CGRectMake(0.0, 0.0, 29, 29);                    
                    [button addTarget:self action:@selector(addContentToGroupButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                }
                    
                deploymentCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                NSString *name = deploymentInfo[@"name"];
                NSString *runtime_name = deploymentInfo[@"runtime-name"];
                
                deploymentCell.textLabel.text = name;
                deploymentCell.detailTextLabel.text = ([name isEqualToString:runtime_name]?nil:runtime_name);

                cell = deploymentCell;
                break;                
            }
            
            case JBADeploymentTableAddSection:
            {
                ButtonCell *addCell = [ButtonCell cellForTableView:tableView];

                addCell.imageView.image = [UIImage imageNamed:@"add.png"];
                
                addCell.textLabel.font = [UIFont italicSystemFontOfSize:16];
                addCell.textLabel.textAlignment = NSTextAlignmentCenter;
                
                if (self.mode == DOMAIN_MODE)
                    addCell.textLabel.text = @"Add Content...";
                else
                    addCell.textLabel.text = @"Add Deployment...";                        

                cell = addCell;
                break;
            }
    }            
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    
    if (section == JBADeploymentTableAddSection)
        [self addContentButtonTapped];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    
    if (section == JBADeploymentTableAddSection)
        return NO;
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];

    NSString *deploymentName = _names[row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIActionSheet *yesno = [[UIActionSheet alloc]
                                initWithTitle:[NSString stringWithFormat:@"Are you sure you want to Remove \"%@\"", deploymentName]
                                completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                                    switch (buttonIndex) {
                                        case 0: // If YES button pressed, proceed...
                                        {
                                            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                                            
                                            [[JBAOperationsManager sharedManager]
                                             removeDeploymentWithName:deploymentName
                                             belongingToGroup:self.group
                                             withSuccess:^(void) {
                                                 [SVProgressHUD showSuccessWithStatus:@"Undeployed Successfully!"];
                                                 
                                                 [_deployments removeObjectForKey:deploymentName];
                                                 [_names removeObjectAtIndex:row];
                                                 
                                                 [tableView deleteRowsAtIndexPaths:@[indexPath] 
                                                                  withRowAnimation:UITableViewRowAnimationFade];
                                                 
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
                                            break;
                                    }
                                }
                                
                                cancelButtonTitle:@"No"
                                destructiveButtonTitle: @"Yes"
                                otherButtonTitles:nil];
        
        [yesno showInView:self.parentViewController.tabBarController.view];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Action Methods
- (void)enableDisableButtonTapped:(id)sender {
    UIButton *senderButton = (UIButton *)sender;
    
    UITableViewCell *buttonCell = (UITableViewCell *) [senderButton findParentViewWithClass:[UITableViewCell class]];
    
    NSUInteger buttonRow = [[self.tableView indexPathForCell:buttonCell] row];
    
    NSString *deploymentName = _names[buttonRow];
    NSMutableDictionary *deploymentInfo = _deployments[deploymentName];
    
    BOOL enable = [senderButton.currentTitle isEqualToString:@"Enable"];

    UIActionSheet *yesno = [[UIActionSheet alloc]
                          initWithTitle:[NSString stringWithFormat:@"Are you sure you want to %@ \"%@\"", (enable ? @"Enable ": @"Disable "), deploymentName]
                          completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                              switch (buttonIndex) {
                                  case 0: // If YES button pressed, proceed...
                                  {   
                                      [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                                      
                                      [[JBAOperationsManager sharedManager]
                                       changeDeploymentStatusForDeploymentWithName:deploymentName
                                       belongingToServerGroup:self.group
                                       enable:enable 
                                       withSuccess:^(void) {
                                           [SVProgressHUD showSuccessWithStatus:(enable ? @"Enabled Successfully!": @"Disabled Successfully!")];
                                           
                                           [deploymentInfo setValue:@(enable) forKey:@"enabled"];
                                           
                                           [self.tableView reloadData];
                                           
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
                                      break;
                                }
                          }
                          cancelButtonTitle:@"No"
                          destructiveButtonTitle: @"Yes"
                          otherButtonTitles:nil];
    
    [yesno showInView:self.parentViewController.tabBarController.view];
}

- (void)addContentButtonTapped {
    id controller;
    
    if (self.mode == STANDALONE_MODE || self.mode == DOMAIN_MODE) {
        JBAAddDeploymentViewController *addDeploymentController = [[JBAAddDeploymentViewController alloc] initWithStyle:UITableViewStylePlain];
        controller = addDeploymentController;
    } else if (self.mode == SERVER_MODE) {
        JBAAddServerGroupDeploymentViewController *addServerGroupDeploymentController = 
                                                [[JBAAddServerGroupDeploymentViewController alloc] initWithStyle:UITableViewStylePlain];
        addServerGroupDeploymentController.existingDeployments = [_deployments allKeys];
        addServerGroupDeploymentController.group = self.group;
        controller = addServerGroupDeploymentController;
    }

    UINavigationController *navigationController = [CommonUtil customizedNavigationController];
    [navigationController pushViewController:controller animated:NO];
    
    JBAAppDelegate *delegate = (JBAAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.navController presentViewController:navigationController animated:YES completion:nil];
}

- (void)addContentToGroupButtonTapped:(id)sender {
    UIButton *senderButton = (UIButton *)sender;
    
    UITableViewCell *buttonCell = (UITableViewCell *)[senderButton superview];
    NSUInteger buttonRow = [[self.tableView indexPathForCell:buttonCell] row];
    
    NSString *deploymentName = _names[buttonRow];
    NSMutableDictionary *deploymentInfo = _deployments[deploymentName];
    
    JBADomainServerGroupsViewController *groupsController = [[JBADomainServerGroupsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    groupsController.deploymentToAdd = deploymentInfo;
    groupsController.groupSelectionMode = YES;
    
    UINavigationController *navigationController = [CommonUtil customizedNavigationController];
    [navigationController pushViewController:groupsController animated:NO];
    
    JBAAppDelegate *delegate = (JBAAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.navController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Notification
- (void)deploymentAdded:(NSNotification *)notification {
    NSMutableDictionary *deploymentInfo = [notification object];
    
    _deployments[deploymentInfo[@"name"]] = deploymentInfo;
    [_names addObject:deploymentInfo[@"name"]];
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:[_deployments count]-1 inSection:JBADeploymentTableListSection];

    [self.tableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationBottom];
}

@end
