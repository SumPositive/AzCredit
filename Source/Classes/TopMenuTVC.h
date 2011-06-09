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

#ifdef GD_Ad_ENABLED
#import "GADBannerViewDelegate.h"
#endif

@class InformationView;

@interface TopMenuTVC : UITableViewController
#ifdef GD_Ad_ENABLED
	<ADBannerViewDelegate>
#endif
{
@private
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	E0root				*Re0root;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	InformationView		*MinformationView;
#ifdef GD_Ad_ENABLED
	ADBannerView		*MbannerView;
	GADBannerView		*RoAdMobView;
	BOOL						MbAdCanVisible;		//[1.0.1]=YES:表示可能　=NO:表示厳禁
#endif
	UIBarButtonItem		*MbuToolBarInfo;	// 正面ON,以外OFFにするため
	//----------------------------------------------assign
	NSInteger	MiE1cardCount;
	BOOL			MbOptAntirotation;
	BOOL			MbInformationOpen;	//[1.0.2]InformationViewを初回自動表示するため
}

@property (nonatomic, retain) E0root				*Re0root;

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
@end
