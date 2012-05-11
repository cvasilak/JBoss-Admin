//
//  JBAJVMMetricsViewController.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBAJVMMetricsViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "MetricInfoCell.h"
#import "SVProgressHUD.h"
#import "JBARefreshable.h"

//#import "F3PlotStrip.h"

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
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
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
        label.frame = CGRectMake(16, 10, 300, 10);
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
                    cell.metricValueLabel.text = [[heap objectForKey:@"committed"] cellDisplayMB];
                    break;
                case JBAJVMTableSecHeapUsageInitRow:
                    cell.metricNameLabel.text = @"Init";
                    cell.metricValueLabel.text = [[heap objectForKey:@"init"] cellDisplayMB];
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
                    cell.metricValueLabel.text = [[nonheap objectForKey:@"committed"] cellDisplayMB];
                    break;
                case JBAJVMTableSecHeapUsageInitRow:
                    cell.metricNameLabel.text = @"Init";                    
                    cell.metricValueLabel.text = [[nonheap objectForKey:@"init"] cellDisplayMB];
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
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    
    [[JBAOperationsManager sharedManager]
     fetchJavaVMMetricsWithSuccess:^(NSDictionary *metrics) {
         [SVProgressHUD dismiss];
         
         _metrics = metrics;
         
         // time to reload table
         [self.tableView reloadData];
         
         [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:JBATableMetricOSSection] withRowAnimation:UITableViewRowAnimationFade];
         
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
