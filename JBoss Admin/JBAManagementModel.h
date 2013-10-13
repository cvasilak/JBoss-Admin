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

#import <UIKit/UIKit.h>

typedef enum {
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
} JBAType;


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


