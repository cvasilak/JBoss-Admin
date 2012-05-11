//
//  JBAProfileController.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBAProfileController.h"
#import "JBossValue.h"
#import "JBAAttributeGenericTypeEditor.h"
#import "JBAOperationsViewController.h"
#import "JBAChildResourcesViewController.h"

#import "JBAManagementModel.h"
#import "JBAOperationsManager.h"

#import "JBARefreshable.h"

#import "SubtitleCell.h"
#import "ButtonCell.h"
#import "SVProgressHUD.h"

// Table Sections
enum JBAProfileTableSections {
    JBATableAttributesSection = 0,
    JBATableChildTypesSection,
    JBATableOperationsSection,
    JBATableProfileNumSections
};

@interface JBAProfileController()<JBARefreshable>

- (void)displayAttributeEditorForNode:(JBAAttribute *)node;

@end

@implementation JBAProfileController {
    NSArray *_attrs;
    NSArray *_childTypes;
}

@synthesize path = _path;

-(void)dealloc {
    DLog(@"JBAProfileController dealloc");    
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
  	DLog(@"JBAProfileController viewDidUnload");

    _attrs = nil;
    _childTypes = nil;
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    DLog(@"JBAProfileController viewDidLoad");

    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;
        
    [self refresh];        

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"JBAProfileController viewWillAppear");
    
    // this will ensure any possible updates in the AttributeEditor 
    // be visible after popping the controller
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return JBATableProfileNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case JBATableAttributesSection:
            return [_attrs count] == 0? nil: @"Attributes";
        case JBATableChildTypesSection:
            return [_childTypes count] == 0? nil: @"Child Types";
        case JBATableOperationsSection:
            return nil;
        default:
            return nil;        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case JBATableAttributesSection:
            return [_attrs count];
        case JBATableChildTypesSection:
            return [_childTypes count];
        case JBATableOperationsSection:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];    
    NSUInteger row = [indexPath row];
    
    id cell;
    
    switch (section) {
            
        case JBATableAttributesSection:
        {
            SubtitleCell *attrCell = [SubtitleCell cellForTableView:tableView];
            
            JBAAttribute *node = [_attrs objectAtIndex:row];
        
            attrCell.textLabel.text = node.name;
            attrCell.imageView.image = nil;
            attrCell.detailTextLabel.text = [node.value cellDisplay];        
            attrCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            cell = attrCell;
            break;            
        }
            
        case JBATableChildTypesSection:
        {
            SubtitleCell *childCell = [SubtitleCell cellForTableView:tableView];
            
            JBAChildType *node = [_childTypes objectAtIndex:row];

            childCell.textLabel.text = node.name;
            childCell.imageView.image = [UIImage imageNamed:@"folder.png"];

            childCell.detailTextLabel.text = nil;
            childCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;                

            cell = childCell;
            break;
        }
    
        case JBATableOperationsSection:
        {
            ButtonCell *operationsCell = [ButtonCell cellForTableView:tableView];

            operationsCell.imageView.image = [UIImage imageNamed:@"operations.png"];
            operationsCell.textLabel.font = [UIFont italicSystemFontOfSize:16];
            operationsCell.textLabel.textAlignment = UITextAlignmentCenter;
            operationsCell.textLabel.text = @"Operations";
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

    switch (section) {
            case JBATableAttributesSection:
            {
                JBAAttribute *selectedNode = [_attrs objectAtIndex:row];
        
                // we must do read-resource-description to initialize info if
                // this attribute description is empty
                // NOTE: since the methods retrieves information for all 
                // attributes we update all of our attributes in our local model
                // to avoid contacting the server again in case a user
                // clicks another attribute in the same resource.
                if (selectedNode.descr == nil) { 
                    DLog(@"not attribute information found, perfoming read-resource-description");
                    
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];                
                    
                    NSDictionary *params = 
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         @"read-resource-description", @"operation",
                         (self.path == nil?[NSArray arrayWithObject:@"/"]: self.path), @"address", nil];

                    [[JBAOperationsManager sharedManager] 
                        postJBossRequestWithParams:params
                             success:^(NSDictionary *JSON) {
                                 [SVProgressHUD dismiss];

                                 // we are only interested for the attributes
                                 NSDictionary *attrs = [JSON objectForKey:@"attributes"];

                                 for (JBAAttribute *node in _attrs) {
                                     NSDictionary *info = [attrs objectForKey:node.name];
                                     node.type = [JBAManagementModel 
                                                  typeFromString:[[info objectForKey:@"type"]objectForKey:@"TYPE_MODEL_VALUE"]];                                  

                                     // for LIST type extract the type of object the list holds
                                     if (node.type == LIST) {
                                         node.valueType = [JBAManagementModel 
                                                            typeFromString:[[info objectForKey:@"value-type"]objectForKey:@"TYPE_MODEL_VALUE"]];                                        
                                     }

                                     node.descr = [info objectForKey:@"description"];
                                     
                                     if (   [[info objectForKey:@"access-type"] isEqualToString:@"read-only"]
                                         || [[info objectForKey:@"access-type"] isEqualToString:@"metric"]) {                                     
                                         node.isReadOnly = YES;
                                     }

                                     node.path = self.path;
                                 }
                                
                                [self displayAttributeEditorForNode:selectedNode];
                                 
                                 
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

                } else { // information is already cached just display the editor
                    [self displayAttributeEditorForNode:selectedNode];
                }
                
                break;
            }

            case JBATableChildTypesSection:
            {
                JBAChildType *selectedNode = [_childTypes objectAtIndex:row];

                JBAChildResourcesViewController *controller = [[JBAChildResourcesViewController alloc] initWithStyle:UITableViewStyleGrouped];

                controller.node = selectedNode;
                controller.path = self.path;

                [self.navigationController pushViewController:controller animated:YES];
                
                break;                    
            }

            case JBATableOperationsSection:
            {
                JBAOperationsViewController *opsController = [[JBAOperationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                opsController.path = self.path;
                
                [self.navigationController pushViewController:opsController animated:YES];
            
            }
            
        }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Utility Method
- (void)displayAttributeEditorForNode:(JBAAttribute *)node {
    JBAAttributeGenericTypeEditor *editorController = [[JBAAttributeGenericTypeEditor alloc] initWithStyle:UITableViewStyleGrouped];
    editorController.node = node;

    [self.navigationController pushViewController:editorController animated:YES];        
}

#pragma mark - Actions
- (void)refresh {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    
    NSDictionary *step1 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"read-resource", @"operation",
                            (self.path==nil? [NSArray arrayWithObject:@"/"]: self.path), @"address", nil];
    
    // will identify the child types of this resource
    NSDictionary *step2 = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"read-children-types", @"operation",
                           (self.path==nil? [NSArray arrayWithObject:@"/"]: self.path), @"address", nil];

    NSDictionary *params =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"composite", @"operation",
         [NSArray arrayWithObjects:step1, step2, nil], @"steps", nil];
    
    [[JBAOperationsManager sharedManager]
        postJBossRequestWithParams:params
             success:^(NSDictionary *JSON) {
                 [SVProgressHUD dismiss];
                 
                 if (  ![[[JSON objectForKey:@"step-1"] objectForKey:@"outcome"] isEqualToString:@"success"]
                    || ![[[JSON objectForKey:@"step-2"] objectForKey:@"outcome"] isEqualToString:@"success"])
                     return;

                 NSDictionary *readResource = [[JSON objectForKey:@"step-1"] objectForKey:@"result"];
                 NSArray *readChildrenTypes = [[JSON objectForKey:@"step-2"] objectForKey:@"result"];
                 
                 NSMutableArray *attrs = [[NSMutableArray alloc] init];
                 NSMutableArray *childTypes = [[NSMutableArray alloc] init];
                 
                 for (NSString *key in [readResource allKeys]) {

                     if ([readChildrenTypes containsObject:key]) { // is it a children type?
                         JBAChildType *node = [[JBAChildType alloc] init];
                         node.name = key;
                         node.value = [readResource objectForKey:key];

                         [childTypes addObject:node];

                     } else {  // nope its an attribute
                         JBAAttribute *node = [[JBAAttribute alloc] init];
                         
                         node.name = key;
                         node.value = [readResource objectForKey:key];
              
                         [attrs addObject:node];
                     }
                 }
                 
                 // sort by node name
                 // see JBAManagementModel:compare() 
                 [attrs sortUsingSelector:@selector(compare:)];
                 [childTypes sortUsingSelector:@selector(compare:)];
                
                 _attrs = attrs;
                 _childTypes = childTypes;
                 
                 [self.tableView reloadData];
                 
             } failure:^(NSError *error) {
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