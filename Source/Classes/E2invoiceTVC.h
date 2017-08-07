//
//  E2invoiceTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E1card;
@class E2temp;

@interface E2invoiceTVC : UITableViewController

@property (nonatomic, strong) E1card            *Re1select;
@property (nonatomic, strong) E8bank            *Re8select;

@end

