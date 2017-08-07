//
//  E8bankTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface E8bankTVC : UITableViewController <UIPopoverControllerDelegate>

@property (nonatomic, assign) E0root	*Re0root;
@property (nonatomic, assign) E1card      *Pe1card;

- (void)refreshTable;
- (instancetype)initWithStyle:(UITableViewStyle)style;

@end
