//
//  E5categoryTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E5categoryTVC : UITableViewController <UIActionSheetDelegate, UISearchBarDelegate> 
{
@private
	//--------------------------retain
	E0root		*Re0root;
	//--------------------------assign
	E3record	*Pe3edit;		// =nil:マスタモード  !=nil:選択モード

	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray			*RaE5categorys;
	//----------------------------------------------------------------Owner移管につきdealloc時のrelese不要
	UIBarButtonItem	*MbuTop;		// BarButton ＜hasChanges時に無効にするため＞
	//----------------------------------------------------------------assign
	NSIndexPath	  *MindexPathActionDelete; // 削除するIndexPath
	BOOL MbOptAntirotation;
	NSInteger MiOptE5SortMode;
	CGPoint		McontentOffsetDidSelect; // didSelect時のScrollView位置を記録
}

@property (nonatomic, retain) E0root	*Re0root;
@property (nonatomic, assign) E3record	*Pe3edit;

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
@end
