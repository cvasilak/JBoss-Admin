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
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
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
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    MetricInfoCell *cell = [MetricInfoCell cellForTableView:tableView];

    switch (section) {
        case JBATableMetricGeneralSection:
        {
            switch (row) {
                case JBAWebConTableSecProtocolRow:
                    cell.metricNameLabel.text = @"Protocol";
                    cell.metricValueLabel.text = [_metrics[@"protocol"] cellDisplay];
                    break;
                case JBAWebConTableSecBytesSentRow:
                    cell.metricNameLabel.text = @"Bytes Sent";
                    cell.metricValueLabel.text = [_metrics[@"bytesSent"] cellDisplay];
                    break;
                case JBAWebConTableSecBytesReceivedRow:
                    cell.metricNameLabel.text = @"Bytes Received";
                    cell.metricValueLabel.text = [_metrics[@"bytesReceived"] cellDisplay];
                    break;
            }
            break;
        }


        case JBATableMetricRequestPerConnectorSection:
        {
            switch (row) {
                case JBAWebConTableSecRequestCountRow:
                    cell.metricNameLabel.text = @"Request Count";
                    cell.metricValueLabel.text = [_metrics[@"requestCount"] cellDisplay];
                    break;
                case JBAWebConTableSecErrorCountRow:
                    cell.metricNameLabel.text = @"Error Count";
                    cell.metricValueLabel.text = [_metrics[@"errorCount"] cellDisplayPercentFromTotal:_metrics[@"requestCount"] withMBConversion:NO];
                    break;
                case JBAWebConTableSecProcessingTimeRow:
                    cell.metricNameLabel.text = @"Processing Time (ms)";
                    cell.metricValueLabel.text = [_metrics[@"processingTime"] cellDisplay];
                    break;
                case JBAWebConTableSecMaxTimeRow:
                    cell.metricNameLabel.text = @"Max Time (ms)";
                    cell.metricValueLabel.text = [_metrics[@"maxTime"] cellDisplay];
                    break;
            }   
            break;
        }
      }
    cell.maxNameWidth = ([@"Processing Time (ms)"
                          sizeWithAttributes:@{NSFontAttributeName:cell.metricNameLabel.font}]).width;
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
