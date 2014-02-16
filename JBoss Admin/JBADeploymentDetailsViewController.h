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

#import <UIKit/UIKit.h>

#define kNumberOfEditableRows	3

#define kLabelTag 2048

#define kDeploymentHashRowIndex          0
#define kDeploymentNameRowIndex          1
#define kDeploymentRuntimeNameRowIndex   2

#define kNonEditableTextColor  [UIColor colorWithRed:.318 green:0.4 blue:.569 alpha:7.0]

@interface JBADeploymentDetailsViewController : UITableViewController<UITextFieldDelegate>

@property(strong, nonatomic) NSString *deploymentHash;
@property(strong, nonatomic) NSString *deploymentName;
@property(strong, nonatomic) NSString *deploymentRuntimeName;

@end
