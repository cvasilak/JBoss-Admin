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

#import "JBAJMSTopicMetricsViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "MetricInfoCell.h"
#import "SVProgressHUD.h"

// Table Sections
typedef NS_ENUM(NSUInteger, JBAJMSTopicTableSections) {
    JBATableTopicInFlightMessagesSection,
    JBATableTopicMessagesProcessedSection,
    JBATableTopicSubscriptionsSection,
    JBATableTopicNumSections
};

// Table Rows
typedef NS_ENUM(NSUInteger, JBAJMSInFlightMessagesRows) {
    JBAJMSTableSecMessagesInTopic,
    JBAJMSTableSecInDelivery,
    JBAJMSTableSecInFlightMessagesNumRows
};

typedef NS_ENUM(NSUInteger, JBAJMSMessagesProcessedRows) {
    JBAJMSTableSecMessagesAddedRow,
    JBAJMSTableSecMessagesDurableRow,
    JBAJMSTableSecMessagesNoNDurableRow,
    JBAJMSTableSecMessagesProcessedNumRows
};

typedef NS_ENUM(NSUInteger, JBAJMSSubscriptionsRows) {
    JBAJMSTableSecNumberOfSubscriptionsRow,
    JBAJMSTableSecDurableSubscribersRow,
    JBAJMSTableSecNoNDurableSubscribersRow, 
    JBAJMSTableSecConsumerNumRows
};

@interface JBAJMSTopicMetricsViewController()<JBARefreshable>

@end

@implementation JBAJMSTopicMetricsViewController {
    NSDictionary *_metrics;
}

@synthesize topic = _topic;

-(void)dealloc {
    DLog(@"JBAJMSTopicMetricsViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBAJMSTopicMetricsViewController viewDidLoad");
    
    self.title = self.topic;

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    [self refresh];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBAJMSTopicMetricsViewController viewWillAppear");
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return JBATableTopicNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case JBATableTopicInFlightMessagesSection:
            return @"In-Flight Messages";
        case JBATableTopicMessagesProcessedSection:
            return @"Messages Processed";
        case JBATableTopicSubscriptionsSection:
            return @"Subscriptions";
        default:
            return nil;        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case JBATableTopicInFlightMessagesSection:
            return JBAJMSTableSecInFlightMessagesNumRows;
        case JBATableTopicMessagesProcessedSection:
            return JBAJMSTableSecMessagesProcessedNumRows;
        case JBATableTopicSubscriptionsSection:
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
        case JBATableTopicInFlightMessagesSection:
        {
            switch (row) {
                case JBAJMSTableSecMessagesInTopic:
                    cell.metricNameLabel.text = @"Messages In Topic";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"message-count"] cellDisplay];
                    break;
                case JBAJMSTableSecInDelivery:
                    cell.metricNameLabel.text= @"In Delivery";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"delivering-count"] cellDisplayPercentFromTotal:[_metrics objectForKey:@"message-count"] withMBConversion:NO];
                    break;
            }   
            break;
        }
            
        case JBATableTopicMessagesProcessedSection:
        {
            switch (row) {
                case JBAJMSTableSecMessagesAddedRow:
                    cell.metricNameLabel.text = @"Messages Added";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"messages-added"] cellDisplay];
                    break;
                case JBAJMSTableSecMessagesDurableRow:
                    cell.metricNameLabel.text = @"Number Durable Messages";                    
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"durable-message-count"] cellDisplayPercentFromTotal:[_metrics objectForKey:@"messages-added"] withMBConversion:NO];
                    break;
                case JBAJMSTableSecMessagesNoNDurableRow:
                    cell.metricNameLabel.text = @"Number NoN-Durable Messages";                    
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"non-durable-message-count"] cellDisplayPercentFromTotal:[_metrics objectForKey:@"messages-added"] withMBConversion:NO];
                    break;
            }
            break;            
        }
            
        case JBATableTopicSubscriptionsSection:
        {
            switch (row) {
                case JBAJMSTableSecNumberOfSubscriptionsRow:
                    cell.metricNameLabel.text = @"Number of Subscriptions";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"subscription-count"] cellDisplay];
                    break;
                case JBAJMSTableSecDurableSubscribersRow:
                    cell.metricNameLabel.text = @"Durable Subscribers";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"durable-subscription-count"] cellDisplay];
                    break;
                case JBAJMSTableSecNoNDurableSubscribersRow:
                    cell.metricNameLabel.text = @"Non-Durable Subscribers";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"non-durable-subscription-count"] cellDisplay];
                    break;
                    
            }
            break;
        }
    }
    cell.maxNameWidth = ([@"Number NoN-Durable Messages" sizeWithFont:cell.metricNameLabel.font]).width;
    return cell;
}

#pragma mark - Actions
- (void)refresh {
    [[JBAOperationsManager sharedManager]
     fetchJMSMetricsForName:self.topic ofType:TOPIC 
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
