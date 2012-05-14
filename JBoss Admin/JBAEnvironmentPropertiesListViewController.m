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
- (void)viewDidUnload {
    DLog(@"JBAEnvironmentPropertiesListViewController viewDidUnLoad");
    
    _keys = nil;
    
    [super viewDidUnload];
}

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
