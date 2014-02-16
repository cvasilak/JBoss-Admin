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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JBAType) {
    STRING,
    INT,
    LONG,
    BIG_DECIMAL,
    BIG_INTEGER,
    DOUBLE,
    BOOLEAN,
    PROPERTY,
    OBJECT,
    BYTES,
    LIST,
    UNDEFINED
};

@interface JBAManagementModel : NSObject

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *descr;

@property(assign, nonatomic) JBAType type;
@property(assign, nonatomic) JBAType valueType;

- (NSString *) typeAsString;

+ (NSString *) stringFromType:(JBAType) type;
+ (JBAType) typeFromString:(NSString *)type;

- (NSComparisonResult)compare:(JBAManagementModel *)otherObject;

@end

@interface JBAAttribute : JBAManagementModel

@property(strong, nonatomic) NSArray *path;  // the path of the resource that this node resides

@property(strong, nonatomic) id value;

@property(assign, nonatomic) BOOL isReadOnly;

@end

@interface JBAChildType : JBAManagementModel

@property(strong, nonatomic) id value;

@end

@interface JBAOperationParameter : JBAManagementModel

@property(assign, nonatomic) BOOL nillable;
@property(assign, nonatomic) BOOL required;

@property(strong, nonatomic) id value;
@property(strong, nonatomic) id defaultValue;

// if the operation is add, a fake parameter is added to the list
// so that the user can edit the resource path. 
// This flag denotes that so the save handler
// will use it to add on resource path and not on the 
// parameter list
@property(assign, nonatomic) BOOL isAddParameter;

- (NSComparisonResult)compareRequired:(JBAOperationParameter *)otherObject;

@end

@interface JBAOperationReply : JBAManagementModel

@end

@interface JBAOperation : JBAManagementModel

@property(strong, nonatomic) NSArray *path;  // the path of the resource that this operation resides

@property(strong, nonatomic) NSArray *parameters;

@property(strong, nonatomic) JBAOperationReply *reply;

@property(assign, nonatomic) BOOL isReadOnly;

@end


