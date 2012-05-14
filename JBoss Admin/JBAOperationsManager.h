//
//  JBAOperationsManager.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBAServer.h"
#import "AFHTTPClient.h"

@interface JBAOperationsManager : AFHTTPClient

// JMS types
typedef enum {
    QUEUE,
    TOPIC
} JMSType;

// Data Source types
typedef enum {
    StandardDataSource,
    XADataSource
} DataSourceType;

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

- (BOOL)isDomainController;

- (void)fetchJBossVersionWithSuccess:(void (^)(NSString *version))success
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


