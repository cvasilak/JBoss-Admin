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
 
    _fieldLabels = @[@"Key", @"Name", @"Runtime Name"];
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

	editCell.label.text = _fieldLabels[row];
	NSNumber *rowAsNum = [NSNumber numberWithInteger:row];
	
    switch (row) {
        case kDeploymentHashRowIndex:
            editCell.txtField.enabled = NO;
            
            if ([[_tempValues allKeys] containsObject:rowAsNum])
                editCell.txtField.text = _tempValues[rowAsNum];
            else
                editCell.txtField.text = self.deploymentHash;
            break;
        case kDeploymentNameRowIndex:
            editCell.txtField.enabled = YES;            
            if ([[_tempValues allKeys] containsObject:rowAsNum])
                editCell.txtField.text = _tempValues[rowAsNum];
            else
                editCell.txtField.text = self.deploymentName;
            break;
        case kDeploymentRuntimeNameRowIndex:
            editCell.txtField.enabled = YES;            
            
            if ([[_tempValues allKeys] containsObject:rowAsNum])            
                editCell.txtField.text = _tempValues[rowAsNum];
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
	NSNumber *tagAsNum = @(textField.tag);
	_tempValues[tagAsNum] = textField.text;
}

- (void)textFieldDone:(id)sender {
    [sender resignFirstResponder];
}

#pragma mark - Action Calls
- (void)finish {
	if (_textFieldBeingEdited != nil) {
		NSNumber *tagAsNum = @(_textFieldBeingEdited.tag);
		_tempValues[tagAsNum] = _textFieldBeingEdited.text;
		
        [_textFieldBeingEdited resignFirstResponder];
	}

    NSMutableDictionary *deploymentInfo = [[NSMutableDictionary alloc] init];
    deploymentInfo[@"name"] = self.deploymentName;
    deploymentInfo[@"runtime-name"] = self.deploymentName;
  
    // construct hash
    NSMutableDictionary *BYTES_VALUE = [NSMutableDictionary dictionary];
    BYTES_VALUE[@"BYTES_VALUE"] = self.deploymentHash;
    
    NSMutableDictionary *HASH = [NSMutableDictionary dictionary];
    HASH[@"hash"] = BYTES_VALUE;
    
    deploymentInfo[@"content"] = @[HASH];

    for (NSNumber *key in [_tempValues allKeys]) {
		switch ([key intValue]) {
			case kDeploymentNameRowIndex:
				deploymentInfo[@"name"] = _tempValues[key];
				break;
			case kDeploymentRuntimeNameRowIndex:
				deploymentInfo[@"runtime-name"] = _tempValues[key];
				break;
			default:
				break;
		}
	}
    
    // initially the deployment is not enabled on
    // the server, reflect this on our local model
    deploymentInfo[@"enabled"] = @NO;

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [[JBAOperationsManager sharedManager]
        addDeploymentContentWithHash:self.deploymentHash
        andName:deploymentInfo[@"name"]
        andRuntimeName:deploymentInfo[@"runtime-name"]
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
