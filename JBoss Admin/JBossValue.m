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
    long mb = [self longValue] / 1024 / 1024;
    
    return [NSString stringWithFormat:@"%ld MB", mb];
}

- (NSString *)cellDisplayPercentFromTotal:(NSNumber *)total withMBConversion:(BOOL)mbconversion {
    long val = [self longValue];
    long tot = [total longValue];

    if (mbconversion) {
        val = val / 1024 / 1024;
        tot = tot / 1024 / 1024;
    }

    float percent = 0;
    if (tot != 0) // check for a malicious division by zero
        percent = ((float) val / tot) * 100;
    
    return [NSString stringWithFormat:(mbconversion?@"%ld MB (%.0f%%)":@"%ld (%.0f%%)"), val, percent];
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


