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

#import "JBADataSourceMetricsViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "MetricInfoCell.h"
#import "SVProgressHUD.h"

// Table Sections
typedef NS_ENUM(NSUInteger, JBADataSourceTableSections) {
    JBATableDataSourcePoolUsageSection,
    JBATableDataSourcePreparedStatementPoolUsage,
    JBATableDataSourceNumSections
};

// Table Rows
typedef NS_ENUM(NSUInteger, JBADataSourcePoolUsageRows) {
    JBADataSourceTableSecAvailableRow,
    JBADataSourceTableSecActiveCountRow,
    JBADataSourceTableSecMaxUsedRow,
    JBADataSourceTableSecDataSourcePoolUsageNumRows
};

typedef NS_ENUM(NSUInteger, JBADataSourcePreparedStatementPoolUsageRows) {
    JBADataSourceCurrentSizeRow,
    JBADataSourceHitCountRow,
    JBADataSourceMissUsedRow,
    JBADataSourceTableSecDataSourcePreparedStatementPoolUsageNumRows
};

@interface JBADataSourceMetricsViewController()<JBARefreshable>

@end

@implementation JBADataSourceMetricsViewController {
    NSDictionary *_metrics;
}

@synthesize dataSourceName = _dataSourceName;
@synthesize dataSourceType = _dataSourceType;

-(void)dealloc {
    DLog(@"JBADataSourceMetricsViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBADataSourceMetricsViewController viewDidLoad");
    
    self.title = self.dataSourceName;

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [self refresh];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBADataSourceMetricsViewController viewWillAppear");
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return JBATableDataSourceNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case JBATableDataSourcePoolUsageSection:
            return @"Pool Usage";
        case JBATableDataSourcePreparedStatementPoolUsage:
            return @"Prepared Statement Pool Usage";
        default:
            return nil;        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case JBATableDataSourcePoolUsageSection:
            return JBADataSourceTableSecDataSourcePoolUsageNumRows;
        case JBATableDataSourcePreparedStatementPoolUsage:
            return JBADataSourceTableSecDataSourcePreparedStatementPoolUsageNumRows;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    MetricInfoCell *cell = [MetricInfoCell cellForTableView:tableView];
    
    switch (section) {
        case JBATableDataSourcePoolUsageSection:
        {
            switch (row) {
                case JBADataSourceTableSecAvailableRow:
                    cell.metricNameLabel.text = @"Available";
                    cell.metricValueLabel.text = [_metrics[@"AvailableCount"] cellDisplay];
                    break;
                case JBADataSourceTableSecActiveCountRow:
                    cell.metricNameLabel.text= @"Active Count";
                    cell.metricValueLabel.text = [_metrics[@"ActiveCount"] cellDisplayPercentFromTotal:_metrics[@"AvailableCount"] withMBConversion:NO];
                    break;
                case JBADataSourceTableSecMaxUsedRow:
                    cell.metricNameLabel.text= @"Max Used";
                    cell.metricValueLabel.text = [_metrics[@"MaxUsedCount"] cellDisplayPercentFromTotal:_metrics[@"AvailableCount"] withMBConversion:NO];
                    break;
            }
            break;
        }
            
        case JBATableDataSourcePreparedStatementPoolUsage:
        {
            switch (row) {
                case JBADataSourceCurrentSizeRow:
                    cell.metricNameLabel.text = @"Current Size";
                    cell.metricValueLabel.text = [_metrics[@"PreparedStatementCacheCurrentSize"] cellDisplay];
                    break;
                case JBADataSourceHitCountRow:
                    cell.metricNameLabel.text = @"Hit Count";                    
                    cell.metricValueLabel.text = [_metrics[@"PreparedStatementCacheHitCount"] cellDisplayPercentFromTotal:_metrics[@"PreparedStatementCacheCurrentSize"] withMBConversion:NO];
                    break;
                case JBADataSourceMissUsedRow:
                    cell.metricNameLabel.text = @"Miss Used";                    
                    cell.metricValueLabel.text = [_metrics[@"PreparedStatementCacheMissCount"] cellDisplayPercentFromTotal:_metrics[@"PreparedStatementCacheCurrentSize"] withMBConversion:NO];
                    break;
            }
            break;            
        }
            
    }
    
    return cell;
}

#pragma mark - Actions
- (void)refresh {
    [[JBAOperationsManager sharedManager]
     fetchDataSourceMetricsForName:self.dataSourceName ofType:self.dataSourceType
     withSuccess:^(NSDictionary *metrics) {
         [SVProgressHUD dismiss];

         _metrics = metrics;
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
