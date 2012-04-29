//
//  EditCell.m
//  JBoss Admin
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "LabelButtonCell.h"

@implementation LabelButtonCell

@synthesize button = _button;

- (id)initWithCellIdentifier:(NSString *)cellID {
    if (self = [super initWithCellIdentifier:cellID]) {
     
        _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        [self.contentView addSubview:_button];

        self.selectionStyle = UITableViewCellSelectionStyleNone;        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat adjustedX = 8;
    
	if (self.adjustX)
        adjustedX = 26;
    
    NSString *title = _button.titleLabel.text;
    
    // TODO: this is a hack!
    // see why _titleLabel.text = nil 
    // but when the tableview is moved it gets the 
    // correct value
    if (title == nil) {
        title = @"Click to Edit";
    }
        
    CGRect t = CGRectInset(self.contentView.bounds, 8, 8);
	t.origin.x += self.label.frame.size.width + adjustedX;
	t.size.width = [title sizeWithFont:_button.titleLabel.font].width + 20;
    _button.frame = t;    
}
@end
