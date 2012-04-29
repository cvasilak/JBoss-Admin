//
//  JBAExtensionsListViewController.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

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
