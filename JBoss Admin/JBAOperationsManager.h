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
#import "JBAServer.h"
#import "AFHTTPClient.h"

@interface JBAOperationsManager : AFHTTPClient

typedef NS_ENUM(NSUInteger, ManagementVersion) {
    MANAGEMENT_VERSION_1 = 1,
    MANAGEMENT_VERSION_2
};

// JMS types
typedef NS_ENUM(NSUInteger, JMSType) {
    QUEUE,
    TOPIC
};

// Data Source types
typedef NS_ENUM(NSUInteger, DataSourceType) {
    StandardDataSource,
    XADataSource
};

+ (JBAOperationsManager *)sharedManager;

+ (JBAOperationsManager *)clientWithJBossServer:(JBAServer *)server;

- (id)initWithJBossServer:(JBAServer *)server;

- (void)postJBossRequestWithParams:(NSDictionary *)params
                           success:(void (^)(id result))success
                           failure:(void (^)(NSError *error))failure;

- (void)postJBossRequestWithParams:(NSDictionary *)params
                           success:(void (^)(id result))success
                           failure:(void (^)(NSError *error))failure 
                           process:(BOOL)process;

- (JBAServer *)server;

- (void)changeDomainServer:(NSString *)server belongingToHost:(NSString *)host;

- (NSString *)domainCurrentHost;

- (NSString *)domainCurrentServer;

- (ManagementVersion)managementVersion;

- (BOOL)isDomainController;

- (void)fetchJBossManagementVersionWithSuccess:(void (^)(NSNumber *version))success
                                andFailure:(void (^)(NSError *error))failure;

- (void)fetchLaunchTypeWithSuccess:(void (^)(NSString *launchType))success
                        andFailure:(void (^)(NSError *error))failure;

- (void)fetchDomainHostInfoWithSuccess:(void (^)(NSArray *hosts))success
                            andFailure:(void (^)(NSError *error))failure;

- (void)fetchDomainGroupInfoWithSuccess:(void (^)(NSMutableDictionary *groups))success
                             andFailure:(void (^)(NSError *error))failure;

- (void)fetchServersInfoForHostWithName:(NSString *)name
                              withSuccess:(void (^)(NSDictionary *servers))success
                               andFailure:(void (^)(NSError *error))failure;

- (void)changeStatusForServerWithName:(NSString *)name
                      belongingToHost:(NSString *)host
                             toStatus:(BOOL)status
                          withSuccess:(void (^)(NSString *status))success
                           andFailure:(void (^)(NSError *error))failure;

- (void)fetchDeploymentsFromServerGroup:(NSString *)group
                            withSuccess:(void (^)(NSMutableDictionary *deployments))success
                             andFailure:(void (^)(NSError *error))failure;

- (void)changeDeploymentStatusForDeploymentWithName:(NSString *)name
                             belongingToServerGroup:(NSString *)group
                                             enable:(BOOL)enable // YES(Deploy) / NO(Undeploy)
                                        withSuccess:(void (^)(void))success
                                         andFailure:(void (^)(NSError *error))failure;

- (void)removeDeploymentWithName:(NSString *)name
                belongingToGroup:(NSString *)group
                     withSuccess:(void (^)(void))success
                      andFailure:(void (^)(NSError *error))failure;

- (void)uploadFileWithName:(NSString *)filename
        withUploadProgress:(void (^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgress
               withSuccess:(void (^)(NSString *deploymentHash))success
                andFailure:(void (^)(NSError *error))failure;

// Step 2: Activate deployment (operation: add)
- (void)addDeploymentContentWithHash:(NSString *)deploymentHash
                                  andName:(NSString *)name
                           andRuntimeName:(NSString *)runtimeName
                              withSuccess:(void (^)(void))success
                               andFailure:(void (^)(NSError *error))failure;

- (void)addDeploymentContentWithHash:(NSString *)deploymentHash
                             andName:(NSString *)name
                      toServerGroups:(NSArray *)groups
                              enable:(BOOL) enable
                         withSuccess:(void (^)(void))success
                          andFailure:(void (^)(NSError *error))failure;
        
- (void)fetchJavaVMMetricsWithSuccess:(void (^)(NSDictionary *metrics))success
                           andFailure:(void (^)(NSError *error))failure;

- (void)fetchJMSMessagingModelListOfType:(JMSType)type
                             withSuccess:(void (^)(NSArray *list))success
                              andFailure:(void (^)(NSError *error))failure;

- (void)fetchJMSMetricsForName:(NSString *)name
                        ofType:(JMSType) type
                   withSuccess:(void (^)(NSDictionary *metrics))success
                    andFailure:(void (^)(NSError *error))failure;

- (void)fetchDataSourcesListWithSuccess:(void (^)(NSDictionary *list))success
                             andFailure:(void (^)(NSError *error))failure;

- (void)fetchDataSourceMetricsForName:(NSString *)name
                        ofType:(DataSourceType) type
                   withSuccess:(void (^)(NSDictionary *metrics))success
                    andFailure:(void (^)(NSError *error))failure;

- (void)fetchTransactionMetricsWithSuccess:(void (^)(NSDictionary *metrics))success
                                andFailure:(void (^)(NSError *error))failure;

- (void)fetchWebConnectorsListWithSuccess:(void (^)(NSArray *list))success
                               andFailure:(void (^)(NSError *error))failure;

- (void)fetchWebConnectorMetricsForName:(NSString *)name
                            withSuccess:(void (^)(NSDictionary *metrics))success
                             andFailure:(void (^)(NSError *error))failure;

- (void)fetchServerInfoWithSuccess:(void (^)(NSDictionary *info))success
                        andFailure:(void (^)(NSError *error))failure;

@end


