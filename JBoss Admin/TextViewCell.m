//
//  TextViewCell.m
//  JBoss Admin
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "TextViewCell.h"

@implementation TextViewCell

@synthesize textView = _textView;

- (id)initWithCellIdentifier:(NSString *)cellID {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID])) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.font = [UIFont boldSystemFontOfSize:14.0];
        _textView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_textView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
	CGRect r = CGRectInset(self.contentView.bounds, 4, 8);
	_textView.frame = r;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlight animated:(BOOL)animated {
    [super setHighlighted:highlight animated:animated];
	
	if(highlight)
		_textView.textColor = [UIColor whiteColor];
	else
		_textView.textColor = [UIColor blackColor];
	
}

@end
