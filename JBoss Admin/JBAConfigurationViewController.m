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
