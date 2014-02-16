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
	NSString *appicationSupportDirectory = [[NSFileManager defaultManager] applicationSupportDirectory];
	return [appicationSupportDirectory stringByAppendingPathComponent:@"Servers.archive"];
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

// TODO: If there are no updates do not save  (Called in applicationWillTerminate at JBAAppDelegate)
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
