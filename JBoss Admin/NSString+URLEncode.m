//
//  NSString+URLEncode.m
//  JBoss Admin
//
//  Created by Darrin Mison on 19/07/13.
//
//  Copyright (c) 2013 forthnet S.A. All rights reserved.
//

#import "NSString+URLEncode.h"

@implementation NSString (URLEncode)


-(NSString*)stringByURLEncoding
{
    return (NSString*)CFBridgingRelease(
                            CFURLCreateStringByAddingPercentEscapes(
                                kCFAllocatorDefault,
                                (CFStringRef)self,
                                NULL,
                                CFSTR(":/?#[]@!$&'()*+,;="),
                                kCFStringEncodingUTF8
                            )
                        );
}



@end
