//
//  E4shopTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface E4shopTVC : UITableViewController <UISearchBarDelegate
//#ifdef AzPAD
	,UIPopoverControllerDelegate
//#endif
>
{
@private
	//--------------------------retain
//	E0root		*Re0root;
//#ifdef AzPAD
	//id									delegate;
	//UIPopoverController*	selfPopover;  // 自身を包むPopover  閉じる為に必要
//#endif
	//--------------------------assign
//	E3record		*__weak Pe3edit;	// =nil:マスタモード  !=nil:選択モード
	E4shop		*sourceE4shop;
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray		*RaE4shops;
	NSString					*RzSearchText;		//[1.1.2]検索文字列を記録しておき、該当が無くて新しく追加する場合の初期値にする
	NSIndexPath	  *MindexPathActionDelete; // 削除するIndexPath  	//[1.1.2]ポインタ代入注意！copyするように改善した。
//#ifdef AzPAD
	NSIndexPath*				MindexPathEdit;	//[1.1.2]ポインタ代入注意！copyするように改善した。
//#endif
	//----------------------------------------------------------------Owner移管につきdealloc時のrelese不要
	UIBarButtonItem		*MbuTop;		// BarButton ＜hasChanges時に無効にするため＞
//#ifdef AzPAD
//	UIPopoverController*	Mpopover;		// 回転時に位置調整するため
//#endif
	//----------------------------------------------------------------assign
	//BOOL MbOptAntirotation;
	NSInteger MiOptE4SortMode;
	CGPoint		McontentOffsetDidSelect; // didSelect時のScrollView位置を記録
}

@property (nonatomic, strong) E0root	*Re0root;
@property (nonatomic, assign) E3record	*Pe3edit;
//#ifdef AzPAD
@property (nonatomic, assign) id									delegate;
//@property (nonatomic, retain) UIPopoverController*	selfPopover;
// delegate method
- (void)refreshTable;
//#endif

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
@end
