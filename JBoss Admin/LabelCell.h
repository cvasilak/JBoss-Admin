//
//  LabelCell.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PRPSmartTableViewCell.h"

@interface LabelCell : PRPSmartTableViewCell

- (id)initWithCellIdentifier:(NSString *)cellID;

@property(strong, readonly, nonatomic) UILabel *label;

@property(assign, nonatomic) BOOL adjustX; // used to adjust the label on the right

@end
