//
//  JBAAttributeEditor.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JBAManagementModel.h"

@interface JBAAttributeEditor : UITableViewController

@property (nonatomic, strong) JBAAttribute *node;

-(IBAction)updateWithValue:(id)value;

@end
