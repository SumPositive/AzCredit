//
//  E1cardTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E1cardTVC : UITableViewController <UIPopoverControllerDelegate>

@property (nonatomic, strong) E0root			*Re0root;
@property (nonatomic, strong) E3record		*Re3edit;
@property (nonatomic, assign) id					delegate;

// デリゲート・メソッド
- (void)refreshTable;

@end
