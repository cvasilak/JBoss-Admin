//
//  Server.h
//  JBoss Admin
//  
//  Created by Christos Vasilakis on 22/02/2012
//  Copyright 2012 All rights reserved.
//

#import <Foundation/Foundation.h>

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
