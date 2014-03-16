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

#import "JBAOperationsManager.h"

#import "AFJSONRequestOperation.h"
#import "NSFileManager+DirectoryLocations.h"

static JBAOperationsManager *sharedManager;

@implementation JBAOperationsManager {
    BOOL _isDomainController;
    
    JBAServer *_server;
    
    NSString *_domainServer;
    NSString *_domainHost;
    
    NSNumber *_managementVersion;
}

+ (JBAOperationsManager *)sharedManager {
    return sharedManager;
}

+ (JBAOperationsManager *)clientWithJBossServer:(JBAServer *)server {
    if (sharedManager != nil)
        sharedManager = nil;
    
    sharedManager = [[JBAOperationsManager alloc] initWithJBossServer:server];
    
    return sharedManager;
}

- (JBAServer *)server {
    return _server;    
}

- (void)changeDomainServer:(NSString *)server belongingToHost:(NSString *)host {
    _isDomainController = YES;
    _domainServer = server;
    _domainHost = host;
}

- (BOOL)isDomainController {
    return _isDomainController;
}

- (NSString *)domainCurrentServer {
    return _domainServer;
}

- (NSString *)domainCurrentHost {
    return _domainHost;
}

- (ManagementVersion)managementVersion {
    return [_managementVersion unsignedIntValue];
}

- (id)initWithJBossServer:(JBAServer *)server{
    self = [super initWithBaseURL:[NSURL URLWithString:server.hostport]];
    
    if (!self) {
        return nil;
    }
    
    if (self) {
        _server = server;
        
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        [self.operationQueue setMaxConcurrentOperationCount:1];
        [self setParameterEncoding:AFJSONParameterEncoding];

        [self setDefaultHeader:@"Content-Type" value:@"application/json"];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
    }
    
    return self;
}

- (NSError *)createError:(id)obj {
    NSMutableString *errorMsg = [[NSMutableString alloc] init];
    
    // handle composite step error
    if ([obj isKindOfClass:[NSMutableDictionary class]]) {
        for (NSString *key in [obj allKeys]) {
            [errorMsg appendString:key]; // summary error
            [errorMsg appendString:@"\n"];            
            
            NSMutableDictionary *errSteps = obj[key];
            
            for (NSString *errStepKey in [errSteps allKeys]) {
                [errorMsg appendString:errStepKey];
                [errorMsg appendString:@"\n"];
                [errorMsg appendString:errSteps[errStepKey]];
                [errorMsg appendString:@"\n"];                
            }
        }
    } else {
        errorMsg = obj;
    }
    
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:errorMsg forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"jboss-admin" code:100 userInfo:errorDetail];
    
    return error;
}


// generic method to send a request to a remote jboss server
- (void)postJBossRequestWithParams:(NSDictionary *)params
                           success:(void (^)(id result))success
                           failure:(void (^)(NSError *error))failure {
    [self postJBossRequestWithParams:params success:success failure:failure process:YES];
}
   
- (void)postJBossRequestWithParams:(NSDictionary *)params
                           success:(void (^)(id result))success
                           failure:(void (^)(NSError *error))failure 
                           process:(BOOL)process {
    
    DLog(@"-------------->\n %@", [params description]);
    
    [self postPath:@"/management" parameters:params
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               
               DLog(@"<-------------\n %@", [JSON description]);
               
               if (JSON == nil) {
                   if (failure)
                       failure([self createError:@"Empty response received from server!"]);
                
                   return;
               }

               // check if its a valid JBoss JSON response 
               if (JSON[@"outcome"] == nil) { 
                   if (failure)
                       failure([self createError:@"Invalid response received from server!"]);
                   
                   return;
               }

                // do an initial process of JSON. Some methods require the full response
                // so by passing false we give them the full response
               if (process) {
                   if ([JSON[@"outcome"] isEqualToString:@"success"]) {
                       if (success)
                           success(JSON[@"result"]);
                   } else {
                       if (failure) {
                           id err = JSON[@"failure-description"];
                           
                           if ([err isKindOfClass:[NSMutableDictionary class]]) // handle domain errors
                               failure([self createError:err[@"domain-failure-description"]]);                                              
                           else
                               failure([self createError:err]);
                       }
                   }

               } else {
                   success(JSON);
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSError *err;
               DLog(@"%@", operation.response.allHeaderFields);
                    
               // handle the case where a non-jboss server is contacted  and response is not json
               // Error Domain=JKErrorDomain Code=-1 "Unexpected token, wanted '{', '}'
               if ([[error domain] isEqualToString:@"JKErrorDomain"] && [error code] == -1) {
                       err = [self createError:@"Invalid response received from server!"];
               } else {
                   err = error;
               }
               
               if (failure)
                   failure(err);
               
           }
     ];   
}

- (NSArray *)prefixAddressWithDomainServer:(NSArray *)address {
    if (_isDomainController) {
        NSMutableArray *convAddress = [[NSMutableArray alloc] init];
        
        [convAddress addObject:@"host"];
        [convAddress addObject:_domainHost];
        [convAddress addObject:@"server"];
        [convAddress addObject:_domainServer];
        
        [convAddress addObjectsFromArray:address];
        
        return convAddress;
    }
    
    return address;
}

- (NSArray *)prefixAddressWithDomainGroup:(NSString *)group address:(NSArray *)address {
    if (_isDomainController) {
        NSMutableArray *convAddress = [[NSMutableArray alloc] init];
        
        // group != nil user requested to see the deployments repository
        if (group != nil) {
            [convAddress addObject:@"server-group"];
            [convAddress addObject:group];
        }

        // if the address is the root don't append it
        if (![address[0] isEqualToString:@"/"])
            [convAddress addObjectsFromArray:address];
        
        return convAddress;
    }
    
    return address;
}



#pragma mark - JBoss Request Types
- (void)fetchJBossManagementVersionWithSuccess:(void (^)(NSNumber *version))success
                                andFailure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = 
        @{@"operation": @"read-attribute",
         @"name": @"management-major-version"};
    
    [self postJBossRequestWithParams:params
                             success:^(NSNumber *version) {
                                 _managementVersion = version;

                                 success(version);
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];
}

- (void)fetchLaunchTypeWithSuccess:(void (^)(NSString *launchType))success
                        andFailure:(void (^)(NSError *error))failure {

    NSDictionary *params = 
        @{@"operation": @"read-attribute",
         @"name": @"launch-type"};
    
    [self postJBossRequestWithParams:params
                             success:^(NSString *launchType) {
                                 success(launchType);
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];
}

- (void)fetchDomainHostInfoWithSuccess:(void (^)(NSArray *hosts))success
                            andFailure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = 
        @{@"operation": @"read-children-names",
         @"child-type": @"host"};

    [self postJBossRequestWithParams:params
                             success:^(NSArray *hosts) {
                                 success(hosts);
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];
}

- (void)fetchDomainGroupInfoWithSuccess:(void (^)(NSMutableDictionary *groups))success
                             andFailure:(void (^)(NSError *error))failure {
    NSDictionary *params = 
        @{@"operation": @"read-children-resources",
         @"child-type": @"server-group"};

    [self postJBossRequestWithParams:params
                             success:^(NSMutableDictionary *groups) {
                                 success(groups);
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];    
}


- (void)fetchServersInfoForHostWithName:(NSString *)name
                              withSuccess:(void (^)(NSDictionary *servers))success
                               andFailure:(void (^)(NSError *error))failure {

    NSDictionary *params = 
        @{@"operation": @"read-children-resources",
         @"address": @[@"host", name],     
         @"child-type": @"server-config",
         @"include-runtime": @YES};

    [self postJBossRequestWithParams:params
                             success:^(NSDictionary *servers) {
                                 success(servers);
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];    
}
- (void)changeStatusForServerWithName:(NSString *)name
                      belongingToHost:(NSString *)host
                             toStatus:(BOOL)status
                          withSuccess:(void (^)(NSString *status))success
                           andFailure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = 
        @{@"operation": (status ? @"start": @"stop"),
         @"address": @[@"host", host, @"server-config", name],
         @"blocking": @YES};
    
    [self postJBossRequestWithParams:params
                             success:^(NSString *result) {
                                 success(result);
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];
}

- (void)fetchDeploymentsFromServerGroup:(NSString *)group
                            withSuccess:(void (^)(NSMutableDictionary *deployments))success
                             andFailure:(void (^)(NSError *error))failure {

    
    NSDictionary *params = 
        @{@"operation": @"read-children-resources",
         @"address": [self prefixAddressWithDomainGroup:group address:@[@"/"]],
         @"child-type": @"deployment"};
    
    [self postJBossRequestWithParams:params
                             success:^(NSMutableDictionary *deployments) {
                                 success(deployments);
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];
}

- (void)changeDeploymentStatusForDeploymentWithName:(NSString *)name
                             belongingToServerGroup:(NSString *)group
                                             enable:(BOOL)enable
                                        withSuccess:(void (^)(void))success
                                         andFailure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = 
        @{@"operation": (enable ? @"deploy": @"undeploy"),
         @"address": [self prefixAddressWithDomainGroup:group address:@[@"deployment", name]]};
    
    [self postJBossRequestWithParams:params
                             success:^(id result) {
                                 success();
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];
}

- (void)removeDeploymentWithName:(NSString *)name
                belongingToGroup:(NSString *)group
                     withSuccess:(void (^)(void))success
                      andFailure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = 
        @{@"operation": @"remove",
         @"address": [self prefixAddressWithDomainGroup:group address:@[@"deployment", name]]};
    
    [self postJBossRequestWithParams:params
                             success:^(id result) {
                                 success();
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];  
}

/* Note: The content is just uploaded and jboss is informed of it
 *       that is, the deployment is NOT enabled by default
 *       (the same behaviour as the web console)
 */
- (void)uploadFileWithName:(NSString *)filename
        withUploadProgress:(void (^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))uploadProgress
               withSuccess:(void (^)(NSString *deploymentHash))success
                andFailure:(void (^)(NSError *error))failure {
    
    [self uploadFile:filename path:@"/management/add-content" mimeType:@"application/octet-stream" useMainQueueOnSuccess:YES useMainQueueOnFailure:YES
      uploadProgress:uploadProgress
          parameters:nil 
           success:^(AFHTTPRequestOperation *operation, id JSON) {
               if ([JSON[@"outcome"] isEqualToString:@"success"]) {
                   // inform client with content hash
                   success(JSON[@"result"][@"BYTES_VALUE"]);
               } else {
                   if (failure) {
                       if (_isDomainController)
                           failure([self createError:JSON[@"failure-description"][@"domain-failure-description"]]);                                              
                       else
                           failure([self createError:JSON[@"failure-description"]]);
                   }
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure)
                   failure(error);
           }
     ];
}

- (void)addDeploymentContentWithHash:(NSString *)deploymentHash
                             andName:(NSString *)name
                      andRuntimeName:(NSString *)runtimeName
                         withSuccess:(void (^)(void))success
                          andFailure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"operation"] = @"add";
    params[@"address"] = @[@"deployment", name];
    params[@"name"] = name;
    params[@"runtime-name"] = runtimeName;
    
    NSMutableDictionary *BYTES_VALUE = [NSMutableDictionary dictionary];
    BYTES_VALUE[@"BYTES_VALUE"] = deploymentHash;
    
    NSMutableDictionary *HASH = [NSMutableDictionary dictionary];
    HASH[@"hash"] = BYTES_VALUE;
    
    params[@"content"] = @[HASH];

    [self postJBossRequestWithParams:params
                             success:^(id result) {
                                 success();
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];  
}

- (void)addDeploymentContentWithHash:(NSString *)deploymentHash
                             andName:(NSString *)name
                      toServerGroups:(NSArray *)groups
                              enable:(BOOL) enable
                         withSuccess:(void (^)(void))success
                          andFailure:(void (^)(NSError *error))failure {
    
    // composite operation
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    for (NSString *group in groups) {
        NSMutableDictionary *groupParams;
        groupParams = [NSMutableDictionary dictionary];
        
        groupParams[@"operation"] = @"add";
        groupParams[@"address"] = [self prefixAddressWithDomainGroup:group address:@[@"deployment", name]];
        groupParams[@"name"] = name;
        //[params setObject:runtimeName forKey:@"runtime-name"];
        
        NSMutableDictionary *BYTES_VALUE = [NSMutableDictionary dictionary];
        BYTES_VALUE[@"BYTES_VALUE"] = deploymentHash;
        
        NSMutableDictionary *HASH = [NSMutableDictionary dictionary];
        HASH[@"hash"] = BYTES_VALUE;
        
        groupParams[@"content"] = @[HASH];
        
        [steps addObject:groupParams];
        
        if (enable) {
            NSDictionary *enableParams = @{@"operation": @"deploy",
                      @"address": [self prefixAddressWithDomainGroup:group address:@[@"deployment", name]]};
            
            [steps addObject:enableParams];
        }
    }
    
    NSDictionary *params =
        @{@"operation": @"composite",
         @"steps": steps};
    
    [self postJBossRequestWithParams:params
                             success:^(NSMutableDictionary *JSON) {
                                 success(); // TODO better handle step transaction fail
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];
}

- (void)fetchJavaVMMetricsWithSuccess:(void (^)(NSDictionary *metrics))success
                           andFailure:(void (^)(NSError *error))failure {

    NSDictionary *memoryParams =
        @{@"operation": @"read-resource",
         @"address": [self prefixAddressWithDomainServer:@[@"core-service", @"platform-mbean", @"type", @"memory"]],
         @"include-runtime": @YES};

    NSDictionary *threadingParams =
        @{@"operation": @"read-resource",
         @"address": [self prefixAddressWithDomainServer:@[@"core-service", @"platform-mbean", @"type", @"threading"]],
         @"include-runtime": @YES};

    NSDictionary *os =
        @{@"operation": @"read-resource",
         @"address": [self prefixAddressWithDomainServer:@[@"core-service", @"platform-mbean", @"type", @"operating-system"]],
         @"include-runtime": @YES};

    NSDictionary *params =
        @{@"operation": @"composite",
         @"steps": @[memoryParams, threadingParams, os]};

    [self postJBossRequestWithParams:params
                             success:^(NSMutableDictionary *JSON) {
                                 NSMutableDictionary *metrics = [NSMutableDictionary dictionary];
                                 
                                 metrics[@"memory"] = JSON[@"step-1"][@"result"];
                                 metrics[@"threading"] = JSON[@"step-2"][@"result"];
                                 metrics[@"os"] = JSON[@"step-3"][@"result"];

                                 success(metrics);
                                 
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];
}

- (void)fetchJMSMessagingModelListOfType:(JMSType)type
                             withSuccess:(void (^)(NSArray *list))success
                              andFailure:(void (^)(NSError *error))failure {

    NSDictionary *params = 
        @{@"operation": @"read-children-names",
         @"child-type": (type == QUEUE? @"jms-queue": @"jms-topic"),
         @"address": [self prefixAddressWithDomainServer:@[@"subsystem", @"messaging",
          @"hornetq-server", @"default"]]};
    
    [self postJBossRequestWithParams:params
                             success:^(NSMutableArray *list) {
                                 success(list);
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];    
}

- (void)fetchJMSMetricsForName:(NSString *)name
                        ofType:(JMSType) type
                   withSuccess:(void (^)(NSDictionary *metrics))success
                    andFailure:(void (^)(NSError *error))failure {

    NSDictionary *params = 
        @{@"operation": @"read-resource",
         @"address": [self prefixAddressWithDomainServer:@[@"subsystem", @"messaging",
          @"hornetq-server", @"default",
          (type == QUEUE? @"jms-queue": @"jms-topic"),
          name]],
         @"include-runtime": @YES};                            
    
    [self postJBossRequestWithParams:params
                             success:^(NSMutableDictionary *metrics) {
                                 success(metrics);
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];     
}

- (void)fetchDataSourcesListWithSuccess:(void (^)(NSDictionary *list))success
                             andFailure:(void (^)(NSError *error))failure {

    NSDictionary *datasources =
        @{@"operation": @"read-children-resources",
         @"address": [self prefixAddressWithDomainServer:@[@"subsystem", @"datasources"]],
         @"child-type": @"data-source"};
    
    NSDictionary *xadatasources =
        @{@"operation": @"read-children-resources",
         @"address": [self prefixAddressWithDomainServer:@[@"subsystem", @"datasources"]],
         @"child-type": @"xa-data-source"};
    
    NSDictionary *params =
        @{@"operation": @"composite",
         @"steps": @[datasources, xadatasources]};
    
    [self postJBossRequestWithParams:params
                             success:^(NSDictionary *JSON) {
                                 NSMutableDictionary *list = [NSMutableDictionary dictionary];

                                 [list addEntriesFromDictionary:JSON[@"step-1"][@"result"]];
                                 [list addEntriesFromDictionary:JSON[@"step-2"][@"result"]];
                                 
                                 success(list);
                                 
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];    
}

- (void)fetchDataSourceMetricsForName:(NSString *)name
                               ofType:(DataSourceType) type
                          withSuccess:(void (^)(NSDictionary *metrics))success
                           andFailure:(void (^)(NSError *error))failure {

    NSDictionary *pool =
        @{@"operation": @"read-resource",
         @"address": [self prefixAddressWithDomainServer:@[@"subsystem", @"datasources",
          (type == XADataSource? @"xa-data-source": @"data-source"),
          name,
          @"statistics", @"pool"]],
         @"include-runtime": @YES};

    NSDictionary *jdbc =
        @{@"operation": @"read-resource",
         @"address": [self prefixAddressWithDomainServer:@[@"subsystem", @"datasources",
          (type == XADataSource? @"xa-data-source": @"data-source"),
          name,
          @"statistics", @"jdbc"]],
         @"include-runtime": @YES};

    NSDictionary *params =
        @{@"operation": @"composite",
         @"steps": @[pool, jdbc]};
    
    [self postJBossRequestWithParams:params
                             success:^(NSDictionary *JSON) {
                                 NSMutableDictionary *metrics = [NSMutableDictionary dictionary];
                                 
                                 [metrics addEntriesFromDictionary:JSON[@"step-1"][@"result"]];
                                 [metrics addEntriesFromDictionary:JSON[@"step-2"][@"result"]];
                                 
                                 success(metrics);
                                 
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];      
}

- (void)fetchTransactionMetricsWithSuccess:(void (^)(NSDictionary *metrics))success
                                andFailure:(void (^)(NSError *error))failure {
    NSDictionary *params =
        @{@"operation": @"read-resource",
         @"address": [self prefixAddressWithDomainServer:@[@"subsystem", @"transactions"]],
         @"include-runtime": @YES};                            
    
    [self postJBossRequestWithParams:params
                             success:^(NSDictionary *metrics) {
                                 success(metrics);
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];
}

- (void)fetchWebConnectorsListWithSuccess:(void (^)(NSArray *list))success
                               andFailure:(void (^)(NSError *error))failure {

    NSDictionary *params =
        @{@"operation": @"read-children-names",
         @"address": [self prefixAddressWithDomainServer:@[@"subsystem", @"web"]], 
         @"child-type": @"connector"};
    
    [self postJBossRequestWithParams:params
                             success:^(NSMutableArray *list) {
                                 success(list);
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];  
}

- (void)fetchWebConnectorMetricsForName:(NSString *)name
                            withSuccess:(void (^)(NSDictionary *metrics))success
                             andFailure:(void (^)(NSError *error))failure {

    NSDictionary *params = 
        @{@"operation": @"read-resource",
         @"address": [self prefixAddressWithDomainServer:@[@"subsystem", @"web", @"connector", name]],
         @"include-runtime": @YES};                            
    
    [self postJBossRequestWithParams:params
                             success:^(NSMutableDictionary *metrics) {
                                 success(metrics);
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];
}

- (void)fetchServerInfoWithSuccess:(void (^)(NSDictionary *info))success
                        andFailure:(void (^)(NSError *error))failure {

    NSDictionary *serverinfo = 
        @{@"operation": @"read-resource",
            @"address": [self prefixAddressWithDomainServer:@[@"/"]],
            @"include-runtime": @YES};                            

    NSDictionary *extensions = 
        @{@"operation": @"read-children-names",
         @"address": [self prefixAddressWithDomainServer:@[@"/"]],         
         @"child-type": @"extension"};

    NSDictionary *properties = 
        @{@"operation": @"read-attribute",
         @"address": [self prefixAddressWithDomainServer:@[@"core-service", @"platform-mbean", @"type", @"runtime"]],         
         @"name": @"system-properties"};

    NSDictionary *params =
        @{@"operation": @"composite",
         @"steps": @[serverinfo, extensions, properties]};

 
    [self postJBossRequestWithParams:params
                             success:^(NSMutableDictionary *JSON) {
                                 NSMutableDictionary *info = [NSMutableDictionary dictionary];
                                 
                                 info[@"server-info"] = JSON[@"step-1"][@"result"];
                                 info[@"extensions"] = JSON[@"step-2"][@"result"];
                                 info[@"properties"] = JSON[@"step-3"][@"result"];                                 
                                 
                                 success(info);

                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];
    
}

@end