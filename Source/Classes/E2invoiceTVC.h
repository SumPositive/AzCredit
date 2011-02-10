//
//  E2invoiceTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E1card;

@interface E2invoiceTVC : UITableViewController
{
	//----------------------------------------------retain
	E1card		*Re1select;		// 必須
	//----------------------------------------------assign
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray	*Me2list;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	BOOL		MbFirstAppear;
	BOOL		MbOptAntirotation;
	E2invoice	*Me2cellButton; // cellLeftButton:にて button.tag をセットして、alertView:にて参照。
}

@property (nonatomic, retain) E1card  *Re1select;

- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用

@end
