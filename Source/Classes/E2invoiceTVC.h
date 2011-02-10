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
	E1card		*Re1select;		// どちらか必須
	E8bank		*Re8select;		// どちらか必須
	//----------------------------------------------assign
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//NSAutoreleasePool	*MautoreleasePool;		// [0.3]autorelease独自解放のため
	NSMutableArray		*RaE2list;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	BOOL		MbFirstAppear;
	BOOL		MbOptAntirotation;
	E2temp		*Me2cellButton;		// cellLeftButton:にて button.tag をセットして、alertView:にて参照。
}

@property (nonatomic, retain) E1card	*Re1select;
@property (nonatomic, retain) E8bank	*Re8select;

- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用

@end

