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

#import "JBADomainHostsViewController.h"
#import "JBADomainServersViewController.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "DefaultCell.h"
#import "SVProgressHUD.h"

@interface JBADomainHostsViewController()<JBARefreshable>

@end

@implementation JBADomainHostsViewController {
    NSArray *_hosts;
}

-(void)dealloc {
    DLog(@"JBADomainHostsViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBADomainHostsViewController viewDidLoad");

    self.title = @"Select Host";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    [self refresh];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBADomainHostsViewController viewWillAppear");
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_hosts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    DefaultCell *cell = [DefaultCell cellForTableView:tableView];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text= [_hosts objectAtIndex:row];
    
    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    NSString *host = [_hosts objectAtIndex:row];
    
    JBADomainServersViewController *serversController = [[JBADomainServersViewController alloc] initWithStyle:UITableViewStylePlain];
    serversController.belongingHost = host;
         
    [self.navigationController pushViewController:serversController animated:YES];
         
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Action Methods
- (void)refresh {
    [[JBAOperationsManager sharedManager]
     fetchDomainHostInfoWithSuccess:^(NSArray *hosts) {
         [SVProgressHUD dismiss];
         
         _hosts = [hosts sortedArrayUsingSelector:@selector(compare:)];
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

@end
