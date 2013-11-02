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

#import "JBAJMSTopicMetricsViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "MetricInfoCell.h"
#import "SVProgressHUD.h"

// Table Sections
enum JBAJMSTopicTableSections {
    JBATableTopicInFlightMessagesSection = 0,
    JBATableTopicMessagesProcessedSection,
    JBATableTopicSubscriptionsSection,
    JBATableTopicNumSections
};

// Table Rows
enum JBAJMSInFlightMessagesRows {
    JBAJMSTableSecMessagesInTopic = 0,
    JBAJMSTableSecInDelivery,
    JBAJMSTableSecInFlightMessagesNumRows
};

enum JBAJMSMessagesProcessedRows {
    JBAJMSTableSecMessagesAddedRow = 0,
    JBAJMSTableSecMessagesDurableRow,
    JBAJMSTableSecMessagesNoNDurableRow,
    JBAJMSTableSecMessagesProcessedNumRows
};

enum JBAJMSSubscriptionsRows {
    JBAJMSTableSecNumberOfSubscriptionsRow = 0,
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
- (void)viewDidUnload {
    DLog(@"JBAJMSTopicMetricsViewController viewDidUnLoad");
    
    _metrics = nil;
    
    [super viewDidUnload];
}

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
