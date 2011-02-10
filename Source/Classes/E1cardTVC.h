//
//  E1cardTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E1cardTVC : UITableViewController <UIActionSheetDelegate> 
{
@private
	//--------------------------retain
	E0root		*Re0root;
	E3record	*Re3edit;		// =nil:マスタモード  !=nil:選択モード
	//--------------------------assign
	
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//NSAutoreleasePool	*MautoreleasePool;		// [0.3]autorelease独自解放のため
	NSMutableArray		*RaE1cards;
	//----------------------------------------------------------------Owner移管につきdealloc時のrelese不要
	UIBarButtonItem	*MbuTop;		// BarButton ＜hasChanges時に無効にするため＞
	UIBarButtonItem *MbuAdd;
	//----------------------------------------------------------------assign
	NSIndexPath	  *MindexPathActionDelete; // 削除するIndexPath
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E0root	*Re0root;
@property (nonatomic, retain) E3record	*Re3edit;

- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
@end
