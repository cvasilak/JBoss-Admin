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

#import "JBAJVMMetricsViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "MetricInfoCell.h"
#import "JBARefreshable.h"

#import "SVProgressHUD.h"

// Table Sections
enum JBAJVMMetricsTableSections {
    JBATableMetricOSSection = 0,
    JBATableMetricHeapUsageSection,
    JBATableMetricNoNHeapUsageSection,
    JBATableMetricThreadUsageSection,
    JBATableMetricNumSections
};

// Table Rows
enum JBAJVMHeapUsageRows {
    JBAJVMTableSecHeapUsageMaxRow = 0,
    JBAJVMTableSecHeapUsageUsedRow,
    JBAJVMTableSecHeapUsageCommitedRow,
    JBAJVMTableSecHeapUsageInitRow,
    JBAJVMTableSecHeapUsageNumRows
};

enum JBAJVMNoNHeapUsageRows {
    JBAJVMTableSecNoNHeapUsageMaxRow = 0,
    JBAJVMTableSecNoNHeapUsageUsedRow,
    JBAJVMTableSecNoNHeapUsageCommitedRow,
    JBAJVMTableSecNoNHeapUsageInitRow,
    JBAJVMTableSecNoNHeapUsageNumRows
};

enum JBAJVMThreadUsageRows {
    JBAJVMTableSecThreadUsageLiveRow = 0,
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
- (void)viewDidUnload {
    DLog(@"JBAJVMMetricsViewController viewDidUnLoad");
 
    _metrics = nil;

    [super viewDidUnload];
}

- (void)viewDidLoad {
    DLog(@"JBAJVMMetricsViewController viewDidLoad");
    
    self.title = @"Java VM Metrics";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
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
                
            NSMutableDictionary *os = [_metrics objectForKey:@"os"];
            return [NSString stringWithFormat:@"%@ %@ (Processors: %@)",
                    [os objectForKey:@"name"], [os objectForKey:@"version"], [os objectForKey:@"available-processors"]];
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
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    MetricInfoCell *cell = [MetricInfoCell cellForTableView:tableView];
    
    switch (section) {
        case JBATableMetricHeapUsageSection:
        {
            NSMutableDictionary *heap = [[_metrics objectForKey:@"memory"] objectForKey:@"heap-memory-usage"];
            
            switch (row) {
                case JBAJVMTableSecHeapUsageMaxRow:
                    cell.metricNameLabel.text = @"Max";
                    cell.metricValueLabel.text = [[heap objectForKey:@"max"] cellDisplayMB];
                    break;
                case JBAJVMTableSecHeapUsageUsedRow:
                    cell.metricNameLabel.text = @"Used";
                    cell.metricValueLabel.text = [[heap objectForKey:@"used"] cellDisplayPercentFromTotal:[heap objectForKey:@"max"] withMBConversion:YES];
                    break;
                case JBAJVMTableSecHeapUsageCommitedRow:
                    cell.metricNameLabel.text = @"Commited";
                    cell.metricValueLabel.text = [[heap objectForKey:@"committed"] cellDisplayPercentFromTotal:[heap objectForKey:@"max"] withMBConversion:YES];
                    break;
                case JBAJVMTableSecHeapUsageInitRow:
                    cell.metricNameLabel.text = @"Init";
                    cell.metricValueLabel.text = [[heap objectForKey:@"init"] cellDisplayPercentFromTotal:[heap objectForKey:@"max"] withMBConversion:YES];
                    break;
            }   
            break;
        }
            
        case JBATableMetricNoNHeapUsageSection:
        {
            NSMutableDictionary *nonheap = [[_metrics objectForKey:@"memory"] objectForKey:@"non-heap-memory-usage"];
          
            switch (row) {
                case JBAJVMTableSecHeapUsageMaxRow:
                    cell.metricNameLabel.text = @"Max";
                    cell.metricValueLabel.text = [[nonheap objectForKey:@"max"] cellDisplayMB];
                    break;
                case JBAJVMTableSecHeapUsageUsedRow:
                    cell.metricNameLabel.text = @"Used";                    
                    cell.metricValueLabel.text = [[nonheap objectForKey:@"used"] cellDisplayPercentFromTotal:[nonheap objectForKey:@"max"] withMBConversion:YES];
                    break;
                case JBAJVMTableSecHeapUsageCommitedRow:
                    cell.metricNameLabel.text = @"Commited";                    
                    cell.metricValueLabel.text = [[nonheap objectForKey:@"committed"] cellDisplayPercentFromTotal:[nonheap objectForKey:@"max"] withMBConversion:YES];
                    break;
                case JBAJVMTableSecHeapUsageInitRow:
                    cell.metricNameLabel.text = @"Init";                    
                    cell.metricValueLabel.text = [[nonheap objectForKey:@"init"] cellDisplayPercentFromTotal:[nonheap objectForKey:@"max"] withMBConversion:YES];
                    break;
            }
            break;            
        }
        
        case JBATableMetricThreadUsageSection:
        {
            NSMutableDictionary *threading = [_metrics objectForKey:@"threading"];

            switch (row) {
                case JBAJVMTableSecThreadUsageLiveRow:
                    cell.metricNameLabel.text = @"Live";
                    cell.metricValueLabel.text = [[threading objectForKey:@"thread-count"] cellDisplay];
                    break;
                case JBAJVMTableSecThreadUsageDaemonRow:
                    cell.metricNameLabel.text = @"Daemon";                    
                    cell.metricValueLabel.text = [[threading objectForKey:@"daemon-thread-count"] cellDisplayPercentFromTotal:[threading objectForKey:@"thread-count"] withMBConversion:NO];
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
