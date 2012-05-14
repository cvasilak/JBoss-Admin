/*
 * JBoss Admin
 * Copyright 2012, Christos Vasilakis, and individual contributors.
 * See the copyright.txt file in the distribution for a full
 * listing of individual contributors.
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */

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
