//
//  JBAAttributeEditor.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBAAttributeEditor.h"
#import "JBAOperationsManager.h"
#import "JBAServerReplyViewController.h"
#import "CommonUtil.h"

#import "JBAAppDelegate.h"

#import "JSONKit.h"
#import "SVProgressHUD.h"

@implementation JBAAttributeEditor {
    NSString *_name;
    NSString *_descr;
}

@synthesize node = _node;

- (void)viewDidUnload {
	[super viewDidUnload];
    
	DLog(@"JBAAttributeEditor viewDidUnload");
}

- (void)viewDidLoad {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Save", 
                                                                   @"Save - for button to save changes")
                                   style:UIBarButtonItemStyleDone
                                   target:self 
                                   action:@selector(save)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // disable save if the attribute is read-only
    self.navigationItem.rightBarButtonItem.enabled = !self.node.isReadOnly;
    
    self.title = @"Edit Attribute";
    
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Actions
-(IBAction)updateWithValue:(id)value; {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];                
    
    NSDictionary *params = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"write-attribute", @"operation",
         (self.node.path == nil?[NSArray arrayWithObject:@"/"]: self.node.path), @"address",
         self.node.name, @"name",
         value /* if nil it will act as a sentinel for dictionaryWithObjectsAndKeys */, @"value", nil];
    
    [[JBAOperationsManager sharedManager] 
        postJBossRequestWithParams:params
         success:^(NSMutableDictionary *JSON) {
             [SVProgressHUD dismiss];

             // if success, update this node value
             if ([[JSON objectForKey:@"outcome"] isEqualToString:@"success"]) {
                 // if type LIST do a copy so subsequent edits do 
                 // not affect the original LIST
                 if (self.node.type == LIST) {
                     self.node.value = [NSMutableArray arrayWithArray:value];
                 } else {
                     self.node.value = value;
                 }
             }
             // display server reply
             JBAServerReplyViewController *replyController = [[JBAServerReplyViewController alloc] initWithStyle:UITableViewStyleGrouped];
             replyController.operationName = self.node.name;
             
             replyController.reply = [JSON JSONStringWithOptions:JKSerializeOptionPretty error:nil];
             
             UINavigationController *navigationController = [CommonUtil customizedNavigationController];
             [navigationController pushViewController:replyController animated:NO];
             
             JBAAppDelegate *delegate = (JBAAppDelegate *)[UIApplication sharedApplication].delegate;
             [delegate.navController presentModalViewController:navigationController animated:YES];
             
         } failure:^(NSError *error) {
             [SVProgressHUD dismiss];
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                             message:[error localizedDescription]
                                                            delegate:nil 
                                                   cancelButtonTitle:@"Bummer"
                                                   otherButtonTitles:nil];
             [alert show];
         } process:NO
     ];   
}

@end
