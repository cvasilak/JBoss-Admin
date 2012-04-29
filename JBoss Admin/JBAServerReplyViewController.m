//
//  JBAServerReplyViewController.m
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import "JBAServerReplyViewController.h"

#import "TextViewCell.h"

@implementation JBAServerReplyViewController

@synthesize operationName = _operationName;
@synthesize reply = _reply;

-(void)dealloc {
    DLog(@"JBAServerReplyViewController dealloc");    
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    DLog(@"JBAServerReplyViewController viewDidUnLoad");
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    DLog(@"JBAServerReplyViewController viewDidLoad");
    
    self.title = self.operationName;

    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" 
                                                                        style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = closeButtonItem;

    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Server Reply";
}
 

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 360.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextViewCell *cellReply = [TextViewCell cellForTableView:tableView];
    cellReply.textView.font = [UIFont systemFontOfSize:14.0];
    cellReply.textView.text = self.reply;
    cellReply.textView.editable = NO;                    
    
    return cellReply;
}

#pragma mark - Action Methods
-(IBAction)close {
    [self dismissModalViewControllerAnimated:YES];   
}

@end
