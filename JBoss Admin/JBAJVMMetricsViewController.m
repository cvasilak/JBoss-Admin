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

#import "JBAJVMMetricsViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "MetricInfoCell.h"
#import "JBARefreshable.h"

#import "SVProgressHUD.h"

// Table Sections
typedef NS_ENUM(NSUInteger, JBAJVMMetricsTableSections) {
    JBATableMetricOSSection,
    JBATableMetricHeapUsageSection,
    JBATableMetricNoNHeapUsageSection,
    JBATableMetricThreadUsageSection,
    JBATableMetricNumSections
};

// Table Rows
enum JBAJVMHeapUsageRows {
    JBAJVMTableSecHeapUsageMaxRow,
    JBAJVMTableSecHeapUsageUsedRow,
    JBAJVMTableSecHeapUsageCommitedRow,
    JBAJVMTableSecHeapUsageInitRow,
    JBAJVMTableSecHeapUsageNumRows
};

typedef NS_ENUM(NSUInteger, JBAJVMNoNHeapUsageRows) {
    JBAJVMTableSecNoNHeapUsageMaxRow,
    JBAJVMTableSecNoNHeapUsageUsedRow,
    JBAJVMTableSecNoNHeapUsageCommitedRow,
    JBAJVMTableSecNoNHeapUsageInitRow,
    JBAJVMTableSecNoNHeapUsageNumRows
};

typedef NS_ENUM(NSUInteger, JBAJVMThreadUsageRows) {
    JBAJVMTableSecThreadUsageLiveRow,
    JBAJVMTableSecThreadUsageDaemonRow,
    JBAJVMTableSecThreadUsageNumRows
};

@interface JBAJVMMetricsViewController()<JBARefreshable>

@end

@implementation JBAJVMMetricsViewController {
    NSDictionary *_metrics;
}

-(void)dealloc {
    DLog(@"JBAJVMMetricsViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBAJVMMetricsViewController viewDidLoad");
    
    self.title = @"Java VM Metrics";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [self refresh];
    
    [super viewDidLoad];    
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBAJVMMetricsViewController viewWillAppear");
    
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
        case JBATableMetricOSSection:
        {
            if (_metrics == nil)
                return @"";
                
            NSMutableDictionary *os = _metrics[@"os"];
            return [NSString stringWithFormat:@"%@ %@ (Processors: %@)",
                    os[@"name"], os[@"version"], os[@"available-processors"]];
        }
        case JBATableMetricHeapUsageSection:
            return @"Heap Usage";
        case JBATableMetricNoNHeapUsageSection:
            return @"Non Heap Usage";
        case JBATableMetricThreadUsageSection:
            return @"Thread Usage";
        default:
            return nil;        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == JBATableMetricOSSection)
        return 12;

    return [tableView rowHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == JBATableMetricOSSection) {
        NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
        
        // Create label with section title
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(16, 10, 300, 12);
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize:14];
        label.text = sectionTitle;

        // Create header view and add label as a subview
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 320, 12)];
        [view addSubview:label];
        
        return view;
    }

	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case JBATableMetricOSSection:
            return 0;
        case JBATableMetricHeapUsageSection:
            return JBAJVMTableSecHeapUsageNumRows;
        case JBATableMetricNoNHeapUsageSection:
            return JBAJVMTableSecNoNHeapUsageNumRows;
        case JBATableMetricThreadUsageSection:
            return JBAJVMTableSecThreadUsageNumRows;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    MetricInfoCell *cell = [MetricInfoCell cellForTableView:tableView];
    
    switch (section) {
        case JBATableMetricHeapUsageSection:
        {
            NSMutableDictionary *heap = _metrics[@"memory"][@"heap-memory-usage"];
            
            switch (row) {
                case JBAJVMTableSecHeapUsageMaxRow:
                    cell.metricNameLabel.text = @"Max";
                    cell.metricValueLabel.text = [heap[@"max"] cellDisplayMB];
                    break;
                case JBAJVMTableSecHeapUsageUsedRow:
                    cell.metricNameLabel.text = @"Used";
                    cell.metricValueLabel.text = [heap[@"used"] cellDisplayPercentFromTotal:heap[@"max"] withMBConversion:YES];
                    break;
                case JBAJVMTableSecHeapUsageCommitedRow:
                    cell.metricNameLabel.text = @"Commited";
                    cell.metricValueLabel.text = [heap[@"committed"] cellDisplayPercentFromTotal:heap[@"max"] withMBConversion:YES];
                    break;
                case JBAJVMTableSecHeapUsageInitRow:
                    cell.metricNameLabel.text = @"Init";
                    cell.metricValueLabel.text = [heap[@"init"] cellDisplayPercentFromTotal:heap[@"max"] withMBConversion:YES];
                    break;
            }   
            break;
        }
            
        case JBATableMetricNoNHeapUsageSection:
        {
            NSMutableDictionary *nonheap = _metrics[@"memory"][@"non-heap-memory-usage"];
          
            switch (row) {
                case JBAJVMTableSecHeapUsageMaxRow:
                    cell.metricNameLabel.text = @"Max";
                    cell.metricValueLabel.text = [nonheap[@"max"] cellDisplayMB];
                    break;
                case JBAJVMTableSecHeapUsageUsedRow:
                    cell.metricNameLabel.text = @"Used";                    
                    cell.metricValueLabel.text = [nonheap[@"used"] cellDisplayPercentFromTotal:nonheap[@"max"] withMBConversion:YES];
                    break;
                case JBAJVMTableSecHeapUsageCommitedRow:
                    cell.metricNameLabel.text = @"Commited";                    
                    cell.metricValueLabel.text = [nonheap[@"committed"] cellDisplayPercentFromTotal:nonheap[@"max"] withMBConversion:YES];
                    break;
                case JBAJVMTableSecHeapUsageInitRow:
                    cell.metricNameLabel.text = @"Init";                    
                    cell.metricValueLabel.text = [nonheap[@"init"] cellDisplayPercentFromTotal:nonheap[@"max"] withMBConversion:YES];
                    break;
            }
            break;            
        }
        
        case JBATableMetricThreadUsageSection:
        {
            NSMutableDictionary *threading = _metrics[@"threading"];

            switch (row) {
                case JBAJVMTableSecThreadUsageLiveRow:
                    cell.metricNameLabel.text = @"Live";
                    cell.metricValueLabel.text = [threading[@"thread-count"] cellDisplay];
                    break;
                case JBAJVMTableSecThreadUsageDaemonRow:
                    cell.metricNameLabel.text = @"Daemon";                    
                    cell.metricValueLabel.text = [threading[@"daemon-thread-count"] cellDisplayPercentFromTotal:threading[@"thread-count"] withMBConversion:NO];
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
     fetchJavaVMMetricsWithSuccess:^(NSDictionary *metrics) {
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
