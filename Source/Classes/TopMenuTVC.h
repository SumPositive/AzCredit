//
//  TopMenuTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef FREE_AD
#import <iAd/iAd.h>
#endif

@class InformationView;
@class E0root;

@interface TopMenuTVC : UITableViewController  <UITextFieldDelegate
//#ifdef AzPAD
	,UIPopoverControllerDelegate
//#endif
#ifdef FREE_AD
	,ADBannerViewDelegate
//	,GADBannerViewDelegate
#endif
>
{
@private
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	E0root				*Re0root;
//#ifdef AzPAD
	UIPopoverController*	selfPopover;  // 自身を包むPopover  閉じる為に必要
//#endif
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
//#ifdef AzPAD
	UIPopoverController*	Mpopover;
//#else
	InformationView		*MinformationView;
	UIBarButtonItem		*MbuToolBarInfo;	// 正面ON,以外OFFにするため
//#endif
#ifdef FREE_AD
	ADBannerView		*MbannerView;
//	GADBannerView		*RoAdMobView;
	BOOL						MbAdCanVisible;		//YES:表示可能な状況　 NO:表示してはいけない状況
#endif
	//----------------------------------------------assign
	NSInteger	MiE1cardCount;
	//BOOL			MbOptAntirotation;
	BOOL			MbInformationOpen;	//[1.0.2]InformationViewを初回自動表示するため
	CGFloat		mAdPositionY;
}

@property (nonatomic, strong) E0root				*Re0root;

//#ifdef AzPAD
- (void)setPopover:(UIPopoverController*)pc;
- (void)e3detailAdd;				//PadRootVCからdelegate呼び出しされる
- (void)refreshTopMenuTVC;	// E3recordDetailTVC:から呼び出される
- (void)popoverClose;				// AppDelegate:applicationDidEnterBackground: から呼び出される
//#endif

@end
