//
//  Server.m
//  JBoss Admin
//
//  Created by Christos Vasilakis on 22/02/2012
//  Copyright 2012 All rights reserved.
//

#import "JBAServer.h"

@implementation JBAServer
@synthesize name;
@synthesize hostname;
@synthesize port;
@synthesize isSSLSecured;
@synthesize username;
@synthesize password;

-(void)dealloc {
    DLog(@"JBAServer dealloc");    
}

#pragma mark -
#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.name forKey:kServerNameKey];
	[aCoder encodeObject:self.hostname forKey:kServerHostnameKey];
   	[aCoder encodeObject:self.port forKey:kServerPortKey];
    [aCoder encodeBool:self.isSSLSecured forKey:kisSSLSecured];
	[aCoder encodeObject:self.username forKey:kServerUsernameKey];
	[aCoder encodeObject:self.password forKey:kServerPasswordKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		self.name = [aDecoder decodeObjectForKey:kServerNameKey];
		self.hostname = [aDecoder decodeObjectForKey:kServerHostnameKey];
   		self.port = [aDecoder decodeObjectForKey:kServerPortKey];
        self.isSSLSecured = [aDecoder decodeBoolForKey:kisSSLSecured];
		self.username = [aDecoder decodeObjectForKey:kServerUsernameKey];
		self.password = [aDecoder decodeObjectForKey:kServerPasswordKey];
	}
	
	return self;
}

- (NSString *)hostport {
    NSMutableString *hostport = [NSMutableString stringWithCapacity:100];
    
    if (isSSLSecured)
        [hostport appendString:@"https://"];
    else
        [hostport appendString:@"http://"];
    
    // adding the username/password in the URL 
    // allows NSURLConnection to auto authorize digest to
    // the server.
    // (RestKit doesn't support it yet as a conf parameter
    // and this is a handy workaround)
    if (username != nil && ![username isEqualToString:@""]) {
        [hostport appendFormat:@"%@:%@@", [username stringByURLEncoding], [password stringByURLEncoding] ];
    }

    [hostport appendFormat:@"%@:%@", hostname, port];

    return hostport;
}

@end
