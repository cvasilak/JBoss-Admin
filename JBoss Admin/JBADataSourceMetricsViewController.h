//
//  JBADataSourceMetricsViewController.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JBAOperationsManager.h"

@interface JBADataSourceMetricsViewController : UITableViewController

@property(strong, nonatomic) NSString *dataSourceName;
@property(nonatomic) JMSType dataSourceType;

@end
