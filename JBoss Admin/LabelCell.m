//
//  LabelCell.m
//  JBoss Admin
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "LabelCell.h"

#define kNonEditableTextColor  [UIColor colorWithRed:.318 green:0.4 blue:.569 alpha:7.0]

@implementation LabelCell

@synthesize label = _label;
@synthesize adjustX;

- (id)initWithCellIdentifier:(NSString *)cellID {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID])) {
     
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = UITextAlignmentRight;
        _label.textColor = kNonEditableTextColor;
        _label.font = [UIFont boldSystemFontOfSize:12.0];
        _label.adjustsFontSizeToFitWidth = YES;
        _label.baselineAdjustment = UIBaselineAdjustmentNone;
        _label.numberOfLines = 20;
        
        [self.contentView addSubview:_label];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat adjustedX = 8;
    
	if (self.adjustX)
        adjustedX = 26;
    
	CGRect r = CGRectInset(self.contentView.bounds, adjustedX, 8);
	r.size = CGSizeMake(110,27);
	_label.frame = r;
}
@end
