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
