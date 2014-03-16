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

#import "JBAConfigurationViewController.h"
#import "JBAExtensionsListViewController.h"
#import "JBAEnvironmentPropertiesListViewController.h"
#import "JBossValue.h"

#import "JBAOperationsManager.h"

#import "MetricInfoCell.h"
#import "DefaultCell.h"
#import "SVProgressHUD.h"

// Table Sections
typedef NS_ENUM(NSUInteger, JBAConfTableSections) {
    JBATableServerInfoSection,
    JBATableServerConfigurationSection,
    JBATableConfNumSections
};

// Table Rows
typedef NS_ENUM(NSUInteger, JBAServerInfoRows) {
    JBAConfTableSecCodeNameRow,
    JBAConfTableSecReleaseVersionRow,
    JBAConfTableSecServerStateRow,
    JBAConfTableSecServerInfoNumRows
};

typedef NS_ENUM(NSUInteger, JBAServerConfRows) {
    JBAConfTableSecExtensionsRow,
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

- (void)viewDidLoad {
    DLog(@"JBAConfigurationViewController viewDidLoad");
    
    self.title = @"Configuration"; 
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
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
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    id cell;
    
    switch (section) {
        case JBATableServerInfoSection:
        {
            MetricInfoCell *metricCell = [MetricInfoCell cellForTableView:tableView];
            
            NSMutableDictionary *info = _serverInfo[@"server-info"];
            
            switch (row) {
                case JBAConfTableSecCodeNameRow:
                    metricCell.metricNameLabel.text = @"Code Name";
                    metricCell.metricValueLabel.text = [info[@"release-codename"] cellDisplay];
                    break;
                case JBAConfTableSecReleaseVersionRow:
                    metricCell.metricNameLabel.text = @"Release Version";
                    metricCell.metricValueLabel.text = [info[@"release-version"] cellDisplay];
                    break;
                case JBAConfTableSecServerStateRow:
                    metricCell.metricNameLabel.text = @"Server State";
                    metricCell.metricValueLabel.text = [info[@"server-state"] cellDisplay];
                    break;
            }
            metricCell.maxNameWidth = ([@"release-codename" sizeWithFont:metricCell.metricNameLabel.font]).width;
            cell = metricCell;
            break;
        }

        case JBATableServerConfigurationSection:
        {
            DefaultCell *labelCell = [DefaultCell cellForTableView:tableView];

            labelCell.textLabel.textAlignment = NSTextAlignmentCenter;
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
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];

    switch (section) {
        case JBATableServerConfigurationSection:
            switch (row) {
                case JBAConfTableSecExtensionsRow:
                {
                    JBAExtensionsListViewController *extensionsController = [[JBAExtensionsListViewController alloc] initWithStyle:UITableViewStylePlain];
                    extensionsController.extensions = _serverInfo[@"extensions"];

                    [self.navigationController pushViewController:extensionsController animated:YES];
                }
                    break;
                case JBAConfTableSecPropertiesRow:
                {
                    JBAEnvironmentPropertiesListViewController *propertiesController = [[JBAEnvironmentPropertiesListViewController alloc] initWithStyle:UITableViewStylePlain];
                    propertiesController.properties = _serverInfo[@"properties"];

                    [self.navigationController pushViewController:propertiesController animated:YES];
                }
                    break;                    
            }
            break;
    }
     
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
