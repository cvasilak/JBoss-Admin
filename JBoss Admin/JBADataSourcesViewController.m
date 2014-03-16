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

#import "JBADataSourcesViewController.h"
#import "JBADataSourceMetricsViewController.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "DefaultCell.h"
#import "SVProgressHUD.h"

@interface JBADataSourcesViewController()<JBARefreshable>

@end

@implementation JBADataSourcesViewController {
    NSArray *_names;
    NSDictionary *_datasources;
}

-(void)dealloc {
    DLog(@"JBADataSourcesViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBADataSourcesViewController viewDidLoad");
    
    self.title = @"Data Sources";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [self refresh];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBADataSourcesViewController viewWillAppear");
    
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
    
    DefaultCell *cell = [DefaultCell cellForTableView:tableView];
    
    NSString *name = [_names objectAtIndex:row];
    cell.textLabel.text = name;
    
    if ([[_datasources objectForKey:name] objectForKey:@"xa-datasource-class"] != nil) {
        cell.imageView.image = [UIImage imageNamed:@"xa-ds.png"];
    } else {
        cell.imageView.image = nil;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
    
    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    NSString *name = [_names objectAtIndex:row];
    
    JBADataSourceMetricsViewController *dataSourceMetricsController = [[JBADataSourceMetricsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    dataSourceMetricsController.dataSourceName = name;
    
    if ([[_datasources objectForKey:name] objectForKey:@"xa-datasource-class"] != nil) {
        dataSourceMetricsController.dataSourceType = XADataSource;
    } else {
        dataSourceMetricsController.dataSourceType = StandardDataSource;
    }

    [self.navigationController pushViewController:dataSourceMetricsController animated:YES];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions
- (void)refresh {
    [[JBAOperationsManager sharedManager]
     fetchDataSourcesListWithSuccess:^(NSDictionary *datasources) {
         [SVProgressHUD dismiss];
         
         _names = [[datasources allKeys] sortedArrayUsingSelector:@selector(compare:)];
         _datasources = datasources;
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
