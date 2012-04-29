//
//  ToggleSwitchCell.m
//  JBoss Admin
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "ToggleSwitchCell.h"

@implementation ToggleSwitchCell

@synthesize toggler = _toggler;

- (id)initWithCellIdentifier:(NSString *)cellID {
    if (self = [super initWithCellIdentifier:cellID]) {
        
        _toggler = [[UISwitch alloc] initWithFrame:CGRectZero];

        [self.contentView addSubview:_toggler];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
	
    CGFloat adjustedX = 8;
    
	if (self.adjustX)
        adjustedX = 26;
    
    CGRect t = CGRectInset(self.bounds, 8, 8);
	t.origin.x += self.label.frame.size.width + adjustedX;
	t.size.width -= self.label.frame.size.width + 6;
	_toggler.frame = t;
}

@end
