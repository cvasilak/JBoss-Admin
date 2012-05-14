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

#import "JBAExtensionsListViewController.h"

#import "DefaultCell.h"

@implementation JBAExtensionsListViewController

@synthesize extensions = _extensions;

-(void)dealloc {
    DLog(@"JBAExtensionsListViewController dealloc");    
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    DLog(@"JBAExtensionsListViewController viewDidUnLoad");
    
    [super viewDidUnload];
}

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
