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

#import "JBAEnvironmentPropertiesListViewController.h"

#import "SubtitleCell.h"

@implementation JBAEnvironmentPropertiesListViewController {
    NSArray *_keys;
}

@synthesize properties = _properties;

-(void)dealloc {
    DLog(@"JBAEnvironmentPropertiesListViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBAEnvironmentPropertiesListViewController viewDidLoad");
    
    self.title = @"Properties";
    
    _keys = [[self.properties allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    [super viewDidLoad];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];

    SubtitleCell *cell = [SubtitleCell cellForTableView:tableView];
    
    NSString *key = [_keys objectAtIndex:row];
    NSString *value = [self.properties objectForKey:key];

    cell.textLabel.text = key;
    cell.detailTextLabel.text = value;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;    
    
    return cell;
}
@end
