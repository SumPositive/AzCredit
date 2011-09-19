//
//  E3recordTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"


@interface E3recordTVC : UITableViewController <UIActionSheetDelegate
#ifdef AzPAD
	,UIPopoverControllerDelegate
#endif
>
{
@private
	//----------------------------------------------retain
	E0root				*Re0root;
#ifdef AzPAD
	id									delegate;
	UIPopoverController*	selfPopover;  // 自身を包むPopover  閉じる為に必要
#endif
	//----------------------------------------------loadViewにて生成 ⇒ unloadReleaseにて破棄
	NSDateFormatter	*RcellDateFormatter;	//[1.1.2]TableCell高速化のため
	NSMutableArray		*RaE3list;
	NSMutableArray		*RaSection;
	NSMutableArray		*RaIndex;
#ifdef FREE_AD
	GADBannerView		*RoAdMobView;
#endif
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
#ifdef AzPAD
	UIPopoverController	*Mpopover;
	NSIndexPath				*MindexPathEdit;
	UIPopoverController	*MpopSetting;			//回転時に閉じるため
#endif
	//----------------------------------------------assign
	E4shop			*Pe4shop;		// 
	E5category		*Pe5category;	// 
	E8bank			*Pe8bank;		//[0.3]New
	BOOL				PbAddMode;	//Stable// YES=表示直後、「新しい利用明細」へ遷移する
	BOOL				MbOptAntirotation;
	CGPoint			McontentOffsetDidSelect; // didSelect時のScrollView位置を記録
	//UITableViewScrollPositionTop
	UITableViewScrollPosition	MmoreScrollPosition;
}

@property (nonatomic, retain) E0root				*Re0root;
@property (nonatomic, assign) E4shop			*Pe4shop;
@property (nonatomic, assign) E5category		*Pe5category;
@property (nonatomic, assign) E8bank			*Pe8bank;
@property (nonatomic, assign) BOOL				PbAddMode;
#ifdef AzPAD
@property (nonatomic, assign) id									delegate;
@property (nonatomic, retain) UIPopoverController*	selfPopover;
//@property (nonatomic, assign) BOOL							PbFirstAdd;
// delegate method
- (void)refreshE3recordTVC:(BOOL)bSameDate;
//- (void)e3modified:(BOOL)bModified;
#endif

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用

@end
