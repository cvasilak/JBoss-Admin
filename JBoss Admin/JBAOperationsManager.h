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


