//
//  E1cardTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef AzPAD
//@class PadPopoverInNaviCon;
#endif

@interface E1cardTVC : UITableViewController <UIActionSheetDelegate
#ifdef AzPAD
	,UIPopoverControllerDelegate
#endif
>
{
@private
	//--------------------------retain
	E0root		*Re0root;
	E3record	*Re3edit;		// =nil:マスタモード  !=nil:選択モード

#ifdef AzPAD
	// E3recordDetailTVC から Popover で呼び出されるときにセットする
	id									delegate;	
	UIPopoverController*	selfPopover;  // 自身を包むPopover  閉じる為に必要
#endif
	//--------------------------assign
	
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray		*RaE1cards;
	//----------------------------------------------------------------Owner移管につきdealloc時のrelese不要
	UIBarButtonItem	*MbuTop;		// BarButton ＜hasChanges時に無効にするため＞
	UIBarButtonItem *MbuAdd;
#ifdef AzPAD
	UIPopoverController*	Mpopover;
	NSIndexPath*				MindexPathEdit;
#endif
	//----------------------------------------------------------------assign
	NSIndexPath	  *MindexPathActionDelete; // 削除するIndexPath
	BOOL MbOptAntirotation;
	CGPoint		McontentOffsetDidSelect; // didSelect時のScrollView位置を記録
}

@property (nonatomic, retain) E0root	*Re0root;
@property (nonatomic, retain) E3record	*Re3edit;
#ifdef AzPAD
@property (nonatomic, assign) id									delegate;
@property (nonatomic, retain) UIPopoverController*	selfPopover;
// デリゲート・メソッド
- (void)refreshTable;
#endif

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
@end
