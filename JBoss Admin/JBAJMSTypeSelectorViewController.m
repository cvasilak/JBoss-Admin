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
