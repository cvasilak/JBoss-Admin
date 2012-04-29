//
//  JBossValue.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JBossValue
- (NSString *)cellDisplay;
- (BOOL)canBePlotted;
@end

@interface NSNull (JBossValue) <JBossValue>
- (NSString *)cellDisplay;
- (BOOL)canBePlotted;
@end

@interface NSNumber (JBossValue) <JBossValue>
- (NSString *)cellDisplay;
- (NSString *)cellDisplayMB;
- (NSString *)cellDisplayPercentFromTotal:(NSNumber *)total withMBConversion:(BOOL)mbconversion;
- (BOOL)canBePlotted;
- (BOOL)isBoolean;
@end

@interface NSString (JBossValue) <JBossValue>
- (NSString *)cellDisplay;
- (NSString *)cellDisplayPercentFromTotal:(NSNumber *)total withMBConversion:(BOOL)mbconversion;
- (BOOL)canBePlotted;
@end

@interface NSArray (JBossValue) <JBossValue>
- (NSString *)cellDisplay;
- (BOOL)canBePlotted;
@end

@interface NSDictionary (JBossValue) <JBossValue>
- (NSString *)cellDisplay;
- (BOOL)canBePlotted;
@end


