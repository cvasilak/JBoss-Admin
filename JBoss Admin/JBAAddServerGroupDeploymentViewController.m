/*
 * JBoss Admin
 * Copyright 2012, Christos Vasilakis, and individual contributors.
 * See the copyright.txt file in the distribution for a full
 * listing of individual contributors.
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
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
- (void)viewDidUnload {
    DLog(@"JBAAddServerGroupDeploymentViewController viewDidUnLoad");
    
    _names = nil;
    _deployments = nil;
    _lastIndexPath = nil;

    [super viewDidUnload];
}

- (void)viewDidLoad {
    DLog(@"JBAAddServerGroupDeploymentViewController viewDidLoad");
    
    self.title = @"Content Repository";

    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;

    UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(addToServerGroup)];
    
    self.navigationItem.rightBarButtonItem = nextButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO; // initially disable it cause nothing is checked
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    
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
    
    NSString *name = [_names objectAtIndex:row];
    cell.textLabel.text = name;
    
    NSUInteger oldRow = [_lastIndexPath row];
    cell.accessoryType = (row == oldRow && _lastIndexPath != nil) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int newRow = [indexPath row];
    int oldRow = (_lastIndexPath != nil) ? [_lastIndexPath row] : -1;
    
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
    NSString *deploymentName = [_names objectAtIndex:[_lastIndexPath row]];
    NSMutableDictionary *deploymentInfo = [_deployments objectForKey:deploymentName];

    UIActionSheet *yesno =
        [[UIActionSheet alloc]
            initWithTitle:@"Please choose deployment operation:"
            completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                if (buttonIndex == 0 /* Add to Group and Enable */ 
                ||  buttonIndex == 1 /* Add to Group */) {
                    
                    BOOL enable = (buttonIndex == 0? YES: NO);
                    [deploymentInfo setObject:[NSNumber numberWithBool:enable] forKey:@"enabled"];
                    
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
                    
                    [[JBAOperationsManager sharedManager]
                     addDeploymentContentWithHash:
                     [[[[deploymentInfo objectForKey:@"content"] objectAtIndex:0] objectForKey:@"hash"] objectForKey:@"BYTES_VALUE"]
                     andName:[deploymentInfo objectForKey:@"name"]
                     toServerGroups:[NSMutableArray arrayWithObject:self.group]
                     enable:enable
                     withSuccess:^(void) {
                         
                         [SVProgressHUD 
                          dismissWithSuccess:[NSString stringWithFormat:@"Successfully Added%@", (enable? @" and Enabled!":@"!")]];
                         
                         [self dismissModalViewControllerAnimated:YES];
                         
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
    [self dismissModalViewControllerAnimated:YES];
}

@end
