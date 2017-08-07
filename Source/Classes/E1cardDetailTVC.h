//
//  E1cardDetailTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E0root;

@interface E1cardDetailTVC : UITableViewController

@property (nonatomic, strong) E1card	*Re1edit;
@property NSInteger						PiAddRow;
@property (nonatomic, assign) id		delegate;

// 公開メソッド
- (void)cancelClose:(id)sender ;

// デリゲート・メソッド

@end
