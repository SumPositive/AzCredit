//
//  TopMenuTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "GADBannerView.h"

#ifdef FREE_AD
#import "GADBannerViewDelegate.h"
#endif
#ifdef FREE_AD_PAD
#import <iAd/iAd.h>
#import "GADBannerView.h"
#endif

@class InformationView;
@class E0root;

@interface TopMenuTVC : UITableViewController  <UITextFieldDelegate
#ifdef AzPAD
	,UIPopoverControllerDelegate
#endif
#ifdef FREE_AD
	,ADBannerViewDelegate
#endif
#ifdef FREE_AD_PAD
	,ADBannerViewDelegate
#endif
>
{
@private
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	E0root				*Re0root;
#ifdef AzPAD
	UIPopoverController*	selfPopover;  // 自身を包むPopover  閉じる為に必要
#endif
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UIBarButtonItem		*MbuToolBarInfo;	// 正面ON,以外OFFにするため
#ifdef AzPAD
	UIPopoverController*	Mpopover;
	//NSIndexPath*				MindexPathEdit;
	UIPopoverController*	MpopInformation;	//回転時に閉じるため
	UIPopoverController*	MpopSetting;			//回転時に閉じるため
#else
	InformationView		*MinformationView;
#endif
#ifdef FREE_AD
	ADBannerView		*MbannerView;
	GADBannerView		*RoAdMobView;
	BOOL						MbAdCanVisible;		//[1.0.1]=YES:表示可能　=NO:表示厳禁
#endif
#ifdef FREE_AD_PAD
	ADBannerView		*MbannerView;
	GADBannerView		*RoAdMobView;
	BOOL						MbAdBannerShow;  // =NO:非表示（表示禁止中）
#endif
	//----------------------------------------------assign
	NSInteger	MiE1cardCount;
	BOOL			MbOptAntirotation;
	BOOL			MbInformationOpen;	//[1.0.2]InformationViewを初回自動表示するため
}

@property (nonatomic, retain) E0root				*Re0root;
#ifdef AzPAD
//@property (nonatomic, retain) UIPopoverController*	selfPopover;
#endif

#ifdef FREE_AD_PAD
- (void)adBannerShow:(BOOL)bShow;
#endif

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
#ifdef AzPAD
- (void)setPopover:(UIPopoverController*)pc;
- (void)e3recordAdd;	//PadRootVCからdelegate呼び出しされる
#endif

@end
