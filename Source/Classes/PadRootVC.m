//
//  PadRootVC.m
//  AzPacking
//
//  Created by Sum Positive on 11/05/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "PadRootVC.h"


@interface PadRootVC (PrivateMethods)
#ifdef FREE_AD_PAD
- (void)bannerViewWillRotate:(UIInterfaceOrientation)toInterfaceOrientation;
#endif
@end


@implementation PadRootVC
//@synthesize popoverController;
@synthesize popoverButtonItem;


- (void)unloadRelease	// dealloc, viewDidUnload から呼び出される
{
	NSLog(@"--- unloadRelease --- PadRootVC");
    //[popoverController release], popoverController = nil;
   [popoverButtonItem release], popoverButtonItem = nil;

#ifdef FREE_AD_PAD
	if (MbannerView) {
		[MbannerView cancelBannerViewAction];	// 停止
		MbannerView.delegate = nil;							// 解放メソッドを呼び出さないようにする
		[MbannerView removeFromSuperview];		// UIView解放		retainCount -1
		[MbannerView release], MbannerView = nil;	// alloc解放			retainCount -1
	}
	
	if (RoAdMobView) {	// AdMobは、unloadReleaseすると落ちる
		RoAdMobView.delegate = nil;  //受信STOP  ＜＜これが無いと破棄後に呼び出されて落ちる
		[RoAdMobView release], RoAdMobView = nil;
	}
#endif
}

- (void)dealloc
{
	[self unloadRelease];
    [super dealloc];
}

- (void)viewDidUnload 
{	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。
	// メモリ不足時、裏側にある場合に呼び出される。addSubviewされたOBJは、self.viewと同時に解放される
	[super viewDidUnload];  // TableCell破棄される
	[self unloadRelease];		// その後、AdMob破棄する
	//self.splitViewController = nil;
	self.popoverButtonItem = nil;
	// この後に loadView ⇒ viewDidLoad ⇒ viewWillAppear がコールされる
}


#pragma mark - View lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う
//（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
	//AzLOG(@"------- E1viewController: loadView");    
	[super loadView];

	self.view.backgroundColor = [UIColor colorWithRed:152/255.0f 
												green:81/255.0f 
												 blue:75/255.0f 
												alpha:1.0f];
	
	//------------------------------------------アイコン
	UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(124,124, 72,72)];
#ifdef AzSTABLE
	[iv setImage:[UIImage imageNamed:@"Icon72S1.png"]];
#else
	[iv setImage:[UIImage imageNamed:@"Icon72Free.png"]];
#endif
	[self.view addSubview:iv]; 
	[iv release], iv = nil;


#ifdef FREE_AD_PAD
	//--------------------------------------------AdMob
	RoAdMobView = [[GADBannerView alloc] initWithFrame:CGRectMake(
																  0, 0, GAD_SIZE_300x250.width, GAD_SIZE_300x250.height)];
	RoAdMobView.alpha = 1;
	RoAdMobView.adUnitID = AdMobID_iPad;
	RoAdMobView.rootViewController = self.splitViewController;
	//[self.view addSubview:RoAdMobView];
	[self.splitViewController.view addSubview:RoAdMobView];
	
	GADRequest *request = [GADRequest request];
	//[request setTesting:YES];
	[RoAdMobView loadRequest:request];	
	
	//--------------------------------------------iAd : AdMobの上層になるように後からaddSubviewする
	if (MbannerView==nil && NSClassFromString(@"ADBannerView")) {
		//													出現前の隠れる↓位置を指定している。
		MbannerView = [[ADBannerView alloc] initWithFrame:CGRectZero]; 
		
		if ([[[UIDevice currentDevice] systemVersion] compare:@"4.2"]==NSOrderedAscending) { // ＜ "4.2"
			// iOS4.2より前
			MbannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:
														  ADBannerContentSizeIdentifier320x50,
														  ADBannerContentSizeIdentifier480x32, nil];
		} else {
			// iOS4.2以降の仕様であるが、以前のOSでは落ちる！！！
			MbannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:
														  ADBannerContentSizeIdentifierPortrait,
														  ADBannerContentSizeIdentifierLandscape, nil];
		}
		//[self bannerViewWillRotate:self.splitViewController.interfaceOrientation];  // 表示位置セット
		MbannerView.delegate = self;
		//[self.view addSubview:MbannerView];
		[self.splitViewController.view addSubview:MbannerView];
		//retainCount +2 --> unloadRelease:にて　-2 している
	}
	
	[self willRotateToInterfaceOrientation:self.splitViewController.interfaceOrientation duration:0];
	//[self adBannerShow:YES]// E1viewController:viewDidAppear:にて表示開始している
#endif
}

/*
// nibファイルでロードされたオブジェクトを初期化する
- (void)viewDidLoad
{
    [super viewDidLoad];
}
 */

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示する
}

/* SplitViewは、透明なので通らない！
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
*/



#pragma mark - Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc
{
    barButtonItem.title = @"padRoot";
	//self.popoverController = pc;
    self.popoverButtonItem = barButtonItem;
	UINavigationController *navi = [svc.viewControllers objectAtIndex:1];
	UIViewController <DetailViewController> *detailVC = navi.visibleViewController;
	if ([detailVC respondsToSelector:@selector(showPopoverButtonItem:)]) {
		[detailVC showPopoverButtonItem:popoverButtonItem];
	}
}

- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem 
{
	UINavigationController *navi = [svc.viewControllers objectAtIndex:1];
	UIViewController <DetailViewController> *detailVC = navi.visibleViewController;
	if ([detailVC respondsToSelector:@selector(hidePopoverButtonItem:)]) {
		[detailVC hidePopoverButtonItem:popoverButtonItem];
	}
    //self.popoverController = nil;
	self.popoverButtonItem = nil;
}

#ifdef FREE_AD_PAD
// shouldAutorotateToInterfaceOrientation で YES を返すと、回転開始時に呼び出される
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
								duration:(NSTimeInterval)duration
{
	if (MbannerView) {
		[self bannerViewWillRotate:toInterfaceOrientation];
	}
	if (RoAdMobView) {
		if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {	// タテ
			RoAdMobView.frame = CGRectMake(
										   768-150-GAD_SIZE_300x250.width,
										   1024-64-GAD_SIZE_300x250.height,
										   GAD_SIZE_300x250.width, GAD_SIZE_300x250.height);
		} else {	// ヨコ
			RoAdMobView.frame = CGRectMake(
										   10,
										   768-64-GAD_SIZE_300x250.height,
										   GAD_SIZE_300x250.width, GAD_SIZE_300x250.height);
		}
	}
}

- (void)bannerViewWillRotate:(UIInterfaceOrientation)toInterfaceOrientation
{
	if (MbannerView) {
		if ([[[UIDevice currentDevice] systemVersion] compare:@"4.2"]==NSOrderedAscending) { // ＜ "4.2"
			// iOS4.2より前
			if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
				MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
			} else {
				MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
			}
		} else {
			// iOS4.2以降の仕様であるが、以前のOSでは落ちる！！！
			if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
				MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
			} else {
				MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
			}
		}
		if (MbAdBannerShow) {
			MbannerView.frame = CGRectMake(0,44,  0,0);
		} else {
			MbannerView.frame = CGRectMake(0,-200,  0,0);  // 非表示
		}
	}
}

//- (void)AdShowApple:(BOOL)bApple AdMob:(BOOL)bMob
- (void)adBannerShow:(BOOL)bShow
{
	AzLOG(@"=== adBannerShow[%d] ===", bShow);
	MbAdBannerShow = bShow;
	if (bShow==NO) { // 表示禁止
		if (MbannerView==nil || MbannerView.frame.origin.y<0 ) return; // 既に非表示
	}
	
	const float fOffset = -200;  // 上に隠す
	// 開始位置：非表示位置
	if (bShow && MbannerView) { // && MbannerEnabled  && MbannerActive
		[self bannerViewWillRotate:self.splitViewController.interfaceOrientation]; // この時点の向きによりY座標修正
		CGRect rc = MbannerView.frame;
		rc.origin.y += fOffset;
		MbannerView.frame = rc;
	}
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.6];
	
	if (MbannerView) {  // && MbannerEnabled && MbannerActive
		CGRect rc = MbannerView.frame;
		if (bShow) {
			rc.origin.y -= fOffset;
			MbannerView.delegate = self;
		} else {
			rc.origin.y += fOffset;
			MbannerView.delegate = nil; // 割り込み禁止
		}
		MbannerView.frame = rc;
	}
	// AdMob 常時表示
	[UIView commitAnimations];
}


// iAd取得できたときに呼ばれる　⇒　表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	AzLOG(@"=== bannerViewDidLoadAd ===");
	if (MbannerView && MbAdBannerShow) { // 許可中のみ通す ＜＜＜表示禁止中に呼び出されてもパスするように
		[self adBannerShow:YES];
	}
}

// iAd取得できなかったときに呼ばれる　⇒　非表示にする
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	if (MbannerView) {	// && MbannerActive
		AzLOG(@"=== didFailToReceiveAdWithError ===");
		[self adBannerShow:NO];
	}
}

// iAdバナーをタップしたときに呼ばれる
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{	// 広告表示前にする処理があれば記述
	return YES;
}

/*
 - (void)bannerViewActionDidFinish:(ADBannerView *)banner
 {
 AzLOG(@"===== bannerViewActionDidFinish =====");
 //[self iAdOff];  一度見れば消えるようにする
 }
 */
#endif


@end
