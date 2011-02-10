//
//  E4toE3recordTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E4shop;

@interface E4toE3recordTVC : UITableViewController <UIActionSheetDelegate>
{
	//----------------------------------------------retain
	//----------------------------------------------assign
	E4shop			*Pe4shop;
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
//	NSMutableArray	*Me2list;  // Pe2selectの前後1ノード計3ノードを保持
	NSMutableArray	*Me3list;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	BOOL		MbOptShouldAutorotate;
	BOOL		MbForTheFirstTime;		// viewDidAppear内で最初に1回だけ画面スクロール位置調整するため
	NSIndexPath *MindexPathActionDelete;
}

@property (nonatomic, assign) E4shop			*Pe4shop;

- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用

@end
