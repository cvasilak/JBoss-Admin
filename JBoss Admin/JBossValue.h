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


