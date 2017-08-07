//
//  TopMenuTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class InformationView;
@class E0root;

@interface TopMenuTVC : UITableViewController  <UITextFieldDelegate,UIPopoverControllerDelegate>

@property (nonatomic, strong) E0root				*Re0root;

- (void)e3detailAdd;				//PadRootVCからdelegate呼び出しされる
- (void)refreshTopMenuTVC;	// E3recordDetailTVC:から呼び出される

@end
