//
//  JBADataSourcesViewController.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBADataSourcesViewController.h"
#import "JBADataSourceMetricsViewController.h"

#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "DefaultCell.h"
#import "SVProgressHUD.h"

@interface JBADataSourcesViewController()<JBARefreshable>

@end

@implementation JBADataSourcesViewController {
    NSArray *_names;
    NSDictionary *_datasources;
}

-(void)dealloc {
    DLog(@"JBADataSourcesViewController dealloc");    
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    DLog(@"JBADataSourcesViewController viewDidUnLoad");
    
    _names = nil;
    _datasources = nil;
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    DLog(@"JBADataSourcesViewController viewDidLoad");
    
    self.title = @"Data Sources";
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;

    [self refresh];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBADataSourcesViewController viewWillAppear");
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_names count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    DefaultCell *cell = [DefaultCell cellForTableView:tableView];
    
    NSString *name = [_names objectAtIndex:row];
    cell.textLabel.text = name;
    
    if ([[_datasources objectForKey:name] objectForKey:@"xa-datasource-class"] != nil) {
        cell.imageView.image = [UIImage imageNamed:@"xa-ds.png"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
    
    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    NSString *name = [_names objectAtIndex:row];
    
    JBADataSourceMetricsViewController *dataSourceMetricsController = [[JBADataSourceMetricsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    dataSourceMetricsController.dataSourceName = name;
    
    if ([[_datasources objectForKey:name] objectForKey:@"xa-datasource-class"] != nil) {
        dataSourceMetricsController.dataSourceType = XADataSource;
    } else {
        dataSourceMetricsController.dataSourceType = StandardDataSource;
    }

    [self.navigationController pushViewController:dataSourceMetricsController animated:YES];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions
- (void)refresh {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    
    [[JBAOperationsManager sharedManager]
     fetchDataSourcesListWithSuccess:^(NSDictionary *datasources) {
         [SVProgressHUD dismiss];
         
         _names = [[datasources allKeys] sortedArrayUsingSelector:@selector(compare:)];
         _datasources = datasources;
         
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
