//
//  JBAJMSTopicMetricsViewController.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBAJMSTopicMetricsViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

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
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
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
    
    return cell;
}

#pragma mark - Actions
- (void)refresh {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    [[JBAOperationsManager sharedManager]
     fetchJMSMetricsForName:self.topic ofType:TOPIC 
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
