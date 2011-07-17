//
//  TopMenuTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SFHFKeychainUtils.h"
#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "TopMenuTVC.h"
#import "E1cardTVC.h"
#import "GooDocsTVC.h"
#import "InformationView.h"
#import "SettingTVC.h"
#import "E2invoiceTVC.h"
#import "E3recordTVC.h"
#import "E3recordDetailTVC.h"
#import "E4shopTVC.h"
#import "E5categoryTVC.h"
#import "E7paymentTVC.h"
#import "E8bankTVC.h"
#import "WebSiteVC.h"
#import "HttpServerView.h"

#ifdef AzPAD
#import "PadRootVC.h"
//#import "PadPopoverInNaviCon.h"
#endif

#define TAG_ALERT_SupportSite		109
#define TAG_VIEW_HttpServer			118


@interface TopMenuTVC (PrivateMethods) // メソッドのみ記述：ここに変数を書くとグローバルになる。他に同じ名称があると不具合発生する
- (void)azInformationView;
- (void)azSettingView;
- (void)e3recordAdd;
#ifdef FREE_AD
- (void)AdRefresh;
- (void)bannerViewWillRotate:(UIInterfaceOrientation)toInterfaceOrientation;
#define FREE_AD_OFFSET_Y			200.0
#endif
#ifdef FREE_AD_PAD
- (void)AdRefresh;
- (void)bannerViewWillRotate:(UIInterfaceOrientation)toInterfaceOrientation;
#define FREE_AD_OFFSET_Y			200.0
#endif
@end

@implementation TopMenuTVC
@synthesize Re0root;
#ifdef AzPAD
//@synthesize selfPopover;
#endif


#pragma mark - Delegate

#ifdef AzPAD
- (void)setPopover:(UIPopoverController*)pc
{
	selfPopover = pc;
}
#endif


#pragma mark - Action

- (void)azInformationView
{
#ifdef  AzPAD
/*	if ([MpopInformation isPopoverVisible]==NO) {
		if (!MpopInformation) { //無ければ1度だけ生成する
			InformationView* vc = [[InformationView alloc] init];  //[1.0.2]Pad対応に伴いControllerにした。
			MpopInformation = [[UIPopoverController alloc] initWithContentViewController:vc];
			[vc release];
		}
		MpopInformation.delegate = nil;	// popoverControllerDidDismissPopover:を呼び出すと！落ちる！
		CGRect rcArrow;
		UIPopoverArrowDirection arrowDir;
		if (selfPopover) {	// Popover Menu のとき、[Menu]ボタンへアンカーする
			[selfPopover dismissPopoverAnimated:YES];
			rcArrow = CGRectMake(60, 5, 1,1); //[Menu]
			arrowDir = UIPopoverArrowDirectionUp;
		} else {
			rcArrow = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:3]];
			rcArrow.origin.x = rcArrow.size.width - 40;	rcArrow.size.width = 10;
			rcArrow.origin.y += 10;	rcArrow.size.height -= 20;
			arrowDir = UIPopoverArrowDirectionLeft;
		}
		[MpopInformation presentPopoverFromRect:rcArrow  inView:self.navigationController.view  
					   permittedArrowDirections:arrowDir animated:YES];
	}*/
	
	InformationView* vc = [[InformationView alloc] init];  //[1.0.2]Pad対応に伴いControllerにした。
	//vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	//[self presentModalViewController:vc animated:YES];
	AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	UINavigationController* naviRight = [apd.mainController.viewControllers objectAtIndex:1];	//[1]Right
	[naviRight popToRootViewControllerAnimated:NO];
	[naviRight pushViewController:vc animated:YES];
	[vc release];

#else
	if (self.interfaceOrientation != UIInterfaceOrientationPortrait) return; // 正面でなければ禁止
	// モーダル UIViewController
	if (MinformationView) {
		[MinformationView release], MinformationView = nil;
	}
	MinformationView = [[InformationView alloc] init];  //[1.0.2]Pad対応に伴いControllerにした。
	MinformationView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:MinformationView animated:YES];
	//[MinformationView release];
	//[MinformationView show];
#endif
}

- (void)azSettingView
{
#ifdef  AzPAD
/*	if ([MpopSetting isPopoverVisible]==NO) {
		if (!MpopSetting) { //無ければ1度だけ生成する
			SettingTVC* vc = [[SettingTVC alloc] init];  //[1.0.2]Pad対応に伴いControllerにした。
			MpopSetting = [[UIPopoverController alloc] initWithContentViewController:vc];
			[vc release];
		}
		MpopSetting.delegate = nil;	// popoverControllerDidDismissPopover:を呼び出すと！落ちる！
		CGRect rcArrow;
		UIPopoverArrowDirection arrowDir;
		if (selfPopover) {	// Popover Menu のとき、[Menu]ボタンへアンカーする
			[selfPopover dismissPopoverAnimated:YES];
			rcArrow = CGRectMake(40, 0, 1,1); //[Menu]
			arrowDir = UIPopoverArrowDirectionUp;
			[MpopSetting presentPopoverFromRect:rcArrow  inView:self.navigationController.view  
					   permittedArrowDirections:arrowDir  animated:YES];
		} else {
			rcArrow = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:3]];
			rcArrow.origin.x = rcArrow.size.width - 20;	rcArrow.size.width = 1;
			rcArrow.origin.y += 10;	rcArrow.size.height -= 20;
			arrowDir = UIPopoverArrowDirectionLeft;
			[MpopSetting presentPopoverFromRect:rcArrow  inView:self.tableView  
					   permittedArrowDirections:arrowDir  animated:YES];
		}
	}*/

	SettingTVC *view = [[SettingTVC alloc] init];
	//[self.navigationController pushViewController:view animated:YES];
	AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	UINavigationController* naviRight = [apd.mainController.viewControllers objectAtIndex:1];	//[1]Right
	[naviRight popToRootViewControllerAnimated:NO];
	[naviRight pushViewController:view animated:YES];
	[view release];

#else
	SettingTVC *view = [[SettingTVC alloc] init];
	[self.navigationController pushViewController:view animated:YES];
	[view release];
#endif
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag) {
		case TAG_ALERT_SupportSite:
			if (buttonIndex == 1) { // OK
				[[UIApplication sharedApplication] 
				 openURL:[NSURL URLWithString:@"http://paynote.tumblr.com/"]];
			}
			break;
	}
}

- (void)e3recordAdd
{
	if (MiE1cardCount <= 0) {
		alertBox(NSLocalizedString(@"No Card",nil),
				 NSLocalizedString(@"No Card msg",nil),
				 NSLocalizedString(@"Roger",nil));
		return;
	}
	
	// Add E3  【注意】同じE3Addが、E3recordTVC内にもある。
	//E3record *e3obj = [NSEntityDescription insertNewObjectForEntityForName:@"E3record"
	//												inManagedObjectContext:Re0root.managedObjectContext];
	E3record *e3obj = [MocFunctions insertAutoEntity:@"E3record"]; // autorelese
	e3obj.dateUse = [NSDate date]; // 迷子にならないように念のため
	e3obj.e1card = nil;
	e3obj.e4shop = nil;
	e3obj.e5category = nil;
	e3obj.e6parts = nil;

	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	e3detail.title = NSLocalizedString(@"Add Record", nil);
	e3detail.Re3edit = e3obj;
	e3detail.PiAdd = (1); // (1)New Add
	
#ifdef FREE_AD_PAD
	MbAdCanVisible = YES;	// E3Add状態のときだけｉＡｄ表示する
	[self AdRefresh];
#endif

#ifdef  AzPAD
	AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	UINavigationController* naviRight = [apd.mainController.viewControllers objectAtIndex:1];	//[1]Right
	[naviRight popToRootViewControllerAnimated:NO];
	// セル選択状態にする
	//[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
	//
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:e3detail];
	Mpopover = [[UIPopoverController alloc] initWithContentViewController:nc];
	Mpopover.delegate = self;	// popoverControllerDidDismissPopover:を呼び出してもらうため
	[nc release];
	// [+]Add mode
	CGRect rc = naviRight.view.bounds;  //  .navigationController.toolbar.frame;
	rc.origin.x += (rc.size.width/2 + 2);		rc.size.width = 1;
	rc.origin.y += (rc.size.height - 30);		rc.size.height = 1;
	[Mpopover presentPopoverFromRect:rc
							  inView:naviRight.view  permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
	e3detail.selfPopover = Mpopover;  [Mpopover release];
	e3detail.delegate = nil;	// ここでは、再描画不要
#else
	//e3detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:YES];
#endif	

	[e3detail release]; // self.navigationControllerがOwnerになる
}

- (void)barButtonAdd {
	// Add Card
	[self e3recordAdd];
}


#pragma mark - Ad - iPhone

#ifdef FREE_AD
//- (void)AdShowApple:(BOOL)bApple AdMob:(BOOL)bMob
- (void)AdRefresh
{
	NSLog(@"=== AdRefresh ===Can[%d] AdMob[%d⇒%d] iAd[%d⇒%d]", MbAdCanVisible, (int)RoAdMobView.alpha, (int)RoAdMobView.tag, (int)MbannerView.alpha, (int)MbannerView.tag);
	if (MbAdCanVisible && MbannerView.alpha==MbannerView.tag && RoAdMobView.alpha==RoAdMobView.tag) {
		NSLog(@"   = 変化なし =");
		return; // 変化なし
	}

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; // slow at end
	[UIView setAnimationDuration:1.2];
	
	if (MbannerView) {
		CGRect rc = MbannerView.frame;
		if (MbAdCanVisible && MbannerView.tag==1) {
			if (MbannerView.alpha==0) {
				rc.origin.y -= FREE_AD_OFFSET_Y;
				MbannerView.frame = rc;
				MbannerView.alpha = 1;
			}
		} else {
			if (MbannerView.alpha==1) {
				rc.origin.y += FREE_AD_OFFSET_Y;
				MbannerView.frame = rc;
				MbannerView.alpha = 0;
			}
		}
	}

	if (RoAdMobView) {
		CGRect rc = RoAdMobView.frame;
		if (MbAdCanVisible && RoAdMobView.tag==1) {
			if (RoAdMobView.alpha==0) {
				rc.origin.y = 480 - 44 - 50;		//AdMobはヨコ向き常に非表示（タテ向きのY座標ならば、ヨコ向きでは非表示）
				RoAdMobView.frame = rc;
				RoAdMobView.alpha = 1;
			}
		} else {
			if (RoAdMobView.alpha==1) {
				rc.origin.y = 480 + 10; // 下部へ隠す
				RoAdMobView.frame = rc;
				RoAdMobView.alpha = 0;	//[1.0.1]3GS-4.3.3においてAdで電卓キーが押せない不具合報告あり。未確認だがこれにて対応
			}
		}
	}
	
	[UIView commitAnimations];
}

- (void)bannerViewWillRotate:(UIInterfaceOrientation)toInterfaceOrientation
{	// 非表示中でも回転対応すること。表示するときの出発位置のため
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
			if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
				MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
			} else {
				MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
			}
		}
		float fYofs = 0;
		if (MbAdCanVisible && MbannerView.alpha==1) {
			// 表示
		} else {
			fYofs = FREE_AD_OFFSET_Y;  // 非表示：下へ隠す ＜＜ヨコからタテになっても見えないように大きめにすること
		}
		if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
			MbannerView.frame = CGRectMake(0, 320 - 32 - 32 + fYofs,  0,0);  // ヨコもToolbarあり
		} else {
			MbannerView.frame = CGRectMake(0, 480 - 44 - 50 + fYofs,  0,0);
		}
	}
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView 
{	// AdMob 広告あり
	NSLog(@"AdMob - adViewDidReceiveAd");
	bannerView.tag = 1;
	[self AdRefresh];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error 
{	// AdMob 広告なし
	NSLog(@"AdMob - adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
	bannerView.tag = 0;
	[self AdRefresh];
}

// iAd取得できたときに呼ばれる　⇒　表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{	// iAd 広告あり
	AzLOG(@"=== iAd : bannerViewDidLoadAd ===");
	banner.tag = 1;
	[self AdRefresh];
}

// iAd取得できなかったときに呼ばれる　⇒　非表示にする
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{	// iAd 広告なし
	AzLOG(@"=== iAd : didFailToReceiveAdWithError ===");
	banner.tag = 0;
	[self AdRefresh];
}

/*
// iAdバナーをタップしたときに呼ばれる
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{	// 広告表示前にする処理があれば記述
	return YES;
}

 // iAd 広告表示を閉じて元に戻る前に呼ばれる
 - (void)bannerViewActionDidFinish:(ADBannerView *)banner
 {
 AzLOG(@"===== bannerViewActionDidFinish =====");
 //[self iAdOff];  一度見れば消えるようにする
 }
 */
#endif

#pragma mark  Ad - iPad
#ifdef FREE_AD_PAD
//- (void)adBannerShow:(BOOL)bShow
- (void)AdRefresh;
{
	NSLog(@"=== AdRefresh ===Can[%d] AdMob[%d⇒%d] iAd[%d⇒%d]", MbAdCanVisible, (int)RoAdMobView.alpha, (int)RoAdMobView.tag, (int)MbannerView.alpha, (int)MbannerView.tag);
	if (MbAdCanVisible && MbannerView.alpha==MbannerView.tag && RoAdMobView.alpha==RoAdMobView.tag) {
		NSLog(@"   = 変化なし =");
		return; // 変化なし
	}
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.6];
	
	if (MbannerView) {
		CGRect rc = MbannerView.frame;
		if (MbAdCanVisible && MbannerView.tag==1) {
			if (MbannerView.alpha==0) {
				rc.origin.y += FREE_AD_OFFSET_Y;
				MbannerView.frame = rc;
				MbannerView.alpha = 1;
			}
		} else {
			if (MbannerView.alpha==1) {
				rc.origin.y -= FREE_AD_OFFSET_Y;
				MbannerView.frame = rc;
				MbannerView.alpha = 0;
			}
		}
	}

	if (RoAdMobView) {
		if (RoAdMobView.tag==1) { //AdMob常時表示なので、MbAdCanVisible判定不要
			RoAdMobView.alpha = 1;
		} else {
			RoAdMobView.alpha = 0;
		}
	}

	//アニメ開始
	[UIView commitAnimations];
}

- (void)bannerViewWillRotate:(UIInterfaceOrientation)toInterfaceOrientation
{	// 非表示中でも回転対応すること。表示するときの出発位置のため
	NSLog(@"iAd - bannerViewWillRotate");
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
			} else {				MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
			}
		}
		
		if (MbAdCanVisible && MbannerView.alpha==1) {
			MbannerView.frame = CGRectMake(0, 40,  0,0);	// 表示
		} else {
			MbannerView.frame = CGRectMake(0, 40 - FREE_AD_OFFSET_Y,  0,0);  // 非表示
		}
	}
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView 
{	// AdMob 広告あり
	NSLog(@"AdMob - adViewDidReceiveAd");
	bannerView.tag = 1;
	[self AdRefresh];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error 
{	// AdMob 広告なし
	NSLog(@"AdMob - adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
	bannerView.tag = 0;
	[self AdRefresh];
}

// iAd取得できたときに呼ばれる　⇒　表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	NSLog(@"iAd - bannerViewDidLoadAd ===");
	banner.tag = 1;
	[self AdRefresh];
}

// iAd取得できなかったときに呼ばれる　⇒　非表示にする
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	NSLog(@"iAd - didFailToReceiveAdWithError");
	banner.tag = 0;
	[self AdRefresh];
}
/*
// iAdバナーをタップしたときに呼ばれる
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{	// 広告表示前にする処理があれば記述
	NSLog(@"iAd - bannerViewActionShouldBegin");
	return YES;
}

 - (void)bannerViewActionDidFinish:(ADBannerView *)banner
 {
	NSLog(@"iAd - bannerViewActionDidFinish");
 //[self iAdOff];  一度見れば消えるようにする
 }
 */
#endif


#pragma mark - View lifecycle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStyleGrouped]; // セクションありテーブル
	if (self) {
		// 初期化成功
#ifdef AzPAD
		self.contentSizeForViewInPopover = CGSizeMake(320, 650);
#endif
		// インストールやアップデート後、1度だけ処理する
		NSString *zNew = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString* zDef = [defaults valueForKey:@"DefVersion"];
		if (![zDef isEqualToString:zNew]) {
			[defaults setValue:zNew forKey:@"DefVersion"];
			MbInformationOpen = YES; // Informationを自動オープンする
		} else {
			MbInformationOpen = NO;
		}
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
//【Tips】ここでaddSubviewするオブジェクトは全てautoreleaseにすること。メモリ不足時には自動的に解放後、改めてここを通るので、初回同様に生成するだけ。
- (void)loadView
{
	NSLog(@"--- loadView --- TopMenuTVC");
	[super loadView];

#ifdef AzPAD
	self.title = @"Menu";
	self.navigationItem.hidesBackButton = YES;
#else
	self.title = NSLocalizedString(@"Product Title",nil);
	// Set up NEXT Left [Back] buttons.
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithImage:[UIImage imageNamed:@"Icon16-Return1.png"]
											  style:UIBarButtonItemStylePlain  target:nil  action:nil] autorelease];
#endif
	
#if defined(AzFREE) && !defined(AzPAD)
	UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon24-Free.png"]];
	UIBarButtonItem* bui = [[UIBarButtonItem alloc] initWithCustomView:iv];
	self.navigationItem.leftBarButtonItem	= bui;
	[bui release];
	[iv release];
#endif

#ifndef AzMAKE_SPLASHFACE
	// Tool Bar Button
#ifdef AzPAD
	// Cell配置により、ボタンなし
#else
	UIBarButtonItem *buFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			 target:nil action:nil] autorelease];
	MbuToolBarInfo = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon16-Information.png"]
													   style:UIBarButtonItemStylePlain  //Bordered
													  target:self action:@selector(azInformationView)] autorelease];
	UIBarButtonItem *buSet = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon16-Setting.png"]
															   style:UIBarButtonItemStylePlain  //Bordered
															  target:self action:@selector(azSettingView)] autorelease];
	UIBarButtonItem *buAdd = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																			target:self action:@selector(barButtonAdd)] autorelease];
	NSArray *buArray = [NSArray arrayWithObjects: MbuToolBarInfo, buFlex, buAdd, buFlex, buSet, nil];
	[self setToolbarItems:buArray animated:YES];
#endif
#endif	
	
#ifdef FREE_AD 
	//--------------------------------------------AdMob
	RoAdMobView = [[[GADBannerView alloc]
				   initWithFrame:CGRectMake(0.0,
											480 + 10,	// 下部に隠す
											GAD_SIZE_320x50.width,
											GAD_SIZE_320x50.height)] autorelease];
	RoAdMobView.adUnitID = AdMobID_iPhone;
	RoAdMobView.rootViewController = self;
	[self.navigationController.view addSubview:RoAdMobView];
	
	GADRequest *request = [GADRequest request];
	//[request setTesting:YES];
	[RoAdMobView loadRequest:request];	
	
	//--------------------------------------------iAd : AdMobの上層になるように後からaddSubviewする
	//NG//float fOSversion =  [[[UIDevice currentDevice] systemVersion] floatValue];  NG// "4.2" --> 4.19999になるため
	//NSLog(@" [[UIDevice currentDevice] systemVersion]=%@", [[UIDevice currentDevice] systemVersion]);
	if ([[[UIDevice currentDevice] systemVersion] compare:@"4.0"]!=NSOrderedAscending) { // !<  (>=) "4.0"
		assert(NSClassFromString(@"ADBannerView"));
		//													出現前の隠れる↓位置を指定している。
		MbannerView = [[[ADBannerView alloc] init] autorelease];  // initWithFrame:CGRectZero]; 

		if ([[[UIDevice currentDevice] systemVersion] compare:@"4.2"]==NSOrderedAscending) { // < "4.2"
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
		[self.navigationController.view addSubview:MbannerView];
	}
	
	// Adパラメータ初期化
	RoAdMobView.alpha = 0;	// 現在状況、(0)非表示  (1)表示中
	RoAdMobView.tag = 0;		// 広告受信状況  (0)なし (1)あり
	RoAdMobView.delegate = self;

	MbannerView.alpha = 0;		// 現在状況、(0)非表示  (1)表示中
	MbannerView.tag = 0;		// 広告受信状況  (0)なし (1)あり
	MbannerView.delegate = self;
	
	MbAdCanVisible = NO;		// 現在状況、(0)表示禁止  (1)表示可能
	[self willRotateToInterfaceOrientation:self.splitViewController.interfaceOrientation duration:0]; // 非表示位置にセット
#endif

#ifdef FREE_AD_PAD
	//--------------------------------------------AdMob
	RoAdMobView = [[[GADBannerView alloc] initWithFrame:CGRectMake(
																  0, 0, GAD_SIZE_300x250.width, GAD_SIZE_300x250.height)] autorelease];
	RoAdMobView.adUnitID = AdMobID_iPad;
	RoAdMobView.rootViewController = self.splitViewController;
	[self.splitViewController.view addSubview:RoAdMobView];
	GADRequest *request = [GADRequest request];
#ifdef xxxAzDEBUG
	//[request setTestDevices: ]; こちらに変えろとのことだが、仕様不明
	//[request setTesting:YES];
#endif
	[RoAdMobView loadRequest:request];	
	
	//--------------------------------------------iAd : AdMobの上層になるように後からaddSubviewする
	if (MbannerView==nil && NSClassFromString(@"ADBannerView")) {
		//													出現前の隠れる↓位置を指定している。
		MbannerView = [[[ADBannerView alloc] initWithFrame:CGRectZero] autorelease]; 
		
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
		[self.splitViewController.view addSubview:MbannerView];
	}
	
	// Adパラメータ初期化
	RoAdMobView.alpha = 0;	// 現在状況、(0)非表示  (1)表示中
	RoAdMobView.tag = 0;		// 広告受信状況  (0)なし (1)あり
	RoAdMobView.delegate = self;
	
	MbannerView.alpha = 0;		// 現在状況、(0)非表示  (1)表示中
	MbannerView.tag = 0;		// 広告受信状況  (0)なし (1)あり
	MbannerView.delegate = self;
	
	MbAdCanVisible = NO;		// 現在状況、(0)表示禁止  (1)表示可能
	[self willRotateToInterfaceOrientation:self.splitViewController.interfaceOrientation duration:0]; // 非表示位置にセット
#endif

	// ToolBar表示は、viewWillAppearにて回転方向により制御している。
}

// loadView の次に呼び出される
- (void)viewDidLoad 
{
	NSLog(@"--- viewDidLoad ---");
	MiE1cardCount = 0;			// viewWillAppearにてセット
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated 	// ＜＜見せない処理＞＞
{
    [super viewWillAppear:animated];

#ifdef AzPAD
	[self.navigationController setToolbarHidden:YES animated:animated]; // ツールバー消す
#else
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示する
#endif
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	//MbOptEnableSchedule = [defaults boolForKey:GD_OptEnableSchedule];
	//MbOptEnableCategory = [defaults boolForKey:GD_OptEnableCategory];
	
	
	
	//-----------------------------------------------------------------------------
	// E1card 件数を求める
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"E1card" 
											  inManagedObjectContext:Re0root.managedObjectContext];
	[fetchRequest setEntity:entity];
	// Fitch
	NSError *error = nil;
	NSArray *arFetch = [Re0root.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		AzLOG(@"Error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	MiE1cardCount = [arFetch count];
	[fetchRequest release];
	
	// TableView Reflesh
	[self.tableView reloadData];
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated
{	// ＜＜魅せる処理＞＞
    [super viewDidAppear:animated];
	//Menuは不要でしょう [self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
	
	if (MbInformationOpen) {	//initWithStyleにて判定処理している
		MbInformationOpen = NO;	// 以後、自動初期表示しない。
		[self azInformationView];  //[1.0.2]最初に表示する。バックグランド復帰時には通らない
	}
	
#ifdef FREE_AD
	// iAdは、bannerViewDidLoadAd を受信したとき開始となるためＮＯ
	// AdMobは、常時開始とするためYES
	MbAdCanVisible = YES;
	[self AdRefresh];
#endif
#ifdef FREE_AD_PAD
	if (selfPopover) {
		MbAdCanVisible = NO; //Popover Menuとして表示されるときはAd非表示
	} else {
		AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		UINavigationController* naviRight = [apd.mainController.viewControllers objectAtIndex:1];	//[1]Right
		if ([naviRight.visibleViewController isMemberOfClass:[PadRootVC class]]) {
			MbAdCanVisible = YES; // タテ⇒ヨコになったとき、右ペインVCが PadRootVC ならば iAd許可
		} else {
			MbAdCanVisible = NO;
		}
	}
	[self AdRefresh];
#endif
	
	// E7E2クリーンアップ：配下のE6が無くなったE2を削除し、さらに配下のE2が無くなったE7も削除する。
	//iPad-NG// [MocFunctions e7e2clean];  // [0.4.18]レス向上のためここで処理。バックグランド時だとE2やE7表示に戻ったとき落ちる可能性あるので没にした。
	//iPad-NG//【原因】左ペインにTopMenuが表示されたタイミングで、TopMenu:viewDidAppear:e7e2clean により削除されてしまい不具合発生した。
	//iPad-NG//【対応】[MocFunctions e7e2clean] 処理を E2 または E7 の unloadRelease に入れた。
	
	// Comback (-1)にして未選択状態にする
	//	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	// (0)This clear
	//	[appDelegate.RaComebackIndex replaceObjectAtIndex:0 withObject:[NSNumber numberWithLong:-1]];
}

// この画面が非表示になる直前に呼ばれる
- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
#ifdef FREE_AD
	// Ad非表示にする
	MbAdCanVisible = NO;  // 以後、Ad表示禁止
	[self AdRefresh];
#endif
}


#pragma mark View 回転

//---------------------------------------------------------------------------回転
// YES を返すと、回転と同時に willRotateToInterfaceOrientation が呼び出され、
//				回転後に didRotateFromInterfaceOrientation が呼び出される。
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	// ここでは回転の許可、禁止だけを判定する  （現在の向きは、self.interfaceOrientation で取得できる）

	if ([self.view viewWithTag:TAG_VIEW_HttpServer]) return NO;		// HttpServerView が表示中なので回転禁止

#ifdef AzPAD
	return YES;
#else
	if (interfaceOrientation==UIInterfaceOrientationPortrait) return YES; // 正面は常に許可
	return !MbOptAntirotation; // Not MbOptAntirotation
#endif
}

// shouldAutorotateToInterfaceOrientation で YES を返すと、回転開始時に呼び出される
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
								duration:(NSTimeInterval)duration
{
#ifdef AzPAD
#else
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
		// 正面：infoボタン表示
		MbuToolBarInfo.enabled = YES;
	} else {
		MbuToolBarInfo.enabled = NO;
		if (MinformationView) {
			[MinformationView hide]; // 正面でなければhide
		}
	}
#endif
#ifdef FREE_AD
	[self bannerViewWillRotate:toInterfaceOrientation];
#endif
#ifdef FREE_AD_PAD
	if (MbannerView) {
		[self bannerViewWillRotate:toInterfaceOrientation];	// 非表示中も回転対応すること。表示するときの出発位置のため
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
										   768-24-GAD_SIZE_300x250.height,
										   GAD_SIZE_300x250.width, GAD_SIZE_300x250.height);
		}
	}
#endif
}

#ifdef AzPAD
// 回転した後に呼び出される
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{	// Popoverの位置を調整する　＜＜UIPopoverController の矢印が画面回転時にターゲットから外れてはならない＞＞
	
/*	if ([MpopInformation isPopoverVisible]) {
		[MpopInformation dismissPopoverAnimated:YES];
	}
	
	if ([MpopSetting isPopoverVisible]) {
		[MpopSetting dismissPopoverAnimated:YES];
	}*/
	
	if ([Mpopover isPopoverVisible]) {
		// Popoverの位置を調整する　＜＜UIPopoverController の矢印が画面回転時にターゲットから外れてはならない＞＞
/*		if (MindexPathEdit) { 
			[self.tableView scrollToRowAtIndexPath:MindexPathEdit 
								  atScrollPosition:UITableViewScrollPositionMiddle animated:NO]; // YESだと次の座標取得までにアニメーションが終了せずに反映されない
			CGRect rc = [self.tableView rectForRowAtIndexPath:MindexPathEdit];
			rc.origin.x += (rc.size.width - 30);		rc.size.width = 20;	// 右側にPopoverさせるため
			rc.origin.y += 10;	rc.size.height -= 20;
			[Mpopover presentPopoverFromRect:rc  inView:self.tableView 
					permittedArrowDirections:UIPopoverArrowDirectionLeft  animated:YES]; //表示開始
		} else {
			// アンカー位置 [Menu]
			CGRect rc = self.view.bounds;  //  .navigationController.toolbar.frame;
			rc.origin.x = 60;		rc.size.width = 20;
			rc.origin.y = 30;		rc.size.height = 20;
			[Mpopover presentPopoverFromRect:rc  inView:self.view	//<<<<<.view !!!
					permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES]; //表示開始
		}*/
		// アンカー位置 [Menu]
		// [+]Add mode
		AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		UINavigationController* naviRight = [apd.mainController.viewControllers objectAtIndex:1];	//[1]Right
		CGRect rc = naviRight.view.bounds;  //  .navigationController.toolbar.frame;
		rc.origin.x += (rc.size.width/2 + 2);		rc.size.width = 1;
		rc.origin.y += (rc.size.height - 30);		rc.size.height = 1;
		[Mpopover presentPopoverFromRect:rc
								  inView:naviRight.view  permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
	}
}
#endif

#pragma mark  View - Unload - dealloc

- (void)unloadRelease {	// dealloc, viewDidUnload から呼び出される
	//【Tips】loadViewでautorelease＆addSubviewしたオブジェクトは全てself.viewと同時に解放されるので、ここでは解放前の停止処理だけする。
	//【Tips】デリゲートなどで参照される可能性のあるデータなどは破棄してはいけない。
	NSLog(@"--- unloadRelease --- TopMenuTVC");
#ifdef FREE_AD
	MbAdCanVisible = NO;  // 以後、Ad表示禁止
	
	if (MbannerView) {
		[MbannerView cancelBannerViewAction];	//[1.0.1] 停止
		MbannerView.delegate = nil;							// 解放メソッドを呼び出さないようにする
		//[MbannerView removeFromSuperview];		// UIView解放		retainCount -1
		//[MbannerView release], MbannerView = nil;	// alloc解放			retainCount -1
	}
	
	if (RoAdMobView) {
		RoAdMobView.delegate = nil;								//受信STOP  ＜＜これが無いと破棄後に呼び出されて落ちる
		//[RoAdMobView release], RoAdMobView = nil;	// 破棄
	}
#endif
#ifdef FREE_AD_PAD
	if (MbannerView) {
		[MbannerView cancelBannerViewAction];	// 停止
		MbannerView.delegate = nil;							// 解放メソッドを呼び出さないようにする
		//[MbannerView removeFromSuperview];		// UIView解放		retainCount -1
		//[MbannerView release], MbannerView = nil;	// alloc解放			retainCount -1
	}
	
	if (RoAdMobView) {	// AdMobは、unloadReleaseすると落ちる
		RoAdMobView.delegate = nil;  //受信STOP  ＜＜これが無いと破棄後に呼び出されて落ちる
		//[RoAdMobView release], RoAdMobView = nil;
	}
#endif
	
#ifdef AzPAD
#else
	[MinformationView hide];
	[MinformationView release], MinformationView = nil;	// azInformationViewにて生成
#endif
}

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
#ifdef AzPAD
//	[MpopInformation release], MpopInformation = nil;
//	[MpopSetting release], MpopSetting = nil;
#endif
	[self unloadRelease];
	// @property (retain)
	[Re0root release], Re0root = nil;
	[super dealloc];
}

// メモリ不足時に呼び出されるので不要メモリを解放する。 ただし、カレント画面は呼ばない。
- (void)viewDidUnload 
{
	//NSLog(@"--- viewDidUnload ---"); 
	[self unloadRelease]; //必ずsuperより先に処理
	[super viewDidUnload];
	// この後に loadView ⇒ viewDidLoad ⇒ viewWillAppear がコールされる
}


/* iOS3.0以降では、viewDidUnload を使うようになった。
 - (void)didReceiveMemoryWarning {
 AzLOG(@"MEMORY! TopMenuTVC: didReceiveMemoryWarning");
 [super didReceiveMemoryWarning];
 }
 */


#pragma mark - TableView lifecycle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // セクションは1つだけ section==0
#ifdef AzMAKE_SPLASHFACE
	return 0;
#else
	switch (section) {
		case 0:			// 利用明細
			return 2;
			break;
		case 1:			// 集計
			return 3;
			break;
		case 2:			// 分類
			return 2;
			break;
		case 3:			// 機能
			return 4;
			break;
	}
	return 0;
#endif
}

#ifdef FREE_AD_PAD
// TableView セクションタイトルを応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	if (section==0) return @"\n     Free edition\n\n";	// iAd上部スペース
	return nil;
}
#endif

// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{
#ifndef AzMAKE_SPLASHFACE
	switch (section) {
		case 3:
#ifdef FREE_AD_PAD
			return	@"\n\n\n\n\n\nAzukiSoft Project\n©2000-2011 Azukid\n\n\n\n\n\n\n";  //iPad//AdMobが表示されているとき最終セルが隠れないようにする
#else
			return	@"\nAzukiSoft Project\n©2000-2011 Azukid\n";
#endif
			break;
	}
#endif
	return nil;
}

/*
// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 44; // デフォルト：44ピクセル
}
*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"CellMenu";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier] autorelease];

#ifdef AzPAD
		cell.textLabel.font = [UIFont systemFontOfSize:18];
#else
		cell.textLabel.font = [UIFont systemFontOfSize:16];
#endif
		//cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.textColor = [UIColor blackColor];
    }
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //[>]
	
	switch (indexPath.section) {
		case 0: //-------------------------------------------------------------Statement
		{
			switch (indexPath.row) {
				case 0:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-GreenPlus.png"];
					cell.textLabel.text = NSLocalizedString(@"Add Record", nil);
					break;
				case 1:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Statements.png"];
					cell.textLabel.text = NSLocalizedString(@"Record list", nil);
					break;
			}
		} break;
			
		case 1: //-------------------------------------------------------------Paid/Unpaid
		{
			switch (indexPath.row) {
				case 0:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Schedule.png"];
					//cell.textLabel.text = NSLocalizedString(@"Payment list", nil);
					// E7 未払い総額
					cell.detailTextLabel.textAlignment = UITextAlignmentRight;
					if ([Re0root.e7unpaids count] <= 0) {
						cell.textLabel.text = [NSString stringWithFormat:@"%@   %@",
											   NSLocalizedString(@"Payment list",nil), 
											   NSLocalizedString(@"No unpaid",nil)];
					} else {
						NSDecimalNumber *decUnpaid = [Re0root valueForKeyPath:@"e7unpaids.@sum.sumAmount"];
						// Amount
						NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
						[formatter setNumberStyle:NSNumberFormatterCurrencyStyle]; // 通貨スタイル（先頭に通貨記号が付く）
						[formatter setLocale:[NSLocale currentLocale]]; 
#ifdef xxxAzPAD
						cell.textLabel.text = [NSString stringWithFormat:@"%@      （%@  %@）", 
											   NSLocalizedString(@"Payment list",nil), 
											   NSLocalizedString(@"Unpaid",nil), 
											   [formatter stringFromNumber:decUnpaid]];
#else
						cell.textLabel.text = [NSString stringWithFormat:@"%@   %@", 
											   NSLocalizedString(@"Payment list",nil), 
											   [formatter stringFromNumber:decUnpaid]];
#endif
						[formatter release];
					}
					break;
				case 1:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Recipient.png"];
					cell.textLabel.text = NSLocalizedString(@"Recipient list", nil);
					break;
				case 2:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Bank.png"];
					cell.textLabel.text = NSLocalizedString(@"Bank list", nil);
					break;
			}
		} break;
			
		case 2: //-------------------------------------------------------------Groups
		{
			switch (indexPath.row) {
				case 0:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Shop.png"];
					cell.textLabel.text = NSLocalizedString(@"Shop list", nil);
					break;
				case 1:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Category.png"];
					cell.textLabel.text = NSLocalizedString(@"Category list", nil);
					break;
			}
		} break;
		
		case 3: //-------------------------------------------------------------Function
		{
			switch (indexPath.row) {
				case 0:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Google.png"];
					cell.textLabel.text = NSLocalizedString(@"Communicate with Google", nil);
					break;
				case 1:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-NearPC.png"];
					cell.textLabel.text = NSLocalizedString(@"Communicate with your PC", nil);
					break;
				case 2:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Setting.png"];
					cell.textLabel.text = NSLocalizedString(@"Setting", nil);
					break;
				case 3:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Information.png"];
					cell.textLabel.text = NSLocalizedString(@"Information", nil);
					break;
			}
		} break;
			
	}
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
#ifdef FREE_AD_PAD
	if (indexPath.section!=0 || indexPath.row!=0) {
		MbAdCanVisible = NO;	// E3Addでなければ、ｉＡｄ非表示
		[self AdRefresh];
	}
#endif

	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
/*	// Comback-L0 TopMenu 記録
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	long lPos = indexPath.section * GD_SECTION_TIMES + indexPath.row;
	// (0)This >> (1)Clear
	[appDelegate.RaComebackIndex replaceObjectAtIndex:0 withObject:[NSNumber numberWithLong:lPos]];
	[appDelegate.RaComebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:-1]];
*/
	
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

	switch (indexPath.section) {
		case 0:
		{
			switch (indexPath.row) {
				case 0: // Add Record
#ifdef FREE_AD_PAD
					MbAdCanVisible = YES; // iAd許可
					[self AdRefresh];
#endif
					[self e3recordAdd]; // E3record 新規追加
					break;
				case 1: // 最近の明細　E3 < E3detail
				{	// E3records へ
					E3recordTVC *tvc = [[E3recordTVC alloc] init];
#ifdef AzDEBUG
					tvc.title = [NSString stringWithFormat:@"E3 %@", cell.textLabel.text];
#else
					tvc.title = cell.textLabel.text;
#endif
					tvc.Re0root = Re0root;
					//tvc.Pe1card = nil;  // =nil:最近の全E3表示モード　　=e1obj:指定E1以下を表示することができる
					tvc.Pe4shop = nil;
					tvc.Pe5category = nil;
#ifdef AzPAD
					AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
					UINavigationController* naviRight = [apd.mainController.viewControllers objectAtIndex:1];	//[1]Right
					[naviRight popToRootViewControllerAnimated:NO];
					[naviRight pushViewController:tvc animated:YES];
#else
					[self.navigationController pushViewController:tvc animated:YES];
#endif
					[tvc release];
				}
					break;
			}
		}
			break;
		case 1:
		{
			switch (indexPath.row) {
				case 0: // 支払予定　E7 < E2 < E6 < E3detail
				{
					// E7paymentTVC へ
					E7paymentTVC *tvc = [[E7paymentTVC alloc] init];
#ifdef AzDEBUG
					tvc.title = [NSString stringWithFormat:@"E7 %@", NSLocalizedString(@"Payment list",nil)];
#else
					tvc.title = NSLocalizedString(@"Payment list",nil); //cell.textLabel.text;
#endif
					tvc.Re0root = Re0root;
#ifdef AzPAD
					AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
					UINavigationController* naviRight = [apd.mainController.viewControllers objectAtIndex:1];	//[1]Right
					[naviRight popToRootViewControllerAnimated:NO];
					[naviRight pushViewController:tvc animated:YES];
#else
					[self.navigationController pushViewController:tvc animated:YES];
#endif
					[tvc release];
				}
					break;
				case 1: // カード一覧  E1 < E2 < E6 < E3detail
				{
					// E1card へ
					E1cardTVC *tvc = [[E1cardTVC alloc] init];
#ifdef AzDEBUG
					tvc.title = [NSString stringWithFormat:@"E1 %@", cell.textLabel.text];
#else
					tvc.title = cell.textLabel.text;
#endif
					tvc.Re0root = Re0root;
					tvc.Re3edit = nil;
#ifdef AzPAD
					AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
					UINavigationController* naviRight = [apd.mainController.viewControllers objectAtIndex:1];	//[1]Right
					[naviRight popToRootViewControllerAnimated:NO];
					[naviRight pushViewController:tvc animated:YES];
#else
					[self.navigationController pushViewController:tvc animated:YES];
#endif
					[tvc release];
				}
					break;
				case 2: // 銀行等口座一覧  E8 
				{
					// E8bank へ
					E8bankTVC *tvc = [[E8bankTVC alloc] init];
#ifdef AzDEBUG
					tvc.title = [NSString stringWithFormat:@"E8 %@", cell.textLabel.text];
#else
					tvc.title = cell.textLabel.text;
#endif
					tvc.Re0root = Re0root;
					tvc.Pe1card = nil;
#ifdef AzPAD
					AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
					UINavigationController* naviRight = [apd.mainController.viewControllers objectAtIndex:1];	//[1]Right
					[naviRight popToRootViewControllerAnimated:NO];
					[naviRight pushViewController:tvc animated:YES];
#else
					[self.navigationController pushViewController:tvc animated:YES];
#endif
					[tvc release];
				}
					break;
			}
		}
			break;
		case 2:
		{
			switch (indexPath.row) {
				case 0: // 利用店一覧  E4 < E3 < E3detail
				{
					E4shopTVC *tvc = [[E4shopTVC alloc] init];
#ifdef AzDEBUG
					tvc.title = [NSString stringWithFormat:@"E4 %@", cell.textLabel.text];
#else
					tvc.title = cell.textLabel.text;
#endif
					tvc.Re0root = Re0root;
					tvc.Pe3edit = nil;
#ifdef AzPAD
					AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
					UINavigationController* naviRight = [apd.mainController.viewControllers objectAtIndex:1];	//[1]Right
					[naviRight popToRootViewControllerAnimated:NO];
					[naviRight pushViewController:tvc animated:YES];
#else
					[self.navigationController pushViewController:tvc animated:YES];
#endif
					[tvc release];
				}
					break;
				case 1: // 分類一覧  E5 < E3 < E3detail
				{
					E5categoryTVC *tvc = [[E5categoryTVC alloc] init];
#ifdef AzDEBUG
					tvc.title = [NSString stringWithFormat:@"E5 %@", cell.textLabel.text];
#else
					tvc.title = cell.textLabel.text;
#endif
					tvc.Re0root = Re0root;
					tvc.Pe3edit = nil;
#ifdef AzPAD
					AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
					UINavigationController* naviRight = [apd.mainController.viewControllers objectAtIndex:1];	//[1]Right
					[naviRight popToRootViewControllerAnimated:NO];
					[naviRight pushViewController:tvc animated:YES];
#else
					[self.navigationController pushViewController:tvc animated:YES];
#endif
					[tvc release];
				}
					break;
			}
		}
			break;
		case 3: // Function
		{
			switch (indexPath.row) {
				case 0:
				{ // Google Document
					GooDocsTVC *goodocs = [[GooDocsTVC alloc] init];
					// 以下は、GooDocsViewの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
					goodocs.title = cell.textLabel.text;
					goodocs.Re0root = Re0root;
#ifdef AzPAD
					AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
					UINavigationController* naviRight = [apd.mainController.viewControllers objectAtIndex:1];	//[1]Right
					[naviRight popToRootViewControllerAnimated:NO];
					[naviRight pushViewController:goodocs animated:YES];
#else
					goodocs.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
					[self.navigationController pushViewController:goodocs animated:YES];
#endif
					[goodocs release];
				}
					break;
				case 1:
				{  // Backup/Restore for YourPC
					//NG//[self.navigationController setToolbarHidden:YES animated:YES]; // ツールバー消す
					//NG//ツールバーを消したいが、戻ったとき表示する方法が未定。
					HttpServerView *vi = [[HttpServerView alloc] initWithFrame:[self.view bounds]];
					vi.Pe0root = Re0root;
					vi.tag = TAG_VIEW_HttpServer; // 表示中は回転禁止にするために参照している
#ifdef AzPAD
					AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
					UINavigationController* naviRight = [apd.mainController.viewControllers objectAtIndex:1];	//[1]Right
					//[naviRight popToRootViewControllerAnimated:NO];
					vi.frame = naviRight.view.bounds;
					[naviRight.view addSubview:vi];
#else
					[self.view addSubview:vi];
#endif
					[vi show];
					[vi release];
				}
					break;
				case 2:
				{  // Setting
#ifdef FREE_AD_PAD
					MbAdCanVisible = YES; // iAd許可
					[self AdRefresh];
#endif
					[self azSettingView];
				}
					break;
				case 3:
				{  // Information
#ifdef FREE_AD_PAD
					MbAdCanVisible = YES; // iAd許可
					[self AdRefresh];
#endif
					[self azInformationView];
				}
					break;
			}
		}
			break;
	}
#ifdef AzPAD
	if (selfPopover) {
		[selfPopover dismissPopoverAnimated:YES];
	}
#endif
}


#ifdef AzPAD
#pragma mark - <UIPopoverControllerDelegate>
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{	// Popoverの外部をタップして閉じる前に通知
	alertBox(NSLocalizedString(@"Cancel or Save",nil), NSLocalizedString(@"Cancel or Save msg",nil), NSLocalizedString(@"Roger",nil));
	return NO; // Popover外部タッチで閉じるのを禁止 ＜＜追加MOCオブジェクトをＣａｎｃｅｌ時に削除する必要があるため＞＞
/*
	// 内部(SAVE)から、dismissPopoverAnimated:で閉じた場合は呼び出されない。
	if ([popoverController.contentViewController isMemberOfClass:[UINavigationController class]]) {
		UINavigationController* nav = (UINavigationController*)popoverController.contentViewController;
		if (0 < [nav.viewControllers count] && [[nav.viewControllers objectAtIndex:0] isMemberOfClass:[E3recordDetailTVC class]]) 
		{	// Popover外側をタッチしたとき cancelClose: を通っていないので、ここで通す。 ＜＜＜同じ処理が E3recordTVC.m にもある＞＞＞
			E3recordDetailTVC* e3tvc = (E3recordDetailTVC *)[nav.viewControllers objectAtIndex:0]; //Root VC   <<<.topViewControllerではダメ>>>
			if ([e3tvc respondsToSelector:@selector(cancelClose:)]) {	// メソッドの存在を確認する
				[e3tvc cancelClose:nil];	// 新しいObject破棄
			}
		}
	}
	return YES; // 閉じることを許可
*/
}
#endif


@end

