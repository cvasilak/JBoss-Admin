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

#import "JBAServersManager.h"
#import "JBAServer.h"

#import "NSFileManager+DirectoryLocations.h"

static JBAServersManager *SharedJBAServersManager = nil;

@interface JBAServersManager()

- (void)load;

@end

@implementation JBAServersManager {
    NSMutableArray *_list;
}

+ (JBAServersManager *)sharedJBAServersManager {
	if (SharedJBAServersManager == nil) {
		SharedJBAServersManager = [[super allocWithZone:NULL] init];
	}
	
	return SharedJBAServersManager;
}

-(id)init {
    [self load];
    
	return (self);
}

- (NSUInteger)count {
    return [_list count];
}

- (void)addServer:(JBAServer *)server {
    [_list addObject:server];
}

- (void)removeServerAtIndex:(NSUInteger)index {
    [_list removeObjectAtIndex:index];
}

- (JBAServer *)serverAtIndex:(NSUInteger)index {
    return [_list objectAtIndex:index];
}

-(NSString *)dataFilePath {
	NSString *appicationSuupportDirectory = [[NSFileManager defaultManager] applicationSupportDirectory];
	return [appicationSuupportDirectory stringByAppendingPathComponent:@"Servers.archive"];
}

- (void)load {
    NSString *filePath = [self dataFilePath];
    
    // if file exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        // load data
        NSData *data;
        NSKeyedUnarchiver *unarchiver;
        
        data = [[NSData alloc] initWithContentsOfFile:filePath];
        unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        _list = [unarchiver decodeObjectForKey:@"Servers"];
        
        [unarchiver finishDecoding];
 
    } else {
        // initialize an empty list
        _list = [[NSMutableArray alloc] init];
    }
}

// TODO: If there are no updates do not save  (Called in applicationWillTerminate at AccessJAppDelegate)
- (void)save {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_list forKey:@"Servers"];
    [archiver finishEncoding];
    
    [data writeToFile:[self dataFilePath] atomically:YES];
}

#pragma mark -
#pragma mark Singleton methods
+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedJBAServersManager];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)strong {
    return self;
}

- (NSUInteger)strongCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

@end
