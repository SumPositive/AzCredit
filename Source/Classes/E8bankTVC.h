//
//  E8bankTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#define E8LISTVIEW_SIZE		CGSizeMake(380, 500)

#ifdef AzPAD
//@class PadPopoverInNaviCon;
#endif

@interface E8bankTVC : UITableViewController <UIActionSheetDelegate
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
	E1card		*Pe1card;		// =nil:マスタモード  !=nil:選択モード

	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray		*RaE8banks;
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
@property (nonatomic, assign) E1card	*Pe1card;
#ifdef AzPAD
@property (nonatomic, assign) id									delegate;
@property (nonatomic, retain) UIPopoverController*	selfPopover;
// delegate method
- (void)refreshTable;
#endif

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
@end
