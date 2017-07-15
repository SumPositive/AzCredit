//
//  E3recordDetailTVC.h.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E0root;
@class E3record;
@class E3recordTVC;
@class CalcView;

@interface E3recordDetailTVC : UITableViewController  <UIActionSheetDelegate>
{
@private
	//--------------------------retain
	E3record		*Re3edit;
//#ifdef AzPAD
	//id									delegate;
	//UIPopoverController*	selfPopover;  // 自身を包むPopover  閉じる為に必要
//#endif
	//--------------------------assign
	NSInteger	PiAdd;				// (0)Edit (>=1)Add:Cancel時にRe3editを削除する  ＜iPad:変更無ければPopover外タッチでCancel＞
												// (1)New (2)Card固定 (3)Shop固定 (4)Category固定  ＜iPad:Popover外タッチで閉じさせない＞
	NSInteger	PiFirstYearMMDD;	// 「この支払日になるように利用明細を追加」のとき、支払日が渡される
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray		*RaE6parts;
	NSMutableArray		*RaE3lasts;		// 前回引用するための直近3件
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	E0root						*Me0root;		// Arrayではない！単独　release不要（するとFreeze）
	UIBarButtonItem		*MbuDelete;		// BarButton ＜PAID時に無効にするため＞ [0.3]
	UILabel					*MlbAmount;
	CalcView					*McalcView;
	UIView						*McalcMaskView;
//#ifdef AzPAD
	NSInteger				MiSourceYearMMDD;	// 修正前の利用日、[Save]時に比較して同じならば修正行だけ再表示し、変化あれば全再表示する
//#else
	UIBarButtonItem		*MbuTop;		// BarButton ＜hasChanges時に無効にするため＞
//#endif
	//----------------------------------------------assign
	AppDelegate *appDelegate;
	BOOL			MbE1cardChange;
	
	//BOOL			MbOptAntirotation;
	BOOL			MbOptEnableInstallment;
	BOOL			MbOptUseDateTime;
	NSInteger		MiE1cardRow;
	BOOL			MbE6checked;		// YES:全回Check済、主要条件の変更禁止！
	BOOL			MbE6paid;				// YES:1回でもPAIDあり、主要条件の変更禁止！
	BOOL			MbCopyAdd;			// YES:既存明細をコピーして新規追加している状態
	BOOL			MbRotatShowCalc;	// YES:回転前に表示されていたので、回転後再表示する。
	NSInteger	MiIndexE3lasts;
	BOOL			MbModified;			// AppDelegate.entityModified方式へ統一変更したが、一部参照している。
	BOOL			MbSaved;			// YES:保存ボタンが押されて、前のViewへ戻る途中。E6が削除されている可能性があるので再描画禁止にする。
}

@property (nonatomic, retain) E3record		*Re3edit;
@property NSInteger							PiAdd;
@property NSInteger							PiFirstYearMMDD;	
//#ifdef AzPAD
@property (nonatomic, assign) id									delegate;
@property (nonatomic, retain) UIPopoverController*	selfPopover;
//#endif

// 公開メソッド
- (void)cancelClose:(id)sender ;
- (void)remakeE6change:(int)iChange;


@end
