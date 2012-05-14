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

#import "MetricInfoCell.h"

#define kNonEditableTextColor  [UIColor colorWithRed:.318 green:0.4 blue:.569 alpha:7.0]

@implementation MetricInfoCell

@synthesize metricNameLabel = _metricNameLabel;
@synthesize metricValueLabel = _metricValueLabel;

- (id)initWithCellIdentifier:(NSString *)cellID {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID])) {
       
        _metricNameLabel = [[UILabel alloc] init];
        _metricNameLabel.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin);

        _metricNameLabel.font = [UIFont boldSystemFontOfSize:12.0];
        _metricNameLabel.textAlignment = UITextAlignmentRight;
        _metricNameLabel.textColor = kNonEditableTextColor;
        _metricNameLabel.backgroundColor = [UIColor clearColor];

        [self.contentView addSubview:_metricNameLabel];
        
        _metricValueLabel = [[UILabel alloc] init];
        _metricValueLabel.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin);
        _metricValueLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _metricValueLabel.textAlignment = UITextAlignmentLeft;
        _metricValueLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:_metricValueLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize metricLabelSize = [_metricNameLabel.text sizeWithFont:_metricNameLabel.font];
    CGSize metricValueSize = [_metricValueLabel.text sizeWithFont:_metricValueLabel.font];

    self.metricNameLabel.frame = CGRectMake(10, 10, metricLabelSize.width+20, 25);
    self.metricValueLabel.frame = CGRectMake(metricLabelSize.width+20+20, 9, metricValueSize.width, 25);         
}

@end
