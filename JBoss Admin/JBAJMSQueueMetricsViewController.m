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

#import "JBAJMSQueueMetricsViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "MetricInfoCell.h"
#import "SVProgressHUD.h"

// Table Sections
enum JBAJMSQueueTableSections {
    JBATableQueueInFlightMessagesSection = 0,
    JBATableQueueMessagesProcessedSection,
    JBATableQueueConsumerSection,
    JBATableQueueNumSections
};

// Table Rows
enum JBAJMSInFlightMessagesRows {
    JBAJMSTableSecMessagesInQueue = 0,
    JBAJMSTableSecInDelivery,
    JBAJMSTableSecInFlightMessagesNumRows
};

enum JBAJMSMessagesProcessedRows {
    JBAJMSTableSecMessagesAddedRow = 0,
    JBAJMSTableSecMessagesScheduledRow,
    JBAJMSTableSecMessagesProcessedNumRows
};

enum JBAJMSConsumerRows {
    JBAJMSTableSecNumberOfConsumersRow = 0,
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
- (void)viewDidUnload {
    DLog(@"JBAJMSQueueMetricsViewController viewDidUnLoad");
    
    _metrics = nil;
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    DLog(@"JBAJMSQueueMetricsViewController viewDidLoad");
    
    self.title = self.queue;
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;

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
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"message-count"] cellDisplay];
                    break;
                case JBAJMSTableSecInDelivery:
                    cell.metricNameLabel.text= @"In Delivery";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"delivering-count"] cellDisplayPercentFromTotal:[_metrics objectForKey:@"message-count"] withMBConversion:NO];
                    break;
            }   
            break;
        }
            
        case JBATableQueueMessagesProcessedSection:
        {
            switch (row) {
                case JBAJMSTableSecMessagesAddedRow:
                    cell.metricNameLabel.text = @"Messages Added";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"messages-added"] cellDisplay];
                    break;
                case JBAJMSTableSecMessagesScheduledRow:
                    cell.metricNameLabel.text = @"Messages Scheduled";                    
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"scheduled-count"] cellDisplay];
                    break;
            }
            break;            
        }
            
        case JBATableQueueConsumerSection:
        {
            switch (row) {
                case JBAJMSTableSecNumberOfConsumersRow:
                    cell.metricNameLabel.text = @"Number of Consumer";
                    cell.metricValueLabel.text = [[_metrics objectForKey:@"consumer-count"] cellDisplay];
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
     fetchJMSMetricsForName:self.queue ofType:QUEUE 
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
