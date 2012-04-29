//
//  JBADeploymentsViewController.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    STANDALONE_MODE,
    DOMAIN_MODE,
    SERVER_MODE,
} OperationMode;

@interface JBADeploymentsViewController : UITableViewController

@property(nonatomic) OperationMode mode;

@property(strong, nonatomic) NSString *group;

@end
