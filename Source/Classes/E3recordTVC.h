//
//  E3recordTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface E3recordTVC : UITableViewController <UIActionSheetDelegate,UIPopoverControllerDelegate>

@property (nonatomic, assign) E0root			*Re0root;
@property (nonatomic, assign) E4shop			*Pe4shop;
@property (nonatomic, assign) E5category		*Pe5category;
@property (nonatomic, assign) E8bank			*Pe8bank;
@property (nonatomic, assign) BOOL              PbAddMode;
@property (nonatomic, assign) id				delegate;

- (void)refreshE3recordTVC:(BOOL)bSameDate;

@end
