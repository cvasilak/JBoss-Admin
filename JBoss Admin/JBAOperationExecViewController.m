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

#import "JBAOperationExecViewController.h"
#import "JBossValue.h"
#import "JBAManagementModel.h"
#import "JBAServerReplyViewController.h"
#import "JBAListEditor.h"
#import "CommonUtil.h"

#import "JBAAppDelegate.h"

#import "JBAOperationsManager.h"
#import "JSONKit.h"

#import "LabelButtonCell.h"
#import "EditCell.h"
#import "ToggleSwitchCell.h"
#import "TextViewCell.h"
#import "DefaultCell.h"
#import "SVProgressHUD.h"
#import "UIView+ParentView.h"

// Table Sections
enum JBAOperationTableSections {
    JBATableEditorSection = 0,
    JBATableHelpSection,
    JBATableOperationNumSections
};

enum JBAHelpRows {
    JBAHelpRow = 0,
    JBAHelpTableSecNumRows
};

@implementation JBAOperationExecViewController {
    UITextField *_textFieldBeingEdited;
}

@synthesize operation = _operation;

-(void)dealloc {
    DLog(@"JBAOperationExecViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"JBAOperationExecViewController viewDidLoad");

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Execute", 
                                                                   @"Execute - execute operation")
                                   style:UIBarButtonItemStyleDone
                                   target:self 
                                   action:@selector(save)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.title = self.operation.name;
    
    [super viewDidLoad];    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return JBATableOperationNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case JBATableEditorSection:
            return @"Parameters";
        case JBATableHelpSection:
            return @"Description";
        default:
            return nil;        
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == JBATableHelpSection) return 160.0;
	return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case JBATableEditorSection:
            return [self.operation.parameters count] == 0? 1: [self.operation.parameters count];
        case JBATableHelpSection:
            return JBAHelpTableSecNumRows;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    id cell;

    switch (section) {
        case JBATableEditorSection:
        {
            if ([self.operation.parameters count] == 0) {
                DefaultCell *labelCell = [DefaultCell cellForTableView:tableView];
                labelCell.textLabel.text = @"empty parameter list";
                labelCell.textLabel.font = [UIFont italicSystemFontOfSize:16];
                labelCell.textLabel.textAlignment = NSTextAlignmentCenter;
                labelCell.accessoryType = UITableViewCellAccessoryNone;
                labelCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell = labelCell;

            } else {
                JBAOperationParameter *parameter = [self.operation.parameters objectAtIndex:row];
                
                if (parameter.type == BOOLEAN) {
                    ToggleSwitchCell *toggleCell = [ToggleSwitchCell cellForTableView:tableView];
                    toggleCell.imageView.image = parameter.required? [UIImage imageNamed:@"star.png"]: nil;
                    toggleCell.label.text = parameter.name;
                    
                    toggleCell.toggler.tag = row;
                    [toggleCell.toggler addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
                    toggleCell.toggler.on = [parameter.value boolValue];
                    toggleCell.adjustX = YES;
                    
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
                    [button addTarget:self action:@selector(showParameterInfo:) forControlEvents:UIControlEventTouchUpInside];
                    toggleCell.accessoryView = button;

                    cell = toggleCell;
                    
                } else if (parameter.type == LIST) {
                    LabelButtonCell *listCell = [LabelButtonCell cellForTableView:tableView];
                    listCell.imageView.image = parameter.required? [UIImage imageNamed:@"star.png"]: nil;
                    listCell.label.text = parameter.name;

                    listCell.button.titleLabel.font = [UIFont italicSystemFontOfSize:15];
                    [listCell.button setTitle:@"Click to Edit" forState:UIControlStateNormal];
                    [listCell.button addTarget:self action:@selector(displayListEditor:) forControlEvents:UIControlEventTouchUpInside];                    
                    listCell.button.tag = row;                    
                    listCell.adjustX = YES;
                    
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
                    [button addTarget:self action:@selector(showParameterInfo:) forControlEvents:UIControlEventTouchUpInside];                    
                    listCell.accessoryView = button;
                    
                    cell = listCell;

                } else {
                    EditCell *editCell = [EditCell cellForTableView:tableView];                
                    editCell.imageView.image = parameter.required? [UIImage imageNamed:@"star.png"]: nil;
                    editCell.label.text = parameter.name;                
                    editCell.txtField.text = @"";

                    if (   parameter.type == INT
                        || parameter.type == LONG 
                        || parameter.type == DOUBLE
                        || parameter.type == BIG_DECIMAL
                        || parameter.type == BIG_INTEGER)
                        editCell.txtField.keyboardType = UIKeyboardTypeDecimalPad;                
                    else
                        editCell.txtField.keyboardType = UIKeyboardTypeDefault;
                    
                    editCell.txtField.placeholder = [parameter typeAsString];
                    editCell.txtField.tag = row;                    
                    editCell.txtField.text = [parameter.value cellDisplay];
                    editCell.txtField.delegate = self;
                    [editCell.txtField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];                    
                    editCell.adjustX = YES;

                    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
                    [button addTarget:self action:@selector(showParameterInfo:) forControlEvents:UIControlEventTouchUpInside];                    
                    editCell.accessoryView = button;
                    
                    cell = editCell;
                }
            }
            
            break;
        }

        case JBATableHelpSection:
        {
            switch (row) {
                case JBAHelpRow:
                {
                    TextViewCell *description = [TextViewCell cellForTableView:tableView];
                    description.textView.text = self.operation.descr;
                    description.textView.editable = NO;                    
                    
                    cell = description;
                }
            }
            
            break;            
        }
            
    }
    
    return cell;
}

#pragma mark - Actions
- (void)save {
    // handle the case where the keyboard is open
    // and user clicks Execute
    if (_textFieldBeingEdited != nil) {
        JBAOperationParameter *parameter = [self.operation.parameters objectAtIndex:_textFieldBeingEdited.tag];
        parameter.value = _textFieldBeingEdited.text;
		
        [_textFieldBeingEdited resignFirstResponder];
	}
    
    NSMutableDictionary *params = 
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         self.operation.name, @"operation", nil];
    
    for (NSUInteger i = 0; i < [self.operation.parameters count]; i++) {
        JBAOperationParameter *parameter = [self.operation.parameters objectAtIndex:i];

        // if generic "add" append the name to the path
        if (parameter.isAddParameter) {
            NSMutableArray *newResourcePath = [[NSMutableArray alloc] init];
            
            for (NSUInteger i = 0; i < [self.operation.path count] - 1 /*remove star*/; i++) {
                [newResourcePath addObject:[self.operation.path objectAtIndex:i]];
            }
            
            if (parameter.value != nil)
                [newResourcePath addObject:parameter.value];
            
            [params setObject:newResourcePath forKey:@"address"];
            
            continue;
        }

        if (parameter.value != nil) {
            if (parameter.type == LIST) {
                 if ([parameter.value count] > 0) // only add the paramater if the list contains items
                     [params setObject:parameter.value forKey:parameter.name];
            } else {
                [params setObject:parameter.value forKey:parameter.name];                
            }

        }
    }
    
    // check if generic add operation already added the address
    if ([params objectForKey:@"address"] == nil) {
        [params setObject:(self.operation.path == nil?[NSArray arrayWithObject:@"/"]: self.operation.path) forKey:@"address"];
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];                
    
    [[JBAOperationsManager sharedManager] 
     postJBossRequestWithParams:params
     success:^(NSMutableDictionary *JSON) {
         [SVProgressHUD dismiss];
         
         JBAServerReplyViewController *replyController = [[JBAServerReplyViewController alloc] initWithStyle:UITableViewStyleGrouped];
         replyController.operationName = self.operation.name;
         replyController.reply = [JSON JSONStringWithOptions:JKSerializeOptionPretty error:nil];
         
         UINavigationController *navigationController = [CommonUtil customizedNavigationController];
         [navigationController pushViewController:replyController animated:NO];
         
         JBAAppDelegate *delegate = (JBAAppDelegate *)[UIApplication sharedApplication].delegate;
         [delegate.navController presentViewController:navigationController animated:YES completion:nil];
         
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

- (void)showParameterInfo:(id)sender {
    id cell = [sender findParentViewWithClass:[UITableViewCell class]];
    
    NSInteger tag;
    
    if ([cell isKindOfClass:[EditCell class]]) {
        EditCell *editCell = (EditCell *)cell;
        tag = editCell.txtField.tag;
    } else if ([cell isKindOfClass:[ToggleSwitchCell class]]) {
        ToggleSwitchCell *toggleCell = (ToggleSwitchCell *)cell;
        tag = toggleCell.toggler.tag;
    } else {
        LabelButtonCell *listCell = (LabelButtonCell *)cell;
        tag = listCell.button.tag;
    }
    
    JBAOperationParameter *parameter = [self.operation.parameters objectAtIndex:tag];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@", parameter.name, (parameter.required?@" (required)": @"")]
                                                    message:parameter.descr
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];

}

- (void)displayListEditor:(id)sender {
    // if any textfield is in edit mode, hide the
    // keyboard prior to display the list editor
    // not to annoy user
    if (_textFieldBeingEdited != nil) {
        [_textFieldBeingEdited resignFirstResponder];
    }
    
    UIButton *button = (UIButton *)sender;

    JBAOperationParameter *parameter = [self.operation.parameters objectAtIndex:button.tag];
    
    JBAListEditor *listEditorController = [[JBAListEditor alloc] initWithStyle:UITableViewStyleGrouped];
    listEditorController.title = parameter.name;

    // initialize an empty list if value is nil
    if (parameter.value == nil || [parameter.value isKindOfClass:[NSNull class]]) {
        parameter.value = [[NSMutableArray alloc] init];
    }
    
    listEditorController.items = parameter.value;
    listEditorController.valueType = parameter.valueType;

    UINavigationController *navigationController = [CommonUtil customizedNavigationController];
    [navigationController pushViewController:listEditorController animated:NO];
    
    JBAAppDelegate *delegate = (JBAAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.navController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Update the model as the "widget values" change
- (void)switchValueChanged:(id)sender {
    UISwitch *toggler = (UISwitch *) sender;
    
    JBAOperationParameter *parameter = [self.operation.parameters objectAtIndex:toggler.tag];
    parameter.value = [NSNumber numberWithBool:toggler.on];
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    JBAOperationParameter *parameter = [self.operation.parameters objectAtIndex:textField.tag];

    if ([textField.text isEqualToString:@""]) {
        parameter.value = nil; // set to nil so the parameter is not submitted to the server (see save())
    } else {
        // convert to numbers if required
        if (parameter.type == INT)
            parameter.value = [NSNumber numberWithInt:[textField.text integerValue]];
        else if (parameter.type == LONG || parameter.type == BIG_INTEGER)
            parameter.value = [NSNumber numberWithLong:[textField.text longLongValue]];
        else if (parameter.type == DOUBLE || parameter.type == BIG_DECIMAL)
            parameter.value = [NSNumber numberWithDouble:[textField.text doubleValue]];
        else if (parameter.type == OBJECT) { // TODO: better handling
            id value = [textField.text objectFromJSONString];

            if (value == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                message:@"Invalid JSON string that represents an Object type!"
                                                               delegate:nil 
                                                      cancelButtonTitle:@"Bummer"
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            } else {
                parameter.value = value;
            }
        }
        else // string
            parameter.value = textField.text;
    }
}

- (void)textFieldDone:(UITextField *)sender {
    [sender resignFirstResponder];
}

@end
