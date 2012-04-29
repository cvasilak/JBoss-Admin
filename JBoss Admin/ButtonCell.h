//
//  ButtonCell.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PRPSmartTableViewCell.h"

@interface ButtonCell : PRPSmartTableViewCell

- (id)initWithCellIdentifier:(NSString *)cellID;

@property(strong, readonly, nonatomic) UIButton *button;

@end
