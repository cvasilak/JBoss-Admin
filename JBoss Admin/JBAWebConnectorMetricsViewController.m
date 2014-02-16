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

#import "JBAWebConnectorMetricsViewController.h"
#import "JBossValue.h"
#import "MetricInfoCell.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "SVProgressHUD.h"

// Table Sections
typedef NS_ENUM(NSUInteger, JBAWebConMetricsTableSections) {
    JBATableMetricGeneralSection,
    JBATableMetricRequestPerConnectorSection,
    JBATableMetricNumSections
};

// Table Rows
typedef NS_ENUM(NSUInteger, JBAWebConGeneralRows) {
    JBAWebConTableSecProtocolRow,
    JBAWebConTableSecBytesSentRow,
    JBAWebConTableSecBytesReceivedRow,
    JBAWebConTableSecGeneralNumRows
};

typedef NS_ENUM(NSUInteger, JBAWebConRequestPerConnectorRows) {
    JBAWebConTableSecRequestCountRow,
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

- (void)viewDidLoad {
    DLog(@"JBAWebConnectorMetricsViewController viewDidLoad");
    
    self.title = self.connectorName;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
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
    cell.maxNameWidth = ([@"Processing Time (ms)" sizeWithFont:cell.metricNameLabel.font]).width;
    return cell;
}


#pragma mark - Actions
- (void)refresh {
    [[JBAOperationsManager sharedManager]
     fetchWebConnectorMetricsForName:self.connectorName
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
