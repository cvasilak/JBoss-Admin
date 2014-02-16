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
