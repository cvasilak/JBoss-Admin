//
//  JBAServersManager.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

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
