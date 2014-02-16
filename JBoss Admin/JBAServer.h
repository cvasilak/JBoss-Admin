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
