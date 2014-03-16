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

#import "JBAJMSQueueMetricsViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "MetricInfoCell.h"
#import "SVProgressHUD.h"

// Table Sections
typedef NS_ENUM(NSUInteger, JBAJMSQueueTableSections) {
    JBATableQueueInFlightMessagesSection,
    JBATableQueueMessagesProcessedSection,
    JBATableQueueConsumerSection,
    JBATableQueueNumSections
};

// Table Rows
typedef NS_ENUM(NSUInteger, JBAJMSInFlightMessagesRows) {
    JBAJMSTableSecMessagesInQueue,
    JBAJMSTableSecInDelivery,
    JBAJMSTableSecInFlightMessagesNumRows
};

typedef NS_ENUM(NSUInteger, JBAJMSMessagesProcessedRows) {
    JBAJMSTableSecMessagesAddedRow,
    JBAJMSTableSecMessagesScheduledRow,
    JBAJMSTableSecMessagesProcessedNumRows
};

typedef NS_ENUM(NSUInteger, JBAJMSConsumerRows) {
    JBAJMSTableSecNumberOfConsumersRow,
    JBAJMSTableSecConsumerNumRows
};

@interface JBAJMSQueueMetricsViewController()<JBARefreshable>

@end

@implementation JBAJMSQueueMetricsViewController {
    NSDictionary *_metrics;
}

@synthesize queue = _queue;

-(void)dealloc {
    DLog(@"JBAJMSQueueMetricsViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBAJMSQueueMetricsViewController viewDidLoad");
    
    self.title = self.queue;

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [self refresh];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBAJMSQueueMetricsViewController viewWillAppear");
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return JBATableQueueNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case JBATableQueueInFlightMessagesSection:
            return @"In-Flight Messages";
        case JBATableQueueMessagesProcessedSection:
            return @"Messages Processed";
        case JBATableQueueConsumerSection:
            return @"Consumer";
        default:
            return nil;        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case JBATableQueueInFlightMessagesSection:
            return JBAJMSTableSecInFlightMessagesNumRows;
        case JBATableQueueMessagesProcessedSection:
            return JBAJMSTableSecMessagesProcessedNumRows;
        case JBATableQueueConsumerSection:
            return JBAJMSTableSecConsumerNumRows;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    MetricInfoCell *cell = [MetricInfoCell cellForTableView:tableView];
    
    switch (section) {
        case JBATableQueueInFlightMessagesSection:
        {
            switch (row) {
                case JBAJMSTableSecMessagesInQueue:
                    cell.metricNameLabel.text = @"Messages In Queue";
                    cell.metricValueLabel.text = [_metrics[@"message-count"] cellDisplay];
                    break;
                case JBAJMSTableSecInDelivery:
                    cell.metricNameLabel.text= @"In Delivery";
                    cell.metricValueLabel.text = [_metrics[@"delivering-count"] cellDisplayPercentFromTotal:_metrics[@"message-count"] withMBConversion:NO];
                    break;
            }   
            break;
        }
            
        case JBATableQueueMessagesProcessedSection:
        {
            switch (row) {
                case JBAJMSTableSecMessagesAddedRow:
                    cell.metricNameLabel.text = @"Messages Added";
                    cell.metricValueLabel.text = [_metrics[@"messages-added"] cellDisplay];
                    break;
                case JBAJMSTableSecMessagesScheduledRow:
                    cell.metricNameLabel.text = @"Messages Scheduled";                    
                    cell.metricValueLabel.text = [_metrics[@"scheduled-count"] cellDisplay];
                    break;
            }
            break;            
        }
            
        case JBATableQueueConsumerSection:
        {
            switch (row) {
                case JBAJMSTableSecNumberOfConsumersRow:
                    cell.metricNameLabel.text = @"Number of Consumer";
                    cell.metricValueLabel.text = [_metrics[@"consumer-count"] cellDisplay];
                    break;
            }
            break;
        }
    }
    cell.maxNameWidth = ([@"Number of Consumer" sizeWithFont:cell.metricNameLabel.font]).width;
    return cell;
}

#pragma mark - Actions
- (void)refresh {
    [[JBAOperationsManager sharedManager]
     fetchJMSMetricsForName:self.queue ofType:QUEUE 
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
