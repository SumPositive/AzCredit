//
//  E8bankTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E8bankTVC : UITableViewController <UIActionSheetDelegate> 
{
@private
	//--------------------------retain
	E0root		*Re0root;
	//--------------------------assign
	E1card		*Pe1card;		// =nil:マスタモード  !=nil:選択モード
	
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//NSAutoreleasePool	*MautoreleasePool;		// [0.3]autorelease独自解放のため
	NSMutableArray		*RaE8banks;
	//----------------------------------------------------------------Owner移管につきdealloc時のrelese不要
	UIBarButtonItem	*MbuTop;		// BarButton ＜hasChanges時に無効にするため＞
	UIBarButtonItem *MbuAdd;
	//----------------------------------------------------------------assign
	NSIndexPath	  *MindexPathActionDelete; // 削除するIndexPath
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E0root	*Re0root;
@property (nonatomic, assign) E1card	*Pe1card;

- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
@end
