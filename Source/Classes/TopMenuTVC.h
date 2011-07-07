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

@class InformationView;

@interface TopMenuTVC : UITableViewController  <UITextFieldDelegate
#ifdef AzPAD
	,UIPopoverControllerDelegate
#endif
#ifdef FREE_AD
	,ADBannerViewDelegate
#endif
>
{
@private
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	E0root				*Re0root;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UIBarButtonItem		*MbuToolBarInfo;	// 正面ON,以外OFFにするため
#ifdef AzPAD
	UIPopoverController*	Mpopover;
	NSIndexPath*				MindexPathEdit;
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
	//----------------------------------------------assign
	NSInteger	MiE1cardCount;
	BOOL			MbOptAntirotation;
	BOOL			MbInformationOpen;	//[1.0.2]InformationViewを初回自動表示するため
}

@property (nonatomic, retain) E0root				*Re0root;

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用

@end
