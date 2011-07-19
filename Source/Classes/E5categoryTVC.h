//
//  E5categoryTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef AzPAD
//@class PadPopoverInNaviCon;
#endif

@interface E5categoryTVC : UITableViewController <UIActionSheetDelegate, UISearchBarDelegate
#ifdef AzPAD
	,UIPopoverControllerDelegate
#endif
>
{
@private
	//--------------------------retain
	E0root		*Re0root;
#ifdef AzPAD
	id									delegate;
	UIPopoverController*	selfPopover;  // 自身を包むPopover  閉じる為に必要
#endif
	//--------------------------assign
	E3record			*Pe3edit;		// =nil:マスタモード  !=nil:選択モード
	E5category		*sourceE5category;
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray			*RaE5categorys;
	//----------------------------------------------------------------Owner移管につきdealloc時のrelese不要
	UIBarButtonItem	*MbuTop;		// BarButton ＜hasChanges時に無効にするため＞
#ifdef AzPAD
	UIPopoverController*	Mpopover;		// 回転時に位置調整するため
	NSIndexPath*				MindexPathEdit;
#endif
	//----------------------------------------------------------------assign
	NSIndexPath	  *MindexPathActionDelete; // 削除するIndexPath
	BOOL MbOptAntirotation;
	NSInteger MiOptE5SortMode;
	CGPoint		McontentOffsetDidSelect; // didSelect時のScrollView位置を記録
}

@property (nonatomic, retain) E0root	*Re0root;
@property (nonatomic, assign) E3record	*Pe3edit;
#ifdef AzPAD
@property (nonatomic, assign) id									delegate;
@property (nonatomic, retain) UIPopoverController*	selfPopover;
// delegate method
- (void)refreshTable;
#endif

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
@end
