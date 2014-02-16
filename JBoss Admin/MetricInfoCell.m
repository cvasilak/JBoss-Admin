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

#import "MetricInfoCell.h"

#define kNonEditableTextColor  [UIColor colorWithRed:.318 green:0.4 blue:.569 alpha:7.0]

@implementation MetricInfoCell

@synthesize metricNameLabel = _metricNameLabel;
@synthesize metricValueLabel = _metricValueLabel;
@synthesize maxNameWidth = _maxNameWidth;

- (id)initWithCellIdentifier:(NSString *)cellID {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID])) {
       
        _metricNameLabel = [[UILabel alloc] init];
        _metricNameLabel.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin);
        
        _metricNameLabel.font = [UIFont boldSystemFontOfSize:12.0];
        _metricNameLabel.adjustsFontSizeToFitWidth = YES;
        _metricNameLabel.minimumScaleFactor = 8;
        _metricNameLabel.textAlignment = NSTextAlignmentRight;
        _metricNameLabel.textColor = kNonEditableTextColor;
        _metricNameLabel.backgroundColor = [UIColor clearColor];

        [self.contentView addSubview:_metricNameLabel];
        
        _metricValueLabel = [[UILabel alloc] init];
        _metricValueLabel.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin);
        _metricValueLabel.font = [UIFont boldSystemFontOfSize:14.0];
        _metricNameLabel.adjustsFontSizeToFitWidth = YES;
        _metricNameLabel.minimumScaleFactor = 8;
        _metricValueLabel.textAlignment = NSTextAlignmentLeft;
        _metricValueLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:_metricValueLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _maxNameWidth = 90;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGSize metricValueSize = [_metricValueLabel.text sizeWithFont:_metricValueLabel.font];

    self.metricNameLabel.frame = CGRectMake(10, 10, self.maxNameWidth, 25);
    self.metricValueLabel.frame = CGRectMake(self.maxNameWidth+20, 9, metricValueSize.width, 25);

}

@end
