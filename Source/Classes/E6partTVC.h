//
//  E6partTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@class E2invoice;
@class E7payment;

@interface E6partTVC : UITableViewController
#ifdef AzPAD
	<UIPopoverControllerDelegate>
#endif
{
@private
	//----------------------------------------------retain
	//----------------------------------------------assign
	E2invoice		*Pe2select;		// E2配下のE6一覧　　どちらか一方だけセット、他方はnilにする  
	E7payment		*Pe7select;		// E7配下のE2配下のE6一覧　　どちらか一方だけセット、他方はnilにする
	NSMutableSet	*Pe2invoices;	// E2集合配下のE6一覧
	//--------------------------------
	NSInteger		PiFirstSection;	// 初期画面中央に表示するE2セクション
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray	*RaE2invoices;
	NSMutableArray	*RaE6parts;		// (Pe2invoices,E6parts) 二次元
#ifdef FREE_AD
	GADBannerView		*RoAdMobView;
#endif
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
#ifdef AzPAD
	UIPopoverController*	Mpopover;
	NSIndexPath*				MindexPathEdit;
#endif
	//----------------------------------------------assign
	E1card		*Me2e1card;
	E0root		*Me7e0root;
	BOOL		MbOptAntirotation;
	BOOL		MbFirstOne;
	NSInteger	MiForTheFirstSection;		// viewDidAppear内で最初に1回だけ画面スクロール位置調整するため
	CGPoint		McontentOffsetDidSelect; // didSelect時のScrollView位置を記録
}

@property (nonatomic, assign) E2invoice		*Pe2select;
@property (nonatomic, assign) E7payment		*Pe7select;
@property (nonatomic, assign) NSMutableSet	*Pe2invoices;
@property (nonatomic, assign) NSInteger		PiFirstSection;

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用

@end
