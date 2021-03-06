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

#import "JBARuntimeController.h"
#import "JBARootController.h"
#import "JBADeploymentsViewController.h"
#import "JBAJVMMetricsViewController.h"
#import "JBAJMSTypeSelectorViewController.h"
#import "JBADataSourcesViewController.h"
#import "JBATransactionsMetricsViewController.h"
#import "JBAWebConnectorTypeSelectorViewController.h"
#import "JBAConfigurationViewController.h"
#import "JBADomainHostsViewController.h"
#import "JBADomainServerGroupsViewController.h"

#import "JBAAppDelegate.h"

#import "CommonUtil.h"
#import "JBAOperationsManager.h"

#import "DefaultCell.h"
#import "ButtonCell.h"
#import "SVProgressHUD.h"

// Table Sections
typedef NS_ENUM(NSUInteger, JBARuntimeTableSections) {
    JBATableRuntimeServerSelectionSection,
    JBATableRuntimeServerStatusSection,
    JBATableRuntimeSubsystemMetricsSection,
    JBATableRuntimeDeploymentsSection,
    JBATableRuntimeMetricsNumSections
};

// Table Rows
typedef NS_ENUM(NSUInteger, JBARuntimeServerStatusRows) {
    JBARuntimeTableSecServerStatusConfigurationRow,
    JBARuntimeTableSecServerStatusJVMRow,
    JBARuntimeTableSecServerStatusNumRows
};

typedef NS_ENUM(NSUInteger, JBARuntimeSubsystemMetricsRows) {
    JBARuntimeTableSecSubsystemMetricsDataSourcesRow,
    JBARuntimeTableSecSubsystemMetricsJMSDestinationsRow,
    JBARuntimeTableSecSubsystemMetricsTransactionsRow,
    JBARuntimeTableSecSubsystemMetricsWebRow,
    JBARuntimeTableSecSubsystemMetricsNumRows
};

typedef NS_ENUM(NSUInteger, JBARuntimeDeploymentStandaloneRows) {
    JBARuntimeTableSecManageDeploymentsRow,
    JBARuntimeTableSecDeploymentStandaloneNumRows
};

typedef NS_ENUM(NSUInteger, JBARuntimeDeploymentDomainRows) {
    JBARuntimeTableSecDeploymentContentRow = 0,
    JBARuntimeTableSecDeploymentServerGroupRow,
    JBARuntimeTableSecDeploymentDomainNumRows
};

@interface JBARuntimeController()

- (void)chooseServer;

@end

@implementation JBARuntimeController

-(void)dealloc {
    DLog(@"JBARuntimeController dealloc");
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBARuntimeController viewDidLoad");
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered
                                                                        target:self action:@selector(logout)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverChanged:) name:@"ServerChangedNotification" object:nil];
    
    // NOTE: not needed here, the progress is already displayed by the JBAServersViewController
    //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    
    // First do a check to see if the server is a DOMAIN CONTROLLER
    // if so update UI accordingly (add menus "Deployment Content", "Server Groups")
    NSDictionary *params = 
        @{@"operation": @"read-children-resources",
         @"child-type": @"host"};
    
    [[JBAOperationsManager sharedManager]
     postJBossRequestWithParams:params
                             success:^(NSMutableDictionary *result) {
                                 [SVProgressHUD dismiss];

                                 NSArray *hosts = [[result allKeys] sortedArrayUsingSelector:@selector(compare:)];

                                 NSString *host;
                                 NSDictionary *serverInfo;
                                 
                                 for (NSUInteger i = 0; i < [hosts count]; i++) {
                                     host = hosts[i];
                                     
                                     NSMutableDictionary *serversType = result[host][@"server"];

                                     if (![serversType isKindOfClass:[NSNull class]]) { // found at least one host with active servers on it
                                         NSArray *servers = [[serversType allKeys] sortedArrayUsingSelector:@selector(compare:)];
                                     
                                        // default select first server in the list
                                        NSString *server = servers[0];
                                        serverInfo = @{@"host": host, @"server": server};
                                        break;
                                     }
                                 }
                                 
                                 if (serverInfo == nil) {
                                     serverInfo = @{@"host": host, @"server": @""};
                                     
                                     UIAlertView *oops = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                    message:@"No active servers found on any host! Please start a server!"
                                                                                   delegate:nil 
                                                                          cancelButtonTitle:@"Bummer"
                                                                          otherButtonTitles:nil];
                                     [oops show];
                                     

                                 }
                                 
                                 // let the UI do the update
                                 NSNotification *notification = [NSNotification notificationWithName:@"ServerChangedNotification" object:serverInfo];
                                 [[NSNotificationCenter defaultCenter] postNotification:notification];

                             } failure:^(NSError *error) {
                                 [SVProgressHUD dismiss];
                                 // we have successfully contacted the jboss server but 
                                 // it is run in STANDALONE mode and didn't respond 
                                 // to (child-type=host) operation  (we can live with that!)
                             }
     ];   

    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return JBATableRuntimeMetricsNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case JBATableRuntimeServerStatusSection:
            return @"Server Status";
        case JBATableRuntimeSubsystemMetricsSection:
            return @"Subsystem Metrics";
        case JBATableRuntimeDeploymentsSection:
            return @"Deployments";
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {  
        case JBATableRuntimeServerSelectionSection:
            return [[JBAOperationsManager sharedManager] isDomainController]? 1: 0;
        case JBATableRuntimeServerStatusSection:
            return JBARuntimeTableSecServerStatusNumRows;
        case JBATableRuntimeSubsystemMetricsSection:
            if ([[JBAOperationsManager sharedManager] managementVersion] < MANAGEMENT_VERSION_2)
                return JBARuntimeTableSecSubsystemMetricsNumRows;
            else
                return JBARuntimeTableSecSubsystemMetricsNumRows - 1;  // exclude "Web" (for now)
        case JBATableRuntimeDeploymentsSection:
            
            if ([[JBAOperationsManager sharedManager] isDomainController])
                return JBARuntimeTableSecDeploymentDomainNumRows;
            else 
                return JBARuntimeTableSecDeploymentStandaloneNumRows;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    id cell;
    
    if (section == JBATableRuntimeServerSelectionSection) {
        ButtonCell *serverCell = [ButtonCell cellForTableView:tableView];

        if (serverCell.accessoryView == nil) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0.0, 0.0, 28, 28);
            UIImage *buttonImage = [UIImage imageNamed:@"servers_selection.png"];
            [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
            [button addTarget:self action:@selector(chooseServer) forControlEvents:UIControlEventTouchUpInside];
            serverCell.accessoryView = button;

            serverCell.textLabel.font = [UIFont italicSystemFontOfSize:16];
            serverCell.textLabel.textAlignment = NSTextAlignmentCenter;
        }

        serverCell.textLabel.text = 
            [NSString stringWithFormat:@"%@:%@",
             [[JBAOperationsManager sharedManager] domainCurrentHost], 
             [[JBAOperationsManager sharedManager] domainCurrentServer]];
        
        cell = serverCell;
        
    } else {
        DefaultCell *runtimeCell = [DefaultCell cellForTableView:tableView];
        
        runtimeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        switch (section) {
            case JBATableRuntimeServerStatusSection:
                switch (row) {
                    case JBARuntimeTableSecServerStatusConfigurationRow:
                        runtimeCell.textLabel.text = @"Configuration";
                        break;
                    case JBARuntimeTableSecServerStatusJVMRow:
                        runtimeCell.textLabel.text = @"JVM";
                        break;
                }
                break;

            case JBATableRuntimeSubsystemMetricsSection:
                switch (row) {
                    case JBARuntimeTableSecSubsystemMetricsDataSourcesRow:
                        runtimeCell.textLabel.text = @"Data Sources";
                        break;
                    case JBARuntimeTableSecSubsystemMetricsJMSDestinationsRow:
                        runtimeCell.textLabel.text = @"JMS Destinations";
                        break;
                    case JBARuntimeTableSecSubsystemMetricsTransactionsRow:
                        runtimeCell.textLabel.text = @"Transactions";
                        break;
                    case JBARuntimeTableSecSubsystemMetricsWebRow:
                        runtimeCell.textLabel.text = @"Web";
                        break;
                }
                break;            

            case JBATableRuntimeDeploymentsSection:
                if ([[JBAOperationsManager sharedManager] isDomainController]) { // DOMAIN Server
                    switch (row) {
                        case JBARuntimeTableSecDeploymentContentRow:
                            runtimeCell.textLabel.text = @"Deployment Content";
                            break;
                        case JBARuntimeTableSecDeploymentServerGroupRow:
                            runtimeCell.textLabel.text = @"Server Groups";
                            break;
                    }
                    break;
                } else { // STANDALONE Server
                    switch (row) {
                        case JBARuntimeTableSecManageDeploymentsRow:
                            runtimeCell.textLabel.text = @"Manage Deployments";
                            break;
                    }
                    break;
                }
        }
        
        cell = runtimeCell;
    }

    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    switch (section) {
        case JBATableRuntimeServerSelectionSection:
            [self chooseServer];
            break;
        case JBATableRuntimeServerStatusSection:
            switch (row) {
                case JBARuntimeTableSecServerStatusConfigurationRow:
                {
                    JBAConfigurationViewController *confController = [[JBAConfigurationViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    
                    [self.navigationController pushViewController:confController animated:YES];

                    break;
                }
                case JBARuntimeTableSecServerStatusJVMRow: 
                {
                    JBAJVMMetricsViewController *jvmMetricsController = [[JBAJVMMetricsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    
                    [self.navigationController pushViewController:jvmMetricsController animated:YES];

                    break;
                }
            }
            break;
 
        case JBATableRuntimeSubsystemMetricsSection:
            switch (row) {
                case JBARuntimeTableSecSubsystemMetricsDataSourcesRow:
                {
                    JBADataSourcesViewController *dataSourcesController = [[JBADataSourcesViewController alloc] initWithStyle:UITableViewStylePlain];
                    
                    [self.navigationController pushViewController:dataSourcesController animated:YES];
                    
                    break;
                }
                case JBARuntimeTableSecSubsystemMetricsJMSDestinationsRow:
                {
                    JBAJMSTypeSelectorViewController *jmsTypesController = [[JBAJMSTypeSelectorViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    
                    [self.navigationController pushViewController:jmsTypesController animated:YES];

                    break;
                }
                case JBARuntimeTableSecSubsystemMetricsTransactionsRow:
                {
                    JBATransactionsMetricsViewController *tranMetricsController = [[JBATransactionsMetricsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    
                    [self.navigationController pushViewController:tranMetricsController animated:YES];
                    
                    break;
                }
                case JBARuntimeTableSecSubsystemMetricsWebRow:
                {
                    JBAWebConnectorTypeSelectorViewController *webConTypesController = [[JBAWebConnectorTypeSelectorViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    
                    [self.navigationController pushViewController:webConTypesController animated:YES];
                    
                    break;
                }
            }
            break;
 
        case JBATableRuntimeDeploymentsSection:
            if ([[JBAOperationsManager sharedManager] isDomainController]) { // DOMAIN server
                switch (row) {
                    case JBARuntimeTableSecDeploymentContentRow:
                    {
                        JBADeploymentsViewController *deploymentsController = [[JBADeploymentsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                        deploymentsController.mode = DOMAIN_MODE;
                        
                        [self.navigationController pushViewController:deploymentsController animated:YES];
                        break;
                    }
                    case JBARuntimeTableSecDeploymentServerGroupRow:
                    {
                        JBADomainServerGroupsViewController *domainsController = [[JBADomainServerGroupsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                        
                        [self.navigationController pushViewController:domainsController animated:YES];
                        
                        break;
                    }                        
                }
                break;
            } else { // STANDALONE server
                switch (row) {
                    case JBARuntimeTableSecDeploymentContentRow:
                    {
                        JBADeploymentsViewController *deploymentsController = [[JBADeploymentsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                        deploymentsController.mode = STANDALONE_MODE;
                        
                        [self.navigationController pushViewController:deploymentsController animated:YES];
                        break;
                    }
                }                
            }
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Action Methods
-(void)logout {
    JBAAppDelegate *delegate = (JBAAppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromLeft;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationTransition: trans forView: [self.view window] cache: NO];
    
    self.navigationController.navigationBarHidden = YES;
    delegate.navController.navigationBarHidden = NO;;
    [delegate.navController popViewControllerAnimated:NO];
    [UIView commitAnimations];
}

- (void)chooseServer {
    JBADomainHostsViewController *hostViewController = [[JBADomainHostsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    UINavigationController *navigationController = [CommonUtil customizedNavigationController];
    [navigationController pushViewController:hostViewController animated:NO];

    JBAAppDelegate *delegate = (JBAAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.navController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Notification Listeners
- (void)serverChanged:(NSNotification *)notification {
    NSDictionary *server = [notification object];
    
    [[JBAOperationsManager sharedManager] changeDomainServer:server[@"server"] belongingToHost:server[@"host"]];
    
    // to fill the host/server on JBATableRuntimeServerSelectionSection
    [self.tableView reloadData];
    
    // highlight animation to inform user
    NSIndexPath *hostServerRow = [NSIndexPath indexPathForRow:0 inSection:JBATableRuntimeServerSelectionSection];
    [self.tableView selectRowAtIndexPath:hostServerRow animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self.tableView deselectRowAtIndexPath:hostServerRow animated:YES];
}

@end
