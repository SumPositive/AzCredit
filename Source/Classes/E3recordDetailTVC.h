//
//  E3recordDetailTVC.h.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E0root;
@class E3record;
@class E3recordTVC;
@class CalcView;

@interface E3recordDetailTVC : UITableViewController 

@property (nonatomic, retain) E3record		*Re3edit;
@property NSInteger							PiAdd;
@property NSInteger							PiFirstYearMMDD;	
@property (nonatomic, assign) id									delegate;

// 公開メソッド
- (void)remakeE6change:(int)iChange;

@end
