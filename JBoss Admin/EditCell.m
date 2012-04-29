//
//  EditCell.m
//  JBoss Admin
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "EditCell.h"

@implementation EditCell

@synthesize txtField = _txtField;

- (id)initWithCellIdentifier:(NSString *)cellID {
    if (self = [super initWithCellIdentifier:cellID]) {
     
        _txtField = [[UITextField alloc] initWithFrame:CGRectZero];
        _txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _txtField.backgroundColor = [UIColor clearColor];
        _txtField.font = [UIFont boldSystemFontOfSize:16.0];
        _txtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _txtField.autocorrectionType = UITextAutocorrectionTypeNo;
        _txtField.returnKeyType = UIReturnKeyDone;
        
        [self.contentView addSubview:_txtField];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat adjustedX = 8;
    
	if (self.adjustX)
        adjustedX = 26;
    
	CGRect bounds = CGRectInset(self.contentView.bounds, 8, 8);
    
    if (self.label.text != nil) {
        bounds.origin.x += self.label.frame.size.width + adjustedX;
        bounds.size.width -= self.label.frame.size.width + 14;
        _txtField.frame = bounds;            
    }

    _txtField.frame = bounds;            
}
@end
