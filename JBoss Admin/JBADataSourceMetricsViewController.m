//
//  JBADataSourceMetricsViewController.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBADataSourceMetricsViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

#import "MetricInfoCell.h"
#import "SVProgressHUD.h"

// Table Sections
enum JBADataSourceTableSections {
    JBATableDataSourcePoolUsageSection = 0,
    JBATableDataSourcePreparedStatementPoolUsage,
    JBATableDataSourceNumSections
};

// Table Rows
enum JBADataSourcePoolUsageRows {
    JBADataSourceTableSecAvailableRow = 0,
    JBADataSourceTableSecActiveCountRow,
    JBADataSourceTableSecMaxUsedRow,
    JBADataSourceTableSecDataSourcePoolUsageNumRows
};

enum JBADataSourcePreparedStatementPoolUsageRows {
    JBADataSourceCurrentSizeRow = 0,
    JBADataSourceHitCountRow,
    JBADataSourceMissUsedRow,
    JBADataSourceTableSecDataSourcePreparedStatementPoolUsageNumRows
};

@implementation JBADataSourceMetricsViewController {
    NSDictionary *_metrics;
}

@synthesize dataSourceName = _dataSourceName;
@synthesize dataSourceType = _dataSourceType;

-(void)dealloc {
    DLog(@"JBADataSourceMetricsViewController dealloc");    
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    DLog(@"JBADataSourceMetricsViewController viewDidUnLoad");
    
    _metrics = nil;
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    DLog(@"JBADataSourceMetricsViewController viewDidLoad");
    
    self.title = self.dataSourceName;
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;

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
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    MetricInfoCell *cell = [MetricInfoCell cellForTableView:tableView];
    
    switch (section) {
        case JBATableDataSourcePoolUsageSection:
        {
            switch (row) {
                case JBADataSourceTableSecAvailableRow:
                    cell.metricNameLabel.text = @"Available";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"AvailableCount"] cellDisplay];
                    break;
                case JBADataSourceTableSecActiveCountRow:
                    cell.metricNameLabel.text= @"Active Count";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"ActiveCount"] cellDisplayPercentFromTotal:[_metrics objectForKey:@"AvailableCount"] withMBConversion:NO];
                    break;
                case JBADataSourceTableSecMaxUsedRow:
                    cell.metricNameLabel.text= @"Max Used";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"MaxUsedCount"] cellDisplayPercentFromTotal:[_metrics objectForKey:@"AvailableCount"] withMBConversion:NO];
                    break;
            }
            break;
        }
            
        case JBATableDataSourcePreparedStatementPoolUsage:
        {
            switch (row) {
                case JBADataSourceCurrentSizeRow:
                    cell.metricNameLabel.text = @"Current Size";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"PreparedStatementCacheCurrentSize"] cellDisplay];
                    break;
                case JBADataSourceHitCountRow:
                    cell.metricNameLabel.text = @"Hit Count";                    
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"PreparedStatementCacheHitCount"] cellDisplayPercentFromTotal:[_metrics objectForKey:@"PreparedStatementCacheCurrentSize"] withMBConversion:NO];
                    break;
                case JBADataSourceMissUsedRow:
                    cell.metricNameLabel.text = @"Miss Used";                    
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"PreparedStatementCacheMissCount"] cellDisplayPercentFromTotal:[_metrics objectForKey:@"PreparedStatementCacheCurrentSize"] withMBConversion:NO];
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
     fetchDataSourceMetricsForName:self.dataSourceName ofType:self.dataSourceType
     withSuccess:^(NSDictionary *metrics) {
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
