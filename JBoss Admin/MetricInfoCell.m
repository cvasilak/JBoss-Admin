//
//  MetricInfoCell.m
//  JBoss Admin
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

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
