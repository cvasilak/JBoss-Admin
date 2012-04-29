//
//  JBAAttributeGenericTypeEditor.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBAAttributeGenericTypeEditor.h"
#import "JBAServerReplyViewController.h"
#import "JBossValue.h"
#import "JBAListEditor.h"

#import "JBAAppDelegate.h"

#import "CommonUtil.h"
#import "JSONKit.h"

#import "EditCell.h"
#import "LabelButtonCell.h"
#import "ToggleSwitchCell.h"
#import "TextViewCell.h"

// Table Sections
enum JBAGenericAttributeEditorTableSections {
    JBATableEditorSection = 0,
    JBATableHelpSection,
    JBATableGenericNumSections
};

// Table Rows
enum JBAEditorRows {
    JBAEditorRow = 0,
    JBAEditorTableSecNumRows
};

enum JBAHelpRows {
    JBAHelpRow = 0,
    JBAHelpTableSecNumRows
};

@implementation JBAAttributeGenericTypeEditor {
    // this will hold temporary the items hold by ListEditor    
    NSMutableArray *_tempList; 
}

-(void)dealloc {
    DLog(@"JBAAttributeGenericTypeEditor dealloc");    
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    DLog(@"JBAAttributeGenericTypeEditor viewDidUnLoad");
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    DLog(@"JBAAttributeGenericTypeEditor viewDidLoad");
    
    // cater for LIST types 
    if (self.node.type == LIST) {
        if ([self.node.value isKindOfClass:[NSNull class]]) // if "undefined"
            _tempList = [[NSMutableArray alloc] init];  // create a new list
        else
            _tempList = [NSMutableArray arrayWithArray:self.node.value];  // else copy the items from the original LIST
    }
    
    [super viewDidLoad];    
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return JBATableGenericNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case JBATableHelpSection:
            return @"Description";
        default:
            return nil;        
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == JBATableHelpSection) return 240.0;
	return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case JBATableEditorSection:
            return JBAEditorTableSecNumRows;
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
            switch (row) {
                case JBAEditorRow:
                    if (self.node.type == BOOLEAN) {
                        ToggleSwitchCell *toggleCell = [ToggleSwitchCell cellForTableView:tableView];
                        toggleCell.label.text = self.node.name;
                        
                        // if "undefined" default to false
                        if ([self.node.value isKindOfClass:[NSNull class]])
                            toggleCell.toggler.on = NO;
                        else 
                            toggleCell.toggler.on = [self.node.value boolValue];

                        cell = toggleCell;

                    } else if (self.node.type == LIST) {
                        LabelButtonCell *listCell = [LabelButtonCell cellForTableView:tableView];
                        listCell.label.text = self.node.name;
                        
                        listCell.button.titleLabel.font = [UIFont italicSystemFontOfSize:15];
                        [listCell.button setTitle:(self.node.isReadOnly? @"Click to View": @"Click To Edit") forState:UIControlStateNormal];
                        [listCell.button addTarget:self action:@selector(displayListEditor:) forControlEvents:UIControlEventTouchUpInside];                    

                        cell = listCell;
                        
                    } else {
                        EditCell *editCell = [EditCell cellForTableView:tableView];                
                        editCell.label.text = self.node.name; 

                        // if "undefined" set an empty text
                        if ([self.node.value isKindOfClass:[NSNull class]])
                            editCell.txtField.text = @"";
                        else
                            editCell.txtField.text = [self.node.value cellDisplay];
                        
                        if (   self.node.type == INT
                            || self.node.type == LONG
                            || self.node.type == DOUBLE
                            || self.node.type == BIG_DECIMAL
                            || self.node.type == BIG_INTEGER)
                            editCell.txtField.keyboardType = UIKeyboardTypeDecimalPad;
                        else
                            editCell.txtField.keyboardType = UIKeyboardTypeDefault;
                        
                        editCell.txtField.placeholder = [self.node typeAsString];
                        [editCell.txtField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        
                        cell = editCell;
                    }

                    break;
            }   
            break;
        }

        case JBATableHelpSection:
        {
            switch (row) {
                case JBAHelpRow:
                {
                    TextViewCell *description = [TextViewCell cellForTableView:tableView];
                    description.textView.text = self.node.descr;
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
-(IBAction)save {
    NSUInteger editorRow[] = {JBATableEditorSection, JBAEditorRow};
    NSIndexPath *onlyRowPath = [NSIndexPath indexPathWithIndexes:editorRow length:2];
    
    id cell = [self.tableView cellForRowAtIndexPath:onlyRowPath];
    id value;
    
    if ([cell isKindOfClass:[EditCell class]]) {
        EditCell *editCell = (EditCell *)cell;
        
        // need to convert numbers
        NSString *textFieldValue = editCell.txtField.text;
        
        // if the textfield is not empty, update value
        // otherwise will be nil and it won't be submitted 
        // to the server see [super updateWithValue]
        if (![textFieldValue isEqualToString:@""]) {
            // TODO couldn't find value to test, need more checks
            if (self.node.type == INT)
                value = [NSNumber numberWithInt:[textFieldValue integerValue]];
            else if (self.node.type == LONG || self.node.type == BIG_INTEGER)
                value = [NSNumber numberWithLong:[textFieldValue longLongValue]];
            else if (self.node.type== DOUBLE || self.node.type == BIG_DECIMAL)
                value = [NSNumber numberWithDouble:[textFieldValue doubleValue]];
            else if (self.node.type == OBJECT) { // TODO: better handling
                value = [textFieldValue objectFromJSONString];
                
                if (value == nil) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                    message:@"Invalid JSON string that represents an Object type!"
                                                                   delegate:nil 
                                                          cancelButtonTitle:@"Bummer"
                                                          otherButtonTitles:nil];
                    [alert show];
                    return;
                }
            }
            else // string
                value = textFieldValue;
        } 
        
        // delay a bit if the keyboard is open so that the progress bar
        // is displayed correctly on the center
        // during the keyboard dismissing from screen
        if ([editCell.txtField isFirstResponder]) {
            [editCell.txtField resignFirstResponder];
            [self performSelector:@selector(updateWithValue:) withObject:value afterDelay:0.3];
            return;
        } else {
            value = editCell.txtField.text;
        }
        
    } else if ([cell isKindOfClass:[ToggleSwitchCell class]]) {
        ToggleSwitchCell *toggleCell = (ToggleSwitchCell *)cell;
        value = [NSNumber numberWithBool:toggleCell.toggler.on];

    } else if ([cell isKindOfClass:[LabelButtonCell class]]) {
        value = _tempList;
    }
    
    [super updateWithValue:value];
}

- (IBAction)displayListEditor:(id)sender {
    JBAListEditor *listEditorController = [[JBAListEditor alloc] initWithStyle:UITableViewStyleGrouped];
    listEditorController.title = self.node.name;
    
    listEditorController.items = _tempList;
    listEditorController.valueType = self.node.valueType;
    listEditorController.isReadOnlyMode = self.node.isReadOnly;
    
    UINavigationController *navigationController = [CommonUtil customizedNavigationController];
    [navigationController pushViewController:listEditorController animated:NO];

    JBAAppDelegate *delegate = (JBAAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.navController presentModalViewController:navigationController animated:YES];   
}

#pragma mark - TextField methods
- (void)textFieldDone:(UITextField *)sender {
    [sender resignFirstResponder];
}

@end
