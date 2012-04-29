//
//  JBARootController.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBARootController.h"
#import "JBARuntimeController.h"
#import "JBAProfileController.h"

#import "CommonUtil.h"

#import "JBAOperationsManager.h"

typedef enum {
    RuntimeTab,
    TreeTab
} Tabs;

@implementation JBARootController {
    UITabBarController *_tabBarController;
}

-(void)dealloc {
    DLog(@"JBARootController dealloc");    
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
	DLog(@"JBARootController viewDidUnload");
    
    [super viewDidUnload];
}

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
    [_tabBarController setViewControllers: [NSArray arrayWithObjects:runtimeNavigationController, profileNavigationController, nil]];

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)||
       (interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
      	_tabBarController.view.frame = CGRectMake(0, 0, 320, 480);
    } else if ((interfaceOrientation == UIInterfaceOrientationPortrait) || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        _tabBarController.view.frame = CGRectMake(0, 0, 320, 460);
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
