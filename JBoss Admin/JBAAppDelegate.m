//
//  JBAAppDelegate.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright (c) 2011 forthnet S.A. All rights reserved.
//

#import "JBAAppDelegate.h"
#import "JBAServersViewController.h"

#import "Reachability.h"
#import "CommonUtil.h"

@implementation JBAAppDelegate

@synthesize window = _window;
@synthesize navController;
@synthesize reachability;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self checkInternetReachability];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    JBAServersViewController *serversViewController = [[JBAServersViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navController = [CommonUtil customizedNavigationController];
    [self.navController pushViewController:serversViewController animated:NO];
    
    [self.window addSubview:self.navController.view];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    DLog(@"applicationWillResignActive called");
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    DLog(@"applicationDidEnterBackground called");
    [self.reachability stopNotifier];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    DLog(@"applicationWillEnterForeground called");
    
    [self checkInternetReachability];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    DLog(@"applicationDidBecomeActive called");
}

- (void)applicationWillTerminate:(UIApplication *)application{
    DLog(@"applicationWillTerminate called");
    
    [self.reachability stopNotifier];
}

#pragma mark -
#pragma mark Reachability Support
-(void)checkInternetReachability {
    // Reachability initialization
    if (self.reachability == nil) {
        self.reachability = [Reachability reachabilityForInternetConnection];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:self.reachability];
    }
	
    if ([reachability currentReachabilityStatus] == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"connectivity is down, for proper operation this app requires an internet connection."
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    
	[reachability startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)obj {
	Reachability *r = (Reachability *)[obj object];
    
    if ([r currentReachabilityStatus] == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"connectivity is down, for proper operation this app requires an internet connection."
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
}

@end
