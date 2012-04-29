//
//  JBossValue.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBossValue.h"
#import "JSONKit.h"

@implementation NSNull (JBossValue)
- (NSString *)cellDisplay {
    return @"undefined";
}

- (BOOL)canBePlotted {
    return NO;
}
@end

@implementation NSNumber (JBossValue) 
- (NSString *)cellDisplay {
    if ([self isBoolean]) {
        return ([self boolValue] == YES? @"true":@"false");
    }

    return [self descriptionWithLocale:[NSLocale currentLocale]];
}

- (NSString *)cellDisplayMB {
    NSInteger mb = [self integerValue] / 1024 / 1024;
    
    return [NSString stringWithFormat:@"%d MB", mb];
}

- (NSString *)cellDisplayPercentFromTotal:(NSNumber *)total withMBConversion:(BOOL)mbconversion {
    NSInteger val = [self integerValue];
    NSInteger tot = [total integerValue];

    if (mbconversion) {
        val = val / 1024 / 1024;
        tot = tot / 1024 / 1024;
    }

    float percent = 0;
    if (tot != 0) // check for a malicious division by zero
        percent = ((float) val / tot) * 100;
    
    return [NSString stringWithFormat:(mbconversion?@"%d MB (%.0f%%)":@"%d (%.0f%%)"), val, percent];
}

- (BOOL)canBePlotted {
    if ([self isBoolean]) 
        return NO;
    
    return YES;
}

- (BOOL)isBoolean {
    // TODO: Determine how to correctly check if its a boolean value
    if ([[[self class] description] isEqualToString:@"__NSCFBoolean"] ||
        [[[self class] description] isEqualToString:@"NSCFBoolean"]) {
        return YES;
    }
    return NO;
}
@end

@implementation NSString (JBossValue)

- (NSString *)cellDisplay {
    return self;
}

- (NSString *)cellDisplayPercentFromTotal:(NSString *)total withMBConversion:(BOOL)mbconversion {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];

    NSNumber *me = [f numberFromString:self];
    NSNumber *other = [f numberFromString:total];
    
    return [me cellDisplayPercentFromTotal:other withMBConversion:mbconversion];
}

- (BOOL)canBePlotted {
    return NO;
}
@end

@implementation NSArray (JBossValue)
- (NSString *)cellDisplay {
   return [self JSONString];
}

- (BOOL)canBePlotted {
    return NO;
}

@end

@implementation NSDictionary (JBossValue)
- (NSString *)cellDisplay {
    return [self JSONString];
}

- (BOOL)canBePlotted {
    return NO;
}

@end


