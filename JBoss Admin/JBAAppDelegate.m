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

#import "JBAAppDelegate.h"
#import "JBAServersViewController.h"

#import "Reachability.h"
#import "CommonUtil.h"

@interface JBAAppDelegate()

-(void)checkInternetReachability;

@end

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
