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
{
@private
	//----------------------------------------------retain
//	E1card		*Re1select;		// どちらか必須
//	E8bank		*Re8select;		// どちらか必須
	//----------------------------------------------assign
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray		*RaE2list;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UIButton		*MbuPaid;
	UIButton		*MbuUnpaid;
	//----------------------------------------------assign
	AppDelegate *appDelegate;
	BOOL		MbFirstAppear;
	//BOOL		MbOptAntirotation;
	BOOL		MbAction;		// 連続タッチされると落ちるので、その対策
	//E2temp		*Me2cellButton;		// cellLeftButton:にて button.tag をセットして、alertView:にて参照。
	CGPoint		McontentOffsetDidSelect; // didSelect時のScrollView位置を記録
}

@property (nonatomic, strong) E1card	*Re1select;
@property (nonatomic, strong) E8bank	*Re8select;

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用

@end

