//
//  JBADeploymentDetailsViewController.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNumberOfEditableRows	3

#define kLabelTag 2048

#define kDeploymentHashRowIndex          0
#define kDeploymentNameRowIndex          1
#define kDeploymentRuntimeNameRowIndex   2

#define kNonEditableTextColor  [UIColor colorWithRed:.318 green:0.4 blue:.569 alpha:7.0]

@interface JBADeploymentDetailsViewController : UITableViewController<UITextFieldDelegate>

@property(strong, nonatomic) NSString *deploymentHash;
@property(strong, nonatomic) NSString *deploymentName;
@property(strong, nonatomic) NSString *deploymentRuntimeName;

@end
