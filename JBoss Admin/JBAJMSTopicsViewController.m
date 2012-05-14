//
//  JBAJMSTopicsViewController.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBAJMSTopicsViewController.h"
#import "JBAJMSTopicMetricsViewController.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "DefaultCell.h"
#import "SVProgressHUD.h"

@interface JBAJMSTopicsViewController()<JBARefreshable>

@end

@implementation JBAJMSTopicsViewController {
    NSArray *_topics;
}

-(void)dealloc {
    DLog(@"JBAJMSTopicsViewController dealloc");    
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    DLog(@"JBAJMSTopicsViewController viewDidUnLoad");
    
    _topics = nil;
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    DLog(@"JBAJMSTopicsViewController viewDidLoad");
    
    self.title = @"Topics";
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;

    [self refresh];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBAJMSTopicsViewController viewWillAppear");
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_topics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];

    DefaultCell *cell = [DefaultCell cellForTableView:tableView];
    
    cell.textLabel.text = [_topics objectAtIndex:row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
    
    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    JBAJMSTopicMetricsViewController *topicMetricsController = [[JBAJMSTopicMetricsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    topicMetricsController.topic = [_topics objectAtIndex:row];
    
    [self.navigationController pushViewController:topicMetricsController animated:YES];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions
- (void)refresh {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    
    [[JBAOperationsManager sharedManager]
     fetchJMSMessagingModelListOfType:TOPIC
     withSuccess:^(NSArray *topics) {
         [SVProgressHUD dismiss];
         
         _topics = [topics sortedArrayUsingSelector:@selector(compare:)];
         
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
