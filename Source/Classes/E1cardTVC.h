//
//  E1cardTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E1cardTVC : UITableViewController <UIPopoverControllerDelegate>
{
@private
	//--------------------------retain
//	E0root				*Re0root;
//	E3record			*Re3edit;		// =nil:マスタモード  !=nil:選択モード

//#ifdef AzPAD
	// E3recordDetailTVC から Popover で呼び出されるときにセットする
	//UIPopoverController*	selfPopover;  // 自身を包むPopover  閉じる為に必要
//#endif
	//--------------------------assign
//	id						__weak delegate;	
	E1card				*sourceE1card;
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray		*RaE1cards;
	//----------------------------------------------------------------Owner移管につきdealloc時のrelese不要
	//UIBarButtonItem	*MbuTop;		// BarButton ＜hasChanges時に無効にするため＞
	UIBarButtonItem *MbuAdd;
//#ifdef AzPAD
	//UIPopoverController*	Mpopover;
	NSIndexPath*				MindexPathEdit;	//[1.1.2]ポインタ代入注意！copyするように改善した。
//#endif
	//----------------------------------------------------------------assign
	NSIndexPath	  *MindexPathActionDelete; // 削除するIndexPath  	//[1.1.2]ポインタ代入注意！copyするように改善した。
	//BOOL MbOptAntirotation;
	CGPoint		McontentOffsetDidSelect; // didSelect時のScrollView位置を記録
}

@property (nonatomic, strong) E0root			*Re0root;
@property (nonatomic, strong) E3record		*Re3edit;
@property (nonatomic, assign) id					delegate;
//#ifdef AzPAD
//@property (nonatomic, retain) UIPopoverController*	selfPopover;
// デリゲート・メソッド
- (void)refreshTable;
//#endif

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
@end
