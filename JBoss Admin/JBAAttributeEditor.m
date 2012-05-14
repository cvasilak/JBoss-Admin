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
