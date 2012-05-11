//
//  JBAWebConnectorMetricsViewController.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBAWebConnectorMetricsViewController.h"
#import "JBossValue.h"
#import "MetricInfoCell.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "SVProgressHUD.h"

// Table Sections
enum JBAWebConMetricsTableSections {
    JBATableMetricGeneralSection = 0,
    JBATableMetricRequestPerConnectorSection,
    JBATableMetricNumSections
};

// Table Rows
enum JBAWebConGeneralRows {
    JBAWebConTableSecProtocolRow = 0,
    JBAWebConTableSecBytesSentRow,
    JBAWebConTableSecBytesReceivedRow,
    JBAWebConTableSecGeneralNumRows
};

enum JBAWebConRequestPerConnectorRows {
    JBAWebConTableSecRequestCountRow = 0,
    JBAWebConTableSecErrorCountRow,
    JBAWebConTableSecProcessingTimeRow,
    JBAWebConTableSecMaxTimeRow,
    JBAWebConTableSecRequestPerConnectorNumRows
};

@interface JBAWebConnectorMetricsViewController()<JBARefreshable>

@end

@implementation JBAWebConnectorMetricsViewController {
    NSDictionary *_metrics;
}

@synthesize connectorName = _connectorName;

-(void)dealloc {
    DLog(@"JBAWebConnectorMetricsViewController dealloc");    
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    DLog(@"JBAWebConnectorMetricsViewController viewDidUnLoad");
 
    _metrics = nil;

    [super viewDidUnload];
}

- (void)viewDidLoad {
    DLog(@"JBAWebConnectorMetricsViewController viewDidLoad");
    
    self.title = self.connectorName;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;

    [self refresh];
    
    [super viewDidLoad];    
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBAWebConnectorMetricsViewController viewWillAppear");
    
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
        case JBATableMetricGeneralSection:
            return @"General";
        case JBATableMetricRequestPerConnectorSection:
            return @"Request per Connector";
        default:
            return nil;        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case JBATableMetricGeneralSection:
            return JBAWebConTableSecGeneralNumRows;
        case JBATableMetricRequestPerConnectorSection:
            return JBAWebConTableSecRequestPerConnectorNumRows;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    MetricInfoCell *cell = [MetricInfoCell cellForTableView:tableView];

    switch (section) {
        case JBATableMetricGeneralSection:
        {
            switch (row) {
                case JBAWebConTableSecProtocolRow:
                    cell.metricNameLabel.text = @"Protocol";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"protocol"] cellDisplay];
                    break;
                case JBAWebConTableSecBytesSentRow:
                    cell.metricNameLabel.text = @"Bytes Sent";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"bytesSent"] cellDisplay];
                    break;
                case JBAWebConTableSecBytesReceivedRow:
                    cell.metricNameLabel.text = @"Bytes Received";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"bytesReceived"] cellDisplay];
                    break;
            }
            break;
        }


        case JBATableMetricRequestPerConnectorSection:
        {
            switch (row) {
                case JBAWebConTableSecRequestCountRow:
                    cell.metricNameLabel.text = @"Request Count";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"requestCount"] cellDisplay];
                    break;
                case JBAWebConTableSecErrorCountRow:
                    cell.metricNameLabel.text = @"Error Count";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"errorCount"] cellDisplayPercentFromTotal:[_metrics objectForKey:@"requestCount"] withMBConversion:NO];
                    break;
                case JBAWebConTableSecProcessingTimeRow:
                    cell.metricNameLabel.text = @"Processing Time (ms)";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"processingTime"] cellDisplay];
                    break;
                case JBAWebConTableSecMaxTimeRow:
                    cell.metricNameLabel.text = @"Max Time (ms)";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"maxTime"] cellDisplay];
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
     fetchWebConnectorMetricsForName:self.connectorName
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
