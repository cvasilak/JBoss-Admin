//
//  JBAAppDelegate.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright (c) 2011 forthnet S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reachability;

@interface JBAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) Reachability *reachability;
@end
