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

    CGFloat adjustedX = 10;
    
	if (self.adjustX)
        adjustedX = 36;
    
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
	t.size.width = [title sizeWithAttributes:@{NSFontAttributeName: _button.titleLabel.font}].width + 20;
    _button.frame = t;    
}
@end
