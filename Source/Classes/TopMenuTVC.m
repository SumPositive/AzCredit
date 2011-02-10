//
//  selectGroupTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
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
#import "EntityRelation.h"
#import "HttpServerView.h"

#define VIEW_TAG_HttpServer			101
#define ALERT_TAG_SupportSite		118


@interface TopMenuTVC (PrivateMethods) // メソッドのみ記述：ここに変数を書くとグローバルになる。他に同じ名称があると不具合発生する
- (void)azInformationView;
- (void)azSettingView;
- (void)e3recordAdd;
- (void)iAdOn;
- (void)iAdOff;
@end

@implementation TopMenuTVC
@synthesize Re0root;


- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	//[MbannerView release];  addSubviewしているので不要
	// @property (retain)
	AzRETAIN_CHECK(@"TopMenuTVC Re0root", Re0root, 0)
	[Re0root release];
	[super dealloc];
}

/* iOS3.0以降では、viewDidUnload を使うようになった。
- (void)didReceiveMemoryWarning {
	AzLOG(@"MEMORY! TopMenuTVC: didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}
*/

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {  // セクションありテーブル
		// 初期化成功
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
	[super loadView];
	AzLOG(@"------- TopMenuTVC: loadView");    
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
	MbannerView = nil;			// ここ(loadView)で生成
	MinformationView = nil;		// azInformationViewにて生成

	MiE1cardCount = 0;			// viewWillAppearにてセット
	
	// Set up NEXT Left [Back] buttons.
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]
									   initWithImage:[UIImage imageNamed:@"simpleLeft-icon16.png"]
									   style:UIBarButtonItemStylePlain  target:nil  action:nil] autorelease];
	
#ifndef AzMAKE_SPLASHFACE
	// Tool Bar Button
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	UIBarButtonItem *buInfo = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Information-icon16.png"]
															   style:UIBarButtonItemStylePlain  //Bordered
															  target:self action:@selector(azInformationView)];
	UIBarButtonItem *buAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																		   target:self action:@selector(barButtonAdd)];
	UIBarButtonItem *buSet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Setting-icon16.png"]
															  style:UIBarButtonItemStylePlain  //Bordered
															 target:self action:@selector(azSettingView)];
	NSArray *buArray = [NSArray arrayWithObjects: buInfo, buFlex, buAdd, buFlex, buSet, nil];
	[self setToolbarItems:buArray animated:YES];
	[buInfo release];
	[buAdd release];
	[buSet release];
	[buFlex release];
#endif	

	// ToolBar表示は、viewWillAppearにて回転方向により制御している。
	
	// iAd
	//MbannerIsVisible = NO;
	if (MbannerView==nil && NSClassFromString(@"ADBannerView")) {
		MbannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0,480, 0,0)];
		MbannerView.delegate = self;
		MbannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, 
													  ADBannerContentSizeIdentifierLandscape, nil];
		MbannerView.hidden = YES;
		//[self.view addSubview:MbannerView];
		[self.navigationController.view addSubview:MbannerView];
		[MbannerView release];
		MbannerEnabled = NO;
	}
}

/*
// メモリ不足時に呼び出されるので不要メモリを解放する。 ただし、カレント画面は呼ばない。
- (void)viewDidUnload 
{
	[super viewDidUnload];
	AzLOG(@"MEMORY! TopMenuTVC: viewDidUnload");
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoad, viewWillAppear で生成したObjを解放する。
	
	// この後に viewDidLoad, viewWillAppear がコールされる
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
}
*/


- (void)barButtonAdd {
	// Add Card
	[self e3recordAdd];
}


- (void)iAdOn
{
	//AzLOG(@"=== iAdOn ===");
	if (MbannerView==nil) return;
	//if (MbannerEnabled==NO OR MbannerIsVisible==YES) return;
	//MbannerIsVisible = YES;
	if (!MbannerEnabled OR !MbannerView.hidden) return;
	MbannerView.hidden = NO;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:3.0];
	
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) { // ヨコ
		MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
		MbannerView.frame = CGRectMake(0, 320 - 32, 0,0);
	} else {
		MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		MbannerView.frame = CGRectMake(0, 480 - 44 - 50, 0,0);
	}
	
	[UIView commitAnimations];
}

- (void)iAdOff
{
	//AzLOG(@"=== iAdOff ===");
	if (MbannerView==nil) return;
	//if (MbannerIsVisible==NO) return;
	//MbannerIsVisible = NO;
	if (MbannerView.hidden) return;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];
	
	CGRect theBannerFrame = self.view.frame;
	theBannerFrame.origin.y = self.navigationController.view.frame.size.height; // viewの外へ出す
	MbannerView.frame = theBannerFrame;	
	MbannerView.hidden = YES;
	
	[UIView commitAnimations];
}


// iAd取得できたときに呼ばれる　⇒　表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	//AzLOG(@"=== bannerViewDidLoadAd ===");
	if (MbannerEnabled) {
		[self iAdOn];
	}
}

// iAd取得できなかったときに呼ばれる　⇒　非表示にする
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	AzLOG(@"=== didFailToReceiveAdWithError ===");
	[self iAdOff];
}

/*
 // MARK: iAd 広告表示を閉じて元に戻る前に呼ばれる
 - (void)bannerViewActionDidFinish:(ADBannerView *)banner
 {
 AzLOG(@"===== bannerViewActionDidFinish =====");
 //[self iAdOff];  一度見れば消えるようにする
 }
 */

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
								duration:(NSTimeInterval)duration
{
	if (MbannerView && !MbannerView.hidden) { //MbannerIsVisible) {
		if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) { // ヨコ
			MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
			MbannerView.frame = CGRectMake(0, 320 - 32, 0,0);
		} else {
			MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
			MbannerView.frame = CGRectMake(0, 480 - 44 - 50, 0,0);
		}
	}
}



// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([self.view viewWithTag:VIEW_TAG_HttpServer]) {
		// HttpServerView が表示中なので回転禁止
		return NO; // 回転禁止
	}
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		// 正面（ホームボタンが画面の下側にある状態）
		[self.navigationController setToolbarHidden:NO animated:YES]; // ツールバー表示する
		return YES; // この方向だけは常に許可する
	} 
	else if (MbOptAntirotation) return NO; // 回転禁止

	if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		// 逆面（ホームボタンが画面の上側にある状態）
		[self.navigationController setToolbarHidden:NO animated:YES]; // ツールバー表示
	} else {
		// 横方向や逆向きのとき
		[self.navigationController setToolbarHidden:YES animated:YES]; // ツールバー非表示=YES
		if (MinformationView) {
			[MinformationView hide]; // 正面でなければhide
		}
	}
	return YES;
	// 現在の向きは、self.interfaceOrientation で取得できる
}


- (void)viewWillAppear:(BOOL)animated 	// ＜＜見せない処理＞＞
{
    [super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	//MbOptEnableSchedule = [defaults boolForKey:GD_OptEnableSchedule];
	//MbOptEnableCategory = [defaults boolForKey:GD_OptEnableCategory];
	
	self.title = NSLocalizedString(@"Product Title",nil);
	

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
	
#ifdef AzMAKE_SPLASHFACE
	MbannerEnabled = NO;
#else
	MbannerEnabled = YES; // TopMenuView画面が表示されたのでiAd許可する
#endif
}

// この画面が非表示になる直前に呼ばれる
- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	[self iAdOff];  // iAdを非表示にする
	MbannerEnabled = NO; // TopMenuView以外の画面に移るのでiAd禁止にする
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated {	// ＜＜魅せる処理＞＞
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる

	// Comback (-1)にして未選択状態にする
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	// (0)This clear
	[appDelegate.RaComebackIndex replaceObjectAtIndex:0 withObject:[NSNumber numberWithLong:-1]];
}

// カムバック処理（復帰再現）：AppDelegate から呼ばれる
- (void)viewComeback:(NSArray *)selectionArray
{
	// L0
	NSInteger lRow = [[selectionArray objectAtIndex:0] integerValue];
	if (lRow < 0) return; // この画面表示
	
	NSInteger lSec = lRow / GD_SECTION_TIMES;
	if (lSec < 0) return; // この画面表示
	lRow -= (lSec * GD_SECTION_TIMES);
	
	if (MiE1cardCount <= 0) return; // No Card
	
	// didSelectRowAtIndexPath と同様の振り分けになる
	switch (lSec) {
		case 0: //---------------------------------------------SECTION 0
			switch (lRow) {
				case 0: // Add Deteil
					// なにもしない
					break;
				case 1: // E3recordTVC へ
					{
						E3recordTVC *tvc = [[E3recordTVC alloc] init];
						tvc.title =  NSLocalizedString(@"Record list", nil);
						tvc.Re0root = Re0root;
						//tvc.Pe1card = nil;  // =nil:最近の全E3表示モード　　=e1obj:指定E1以下を表示することができる
						tvc.Pe4shop = nil;
						tvc.Pe5category = nil;
						[self.navigationController pushViewController:tvc animated:NO];
						lRow = [[selectionArray objectAtIndex:1] integerValue];
						if (0 <= lRow) { // lRow<0:ならば「最近の明細：末尾」を表示する
							// viewComeback を呼び出す
							[tvc viewWillAppear:NO]; // Fechデータセットさせるため
							[tvc viewComeback:selectionArray];
						}
						[tvc release];
					}
					break;
				case 2: // E7paymentTVC へ
				{
					// E7paymentTVC へ
					E7paymentTVC *tvc = [[E7paymentTVC alloc] init];
					tvc.title =  NSLocalizedString(@"Payment list", nil);
					tvc.Re0root = Re0root;
					[self.navigationController pushViewController:tvc animated:NO];
					// viewComeback を呼び出す
					[tvc viewWillAppear:NO]; // Fechデータセットさせるため
					[tvc viewComeback:selectionArray];
					[tvc release];
				}
					break;
			}
			break;
		case 1: //---------------------------------------------SECTION 1
			switch (lRow) {
				case 0: // E1card へ
					{
						E1cardTVC *tvc = [[E1cardTVC alloc] init];
						tvc.title = NSLocalizedString(@"Card list",nil);
						tvc.Re0root = Re0root;
						tvc.Re3edit = nil;
						[self.navigationController pushViewController:tvc animated:NO];
						// viewComeback を呼び出す
						[tvc viewWillAppear:NO]; // Fechデータセットさせるため
						[tvc viewComeback:selectionArray];
						[tvc release];
					}
					break;
				case 1: // E4shop へ
				{
					E4shopTVC *tvc = [[E4shopTVC alloc] init];
					tvc.title = NSLocalizedString(@"Shop list",nil);
					tvc.Re0root = Re0root;
					tvc.Pe3edit = nil;
					[self.navigationController pushViewController:tvc animated:NO];
					// viewComeback を呼び出す
					[tvc viewWillAppear:NO]; // Fechデータセットさせるため
					[tvc viewComeback:selectionArray];
					[tvc release];
				}
					break;
				case 2: // Category list
					break;
			}
			break;
		case 2: //---------------------------------------------SECTION 2
			switch (lRow) {
				case 0:
				{
					GooDocsTVC *goodocs = [[GooDocsTVC alloc] init];
					goodocs.title = @"Google Document";
					goodocs.Re0root = Re0root;
					goodocs.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
					[self.navigationController pushViewController:goodocs animated:NO];
					[goodocs release];
				}
					break;
			}
			break;
	}
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // セクションは1つだけ section==0
#ifdef AzMAKE_SPLASHFACE
	return 0;
#else
	switch (section) {
		case 0:			// 利用明細
			return 3;
			break;
		case 1:			// 集計
			return 4;
			break;
		case 2:			// 機能
			return 3;
			break;
	}
	return 0;
#endif
}

/*
// TableView セクションタイトルを応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	return nil;
}
*/

// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{
#ifndef AzMAKE_SPLASHFACE
	switch (section) {
		case 2:
			return	@"AzukiSoft Project\n"
					@"©2000-2010 Azukid\n\n"; // iAdが表示されているとき最終セルが隠れないようにする
			break;
	}
#endif
	return nil;
}

/*
// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.section==1) { // 分類
		return 44; // デフォルト：44ピクセル
	}
	return 44; // デフォルト：44ピクセル
}
*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"CellMenu";
    //static NSString *zCelliAd = @"CelliAd";

/*	if (indexPath.section==2)
	{	// iAd行セル
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:zCelliAd];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:zCelliAd] autorelease];
			cell.textLabel.text = @"iAd";
			cell.textLabel.textAlignment = UITextAlignmentCenter; // 中央寄せ
			cell.showsReorderControl = NO; // Move禁止
			
			if (NSClassFromString(@"ADBannerView")) {
				// iAd
				MbannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
				//MbannerView.delegate = self;
				MbannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, 
															  ADBannerContentSizeIdentifier480x32, nil];
				if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
					MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
				} else {
					MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
				}
				MbannerView.frame = CGRectZero;
				[cell addSubview:MbannerView];
				[MbannerView release];
			}
		}
		return cell;
	}*/
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier] autorelease];

		cell.textLabel.font = [UIFont systemFontOfSize:16];
		//cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.textColor = [UIColor blackColor];
		
//		cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
		//cell.detailTextLabel.textAlignment = UITextAlignmentRight;
//		cell.detailTextLabel.textColor = [UIColor blackColor];

		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	switch (indexPath.section) {
		case 0: //-------------------------------------------------------------Statement
		{
			switch (indexPath.row) {
				case 0:
					cell.imageView.image = [UIImage imageNamed:@"Cell32-Add.png"];
					cell.textLabel.text = NSLocalizedString(@"Add Record", nil);
					break;
				case 1:
					cell.imageView.image = [UIImage imageNamed:@"Statements32.png"];
					cell.textLabel.text = NSLocalizedString(@"Record list", nil);
					break;
				case 2:
					cell.imageView.image = [UIImage imageNamed:@"PaySchedule32.png"];
					//cell.textLabel.text = NSLocalizedString(@"Payment list", nil);
					// E7 未払い総額
					cell.detailTextLabel.textAlignment = UITextAlignmentRight;
					if ([Re0root.e7unpaids count] <= 0) {
						cell.textLabel.text = [NSString stringWithFormat:@"%@   (%@)",
											   NSLocalizedString(@"Payment list",nil), 
											   NSLocalizedString(@"No unpaid",nil)];
					} else {
						NSNumber *nUnpaid = [Re0root valueForKeyPath:@"e7unpaids.@sum.sumAmount"];
						// Amount JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
						NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
						[formatter setNumberStyle:NSNumberFormatterCurrencyStyle]; // 通貨スタイル
						NSLocale *localeJP = [[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"];
						[formatter setLocale:localeJP];
						[localeJP release];
						cell.textLabel.text = [NSString stringWithFormat:@"%@   (%@%@)", 
											   NSLocalizedString(@"Payment list",nil), 
											   NSLocalizedString(@"Unpaid",nil), 
												[formatter stringFromNumber:nUnpaid]];
						[formatter release];
					}
					break;
			}
		}
			break;
		case 1: //-------------------------------------------------------------Groups
		{
			switch (indexPath.row) {
				case 0:
					cell.imageView.image = [UIImage imageNamed:@"Cards32.png"];
					cell.textLabel.text = NSLocalizedString(@"Card list", nil);
					break;
				case 1:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Bank.png"];
					cell.textLabel.text = NSLocalizedString(@"Bank list", nil);
					break;
				case 2:
					cell.imageView.image = [UIImage imageNamed:@"Shop32.png"];
					cell.textLabel.text = NSLocalizedString(@"Shop list", nil);
					break;
				case 3:
					cell.imageView.image = [UIImage imageNamed:@"Category32.png"];
					cell.textLabel.text = NSLocalizedString(@"Category list", nil);
					break;
			}
		}
			break;
		case 2: //-------------------------------------------------------------Function
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
					cell.imageView.image = [UIImage imageNamed:@"Icon32-WebSafari.png"];
					cell.textLabel.text = NSLocalizedString(@"Support Site", nil);
					break;
			}
		}
			break;
	}
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
	// Comback-L0 TopMenu 記録
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	long lPos = indexPath.section * GD_SECTION_TIMES + indexPath.row;
	// (0)This >> (1)Clear
	[appDelegate.RaComebackIndex replaceObjectAtIndex:0 withObject:[NSNumber numberWithLong:lPos]];
	[appDelegate.RaComebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:-1]];

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
					tvc.title = cell.textLabel.text;
					tvc.Re0root = Re0root;
					//tvc.Pe1card = nil;  // =nil:最近の全E3表示モード　　=e1obj:指定E1以下を表示することができる
					tvc.Pe4shop = nil;
					tvc.Pe5category = nil;
					[self.navigationController pushViewController:tvc animated:YES];
					[tvc release];
				}
					break;
				case 2: // 支払予定　E7 < E2 < E6 < E3detail
				{
					// E7paymentTVC へ
					E7paymentTVC *tvc = [[E7paymentTVC alloc] init];
					tvc.title = NSLocalizedString(@"Payment list",nil); //cell.textLabel.text;
					tvc.Re0root = Re0root;
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
				case 0: // カード一覧  E1 < E2 < E6 < E3detail
				{
					// E1card へ
					E1cardTVC *tvc = [[E1cardTVC alloc] init];
					tvc.title = cell.textLabel.text;
					tvc.Re0root = Re0root;
					tvc.Re3edit = nil;
					[self.navigationController pushViewController:tvc animated:YES];
					[tvc release];
				}
					break;
				case 1: // 銀行等口座一覧  E8 
				{
					// E8bank へ
					E8bankTVC *tvc = [[E8bankTVC alloc] init];
					tvc.title = cell.textLabel.text;
					tvc.Re0root = Re0root;
					tvc.Pe1card = nil;
					[self.navigationController pushViewController:tvc animated:YES];
					[tvc release];
				}
					break;
				case 2: // 利用店一覧  E4 < E3 < E3detail
				{
					E4shopTVC *tvc = [[E4shopTVC alloc] init];
					tvc.title = cell.textLabel.text;
					tvc.Re0root = Re0root;
					tvc.Pe3edit = nil;
					[self.navigationController pushViewController:tvc animated:YES];
					[tvc release];
				}
					break;
				case 3: // 分類一覧  E4 < E3 < E3detail
				{
					E5categoryTVC *tvc = [[E5categoryTVC alloc] init];
					tvc.title = cell.textLabel.text;
					tvc.Re0root = Re0root;
					tvc.Pe3edit = nil;
					[self.navigationController pushViewController:tvc animated:YES];
					[tvc release];
				}
					break;
			}
		}
			break;
		case 2: // Function
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
					[self iAdOff];
					MbannerEnabled = NO;
					//
					HttpServerView *vi = [[HttpServerView alloc] initWithFrame:[self.view bounds]];
					vi.Pe0root = Re0root;
					vi.tag = VIEW_TAG_HttpServer; // 表示中は回転禁止にするために参照している
					[self.view addSubview:vi];
					[vi show];
					[vi release];
				}
					break;
				case 2:
				{  // サポートWebサイトへ
					UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Go to support",nil)
																	 message:NSLocalizedString(@"SupportSite message",nil)
																	delegate:self 
														   cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
														   otherButtonTitles:@"OK", nil] autorelease];
					alert.tag = ALERT_TAG_SupportSite;
					[alert show];
				}
					break;
			}
		}
			break;
	}
}

- (void)azInformationView
{
	// ヨコ非対応につき正面以外は、hideするようにした。
	MinformationView = [[InformationView alloc] initWithFrame:[self.view.window bounds]];
	[self.view.window addSubview:MinformationView]; //回転しないが、.viewから出すとToolBarが隠れない
	[MinformationView release]; // addSubviewにてretain(+1)されるため、こちらはrelease(-1)して解放
	[MinformationView show];
}

- (void)azSettingView
{
	SettingTVC *view = [[SettingTVC alloc] init];
	//view.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:view animated:YES];
	[view release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag) {
		case ALERT_TAG_SupportSite:
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
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Card",nil) 
														 message:NSLocalizedString(@"No Card msg",nil) 
														delegate:nil 
											   cancelButtonTitle:nil 
											   otherButtonTitles:@"OK", nil] autorelease];
		[alert show];
		return;
	}
	
	E3record *e3obj = [NSEntityDescription insertNewObjectForEntityForName:@"E3record"
													inManagedObjectContext:Re0root.managedObjectContext];
	e3obj.dateUse = [NSDate date]; // 迷子にならないように念のため
	e3obj.e1card = nil;
	e3obj.e4shop = nil;
	e3obj.e5category = nil;
	e3obj.e6parts = nil;

	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	e3detail.title = NSLocalizedString(@"Add Record", nil);
	e3detail.Re3edit = e3obj;
	e3detail.PiAdd = (1); // (1)New Add
	//e3detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:YES];
	[e3detail release]; // self.navigationControllerがOwnerになる
}


@end

