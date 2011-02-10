//
//  E3recordDetailTVC.h.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E3record;
@class CalcView;

@interface E3recordDetailTVC : UITableViewController  <UIActionSheetDelegate>
{
	//--------------------------retain
	E3record	*Re3edit;
	//--------------------------assign
	NSInteger	PiAdd;				// (0)Edit (>=1)Add:Cancel時にRe3editを削除する
									//		     (1)New (2)Card固定 (3)Shop固定 (4)Category固定
	NSInteger	PiFirstYearMMDD;	// PbAdd=YESのとき、E2がこの支払日以降になるように追加する
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	E0root			*Me0root;		// Arrayではない！単独　release不要（するとFreeze）
	NSMutableArray	*Me6parts;
	NSMutableArray	*Me3lasts;		// 前回引用するための直近3件
//	E3record		*Me3editMask;	// Re3editをコピーしておき、比較することにより、その間で修正された箇所を検出するため
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UIBarButtonItem		*MbuTop;		// BarButton ＜hasChanges時に無効にするため＞
	UISegmentedControl	*MsegAddPrevious;
	UILabel				*MlbAmount;
	CalcView			*McalcView;
	//----------------------------------------------assign
	BOOL			MbOptAntirotation;
	BOOL			MbOptEnableCategory;
	BOOL			MbOptEnableInstallment;
	BOOL			MbOptUseDateTime;
//	BOOL			MbOptNumAutoShow;
//	BOOL			MbOptFixedPriority;
	BOOL			MbAddmode;			// cancel:
	NSInteger		MiE1cardRow;
	BOOL			MbE6paid;			// YES:PAIDあり、主要条件の変更禁止！
	BOOL			MbCopyAdd;			// YES:既存明細をコピーして新規追加している状態
	BOOL			MbRotatShowCalc;	// YES:回転前に表示されていたので、回転後再表示する。
	NSInteger		MiIndexE3lasts;
}

@property (nonatomic, retain) E3record	*Re3edit;
//@property BOOL							PbAdd;
@property NSInteger						PiAdd;
@property NSInteger						PiFirstYearMMDD;	

@end
