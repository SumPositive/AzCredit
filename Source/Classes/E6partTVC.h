//
//  E6partTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E2invoice;
@class E7payment;

@interface E6partTVC : UITableViewController	<UIPopoverControllerDelegate>

@property (nonatomic, assign) E2invoice		*Pe2select;
@property (nonatomic, assign) E7payment		*Pe7select;
@property (nonatomic, assign) NSMutableSet	*Pe2invoices;
@property (nonatomic, assign) NSInteger		PiFirstSection;

- (void)refreshE6partTVC:(BOOL)bSame;

@end
