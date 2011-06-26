//
//  E4shopTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef AzPAD
@class PadPopoverInNaviCon;
#endif

@interface E4shopTVC : UITableViewController <UIActionSheetDelegate, UISearchBarDelegate> 
{
@private
	//--------------------------retain
	E0root		*Re0root;
#ifdef AzPAD
	PadPopoverInNaviCon*	RpopNaviCon;
#endif
	//--------------------------assign
	E3record	*Pe3edit;	// =nil:マスタモード  !=nil:選択モード

	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray		*RaE4shops;
	//----------------------------------------------------------------Owner移管につきdealloc時のrelese不要
	UIBarButtonItem	*MbuTop;		// BarButton ＜hasChanges時に無効にするため＞
	//----------------------------------------------------------------assign
	NSIndexPath	  *MindexPathActionDelete; // 削除するIndexPath
	BOOL MbOptAntirotation;
	NSInteger MiOptE4SortMode;
	CGPoint		McontentOffsetDidSelect; // didSelect時のScrollView位置を記録
}

@property (nonatomic, retain) E0root	*Re0root;
@property (nonatomic, assign) E3record	*Pe3edit;
#ifdef AzPAD
@property (nonatomic, retain) PadPopoverInNaviCon*	RpopNaviCon;
#endif

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
@end
