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

#import "JBAAppDelegate.h"

#import "JBAServersViewController.h"
#import "JBAServerDetailController.h"
#import "JBARootController.h"
#import "JBAServer.h"
#import "JBAServersManager.h"

#import "JBAOperationsManager.h"

#import "SVProgressHUD.h"
#import "UIActionSheet+BlockExtensions.h"

@implementation JBAServersViewController

-(void)dealloc {
    DLog(@"JBAServersViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBAServersViewController viewDidLoad");
    
    self.title = @"Servers";
	
	UIBarButtonItem *editButton = self.editButtonItem; 
    [editButton setTarget:self];
    [editButton setAction:@selector(toggleEdit)];
    self.navigationItem.leftBarButtonItem = editButton;
    
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addServer)];
    self.navigationItem.rightBarButtonItem = addButton;    

  	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[JBAServersManager sharedJBAServersManager] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
	static NSString *JBAServerCellIdentifier = @"JBAServerCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JBAServerCellIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:JBAServerCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	
    JBAServer *server = [[JBAServersManager sharedJBAServersManager] serverAtIndex:row];
	
	cell.textLabel.text = server.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%@", server.hostname, server.port];
    
	return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    JBAServer *server = [[JBAServersManager sharedJBAServersManager] serverAtIndex:row];    
    // initialize JBAOperationsManager singleton for all controllers to use
    [JBAOperationsManager clientWithJBossServer:server];    
    
    // Check if we have connectivity to the server
    // by reading the 'management-major-version' attribute
    [[JBAOperationsManager sharedManager]
     fetchJBossManagementVersionWithSuccess:^(NSNumber *version) {
         // OK we have successfuly connected
         // let the ball rolling...
         JBARootController *rootController = [[JBARootController alloc] init];

         UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromRight;
         [UIView beginAnimations: nil context: nil];
         [UIView setAnimationDuration:0.8];
         [UIView setAnimationTransition: trans forView: [self.view window] cache: NO];

         self.navigationController.navigationBarHidden = YES;
         [self.navigationController pushViewController:rootController animated: NO];
         [UIView commitAnimations];

     } andFailure:^(NSError *error) {
         [SVProgressHUD dismiss]; 
         
         NSString *msg = [error localizedDescription];
         
         // TODO check if we can do better for this...
         // some commands (such as :shutdown) return an empty response
         // if we are here, we know its a username/password wrong combination
         if ([msg isEqualToString:@"Empty response received from server!"]) {
             msg = @"The username or password you provided is incorrect!";
         } else if ([msg isEqualToString:@"Invalid response received from server!"]) {
             msg = @"Please ensure a JBoss server is up and running at that host and a management user exists!";
         }
         
         UIAlertView *oops = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:msg
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
         
         [oops show];
     }
     ];   
    
  	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	
    JBAServer *server = [[JBAServersManager sharedJBAServersManager] serverAtIndex:row];
    
	JBAServerDetailController *detailController = [[JBAServerDetailController alloc] initWithStyle:UITableViewStyleGrouped];
	detailController.title = server.name;
	detailController.server = server;
    
	[self.navigationController pushViewController:detailController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    JBAServer *server = [[JBAServersManager sharedJBAServersManager] serverAtIndex:row];
    
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIActionSheet *yesno = [[UIActionSheet alloc]
                                initWithTitle:[NSString stringWithFormat:@"Are you sure you want to delete %@", server.name]
                                completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                                    if (buttonIndex == 0) { // Yes proceed
                                        [[JBAServersManager sharedJBAServersManager] removeServerAtIndex:row];
                                        
                                        // update server list on disk
                                        [[JBAServersManager sharedJBAServersManager] save];

                                        NSArray *paths = @[[NSIndexPath indexPathForRow:row inSection:0]];
                                        [[self tableView] deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];                                    
                                    }
                                }
                                
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle: @"Yes"
                                otherButtonTitles:nil];
        
        [yesno showInView:self.view];         
   	}
}

#pragma mark - Action Methods
- (void)addServer {
	JBAServerDetailController *detailController = [[JBAServerDetailController alloc] initWithStyle:UITableViewStyleGrouped];
	detailController.title = @"New Server";
	
	[self.navigationController pushViewController:detailController animated:YES];
}

- (void)toggleEdit {
    BOOL editing = !self.tableView.editing;
    self.navigationItem.rightBarButtonItem.enabled = !editing;
    self.navigationItem.leftBarButtonItem.title = (editing) ? @"Done" :  @"Edit";
    [self.tableView setEditing:editing animated:YES];
}

@end
