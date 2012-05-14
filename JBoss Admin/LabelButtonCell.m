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
