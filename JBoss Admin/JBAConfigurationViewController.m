//
//  JBAConfigurationViewController.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBAConfigurationViewController.h"
#import "JBAExtensionsListViewController.h"
#import "JBAEnvironmentPropertiesListViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

#import "MetricInfoCell.h"
#import "DefaultCell.h"
#import "SVProgressHUD.h"

// Table Sections
enum JBAConfTableSections {
    JBATableServerInfoSection = 0,
    JBATableServerConfigurationSection,
    JBATableConfNumSections
};

// Table Rows
enum JBAServerInfoRows {
    JBAConfTableSecCodeNameRow = 0,
    JBAConfTableSecReleaseVersionRow,
    JBAConfTableSecServerStateRow,
    JBAConfTableSecServerInfoNumRows
};

enum JBAServerConfRows {
    JBAConfTableSecExtensionsRow = 0,
    JBAConfTableSecPropertiesRow,
    JBAConfTableSecServerConfNumRows
};

@implementation JBAConfigurationViewController {
    NSDictionary *_serverInfo;
}

-(void)dealloc {
    DLog(@"JBAConfigurationViewController dealloc");    
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    DLog(@"JBAConfigurationViewController viewDidUnLoad");
 
    _serverInfo = nil;

    [super viewDidUnload];
}

- (void)viewDidLoad {
    DLog(@"JBAConfigurationViewController viewDidLoad");
    
    self.title = @"Configuration"; 
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    
    [[JBAOperationsManager sharedManager]
     fetchServerInfoWithSuccess:^(NSDictionary *serverInfo) {
            [SVProgressHUD dismiss];
         
            _serverInfo = serverInfo;
         
            // time to reload table
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
    
    [super viewDidLoad];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return JBATableConfNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case JBATableServerInfoSection:
            return @"Server Information";
        case JBATableServerConfigurationSection:
            return @"Server Configuration";
        default:
            return nil;        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case JBATableServerInfoSection:
            return JBAConfTableSecServerInfoNumRows;
        case JBATableServerConfigurationSection:
            return JBAConfTableSecServerConfNumRows;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    id cell;
    
    switch (section) {
        case JBATableServerInfoSection:
        {
            MetricInfoCell *metricCell = [MetricInfoCell cellForTableView:tableView];
            
            NSMutableDictionary *info = [_serverInfo objectForKey:@"server-info"];
            
            switch (row) {
                case JBAConfTableSecCodeNameRow:
                    metricCell.metricNameLabel.text = @"Code Name";
                    metricCell.metricValueLabel.text = [[info objectForKey:@"release-codename"] cellDisplay];
                    break;
                case JBAConfTableSecReleaseVersionRow:
                    metricCell.metricNameLabel.text = @"Release Version";
                    metricCell.metricValueLabel.text = [[info objectForKey:@"release-version"] cellDisplay];
                    break;
                case JBAConfTableSecServerStateRow:
                    metricCell.metricNameLabel.text = @"Server State";
                    metricCell.metricValueLabel.text = [[info objectForKey:@"server-state"] cellDisplay];
                    break;
            }
            
            cell = metricCell;
            break;
        }

        case JBATableServerConfigurationSection:
        {
            DefaultCell *labelCell = [DefaultCell cellForTableView:tableView];

            labelCell.textLabel.textAlignment = UITextAlignmentCenter;
            labelCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            switch (row) {
                case JBAConfTableSecExtensionsRow:
                    labelCell.textLabel.text = @"Extensions";
                    break;
                case JBAConfTableSecPropertiesRow:
                    labelCell.textLabel.text = @"Environment Properties";
                    break;
            }   
            
            cell = labelCell;
            break;
        }
      }

    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    switch (section) {
        case JBATableServerConfigurationSection:
            switch (row) {
                case JBAConfTableSecExtensionsRow:
                {
                    JBAExtensionsListViewController *extensionsController = [[JBAExtensionsListViewController alloc] initWithStyle:UITableViewStylePlain];
                    extensionsController.extensions = [_serverInfo objectForKey:@"extensions"];

                    [self.navigationController pushViewController:extensionsController animated:YES];
                }
                    break;
                case JBAConfTableSecPropertiesRow:
                {
                    JBAEnvironmentPropertiesListViewController *propertiesController = [[JBAEnvironmentPropertiesListViewController alloc] initWithStyle:UITableViewStylePlain];
                    propertiesController.properties = [_serverInfo objectForKey:@"properties"];

                    [self.navigationController pushViewController:propertiesController animated:YES];
                }
                    break;                    
            }
            break;
    }
     
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
