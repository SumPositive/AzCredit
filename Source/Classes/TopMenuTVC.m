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

#define AD_HIDDEN_OFS_Y		200		//iAdを非表示/表示するときのＹ軸変位


@interface TopMenuTVC (PrivateMethods) // メソッドのみ記述：ここに変数を書くとグローバルになる。他に同じ名称があると不具合発生する
- (void)azInformationView;
- (void)azSettingView;
- (void)e3recordAdd;

#ifdef FREE_AD
//- (void)iAdOn;
//- (void)iAdOff;
- (void)AdShowApple:(BOOL)bApple AdMob:(BOOL)bMob;
- (void)bannerViewWillRotate:(UIInterfaceOrientation)toInterfaceOrientation;
#endif
@end

@implementation TopMenuTVC
@synthesize Re0root;


#pragma mark - Action

- (void)azInformationView
{
#ifdef  AzPAD
	if (MinformationView) {
		[MinformationView release], MinformationView = nil;
	}
	MinformationView = [[InformationView alloc] init];  //[1.0.2]Pad対応に伴いControllerにした。
	//MinformationView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
	[Mpopover release], Mpopover = nil;
	//Mpopover = [[PadPopoverInNaviCon alloc] initWithContentViewController:MinformationView];
	Mpopover = [[UIPopoverController alloc] initWithContentViewController:MinformationView];
	Mpopover.delegate = nil;	// popoverControllerDidDismissPopover:を呼び出すと！落ちる！
	CGRect rcArrow;
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) { //iPad初期、常にタテになる。原因不明
		rcArrow = CGRectMake(0, 1027-60, 32,32);
	} else {
		rcArrow = CGRectMake(0, 768-60, 32,32);
	}
	Mpopover.popoverContentSize = CGSizeMake(320, 510);
	[Mpopover presentPopoverFromRect:rcArrow  inView:self.navigationController.view  
			permittedArrowDirections:UIPopoverArrowDirectionDown  animated:YES];
#else
	if (self.interfaceOrientation != UIInterfaceOrientationPortrait) return; // 正面でなければ禁止
/*	// ヨコ非対応につき正面以外は、hideするようにした。
	if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
		return; // 正面だけにボタン表示するようにしたので通らないハズだが、念のため。
	}
	
	if (MinformationView==nil) {
		MinformationView = [[InformationView alloc] initWithFrame:[self.view.window bounds]];
		[self.view.window addSubview:MinformationView]; //回転しないが、.viewから出すとToolBarが隠れない
		//NG//[MinformationView release] viewDidUnloadにて解放
	}*/
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
	SettingTVC *view = [[SettingTVC alloc] init];
#ifdef  AzPAD
	[Mpopover release], Mpopover = nil;
	//Mpopover = [[PadPopoverInNaviCon alloc] initWithContentViewController:vi];
	Mpopover = [[UIPopoverController alloc] initWithContentViewController:view];
	Mpopover.delegate = nil;	// popoverControllerDidDismissPopover:を呼び出すと！落ちる！
	CGRect rcArrow;
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		rcArrow = CGRectMake(768-32, 1027-60, 32,32);
	} else {
		rcArrow = CGRectMake(1024-320-32, 768-60, 32,32);
	}
	Mpopover.popoverContentSize = CGSizeMake(480, 300);
	[Mpopover presentPopoverFromRect:rcArrow	inView:self.navigationController.view  
			permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
#else
	//view.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:view animated:YES];
#endif
	[view release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag) {
		case TAG_ALERT_SupportSite:
			if (buttonIndex == 1) { // OK
				[[UIApplication sharedApplication] 
				 openURL:[NSURL URLWithString:@"http://azukisoft.seesaa.net/category/9034665-1.html"]];
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

#ifdef xxxAzDEBUG
	// DEBUG : insertAutoEntityで生成されたEntityは、rollBack では削除されないことを確認した。
	e3obj.nAmount = [NSDecimalNumber decimalNumberWithString:@"999001"];
	NSLog(@"*****1***** e3obj=%@", e3obj);
	NSLog(@"*****1***** e3obj.nAmount=%@", e3obj.nAmount);
	[MocFunctions rollBack];
	NSLog(@"*****2***** e3obj=%@", e3obj);
	NSLog(@"*****2***** e3obj.nAmount=%@", e3obj.nAmount);
	e3obj.dateUse = [NSDate date]; // 迷子にならないように念のため
	e3obj.nAmount = [NSDecimalNumber decimalNumberWithString:@"999002"];
	NSLog(@"*****3***** e3obj=%@", e3obj);
	NSLog(@"*****3***** e3obj.nAmount=%@", e3obj.nAmount);
	return;
#endif
	
	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	e3detail.title = NSLocalizedString(@"Add Record", nil);
	e3detail.Re3edit = e3obj;
	e3detail.PiAdd = (1); // (1)New Add
	
#ifdef  AzPAD
	//Mpopover = [[PadPopoverInNaviCon alloc] initWithContentViewController:e3detail];
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:e3detail];
	Mpopover = [[UIPopoverController alloc] initWithContentViewController:nc];
	Mpopover.delegate = self;	// popoverControllerDidDismissPopover:を呼び出してもらうため
	[nc release];
	MindexPathEdit = [NSIndexPath indexPathForRow:0 inSection:0];
	CGRect rc = [self.tableView rectForRowAtIndexPath:MindexPathEdit];
	rc.origin.x += rc.size.width/2;		rc.size.width /= 2;	// 右に寄せる、次のPopoverをできるだけ左側に表示するため
	rc.origin.y += 10;	rc.size.height -= 20;
	Mpopover.popoverContentSize = E3DETAILVIEW_SIZE;
	[Mpopover presentPopoverFromRect:rc
							  inView:self.tableView  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	e3detail.selfPopover = Mpopover; [Mpopover release];
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


#pragma mark - Ad

#ifdef FREE_AD
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
			if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
				MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
			} else {
				MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
			}
		}
		if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
			MbannerView.frame = CGRectMake(0, 320 - 32 - 32,  0,0);  // ヨコもToolbarあり
		} else {
			MbannerView.frame = CGRectMake(0, 480 - 44 - 50,  0,0);
		}
	}
}

- (void)AdShowApple:(BOOL)bApple AdMob:(BOOL)bMob
{
	AzLOG(@"=== AdShowApple[%d] AdMob[%d] ===", bApple, bMob);
	// 開始位置：非表示位置
	if (bApple && MbAdCanVisible && MbannerView) {
		[self bannerViewWillRotate:self.interfaceOrientation]; // この時点の向きによりY座標修正 ＜＜ヨコ向き表示にも対応するため＞＞
		CGRect rc = MbannerView.frame;
		rc.origin.y += AD_HIDDEN_OFS_Y;
		MbannerView.frame = rc;
	}
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; // slow at end
	[UIView setAnimationDuration:1.2];
	
	if (MbannerView) {
		CGRect rc = MbannerView.frame;
		if (bApple && MbAdCanVisible) {
			rc.origin.y -= AD_HIDDEN_OFS_Y;
			MbannerView.alpha = 1;
			//MbannerView.delegate = self;
			bMob = NO;
		} else {
			rc.origin.y += AD_HIDDEN_OFS_Y;
			MbannerView.alpha = 0;		//[1.0.1]3GS-4.3.3においてAdで電卓キーが押せない不具合報告あり。未確認だがこれにて対応
			//MbannerView.delegate = nil; //NG//Unhandled error発生する。破棄直前にだけ=nilする
		}
		MbannerView.frame = rc;
		//[MbannerView cancelBannerViewAction];	//[1.0.1]STOP
	}
	if (RoAdMobView) {
		CGRect rc = RoAdMobView.frame;
		if (bMob && MbAdCanVisible) {
			rc.origin.y = 480 - 44 - 50;		//AdMobはヨコ向き常に非表示（タテ向きのY座標ならば、ヨコ向きでは非表示）
			RoAdMobView.alpha = 1;
		} else {
			rc.origin.y = 480 + 10; // 下部へ隠す
			RoAdMobView.alpha = 0;	//[1.0.1]3GS-4.3.3においてAdで電卓キーが押せない不具合報告あり。未確認だがこれにて対応
		}
		RoAdMobView.frame = rc;
	}
	
	[UIView commitAnimations];
}

// iAd取得できたときに呼ばれる　⇒　表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	AzLOG(@"=== iAd : bannerViewDidLoadAd ===");
	if (MbAdCanVisible && MbannerView) {
		[self AdShowApple:YES AdMob:NO];
	}
}

// iAd取得できなかったときに呼ばれる　⇒　非表示にする
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	AzLOG(@"=== iAd : didFailToReceiveAdWithError ===");
	if (MbannerView) {
		[self AdShowApple:NO AdMob:YES];
	}
}

// iAdバナーをタップしたときに呼ばれる
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{	// 広告表示前にする処理があれば記述
	return YES;
}

/*
 // iAd 広告表示を閉じて元に戻る前に呼ばれる
 - (void)bannerViewActionDidFinish:(ADBannerView *)banner
 {
 AzLOG(@"===== bannerViewActionDidFinish =====");
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
#ifdef FREE_AD
		MbAdCanVisible = NO;
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
- (void)loadView
{
	NSLog(@"--- loadView ---");
	[super loadView];

	// Set up NEXT Left [Back] buttons.
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]
									   initWithImage:[UIImage imageNamed:@"Icon16-Return1.png"]
									   style:UIBarButtonItemStylePlain  target:nil  action:nil] autorelease];
	
#if defined(AzFREE) && !defined(AzPAD)
	UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon24-Free.png"]];
	UIBarButtonItem* bui = [[UIBarButtonItem alloc] initWithCustomView:iv];
	self.navigationItem.leftBarButtonItem	= bui;
	[bui release];
	[iv release];
#endif

#ifndef AzMAKE_SPLASHFACE
	// Tool Bar Button
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	MbuToolBarInfo = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon16-Information.png"]
													  style:UIBarButtonItemStylePlain  //Bordered
													 target:self action:@selector(azInformationView)];
	UIBarButtonItem *buAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																		   target:self action:@selector(barButtonAdd)];
	UIBarButtonItem *buSet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon16-Setting.png"]
															  style:UIBarButtonItemStylePlain  //Bordered
															 target:self action:@selector(azSettingView)];
	NSArray *buArray = [NSArray arrayWithObjects: MbuToolBarInfo, buFlex, buAdd, buFlex, buSet, nil];
	[self setToolbarItems:buArray animated:YES];
	[MbuToolBarInfo release];
	[buAdd release];
	[buSet release];
	[buFlex release];
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
	
	self.title = NSLocalizedString(@"Product Title",nil);
	
	//[0.4]以降、ヨコでもツールバーを表示するようにした。
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示する
	
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
	
	
#ifdef FREE_AD 
	MbAdCanVisible = YES;
	//--------------------------------------------AdMob
	if (RoAdMobView==nil) {
		RoAdMobView = [[GADBannerView alloc]
					   initWithFrame:CGRectMake(0.0,
												480 + 10,	// 下部に隠す
												GAD_SIZE_320x50.width,
												GAD_SIZE_320x50.height)];
		//RoAdMobView.delegate = self;
		
		RoAdMobView.adUnitID = AdMobID_iPhone;
		RoAdMobView.rootViewController = self;
		[self.navigationController.view addSubview:RoAdMobView];
		
		GADRequest *request = [GADRequest request];
		//[request setTesting:YES];
		[RoAdMobView loadRequest:request];	
	}
	
	//--------------------------------------------iAd : AdMobの上層になるように後からaddSubviewする
	if (MbannerView==nil) {
		//NG//float fOSversion =  [[[UIDevice currentDevice] systemVersion] floatValue];  NG// "4.2" --> 4.19999になるため
		//NSLog(@" [[UIDevice currentDevice] systemVersion]=%@", [[UIDevice currentDevice] systemVersion]);
		if ([[[UIDevice currentDevice] systemVersion] compare:@"4.0"]!=NSOrderedAscending) { // !<  (>=) "4.0"
			assert(NSClassFromString(@"ADBannerView"));
			//													出現前の隠れる↓位置を指定している。
			MbannerView = [[ADBannerView alloc] init];  // initWithFrame:CGRectZero]; 
			MbannerView.delegate = self;
			
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
			[self bannerViewWillRotate:self.interfaceOrientation];  // 表示位置セット
			CGRect rc = MbannerView.frame;
			rc.origin.y += AD_HIDDEN_OFS_Y;  // 下部に隠す
			MbannerView.frame = rc;
			[self.navigationController.view addSubview:MbannerView];
			//retainCount +2 --> unloadRelease:にて　-2 している
		}
	}
#endif
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated
{	// ＜＜魅せる処理＞＞
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
	
	if (MbInformationOpen) {	//initWithStyleにて判定処理している
		MbInformationOpen = NO;	// 以後、自動初期表示しない。
		[self azInformationView];  //[1.0.2]最初に表示する。バックグランド復帰時には通らない
	}
	
#ifdef FREE_AD
	// iAdは、bannerViewDidLoadAd を受信したとき開始となるためＮＯ
	// AdMobは、常時開始とするためYES
	[self AdShowApple:NO AdMob:YES];
#endif
#ifdef FREE_AD_PAD
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.padRootVC adBannerShow:YES];
#endif
	
	// E7E2クリーンアップ：配下のE6が無くなったE2を削除し、さらに配下のE2が無くなったE7も削除する。
	[MocFunctions e7e2clean];  // [0.4.18]レス向上のためここで処理。バックグランド時だとE2やE7表示に戻ったとき落ちる可能性あるので没にした。
	
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
	[self AdShowApple:NO AdMob:NO];
#endif
#ifdef FREE_AD_PAD
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.padRootVC adBannerShow:NO];
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
}

#ifdef AzPAD
// 回転した後に呼び出される
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{	// Popoverの位置を調整する　＜＜UIPopoverController の矢印が画面回転時にターゲットから外れてはならない＞＞
	if (Mpopover) {
		// 配下の Popover が開いておれば強制的に閉じる。回転すると位置が合わなくなるため
		id nav = [Mpopover contentViewController];
		//NSLog(@"nav=%@", nav);
		if ([nav isMemberOfClass:[UINavigationController class]]) {
			if ([nav respondsToSelector:@selector(visibleViewController)]) { //念のためにメソッドの存在を確認
				id vc = [nav visibleViewController];
				//NSLog(@"vc=%@", vc);
				if ([vc respondsToSelector:@selector(closePopover)]) { //念のためにメソッドの存在を確認
					[vc closePopover];
				}
			}
		}
		
		// Popoverの位置を調整する　＜＜UIPopoverController の矢印が画面回転時にターゲットから外れてはならない＞＞
		if (MindexPathEdit) { 
			//NSLog(@"MindexPathEdit=%@", MindexPathEdit);
			[self.tableView scrollToRowAtIndexPath:MindexPathEdit 
								  atScrollPosition:UITableViewScrollPositionMiddle animated:NO]; // YESだと次の座標取得までにアニメーションが終了せずに反映されない
			CGRect rc = [self.tableView rectForRowAtIndexPath:MindexPathEdit];
			rc.origin.x += rc.size.width/2;		rc.size.width /= 2;	// 右に寄せる、次のPopoverをできるだけ左側に表示するため
			rc.origin.y += 10;	rc.size.height -= 20;
			//　キーボードが出てサイズが小さくなった状態から復元するためには下記のように二段階処理が必要
			CGSize currentSetSizeForPopover = E3DETAILVIEW_SIZE; // 最終的に設定したいサイズ
			CGSize fakeMomentarySize = CGSizeMake(currentSetSizeForPopover.width - 1.0f, currentSetSizeForPopover.height - 1.0f);
			Mpopover.popoverContentSize = fakeMomentarySize;			// 変動させるための偽サイズ
			[Mpopover presentPopoverFromRect:rc  inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionUp  animated:YES]; //表示開始
			Mpopover.popoverContentSize = currentSetSizeForPopover; // 目的とするサイズ復帰
		} 
		else {
			// 回転後のアンカー位置が再現不可なので閉じる
			[Mpopover dismissPopoverAnimated:YES];
			[Mpopover release], Mpopover = nil;
		}
	}
}
#endif

#pragma mark  View - Unload - dealloc

- (void)unloadRelease	// dealloc, viewDidUnload から呼び出される
{
	NSLog(@"--- unloadRelease --- TopMenuTVC");
#ifdef FREE_AD
	MbAdCanVisible = NO;  // 以後、Ad表示禁止
	
	if (MbannerView) {
		[MbannerView cancelBannerViewAction];	//[1.0.1] 停止
		MbannerView.delegate = nil;							// 解放メソッドを呼び出さないようにする
		[MbannerView removeFromSuperview];		// UIView解放		retainCount -1
		[MbannerView release], MbannerView = nil;	// alloc解放			retainCount -1
	}
	
	if (RoAdMobView) {
		RoAdMobView.delegate = nil;								//受信STOP  ＜＜これが無いと破棄後に呼び出されて落ちる
		[RoAdMobView release], RoAdMobView = nil;	// 破棄
	}
#endif
	[MinformationView hide];
	[MinformationView release], MinformationView = nil;	// azInformationViewにて生成
}

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[self unloadRelease];
	// @property (retain)
	[Re0root release], Re0root = nil;
	[super dealloc];
}

// メモリ不足時に呼び出されるので不要メモリを解放する。 ただし、カレント画面は呼ばない。
- (void)viewDidUnload 
{
	//NSLog(@"--- viewDidUnload ---"); 
	// メモリ不足時、裏側にある場合に呼び出される。addSubviewされたOBJは、self.viewと同時に解放される
	[self unloadRelease];
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
			return 3;
			break;
	}
	return 0;
#endif
}

#ifdef FREE_AD_PAD
// TableView セクションタイトルを応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	if (section==0) return @"\n\n";	// iAd上部スペース
	return nil;
}
#endif

// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{
#ifndef AzMAKE_SPLASHFACE
	switch (section) {
		case 3:
			return	@"\nAzukiSoft Project\n©2000-2011 Azukid\n\n";  // iAdが表示されているとき最終セルが隠れないようにする
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
		cell.textLabel.font = [UIFont systemFontOfSize:20];
#else
		cell.textLabel.font = [UIFont systemFontOfSize:16];
#endif
		//cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.textColor = [UIColor blackColor];
    }
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	switch (indexPath.section) {
		case 0: //-------------------------------------------------------------Statement
		{
			switch (indexPath.row) {
				case 0:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-GreenPlus.png"];
					cell.textLabel.text = NSLocalizedString(@"Add Record", nil);
#ifdef AzPAD
					cell.accessoryType = UITableViewCellAccessoryNone;
#endif
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
						cell.textLabel.text = [NSString stringWithFormat:@"%@   %@", 
											   NSLocalizedString(@"Payment list",nil), 
											   [formatter stringFromNumber:decUnpaid]];
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
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Safari.png"];
					cell.textLabel.text = NSLocalizedString(@"Support Site", nil);
					break;
			}
		} break;
			
	}
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
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
					[self e3recordAdd]; // E3record 新規追加
					break;
				case 1: // 最近の明細　E3 < E3detail
				{
					// E3records へ
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
					[self.navigationController pushViewController:tvc animated:YES];
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
					[self.navigationController pushViewController:tvc animated:YES];
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
					[self.navigationController pushViewController:tvc animated:YES];
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
					[self.navigationController pushViewController:tvc animated:YES];
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
					[self.navigationController pushViewController:tvc animated:YES];
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
					[self.navigationController pushViewController:tvc animated:YES];
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
					goodocs.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
					[self.navigationController pushViewController:goodocs animated:YES];
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
					[self.view addSubview:vi];
					[vi show];
					[vi release];
				}
					break;
				case 2:
				{  // サポートWebサイトへ
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Go to support",nil)
																	 message:NSLocalizedString(@"SupportSite message",nil)
																	delegate:self 
														   cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
														   otherButtonTitles:@"OK", nil];
					alert.tag = TAG_ALERT_SupportSite;
					[alert show];
					[alert release];
				}
					break;
			}
		}
			break;
	}
}


#ifdef AzPAD
#pragma mark - <UIPopoverControllerDelegate>
// Information, Setting では、 .delegate = nil; として呼び出されないようにしている。

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{	// Popoverの外部をタップして閉じる前に通知
	//return NO; //枠外タッチでは閉じさせない [Cancel/Save]ボタン必須

	// MpopE2viewが閉じたときも、ここを通るため、Mpopoverと区別する必要がある
	if (popoverController==Mpopover) {
		// 内部(SAVE)から、dismissPopoverAnimated:で閉じた場合は呼び出されない。
		// つまり、これが呼び出されたときは、常に CANCEL　である。
		// Popover外側をタッチしたとき E3recordDetailTVC -　cancel を通っていないので、ここで通す。
		// PadPopoverInNaviCon を使っているから
		UINavigationController* nav = (UINavigationController*)popoverController.contentViewController;
		E3recordDetailTVC* e3tvc = (E3recordDetailTVC *)nav.topViewController;
		[e3tvc cancelClose:nil];
	}
	return YES; // 閉じることを許可
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{	// Popoverの外部をタップして閉じた後に通知
	// MpopE2viewが閉じたときも、ここを通るため、Mpopoverと区別する必要がある
	if (popoverController==Mpopover) {	// Cancelときは、dismissPopoverCancel:にて強制的に nil にしている
		// [SAVE]ボタンが押された
		
		// 未払い総額 再描画
		
	}
	// [Cancel][Save][枠外タッチ]何れでも閉じるときここを通るので解放する。さもなくば回転後に現れることになる
	[Mpopover release], Mpopover = nil;
	return;
}
#endif


@end

