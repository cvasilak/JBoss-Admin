//
//  ServerDetailController.h
//  JBoss Admin
//
//  Author: Christos Vasilakis <cvasilak@gmail.com>
//  Copyright 2012 All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNumberOfEditableRows	6

#define kServerNameRowIndex             0
#define kServerHostnameRowIndex         1
#define kServerPortRowIndex             2
#define kServerUseSSLRowIndex           3
#define kServerUsernameRowIndex         4
#define kServerPasswordRowIndex         5

#define kNonEditableTextColor  [UIColor colorWithRed:.318 green:0.4 blue:.569 alpha:7.0]

#define kLabelTag 4096

@class JBAServer;

@interface JBAServerDetailController : UITableViewController <UITextFieldDelegate>

@property(strong, nonatomic) JBAServer *server;

@end
