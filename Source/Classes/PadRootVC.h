//
//  PadRootVC.h
//  AzPacking
//
//  Created by Sum Positive on 11/05/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef FREE_AD_PAD
#import <iAd/iAd.h>
#import "GADBannerView.h"
#endif


@protocol DetailViewController
- (void)showPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
- (void)hidePopoverButtonItem:(UIBarButtonItem *)barButtonItem;
@end


@interface PadRootVC : UIViewController <UISplitViewControllerDelegate
#ifdef FREE_AD_PAD
	,ADBannerViewDelegate
#endif
>
{
@private
    //UIPopoverController		*popoverController;    
    UIBarButtonItem				*popoverButtonItem;
	
#ifdef FREE_AD_PAD
	ADBannerView		*MbannerView;
	GADBannerView		*RoAdMobView;
	BOOL						MbAdBannerShow;  // =NO:非表示（表示禁止中）
#endif
}

//@property (nonatomic, retain) UIPopoverController		*popoverController;
@property (nonatomic, retain) UIBarButtonItem			*popoverButtonItem;

#ifdef FREE_AD_PAD
- (void)adBannerShow:(BOOL)bShow;
#endif

@end
