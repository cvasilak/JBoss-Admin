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

#import "JBAJMSTypeSelectorViewController.h"
#import "JBAJMSQueuesViewController.h"
#import "JBAJMSTopicsViewController.h"

#import "DefaultCell.h"

// Table Rows
typedef NS_ENUM(NSUInteger, JBAJMSTypeRows) {
    JBAJMSTypeQueueRow,
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
    NSInteger row = [indexPath row];

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
     NSInteger row = [indexPath row];
    
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
