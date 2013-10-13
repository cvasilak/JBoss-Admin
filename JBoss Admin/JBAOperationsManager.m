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

#import "JBAOperationsManager.h"

#import "AFJSONRequestOperation.h"
#import "NSFileManager+DirectoryLocations.h"

static JBAOperationsManager *sharedManager;

@implementation JBAOperationsManager {
    BOOL _isDomainController;
    
    JBAServer *_server;
    
    NSString *_domainServer;
    NSString *_domainHost;
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
            
            NSMutableDictionary *errSteps = [obj objectForKey:key];
            
            for (NSString *errStepKey in [errSteps allKeys]) {
                [errorMsg appendString:errStepKey];
                [errorMsg appendString:@"\n"];
                [errorMsg appendString:[errSteps objectForKey:errStepKey]];
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
               if ([JSON objectForKey:@"outcome"] == nil) { 
                   if (failure)
                       failure([self createError:@"Invalid response received from server!"]);
                   
                   return;
               }

                // do an initial process of JSON. Some methods require the full response
                // so by passing false we give them the full response
               if (process) {
                   if ([[JSON objectForKey:@"outcome"] isEqualToString:@"success"]) {
                       if (success)
                           success([JSON objectForKey:@"result"]);
                   } else {
                       if (failure) {
                           id err = [JSON objectForKey:@"failure-description"];
                           
                           if ([err isKindOfClass:[NSMutableDictionary class]]) // handle domain errors
                               failure([self createError:[err objectForKey:@"domain-failure-description"]]);                                              
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
        if (![[address objectAtIndex:0] isEqualToString:@"/"])
            [convAddress addObjectsFromArray:address];
        
        return convAddress;
    }
    
    return address;
}



#pragma mark - JBoss Request Types
- (void)fetchJBossVersionWithSuccess:(void (^)(NSString *version))success
                                andFailure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-attribute", @"operation",
         @"release-version", @"name", nil];
    
    [self postJBossRequestWithParams:params
                             success:^(NSString *version) {
                                 success(version);
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];
}

- (void)fetchLaunchTypeWithSuccess:(void (^)(NSString *launchType))success
                        andFailure:(void (^)(NSError *error))failure {

    NSDictionary *params = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-attribute", @"operation",
         @"launch-type", @"name", nil];
    
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
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-children-names", @"operation",
         @"host", @"child-type", nil];

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
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-children-resources", @"operation",
         @"server-group", @"child-type", nil];

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
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-children-resources", @"operation",
         [NSArray arrayWithObjects:@"host", name, nil], @"address",     
         @"server-config", @"child-type",
         [NSNumber numberWithBool:YES], @"include-runtime", nil];

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
        [NSDictionary dictionaryWithObjectsAndKeys:
         (status ? @"start": @"stop"), @"operation",
         [NSArray arrayWithObjects:@"host", host, @"server-config", name, nil], @"address",
         [NSNumber numberWithBool:YES], @"blocking", nil];
    
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
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-children-resources", @"operation",
         [self prefixAddressWithDomainGroup:group address:[NSArray arrayWithObject:@"/"]], @"address",
         @"deployment", @"child-type", nil];
    
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
        [NSDictionary dictionaryWithObjectsAndKeys:
         (enable ? @"deploy": @"undeploy"), @"operation",
         [self prefixAddressWithDomainGroup:group address:[NSArray arrayWithObjects:@"deployment", name, nil]], @"address", nil];
    
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
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"remove", @"operation",
         [self prefixAddressWithDomainGroup:group address:[NSArray arrayWithObjects:@"deployment", name, nil]], @"address", nil];
    
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
               if ([[JSON objectForKey:@"outcome"] isEqualToString:@"success"]) {
                   // inform client with content hash
                   success([[JSON objectForKey:@"result"] objectForKey:@"BYTES_VALUE"]);
               } else {
                   if (failure) {
                       if (_isDomainController)
                           failure([self createError:[[JSON objectForKey:@"failure-description"] objectForKey:@"domain-failure-description"]]);                                              
                       else
                           failure([self createError:[JSON objectForKey:@"failure-description"]]);
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
    
    [params setObject:@"add" forKey:@"operation"];
    [params setObject:[NSArray arrayWithObjects:@"deployment", name, nil] forKey:@"address"];
    [params setObject:name forKey:@"name"];
    [params setObject:runtimeName forKey:@"runtime-name"];
    
    NSMutableDictionary *BYTES_VALUE = [NSMutableDictionary dictionary];
    [BYTES_VALUE setObject:deploymentHash forKey:@"BYTES_VALUE"];
    
    NSMutableDictionary *HASH = [NSMutableDictionary dictionary];
    [HASH setObject:BYTES_VALUE forKey:@"hash"];
    
    [params setObject:[NSArray arrayWithObjects:HASH, nil] forKey:@"content"];

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
        
        [groupParams setObject:@"add" forKey:@"operation"];
        [groupParams setObject:[self prefixAddressWithDomainGroup:group address:[NSArray arrayWithObjects:@"deployment", name, nil]] forKey:@"address"];
        [groupParams setObject:name forKey:@"name"];
        //[params setObject:runtimeName forKey:@"runtime-name"];
        
        NSMutableDictionary *BYTES_VALUE = [NSMutableDictionary dictionary];
        [BYTES_VALUE setObject:deploymentHash forKey:@"BYTES_VALUE"];
        
        NSMutableDictionary *HASH = [NSMutableDictionary dictionary];
        [HASH setObject:BYTES_VALUE forKey:@"hash"];
        
        [groupParams setObject:[NSArray arrayWithObjects:HASH, nil] forKey:@"content"];
        
        [steps addObject:groupParams];
        
        if (enable) {
            NSDictionary *enableParams = [NSDictionary dictionaryWithObjectsAndKeys:
                      @"deploy", @"operation",
                      [self prefixAddressWithDomainGroup:group address:[NSArray arrayWithObjects:@"deployment", name, nil]], @"address", nil];
            
            [steps addObject:enableParams];
        }
    }
    
    NSDictionary *params =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"composite", @"operation",
         steps, @"steps", nil];
    
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
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-resource", @"operation",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"core-service", @"platform-mbean", @"type", @"memory", nil]], @"address",
         [NSNumber numberWithBool:YES], @"include-runtime", nil];

    NSDictionary *threadingParams =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-resource", @"operation",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"core-service", @"platform-mbean", @"type", @"threading", nil]], @"address",
         [NSNumber numberWithBool:YES], @"include-runtime", nil];

    NSDictionary *os =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-resource", @"operation",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"core-service", @"platform-mbean", @"type", @"operating-system", nil]], @"address",
         [NSNumber numberWithBool:YES], @"include-runtime", nil];

    NSDictionary *params =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"composite", @"operation",
         [NSArray arrayWithObjects:memoryParams, threadingParams, os, nil], @"steps", nil];

    [self postJBossRequestWithParams:params
                             success:^(NSMutableDictionary *JSON) {
                                 NSMutableDictionary *metrics = [NSMutableDictionary dictionary];
                                 
                                 [metrics setObject:[[JSON objectForKey:@"step-1"] objectForKey:@"result"] forKey:@"memory"];
                                 [metrics setObject:[[JSON objectForKey:@"step-2"] objectForKey:@"result"] forKey:@"threading"];
                                 [metrics setObject:[[JSON objectForKey:@"step-3"] objectForKey:@"result"] forKey:@"os"];

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
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-children-names", @"operation",
         (type == QUEUE? @"jms-queue": @"jms-topic"), @"child-type",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"subsystem", @"messaging",
          @"hornetq-server", @"default", nil]], @"address", nil];
    
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
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-resource", @"operation",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"subsystem", @"messaging",
          @"hornetq-server", @"default",
          (type == QUEUE? @"jms-queue": @"jms-topic"),
          name, nil]], @"address",
         [NSNumber numberWithBool:YES], @"include-runtime",nil];                            
    
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
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-children-resources", @"operation",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"subsystem", @"datasources", nil]], @"address",
         @"data-source", @"child-type", nil];
    
    NSDictionary *xadatasources =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-children-resources", @"operation",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"subsystem", @"datasources", nil]], @"address",
         @"xa-data-source", @"child-type", nil];
    
    NSDictionary *params =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"composite", @"operation",
         [NSArray arrayWithObjects:datasources, xadatasources, nil], @"steps",
         nil];
    
    [self postJBossRequestWithParams:params
                             success:^(NSDictionary *JSON) {
                                 NSMutableDictionary *list = [NSMutableDictionary dictionary];

                                 [list addEntriesFromDictionary:[[JSON objectForKey:@"step-1"] objectForKey:@"result"]];
                                 [list addEntriesFromDictionary:[[JSON objectForKey:@"step-2"] objectForKey:@"result"]];
                                 
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
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-resource", @"operation",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"subsystem", @"datasources",
          (type == XADataSource? @"xa-data-source": @"data-source"),
          name,
          @"statistics", @"pool", nil]], @"address",
         [NSNumber numberWithBool:YES], @"include-runtime", nil];

    NSDictionary *jdbc =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-resource", @"operation",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"subsystem", @"datasources",
          (type == XADataSource? @"xa-data-source": @"data-source"),
          name,
          @"statistics", @"jdbc", nil]], @"address",
         [NSNumber numberWithBool:YES], @"include-runtime", nil];

    NSDictionary *params =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"composite", @"operation",
         [NSArray arrayWithObjects:pool, jdbc, nil], @"steps", nil];
    
    [self postJBossRequestWithParams:params
                             success:^(NSDictionary *JSON) {
                                 NSMutableDictionary *metrics = [NSMutableDictionary dictionary];
                                 
                                 [metrics addEntriesFromDictionary:[[JSON objectForKey:@"step-1"] objectForKey:@"result"]];
                                 [metrics addEntriesFromDictionary:[[JSON objectForKey:@"step-2"] objectForKey:@"result"]];
                                 
                                 success(metrics);
                                 
                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];      
}

- (void)fetchTransactionMetricsWithSuccess:(void (^)(NSDictionary *metrics))success
                                andFailure:(void (^)(NSError *error))failure {
    NSDictionary *params =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-resource", @"operation",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"subsystem", @"transactions", nil]], @"address",
         [NSNumber numberWithBool:YES], @"include-runtime",nil];                            
    
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
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-children-names", @"operation",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"subsystem", @"web", nil]], @"address", 
         @"connector", @"child-type",nil];
    
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
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-resource", @"operation",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"subsystem", @"web", @"connector", name, nil]]
         , @"address",
         [NSNumber numberWithBool:YES], @"include-runtime", nil];                            
    
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
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"read-resource", @"operation",
            [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"/", nil]], @"address",
            [NSNumber numberWithBool:YES], @"include-runtime", nil];                            

    NSDictionary *extensions = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-children-names", @"operation",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"/", nil]], @"address",         
         @"extension", @"child-type", nil];

    NSDictionary *properties = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"read-attribute", @"operation",
         [self prefixAddressWithDomainServer:[NSArray arrayWithObjects:@"core-service", @"platform-mbean", @"type", @"runtime", nil]], @"address",         
         @"system-properties", @"name", nil];

    NSDictionary *params =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"composite", @"operation",
         [NSArray arrayWithObjects:serverinfo, extensions, properties, nil], @"steps", nil];

 
    [self postJBossRequestWithParams:params
                             success:^(NSMutableDictionary *JSON) {
                                 NSMutableDictionary *info = [NSMutableDictionary dictionary];
                                 
                                 [info setObject:[[JSON objectForKey:@"step-1"] objectForKey:@"result"] forKey:@"server-info"];
                                 [info setObject:[[JSON objectForKey:@"step-2"] objectForKey:@"result"] forKey:@"extensions"];
                                 [info setObject:[[JSON objectForKey:@"step-3"] objectForKey:@"result"] forKey:@"properties"];                                 
                                 
                                 success(info);

                             } failure:^(NSError *error) {
                                 failure(error);
                             }
     ];
    
}

@end