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

#import <Foundation/Foundation.h>
#import "NSString+URLEncode.h"

#define kServerNameKey          @"Name"
#define kServerHostnameKey      @"Hostname"
#define kServerPortKey          @"Port"
#define kisSSLSecured           @"isSSLSecured"
#define kServerUsernameKey      @"Username"
#define kServerPasswordKey      @"Password"

@interface JBAServer : NSObject <NSCoding> 
    
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *hostname;
@property (strong, nonatomic) NSString *port;
@property (nonatomic) BOOL isSSLSecured;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

- (NSString *)hostport;

@end
