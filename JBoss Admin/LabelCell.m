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
