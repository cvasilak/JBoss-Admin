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

#import "JBAChildResourcesViewController.h"
#import "JBAProfileController.h"
#import "JBAOperationsViewController.h"

#import "JBAManagementModel.h"
#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "SVProgressHUD.h"

#import "DefaultCell.h"
#import "SubtitleCell.h"
#import "ButtonCell.h"

// Table Sections
enum JBAChildTypesTableSections {
    JBATableChildResourcesSection,
    JBATableGenericOpsSection,
    JBATableChildTypesNumSections
};

@interface JBAChildResourcesViewController()<JBARefreshable>

@end

@implementation JBAChildResourcesViewController {
    NSArray *_names;
    BOOL _hasGenericOperations;
}

@synthesize path = _path;
@synthesize node = _node;

-(void)dealloc {
    DLog(@"JBAChildResourcesViewController dealloc");    
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    DLog(@"JBAChildResourcesViewController viewDidUnLoad");
    
    _names = nil;

    [super viewDidUnload];
}

- (void)viewDidLoad {
    DLog(@"JBAChildResourcesViewController viewDidLoad");

    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    self.title = self.node.name;
    
    [self refresh];
    
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return JBATableChildTypesNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case JBATableChildResourcesSection:
            return [_names count] > 0? @"Child Resources": nil;
        default:
            return nil;        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case JBATableChildResourcesSection:
            return [_names count];
        case JBATableGenericOpsSection:
            return _hasGenericOperations? 1: 0;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    id cell;
    
    switch (section) {
        case JBATableChildResourcesSection:
        {

            NSString *name = [_names objectAtIndex:row];
            
            if ([name isEqualToString:@"<undefined>"]) {
                DefaultCell *undefinedCell = [DefaultCell cellForTableView:tableView];                
                undefinedCell.textLabel.font = [UIFont italicSystemFontOfSize:16];
                undefinedCell.textLabel.textAlignment = UITextAlignmentCenter;
                undefinedCell.textLabel.text = name;
                
                cell = undefinedCell;
            } else {
                
                SubtitleCell *childrenTypeCell = [SubtitleCell cellForTableView:tableView];
                childrenTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                childrenTypeCell.textLabel.text = name;                
                
                cell = childrenTypeCell;
            }
            
            break;
        }
        case JBATableGenericOpsSection:
        {
            ButtonCell *operationsCell = [ButtonCell cellForTableView:tableView];
            
            operationsCell.imageView.image = [UIImage imageNamed:@"operations.png"];
            operationsCell.textLabel.font = [UIFont italicSystemFontOfSize:16];
            operationsCell.textLabel.textAlignment = UITextAlignmentCenter;
            operationsCell.textLabel.text = @"Generic Operations";
            operationsCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            cell = operationsCell;
            
            break;
        }

    }
    
    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];    
    
    switch (section) {
        case JBATableChildResourcesSection:
        {
            NSString *name = [_names objectAtIndex:row];
            
            // do nothing for undefined
            if ([name isEqualToString:@"<undefined>"])
                return;
            
            NSMutableArray *next = [[NSMutableArray alloc] initWithArray:self.path];
            [next addObject:self.node.name];
            [next addObject:name];
            
            JBAProfileController *controller = [[JBAProfileController alloc] initWithStyle:UITableViewStyleGrouped];
            
            controller.path = next;
            controller.title = name;
            
            [self.navigationController pushViewController:controller animated:YES];
            
            break;
        }
        case JBATableGenericOpsSection:
        {
            NSMutableArray *next = [[NSMutableArray alloc] initWithArray:self.path];
            [next addObject:self.node.name];            
            [next addObject:@"*"];
            
            JBAOperationsViewController *opsController = [[JBAOperationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            opsController.path = next;
            
            [self.navigationController pushViewController:opsController animated:YES];
            
            break;
        }
    }
}

#pragma mark - Actions
-(IBAction)refresh {
    _hasGenericOperations = NO;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];                

    // will identify the child resources of this child type
    // Note: we reload here in case an "add" happened down the road
    NSDictionary *childNamesParams = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"read-children-names", @"operation",
                           (self.path==nil? [NSArray arrayWithObject:@"/"]: self.path), @"address", 
                           self.node.name, @"child-type", nil];
    

    
    // append child-type name and the star for "read-operation-names"
    NSMutableArray *genericOpsPath = [[NSMutableArray alloc] initWithArray:self.path];
    [genericOpsPath addObject:self.node.name];
    [genericOpsPath addObject:@"*"];

    NSDictionary *genericOpsParams =  [NSDictionary dictionaryWithObjectsAndKeys:
                            @"read-operation-names", @"operation",
                            genericOpsPath, @"address", nil];

    
    [[JBAOperationsManager sharedManager] 
     postJBossRequestWithParams:childNamesParams
     success:^(NSArray *childNames) {
         
         _names = [childNames sortedArrayUsingSelector:@selector(compare:)];
         self.node.value = _names;

         [[JBAOperationsManager sharedManager] 
          postJBossRequestWithParams:genericOpsParams
          success:^(NSArray *names) {
              [SVProgressHUD dismiss];

              // operations found, check if they contain 
              // generic add
              for (NSString *name in names) {
                  if ([name isEqualToString:@"add"]) {
                      _hasGenericOperations = YES;
                      break;
                  }
              }

              // if no generic operations found and children resources
              // are empty inform as "undefined"
              if (!_hasGenericOperations && [_names count] == 0) {
                  _names = [NSArray arrayWithObject:@"<undefined>"];                  
              }
              
              [self.tableView reloadData];
              
          } failure:^(NSError *error) {
              [SVProgressHUD dismiss];
              
              // empty operation list
              if ([error.domain isEqualToString:@"jboss-admin"]) {
                  // if no children resources found inform as "undefined"
                  if ([_names count] == 0) {
                      _names = [NSArray arrayWithObject:@"<undefined>"];
                      
                  }

                 [self.tableView reloadData]; 
                  
                  return;                  
              }
             
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                              message:[error localizedDescription]
                                                             delegate:nil 
                                                    cancelButtonTitle:@"Bummer"
                                                    otherButtonTitles:nil];
              [alert show];
          }
          ]; 
         
     } failure:^(NSError *error) {
         [SVProgressHUD dismiss];
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                         message:[error localizedDescription]
                                                        delegate:nil 
                                               cancelButtonTitle:@"Bummer"
                                               otherButtonTitles:nil];
         [alert show];
     }
     ];     
   
}
@end
