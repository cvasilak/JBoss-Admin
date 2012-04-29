//
//  JBADomainServerGroupsViewController.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBADomainServerGroupsViewController : UITableViewController

@property(strong, nonatomic) NSMutableDictionary *deploymentToAdd;
@property(nonatomic) BOOL groupSelectionMode;

@end
