//
//  JBAEnvironmentPropertiesListViewController.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

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
