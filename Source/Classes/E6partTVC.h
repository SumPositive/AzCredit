//
//  E6partTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E2invoice;
@class E7payment;

@interface E6partTVC : UITableViewController // <UIActionSheetDelegate> 
{
	//----------------------------------------------retain
	//----------------------------------------------assign
	E2invoice		*Pe2select;		// E2配下のE6一覧　　どちらか一方だけセット、他方はnilにする  
	E7payment		*Pe7select;		// E7配下のE2配下のE6一覧　　どちらか一方だけセット、他方はnilにする
	NSMutableSet	*Pe2invoices;	// E2集合配下のE6一覧
	//--------------------------------
	NSInteger		PiFirstSection;	// 初期画面中央に表示するE2セクション
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSAutoreleasePool	*MautoreleasePool;		// [0.3]autorelease独自解放のため
	NSMutableArray	*Me2invoices;
	NSMutableArray	*Me6parts;		// (Pe2invoices,E6parts) 二次元
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	E1card		*Me2e1card;
	E0root		*Me7e0root;
	E6part		*Me6actionDelete;		// commitEditingStyle:にてセット、actionSheet:にて削除実行
	BOOL		MbOptAntirotation;
	BOOL		MbFirstOne;
	NSInteger	MiForTheFirstSection;		// viewDidAppear内で最初に1回だけ画面スクロール位置調整するため
}

@property (nonatomic, assign) E2invoice		*Pe2select;
@property (nonatomic, assign) E7payment		*Pe7select;
@property (nonatomic, assign) NSMutableSet	*Pe2invoices;
@property (nonatomic, assign) NSInteger		PiFirstSection;

- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用

@end
