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

#import "JBAServerDetailController.h"
#import "JBAServersViewController.h"
#import "JBAServer.h"
#import "JBAServersManager.h"

#import "UIView+ParentView.h"

@implementation JBAServerDetailController {
    NSArray *_fieldLabels;
    NSMutableDictionary *_tempValues;
    UITextField *_textFieldBeingEdited;
}

@synthesize server = _server;

-(void)dealloc {
    DLog(@"JBAServerDetailController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBAServerDetailController viewDidLoad");
    
    _fieldLabels = [[NSArray alloc] initWithObjects:@"Name", @"Hostname", @"Port",  @"Use SSL", @"Username", @"Password", nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    
    _tempValues = [[NSMutableDictionary alloc] init];
    
    if (self.server == nil) { // new server
        [_tempValues setObject:@"9990" forKey:[NSNumber numberWithInt:kServerPortRowIndex]];
    }
    
	[super viewDidLoad];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return kNumberOfEditableRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *JBAServerCellEditIdentifer = @"JBAServerCellEditIdentifer";
  	static NSString *JBAServerCellEditSwitchIdentifer = @"JBAServerCellEditSwitchIdentifer";
    
    NSInteger row = [indexPath row];
	
    UITableViewCell *cell;
    
    if (row == kServerUseSSLRowIndex) {
        cell = [tableView dequeueReusableCellWithIdentifier:JBAServerCellEditSwitchIdentifer];        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:JBAServerCellEditIdentifer];        
    }
	
	if (cell == nil) {
        if (row == kServerUseSSLRowIndex /* || anotherUISwitchRowIndex*/) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JBAServerCellEditSwitchIdentifer];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 110, 25)];
            label.tag = kLabelTag;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont boldSystemFontOfSize:12.0];
            label.textColor = kNonEditableTextColor;
            label.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:label];

            UISwitch *toggler = [[UISwitch alloc] initWithFrame:CGRectMake(130, 10, 0, 0)];
            [toggler addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:toggler];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JBAServerCellEditIdentifer];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 110, 25)];
            label.tag = kLabelTag;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont boldSystemFontOfSize:12.0];
            label.textColor = kNonEditableTextColor;
            label.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:label];
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(130, 10, 168, 25)];
            textField.clearsOnBeginEditing = NO;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;

            [textField setDelegate:self];
            if (row == kServerPasswordRowIndex)
                [textField setSecureTextEntry:YES];
            else
                [textField setSecureTextEntry:NO];
            
            if (row == kServerPortRowIndex)
                [textField setKeyboardType:UIKeyboardTypeDecimalPad];
            else 
                [textField setKeyboardType:UIKeyboardTypeDefault];
            
            textField.returnKeyType = UIReturnKeyNext;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
            
            [cell.contentView addSubview:textField];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	UILabel *label = (UILabel *) [cell viewWithTag:kLabelTag];
	UITextField *textField = nil;
    UISwitch *toggler = nil;
    
    for (UIView *oneView in cell.contentView.subviews) {
		if ([oneView isMemberOfClass:[UITextField class]])
			textField = (UITextField *) oneView;
        else if ([oneView isMemberOfClass:[UISwitch class]]) {
            toggler = (UISwitch *) oneView;
        }
	}
	
	label.text = [_fieldLabels objectAtIndex:row];
	NSNumber *rowAsNum = [NSNumber numberWithInteger:row];
	
	switch (row) {
		case kServerNameRowIndex:
			if ([[_tempValues allKeys] containsObject:rowAsNum])
				textField.text = [_tempValues objectForKey:rowAsNum];
			else
				textField.text = self.server.name;
			
			break;
		case kServerHostnameRowIndex:
			if ([[_tempValues allKeys] containsObject:rowAsNum])
				textField.text = [_tempValues objectForKey:rowAsNum];
			else
				textField.text = self.server.hostname;
			
			break;
		case kServerPortRowIndex:
			if ([[_tempValues allKeys] containsObject:rowAsNum])
				textField.text = [_tempValues objectForKey:rowAsNum];
			else
				textField.text = self.server.port;
			
			break;
		case kServerUseSSLRowIndex:
			if ([[_tempValues allKeys] containsObject:rowAsNum])
				toggler.on = [[_tempValues objectForKey:rowAsNum] boolValue];
			else
				toggler.on = self.server.isSSLSecured;
			
			break;
		case kServerUsernameRowIndex:
			if ([[_tempValues allKeys] containsObject:rowAsNum])
				textField.text = [_tempValues objectForKey:rowAsNum];
			else
				textField.text = self.server.username;
			
			break;
		case kServerPasswordRowIndex:
			if ([[_tempValues allKeys] containsObject:rowAsNum])
				textField.text = [_tempValues objectForKey:rowAsNum];
			else
				textField.text = self.server.password;
            
			break;
		default:
			break;
	}
	
	if (_textFieldBeingEdited == textField)
		_textFieldBeingEdited = nil;
    
    if (toggler != NULL)
        toggler.tag = row;
    else
       	textField.tag = row;
    
	
	return cell;
}

#pragma mark - UISwitch value changed
- (void)switchValueChanged: (id)sender {
    UISwitch *toggler = (UISwitch *) sender;

	NSNumber *tagAsNum = [NSNumber numberWithInteger:toggler.tag];
	[_tempValues setObject:[NSNumber numberWithBool:toggler.on] forKey:tagAsNum];
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	NSNumber *tagAsNum = [NSNumber numberWithInteger:textField.tag];
	// textfield.text password is not initialized to '' for password fields
    if (textField.text == nil)
        return;
    
    [_tempValues setObject:textField.text forKey:tagAsNum];
}

- (void)textFieldDone:(id)sender {
	UITableViewCell *cell = (UITableViewCell *)[sender findParentViewWithClass:[UITableViewCell class]];
    NSIndexPath *textFieldIndexPath = [self.tableView indexPathForCell:cell];
	NSUInteger row = [textFieldIndexPath row];
	
	row++;
	if (row >= kNumberOfEditableRows)
		row = 0;
	
	NSUInteger newIndex[] = {0, row};
	NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
	UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:newPath];
	
    UITextField *nextField = nil;
	
	for (UIView *oneView in nextCell.contentView.subviews) {
		if ([oneView isMemberOfClass:[UITextField class]])
			nextField = (UITextField *)oneView;
	}
	
	[nextField becomeFirstResponder];
}

#pragma mark - Action Methods
- (void)save {
	if (_textFieldBeingEdited != nil) {
		NSNumber *tagAsNum = [NSNumber numberWithInteger:_textFieldBeingEdited.tag];
		[_tempValues setObject:_textFieldBeingEdited.text forKey:tagAsNum];
		
        [_textFieldBeingEdited resignFirstResponder];
	}
    
    JBAServer *theServer;
    
    if (self.server == nil)
        theServer = [[JBAServer alloc] init];
    else
        theServer = self.server;
    
    for (NSNumber *key in [_tempValues allKeys]) {
		switch ([key intValue]) {
			case kServerNameRowIndex:
				theServer.name = [_tempValues objectForKey:key];
				break;
			case kServerHostnameRowIndex:
				theServer.hostname = [_tempValues objectForKey:key];
				break;
			case kServerPortRowIndex:
				theServer.port = [_tempValues objectForKey:key];
				break;
			case kServerUseSSLRowIndex:
				theServer.isSSLSecured = [[_tempValues objectForKey:key] boolValue];
				break;
			case kServerUsernameRowIndex:
				theServer.username = [_tempValues objectForKey:key];
				break;
			case kServerPasswordRowIndex:
				theServer.password = [_tempValues objectForKey:key];
				break;
			default:
				break;
		}
	}
    
    // At least hostname and port must be defined
    if ([theServer.hostname length] == 0 ||
        [theServer.port length] == 0) {
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:@"Please complete at least Hostname and Port field!"
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        
        [alert show];

        return;
    }
    
    if (self.server == nil) {  // if it is a new server 
        [[JBAServersManager sharedJBAServersManager] addServer:theServer]; // add it to the list
	} 
    
    if ([_tempValues count] != 0)  { // if there was any change
        // update server list on disk
        [[JBAServersManager sharedJBAServersManager] save];
    }
    
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel {
	[self.navigationController popViewControllerAnimated:YES];
}
@end
