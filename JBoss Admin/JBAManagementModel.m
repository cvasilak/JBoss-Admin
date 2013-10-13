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

#import "JBAManagementModel.h"

@implementation JBAManagementModel

@synthesize name;
@synthesize descr;
@synthesize type;
@synthesize valueType;

-(void)dealloc {
    DLog(@"JBAManagementModel dealloc");    
}

- (NSString  *) typeAsString {
    return [JBAManagementModel stringFromType:self.type];
}

- (NSString  *) valueTypeAsString {
    return [JBAManagementModel stringFromType:self.valueType];
}

+ (NSString  *) stringFromType:(JBAType) type {
    switch (type) {
        case STRING:
            return @"String";
            break;
        case INT:
            return @"Int";
            break;
        case LONG:            
            return @"Long";
            break;
        case BIG_DECIMAL:
            return @"Big Decimal";
            break;
        case BIG_INTEGER:
            return @"Big Integer";
            break;
        case DOUBLE:
            return @"Double";
            break;
        case BOOLEAN:
            return @"Boolean";
            break;
        case PROPERTY:
            return @"Property";
            break;            
        case OBJECT:
            return @"Object";
            break;
        case BYTES:
            return @"Bytes";
            break;
        case LIST:
            return @"List";
            break;
        default:
            return nil;
    }
}

+ (JBAType) typeFromString:(NSString *)type {
    if ([type isEqualToString:@"STRING"])
        return STRING;
    else if ([type isEqualToString:@"INT"]) 
        return INT;
    else if ([type isEqualToString:@"LONG"])
        return LONG;
    else if ([type isEqualToString:@"BIG_DECIMAL"])
        return BIG_DECIMAL;
    else if ([type isEqualToString:@"BIG_INTEGER"])
        return BIG_INTEGER;
    else if ([type isEqualToString:@"DOUBLE"])
        return DOUBLE;
    else if ([type isEqualToString:@"BOOLEAN"])
        return BOOLEAN;
    else if ([type isEqualToString:@"PROPERTY"])
        return PROPERTY;
    else if ([type isEqualToString:@"OBJECT"])
        return OBJECT;
    else if ([type isEqualToString:@"BYTES"])
        return BYTES;
    else if ([type isEqualToString:@"LIST"])
        return LIST;
    
    return UNDEFINED;
}

// sort by name
- (NSComparisonResult)compare:(JBAAttribute *)otherObject {
    return [self.name compare:otherObject.name];
}

@end

@implementation JBAAttribute

@synthesize path;
@synthesize value;
@synthesize isReadOnly;

@end

@implementation JBAChildType

@synthesize value;

@end


@implementation JBAOperationParameter

@synthesize nillable;
@synthesize required;
@synthesize value;
@synthesize defaultValue;
@synthesize isAddParameter;

// sort by required parameter
- (NSComparisonResult)compareRequired:(JBAOperationParameter *)otherObject {
    if (self.required && !otherObject.required)
        return (NSComparisonResult)NSOrderedAscending;
    else if (!self.required && otherObject.required)
        return (NSComparisonResult)NSOrderedDescending;
    
    return (NSComparisonResult)NSOrderedSame;
}

@end

@implementation JBAOperationReply 

@end

@implementation JBAOperation

@synthesize path;
@synthesize parameters;
@synthesize reply;
@synthesize isReadOnly;

@end

