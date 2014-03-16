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

#import "JBADeploymentDetailsViewController.h"

#import "JBAOperationsManager.h"

#import "EditCell.h"

#import "SVProgressHUD.h"

@implementation JBADeploymentDetailsViewController {
    NSArray *_fieldLabels;

    NSMutableDictionary *_tempValues;
    UITextField *_textFieldBeingEdited;
}

@synthesize deploymentHash = _deploymentHash;
@synthesize deploymentName = _deploymentName;
@synthesize deploymentRuntimeName = _deploymentRuntimeName;

-(void)dealloc {
    DLog(@"JBADeploymentDetailsViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBADeploymentDetailsViewController viewDidLoad");
 
    _fieldLabels = [[NSArray alloc] initWithObjects:@"Key", @"Name", @"Runtime Name", nil];
    _tempValues = [[NSMutableDictionary alloc] init];
    
    self.title = @"Step 2/2: Verify";
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *finishButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finish" style:UIBarButtonItemStyleDone target:self action:@selector(finish)];
    
    self.navigationItem.rightBarButtonItem = finishButtonItem;
    //self.navigationItem.rightBarButtonItem.enabled = NO; // initially disable it cause nothing is checked

    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_fieldLabels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    EditCell *editCell = [EditCell cellForTableView:tableView];                

	editCell.label.text = [_fieldLabels objectAtIndex:row];
	NSNumber *rowAsNum = [[NSNumber alloc] initWithInt:row];
	
    switch (row) {
        case kDeploymentHashRowIndex:
            editCell.txtField.enabled = NO;
            
            if ([[_tempValues allKeys] containsObject:rowAsNum])
                editCell.txtField.text = [_tempValues objectForKey:rowAsNum];
            else
                editCell.txtField.text = self.deploymentHash;
            break;
        case kDeploymentNameRowIndex:
            editCell.txtField.enabled = YES;            
            if ([[_tempValues allKeys] containsObject:rowAsNum])
                editCell.txtField.text = [_tempValues objectForKey:rowAsNum];
            else
                editCell.txtField.text = self.deploymentName;
            break;
        case kDeploymentRuntimeNameRowIndex:
            editCell.txtField.enabled = YES;            
            
            if ([[_tempValues allKeys] containsObject:rowAsNum])            
                editCell.txtField.text = [_tempValues objectForKey:rowAsNum];
            else
                editCell.txtField.text = self.deploymentRuntimeName;
            break;
    }
    
    if (_textFieldBeingEdited ==  editCell.txtField)
		_textFieldBeingEdited = nil;

    editCell.txtField.delegate = self;
    [editCell.txtField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];                    
   	editCell.txtField.tag = row;

    return editCell;
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textField.tag];
	[_tempValues setObject:textField.text forKey:tagAsNum];
}

- (void)textFieldDone:(id)sender {
    [sender resignFirstResponder];
}

#pragma mark - Action Calls
- (void)finish {
	if (_textFieldBeingEdited != nil) {
		NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:_textFieldBeingEdited.tag];
		[_tempValues setObject:_textFieldBeingEdited.text forKey:tagAsNum];
		
        [_textFieldBeingEdited resignFirstResponder];
	}

    NSMutableDictionary *deploymentInfo = [[NSMutableDictionary alloc] init];
    [deploymentInfo setObject:self.deploymentName forKey:@"name"];
    [deploymentInfo setObject:self.deploymentName forKey:@"runtime-name"];
  
    // construct hash
    NSMutableDictionary *BYTES_VALUE = [NSMutableDictionary dictionary];
    [BYTES_VALUE setObject:self.deploymentHash forKey:@"BYTES_VALUE"];
    
    NSMutableDictionary *HASH = [NSMutableDictionary dictionary];
    [HASH setObject:BYTES_VALUE forKey:@"hash"];
    
    [deploymentInfo setObject:[NSArray arrayWithObjects:HASH, nil] forKey:@"content"];

    for (NSNumber *key in [_tempValues allKeys]) {
		switch ([key intValue]) {
			case kDeploymentNameRowIndex:
				[deploymentInfo setObject:[_tempValues objectForKey:key] forKey:@"name"];
				break;
			case kDeploymentRuntimeNameRowIndex:
				[deploymentInfo setObject:[_tempValues objectForKey:key] forKey:@"runtime-name"];
				break;
			default:
				break;
		}
	}
    
    // initially the deployment is not enabled on
    // the server, reflect this on our local model
    [deploymentInfo setObject:[NSNumber numberWithBool:NO] forKey:@"enabled"];

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [[JBAOperationsManager sharedManager]
        addDeploymentContentWithHash:self.deploymentHash
        andName:[deploymentInfo objectForKey:@"name"]
        andRuntimeName:[deploymentInfo objectForKey:@"runtime-name"]
        withSuccess:^(void) {
    
            [SVProgressHUD showSuccessWithStatus:@"Successfully Added!"];

            [self dismissViewControllerAnimated:YES completion:nil];
            
            // ok inform JBADeploymentsViewController of the 
            // new deployment so it can update model and table view
            NSNotification *notification = [NSNotification notificationWithName:@"DeploymentAddedNotification" object:deploymentInfo];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
        } andFailure:^(NSError *error) {
            [SVProgressHUD dismiss];
            
            UIAlertView *oops = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                           message:[error localizedDescription]
                                                          delegate:nil 
                                                 cancelButtonTitle:@"Bummer"
                                                 otherButtonTitles:nil];
            [oops show];
        }];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
