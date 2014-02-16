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

#import "LabelCell.h"

#define kNonEditableTextColor  [UIColor colorWithRed:.318 green:0.4 blue:.569 alpha:7.0]

@implementation LabelCell

@synthesize label = _label;
@synthesize adjustX;

- (id)initWithCellIdentifier:(NSString *)cellID {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID])) {
     
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentCenter;
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
