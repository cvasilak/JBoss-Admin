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

#import "JBAServerReplyViewController.h"

#import "TextViewCell.h"

@implementation JBAServerReplyViewController

@synthesize operationName = _operationName;
@synthesize reply = _reply;

-(void)dealloc {
    DLog(@"JBAServerReplyViewController dealloc");    
}

#pragma mark - View lifecycle

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
-(void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
