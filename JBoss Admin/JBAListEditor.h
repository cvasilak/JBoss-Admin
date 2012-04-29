//
//  JBAListEditor.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JBAManagementModel.h"

@interface JBAListEditor : UITableViewController  <UITextFieldDelegate>

@property(strong, nonatomic) NSMutableArray *items;

@property(assign, nonatomic) JBAType valueType;

@property(assign, nonatomic) BOOL isReadOnlyMode;

@end
