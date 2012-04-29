//
//  JBAOperationExecViewController.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <UIKit/UIKit.h>

@class JBAOperation;

@interface JBAOperationExecViewController : UITableViewController <UITextFieldDelegate>

@property(strong, nonatomic) JBAOperation *operation;

@end
