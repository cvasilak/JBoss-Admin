//
//  JBAManagementModel.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <UIKit/UIKit.h>

//BIG_DECIMAL, BIG_INTEGER, BOOLEAN, BYTES, DOUBLE, INT, LIST, LONG, OBJECT, PROPERTY, STRING.
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

@end

@interface JBAOperationReply : JBAManagementModel

@end

@interface JBAOperation : JBAManagementModel

@property(strong, nonatomic) NSArray *path;  // the path of the resource that this operation resides

@property(strong, nonatomic) NSArray *parameters;

@property(strong, nonatomic) JBAOperationReply *reply;

@property(assign, nonatomic) BOOL isReadOnly;

@end


