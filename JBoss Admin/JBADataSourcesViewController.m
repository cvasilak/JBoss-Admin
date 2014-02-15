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

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
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
