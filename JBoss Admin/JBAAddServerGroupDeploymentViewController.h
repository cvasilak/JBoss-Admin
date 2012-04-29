//
//  JBAAddServerGroupDeploymentViewController.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBAAddServerGroupDeploymentViewController : UITableViewController

@property(unsafe_unretained, nonatomic) UINavigationController *parentNavController;

@property(strong, nonatomic) NSString *group;
@property(strong, nonatomic) NSArray *existingDeployments;

@end
