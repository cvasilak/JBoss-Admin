//
//  JBAChildResourcesViewController.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <UIKit/UIKit.h>

@class JBAChildType;

@interface JBAChildResourcesViewController : UITableViewController

@property(strong, nonatomic) NSArray *path;
@property(strong, nonatomic) JBAChildType *node;

@end
