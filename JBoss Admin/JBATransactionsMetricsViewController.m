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

#import "JBATransactionsMetricsViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "MetricInfoCell.h"
#import "SVProgressHUD.h"

// Table Sections
typedef NS_ENUM(NSUInteger, JBATranMetricsTableSections) {
    JBATableMetricSuccessFailureSection,
    JBATableMetricFailureOriginSection,
    JBATableMetricNumSections
};

// Table Rows
typedef NS_ENUM(NSUInteger, JBATranSuccessFailureRows) {
    JBATranTableSecTotalRow = 0,
    JBATranTableSecCommitedRow,
    JBATranTableSecAbortedRow,
    JBATranTableSecTimedOutRow,
    JBATranTableSecSuccessFailureNumRows
};

typedef NS_ENUM(NSUInteger, JBATranFailureOriginRows) {
    JBATranTableSecApplicationsRow,
    JBATranTableSecResourcesRow,
    JBATranTableSecFailureOriginNumRows
};

@interface JBATransactionsMetricsViewController()<JBARefreshable>

@end

@implementation JBATransactionsMetricsViewController {
    NSDictionary *_metrics;
}

-(void)dealloc {
    DLog(@"JBATransactionsMetricsViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBATransactionsMetricsViewController viewDidLoad");
    
    self.title = @"Transactions";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [self refresh];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBATransactionsMetricsViewController viewWillAppear");
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return JBATableMetricNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case JBATableMetricSuccessFailureSection:
            return @"Success/Failure Ratio";
        case JBATableMetricFailureOriginSection:
            return @"Failure Origin";
        default:
            return nil;        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case JBATableMetricSuccessFailureSection:
            return JBATranTableSecSuccessFailureNumRows;
        case JBATableMetricFailureOriginSection:
            return JBATranTableSecFailureOriginNumRows;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    MetricInfoCell *cell = [MetricInfoCell cellForTableView:tableView];

    switch (section) {
        case JBATableMetricSuccessFailureSection:
        {
            switch (row) {
                case JBATranTableSecTotalRow:
                    cell.metricNameLabel.text = @"Total";
                    cell.metricValueLabel.text = [_metrics[@"number-of-transactions"] cellDisplay];
                    break;
                case JBATranTableSecCommitedRow:
                    cell.metricNameLabel.text = @"Commited";
                    cell.metricValueLabel.text = [_metrics[@"number-of-committed-transactions"] cellDisplayPercentFromTotal:_metrics[@"number-of-transactions"] withMBConversion:NO];
                    break;
                case JBATranTableSecAbortedRow:
                    cell.metricNameLabel.text = @"Aborted";
                    cell.metricValueLabel.text = [_metrics[@"number-of-aborted-transactions"] cellDisplayPercentFromTotal:_metrics[@"number-of-transactions"] withMBConversion:NO];
                    break;
                case JBATranTableSecTimedOutRow:
                    cell.metricNameLabel.text = @"Timed Out";
                    cell.metricValueLabel.text = [_metrics[@"number-of-timed-out-transactions"] cellDisplayPercentFromTotal:_metrics[@"number-of-transactions"] withMBConversion:NO];
                    break;
            }   
            break;
        }
            
        case JBATableMetricFailureOriginSection:
        {
            switch (row) {
                case JBATranTableSecApplicationsRow:
                    cell.metricNameLabel.text = @"Applications";
                    cell.metricValueLabel.text = [_metrics[@"number-of-application-rollbacks"] cellDisplay];
                    break;
                case JBATranTableSecResourcesRow:
                    cell.metricNameLabel.text = @"Resources";                    
                    cell.metricValueLabel.text = [_metrics[@"number-of-resource-rollbacks"] cellDisplay];
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
     fetchTransactionMetricsWithSuccess:^(NSDictionary *metrics) {
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
