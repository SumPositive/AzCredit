//
//  TopMenuTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@class InformationView;

@interface TopMenuTVC : UITableViewController <ADBannerViewDelegate>
{
@private
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	E0root				*Re0root;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	InformationView		*MinformationView;
	ADBannerView		*MbannerView;
	//UIView				*MviewLogin;
	UIBarButtonItem		*MbuToolBarInfo;	// 正面ON,以外OFFにするため
	//----------------------------------------------assign
	BOOL		MbannerEnabled;		// YES=iAd 許可（TopMenuViewのときだけ）
	BOOL		MbannerActive;
	//.hidden利用//BOOL MbannerIsVisible;	// YES=iAd 今表示されている
	NSInteger	MiE1cardCount;
	BOOL		MbOptAntirotation;
}

@property (nonatomic, retain) E0root				*Re0root;

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
@end
