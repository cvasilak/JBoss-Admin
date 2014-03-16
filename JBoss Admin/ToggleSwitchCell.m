/*
 * JBoss Admin
 * Copyright Christos Vasilakis, and individual contributors
 * See the copyright.txt file in the distribution for a full
 * listing of individual contributors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
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
	
    CGFloat adjustedX = 10;
    
	if (self.adjustX)
        adjustedX = 36;
    
    CGRect t = CGRectInset(self.bounds, 8, 8);
	t.origin.x += self.label.frame.size.width + adjustedX;
	t.size.width -= self.label.frame.size.width + 6;
	_toggler.frame = t;
}

@end
