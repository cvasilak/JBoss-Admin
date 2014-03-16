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

#import "JBADomainServersViewController.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "SubtitleCell.h"
#import "SVProgressHUD.h"
#import "UIActionSheet+BlockExtensions.h"

@interface JBADomainServersViewController()<JBARefreshable>

@end

@implementation JBADomainServersViewController {
    NSArray *_names;
    NSDictionary *_servers;    
}

@synthesize belongingHost = _belongingHost;

-(void)dealloc {
    DLog(@"JBADomainServersViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBADomainServersViewController viewDidLoad");
    
    self.title = @"Select Server";

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [self refresh];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBADomainServersViewController viewWillAppear");
    
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

    UIButton *button;

    if (cell.accessoryView == nil) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0.0, 0.0, 70, 27);
        button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        cell.accessoryView = button;
    } else {
        button = (UIButton *)cell.accessoryView;
    }
    
    NSString *serverName = _names[row];
    NSMutableDictionary *serverInfo = _servers[serverName];
    
    if ([serverInfo[@"status"] isEqualToString:@"STARTED"]) {
        cell.imageView.image = [UIImage imageNamed:@"up.png"];
        
        UIImage *buttonDisableImage = [UIImage imageNamed:@"disable.png"];
        [button setBackgroundImage:buttonDisableImage forState:UIControlStateNormal];
        [button setTitle:@"Stop" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(enableDisableButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
    } else if (  [serverInfo[@"status"] isEqualToString:@"DISABLED"]
              || [serverInfo[@"status"] isEqualToString:@"STOPPED"]
              || [serverInfo[@"status"] isEqualToString:@"FAILED"] ) {
        cell.imageView.image = [UIImage imageNamed:@"down.png"];   
        
        UIImage *buttonEnableImage = [UIImage imageNamed:@"enable.png"];
        [button setBackgroundImage:buttonEnableImage forState:UIControlStateNormal];
        [button setTitle:@"Start" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(enableDisableButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;        
    } else if (  [serverInfo[@"status"] isEqualToString:@"STARTING"]
              || [serverInfo[@"status"] isEqualToString:@"STOPPING"]) {
        cell.imageView.image = [UIImage imageNamed:@"down.png"];   
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;        
    }

    cell.textLabel.text = serverName;
    cell.detailTextLabel.text = serverInfo[@"group"];
    
    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     NSUInteger row = [indexPath row];

    NSString *serverName = _names[row];
    NSMutableDictionary *serverInfo = _servers[serverName];
    
    // TODO: better handling for this status
    if ( [serverInfo[@"status"] isEqualToString:@"DISABLED"]
        ||[serverInfo[@"status"] isEqualToString:@"STOPPED"]
        ||[serverInfo[@"status"] isEqualToString:@"STARTING"]
        ||[serverInfo[@"status"] isEqualToString:@"STOPPING"])
        return;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *server = @{@"host": self.belongingHost, @"server": serverName};
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // ok inform runtime for server changed
    NSNotification *notification = [NSNotification notificationWithName:@"ServerChangedNotification" object:server];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - Action Methods
- (void)refresh {
    [[JBAOperationsManager sharedManager]
     fetchServersInfoForHostWithName:self.belongingHost
     withSuccess:^(NSDictionary *servers) {
         [SVProgressHUD dismiss];
         
         _servers = servers;
         _names = [[_servers allKeys] sortedArrayUsingSelector:@selector(compare:)];
         [self.tableView reloadData];
         
         [self.refreshControl endRefreshing];
         
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

- (void)enableDisableButtonTapped:(id)sender {
    UIButton *senderButton = (UIButton *)sender;
    
    UITableViewCell *buttonCell = (UITableViewCell *)[senderButton superview];
    NSUInteger buttonRow = [[self.tableView indexPathForCell:buttonCell] row];
    
    BOOL start = [senderButton.currentTitle isEqualToString:@"Start"];
    
    NSString *serverName = _names[buttonRow];
    NSMutableDictionary *serverInfo = _servers[serverName];    
    
    UIActionSheet *yesno = [[UIActionSheet alloc]
                            initWithTitle:[NSString stringWithFormat:@"Are you sure you want to %@ \"%@\"", (start ? @"Start ": @"Stop "), serverName]
                            completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                                switch (buttonIndex) {
                                    case 0: // If YES button pressed, proceed...
                                    {   
                                        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                                        
                                        [[JBAOperationsManager sharedManager]
                                         changeStatusForServerWithName:serverName
                                         belongingToHost:self.belongingHost
                                         toStatus:start 
                                         withSuccess:^(NSString *result) {
                                             
                                             BOOL anErrorHasOccured = false;
                                             
                                             if (start && ![result isEqualToString:@"STARTED"]) {
                                                 [SVProgressHUD showSuccessWithStatus:@"Server failed to start!"];
                                                 anErrorHasOccured = YES;
                                             }
                                             
                                             if (!start && ![result isEqualToString:@"STOPPED"]) {
                                                 [SVProgressHUD showErrorWithStatus:@"Server failed to stop!"];
                                                 anErrorHasOccured = YES;                                                
                                             }
                                             
                                             if (!anErrorHasOccured)
                                                 [SVProgressHUD showSuccessWithStatus:(start ? @"Started Successfully!": @"Stopped Successfully!")];
                                             
                                             // if we are here the operation was success
                                             [serverInfo setValue:result forKey:@"status"];
                                             
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
    
    [yesno showInView:self.view];    
}
@end
