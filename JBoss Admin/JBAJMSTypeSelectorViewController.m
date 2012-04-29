//
//  JBAJMSTypeSelectorViewController.m
//  JBoss Admin
///
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBAJMSTypeSelectorViewController.h"
#import "JBAJMSQueuesViewController.h"
#import "JBAJMSTopicsViewController.h"

#import "DefaultCell.h"

// Table Rows
enum JBAJMSTypeRows {
    JBAJMSTypeQueueRow = 0,
    JBAJMSTypeTopicRow,
    JBAJMSTypeNumRows
};

@implementation JBAJMSTypeSelectorViewController

-(void)dealloc {
    DLog(@"JBAJMSTypeSelectorViewController dealloc");    
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    DLog(@"JBAJMSTypeSelectorViewController viewDidUnLoad");

    [super viewDidUnload];    
}

- (void)viewDidLoad {
    DLog(@"JBAJMSTypeSelectorViewController viewDidLoad");
    
    self.title = @"Messaging Model";
    
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return JBAJMSTypeNumRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];

    DefaultCell *cell = [DefaultCell cellForTableView:tableView];
    
    switch (row) {
        case JBAJMSTypeQueueRow:
            cell.textLabel.text = @"Queues";
            break;
        case JBAJMSTypeTopicRow:
            cell.textLabel.text = @"Topics";
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    

    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     NSUInteger row = [indexPath row];
    
    switch (row) {
        case JBAJMSTypeQueueRow:
        {
            JBAJMSQueuesViewController *jmsQueuesSelectorController = [[JBAJMSQueuesViewController alloc] initWithStyle:UITableViewStylePlain];
            
            [self.navigationController pushViewController:jmsQueuesSelectorController animated:YES];

            break;
        }
        case JBAJMSTypeTopicRow:
        {
            JBAJMSTopicsViewController *jmsTopicsSelectorController = [[JBAJMSTopicsViewController alloc] initWithStyle:UITableViewStylePlain];
            
            [self.navigationController pushViewController:jmsTopicsSelectorController animated:YES];
            
            break;
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
