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

#import "JBAExtensionsListViewController.h"

#import "DefaultCell.h"

@implementation JBAExtensionsListViewController

@synthesize extensions = _extensions;

-(void)dealloc {
    DLog(@"JBAExtensionsListViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBAExtensionsListViewController viewDidLoad");
    
    self.title = @"Extensions";
    
    // sort names
    self.extensions = [self.extensions sortedArrayUsingSelector:@selector(compare:)];
    
    [super viewDidLoad];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.extensions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];

    DefaultCell *cell = [DefaultCell cellForTableView:tableView];
    
    cell.textLabel.text = [self.extensions objectAtIndex:row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;    
    
    return cell;
}
@end
