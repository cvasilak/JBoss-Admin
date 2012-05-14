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
        [hostport appendFormat:@"%@:%@@", username, password];
    }

    [hostport appendFormat:@"%@:%@", hostname, port];

    return hostport;
}

@end
