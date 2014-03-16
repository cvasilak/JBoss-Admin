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

#import "JBARootController.h"
#import "JBARuntimeController.h"
#import "JBAProfileController.h"

#import "CommonUtil.h"

#import "JBAOperationsManager.h"

typedef NS_ENUM(NSUInteger, Tabs) {
    RuntimeTab,
    TreeTab
};

@implementation JBARootController {
    UITabBarController *_tabBarController;
}

-(void)dealloc {
    DLog(@"JBARootController dealloc");    
}

#pragma mark - View lifecycle

- (void)loadView {
    DLog(@"JBARootController loadView");
    
    UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
    
    // Declare view controllers
    JBARuntimeController *runtimeController = [[JBARuntimeController alloc] initWithStyle:UITableViewStyleGrouped];
    JBAProfileController *profileController = [[JBAProfileController alloc] initWithStyle:UITableViewStyleGrouped];
    
    // Set a title for each view controller. These will also be names of each tab
    runtimeController.title = @"Runtime";
    profileController.title = @"Browse Tree";

    runtimeController.tabBarItem.image = [UIImage imageNamed:@"summary.png"];
	profileController.tabBarItem.image = [UIImage imageNamed:@"profile.png"];
    
    UINavigationController *runtimeNavigationController = [CommonUtil customizedNavigationController];
    [runtimeNavigationController pushViewController:runtimeController animated:NO];
    
    UINavigationController *profileNavigationController = [CommonUtil customizedNavigationController];
    [profileNavigationController pushViewController:profileController animated:NO];
    
    _tabBarController = [[UITabBarController alloc] init];
    
	// Set each tab to show an appropriate view controller
    [_tabBarController setViewControllers: @[runtimeNavigationController, profileNavigationController]];

    // TODO: revisit this
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)||
       (interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
      	_tabBarController.view.frame = CGRectMake(0, 0, 320, IS_WIDESCREEN? 568: 480);
    } else if ((interfaceOrientation == UIInterfaceOrientationPortrait) || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        _tabBarController.view.frame = CGRectMake(0, 0, 320, IS_WIDESCREEN? 550: 460);
    }

    // Finally, add the tab controller view to the parent view
    [self.view addSubview:_tabBarController.view];
}

- (void)viewDidLoad {
    DLog(@"JBARootController viewDidLoad");
    
    [super viewDidLoad];
}

// adjust navigation toolbar height upon interface orientation change
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    UINavigationController *navigationController = (UINavigationController *)_tabBarController.selectedViewController;
    
    CGRect frame = navigationController.navigationBar.frame;
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        frame.size.height = 44;
    } else {
        frame.size.height = 32;
    }
    
    navigationController.navigationBar.frame = frame;
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
