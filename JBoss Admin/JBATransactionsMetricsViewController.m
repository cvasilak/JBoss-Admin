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

#import "JBATransactionsMetricsViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "MetricInfoCell.h"
#import "SVProgressHUD.h"

// Table Sections
enum JBATranMetricsTableSections {
    JBATableMetricSuccessFailureSection = 0,
    JBATableMetricFailureOriginSection,
    JBATableMetricNumSections
};

// Table Rows
enum JBATranSuccessFailureRows {
    JBATranTableSecTotalRow = 0,
    JBATranTableSecCommitedRow,
    JBATranTableSecAbortedRow,
    JBATranTableSecTimedOutRow,
    JBATranTableSecSuccessFailureNumRows
};

enum JBATranFailureOriginRows {
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
- (void)viewDidUnload {
    DLog(@"JBATransactionsMetricsViewController viewDidUnLoad");
 
    _metrics = nil;

    [super viewDidUnload];
}

- (void)viewDidLoad {
    DLog(@"JBATransactionsMetricsViewController viewDidLoad");
    
    self.title = @"Transactions";
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
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
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    MetricInfoCell *cell = [MetricInfoCell cellForTableView:tableView];

    switch (section) {
        case JBATableMetricSuccessFailureSection:
        {
            switch (row) {
                case JBATranTableSecTotalRow:
                    cell.metricNameLabel.text = @"Total";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"number-of-transactions"] cellDisplay];
                    break;
                case JBATranTableSecCommitedRow:
                    cell.metricNameLabel.text = @"Commited";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"number-of-committed-transactions"] cellDisplayPercentFromTotal:[_metrics objectForKey:@"number-of-transactions"] withMBConversion:NO];
                    break;
                case JBATranTableSecAbortedRow:
                    cell.metricNameLabel.text = @"Aborted";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"number-of-aborted-transactions"] cellDisplayPercentFromTotal:[_metrics objectForKey:@"number-of-transactions"] withMBConversion:NO];
                    break;
                case JBATranTableSecTimedOutRow:
                    cell.metricNameLabel.text = @"Timed Out";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"number-of-timed-out-transactions"] cellDisplayPercentFromTotal:[_metrics objectForKey:@"number-of-transactions"] withMBConversion:NO];
                    break;
            }   
            break;
        }
            
        case JBATableMetricFailureOriginSection:
        {
            switch (row) {
                case JBATranTableSecApplicationsRow:
                    cell.metricNameLabel.text = @"Applications";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"number-of-application-rollbacks"] cellDisplay];
                    break;
                case JBATranTableSecResourcesRow:
                    cell.metricNameLabel.text = @"Resources";                    
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"number-of-resource-rollbacks"] cellDisplay];
                    break;
               }
            break;            
        }
    }
    
    return cell;
}

#pragma mark - Actions
- (void)refresh {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    
    [[JBAOperationsManager sharedManager]
     fetchTransactionMetricsWithSuccess:^(NSDictionary *metrics) {
         [SVProgressHUD dismiss];
         
         _metrics = metrics;
         
         // time to reload table
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
}

@end
