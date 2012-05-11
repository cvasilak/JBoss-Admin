//
//  JBAWebConnectorTypeSelectorViewController.m
//  JBoss Admin
///
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBAWebConnectorTypeSelectorViewController.h"
#import "JBAWebConnectorMetricsViewController.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "DefaultCell.h"
#import "SVProgressHUD.h"

@interface JBAWebConnectorTypeSelectorViewController()<JBARefreshable>

@end

@implementation JBAWebConnectorTypeSelectorViewController {
    NSArray *_connectors;
}

-(void)dealloc {
    DLog(@"JBAWebConnectorTypeSelectorViewController dealloc");    
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    DLog(@"JBAWebConnectorTypeSelectorViewController viewDidUnLoad");

    _connectors = nil;
    
    [super viewDidUnload];    
}

- (void)viewDidLoad {
    DLog(@"JBAWebConnectorTypeSelectorViewController viewDidLoad");
    
    self.title = @"Connectors";

    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;    
    
    [self refresh];
    
    [super viewDidLoad];    
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBAWebConnectorTypeSelectorViewController viewWillAppear");
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_connectors count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];

    DefaultCell *cell = [DefaultCell cellForTableView:tableView];
    
    cell.textLabel.text = [_connectors objectAtIndex:row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;        

    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    NSString *connector = [_connectors objectAtIndex:row];
    
    JBAWebConnectorMetricsViewController *connectorMetricsController = [[JBAWebConnectorMetricsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    connectorMetricsController.connectorName = connector;
    
    [self.navigationController pushViewController:connectorMetricsController animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions
- (void)refresh {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    
    [[JBAOperationsManager sharedManager]
     fetchWebConnectorsListWithSuccess:^(NSArray *connectors) {
         [SVProgressHUD dismiss];
         _connectors = connectors;
         
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
