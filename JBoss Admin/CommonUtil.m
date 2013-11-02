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

#import "CommonUtil.h"

#define LESS_THAN_IOS_7 floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1

@implementation CommonUtil

+ (UINavigationController *)customizedNavigationController {
    UINavigationController *navController = [[UINavigationController alloc] initWithNibName:nil bundle:nil];

    UINavigationBar *navBar = [navController navigationBar];

    // TODO remove once iOS 6 fades out of existence
    if (LESS_THAN_IOS_7) {
        [navBar setTintColor:[UIColor colorWithRed:0.26f green:0.36f blue:0.46 alpha:0.8]];
        [navBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar-bg-44px.png"] forBarMetrics:UIBarMetricsDefault];
    } else {
        [navBar setTintColor:[UIColor whiteColor]];
        [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [navBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar-bg.png"] forBarMetrics:UIBarMetricsDefault];
    }

    return navController;
}

@end
