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
