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
