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
- (void)viewDidUnload {
    DLog(@"JBAServersViewController viewDidUnload");
    
	[super viewDidUnload];
}

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

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    
    JBAServer *server = [[JBAServersManager sharedJBAServersManager] serverAtIndex:row];    
    // initialize JBAOperationsManager singleton for all controllers to use
    [JBAOperationsManager clientWithJBossServer:server];    
    
    // Check if we have connectivity to the server
    // by reading the 'release-version' attribute
    [[JBAOperationsManager sharedManager]
     fetchJBossVersionWithSuccess:^(NSString *version) {
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

                                        NSArray *paths = [NSArray arrayWithObject: [NSIndexPath indexPathForRow:row inSection:0]];
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
