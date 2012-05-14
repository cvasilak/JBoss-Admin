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
