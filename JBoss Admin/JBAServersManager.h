//
//  JBAServersManager.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <Foundation/Foundation.h>

@class JBAServer;

@interface JBAServersManager : NSObject

- (NSUInteger)count;

- (void)addServer:(JBAServer *)server;
- (void)removeServerAtIndex:(NSUInteger)index;

- (JBAServer *)serverAtIndex:(NSUInteger)index;

//- (void)load;
- (void)save;

+ (JBAServersManager *)sharedJBAServersManager;
@end
