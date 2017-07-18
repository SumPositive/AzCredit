//
//  E8bankTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface E8bankTVC : UITableViewController <UIActionSheetDelegate
//#ifdef AzPAD
	,UIPopoverControllerDelegate
//#endif
>
{
@private
	//--------------------------retain
//	E0root		*Re0root;
	//--------------------------assign
//	E1card		*__weak Pe1card;		// =nil:マスタモード  !=nil:選択モード
	E8bank	*sourceE8bank;
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray		*RaE8banks;
	NSIndexPath	  *MindexPathActionDelete; // 削除するIndexPath	//[1.1.2]ポインタ代入注意！copyするように改善した。
//#ifdef AzPAD
	NSIndexPath*				MindexPathEdit;	//[1.1.2]ポインタ代入注意！copyするように改善した。
//#endif
	//----------------------------------------------------------------Owner移管につきdealloc時のrelese不要
	UIBarButtonItem	*MbuTop;		// BarButton ＜hasChanges時に無効にするため＞
	UIBarButtonItem *MbuAdd;
//#ifdef AzPAD
//	UIPopoverController*	Mpopover;		// 回転時に位置調整するため
//#endif
	//----------------------------------------------------------------assign
	//BOOL MbOptAntirotation;
	CGPoint		McontentOffsetDidSelect; // didSelect時のScrollView位置を記録
}

@property (nonatomic, assign) E0root	*Re0root;
@property (nonatomic, assign) E1card      *Pe1card;

//#ifdef AzPAD
// delegate method
- (void)refreshTable;
//#endif

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
@end
