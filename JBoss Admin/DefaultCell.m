//
//  DefaultCell.m
//  JBoss Admin
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "DefaultCell.h"

@implementation DefaultCell

- (id)initWithCellIdentifier:(NSString *)cellID {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID])) {

    }

    return self;
}

@end
