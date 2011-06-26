//
//  E3recordTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "SettingTVC.h"
#import "E3recordTVC.h"
#import "E3recordDetailTVC.h"

#ifdef AzPAD
#import "PadPopoverInNaviCon.h"
#endif

#define ALERT_TAG_NoMore		109


@interface E3recordTVC (PrivateMethods)
- (void)setMe3list:(NSDate *)dateMiddle;
- (void)azSettingView;
- (void)e3detailView:(NSIndexPath *)indexPath;
- (void)cellButton: (UIButton *)button;
@end

@implementation E3recordTVC
@synthesize Re0root;
@synthesize Pe4shop;
@synthesize Pe5category;
@synthesize Pe8bank;
//@synthesize MdateTarget;


#pragma mark - Action

- (void)azSettingView
{
	SettingTVC *view = [[SettingTVC alloc] init];
	//view.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:view animated:YES];
	[view release];
}

- (void)barButtonTop {
	[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
}

- (void)barButtonAdd {
	// Add Card
	[self e3detailView:nil]; // :(nil)Add mode
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag) {
		case ALERT_TAG_NoMore:
			[self.navigationController popViewControllerAnimated:YES]; 	// < 前のViewへ戻る
			break;
	}
}

- (void)e3detailView:(NSIndexPath *)indexPath 
{
	// ドリルダウン
	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init];
	// 以下は、E3detailTVCの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
	if (indexPath != nil && indexPath.section >= 1
		&& indexPath.section < [RaE3list count]  
		&& indexPath.row < [[RaE3list objectAtIndex:indexPath.section] count]) {
		// Edit Item
		e3detail.title = NSLocalizedString(@"Edit Record", nil);
		e3detail.Re3edit = [[RaE3list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		e3detail.PiAdd = 0; // (0)Edit mode
		
		//[0.4.2]Fix:
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[app.Me3dateUse release], app.Me3dateUse = nil; //1.0.0//
		app.Me3dateUse = [e3detail.Re3edit.dateUse copy];
		NSLog(@"app.Me3dateUse=%@", app.Me3dateUse);
	}
	else {
		// Add E3  【注意】同じE3Addが、TopMenuTVC内にもある。
		//E3record *e3obj = [NSEntityDescription insertNewObjectForEntityForName:@"E3record"
		//												   inManagedObjectContext:Re0root.managedObjectContext];
		E3record *e3obj = [MocFunctions insertAutoEntity:@"E3record"]; // autorelese
		e3obj.dateUse = [NSDate date]; // 迷子にならないように念のため
		//e3obj.nReservType = [NSNumber numberWithInt:0]; // (0)利用
		e3obj.e1card = nil;
		e3obj.e4shop = Pe4shop;
		e3obj.e5category = Pe5category;
		e3obj.e6parts = nil;
		// Args
		e3detail.title = NSLocalizedString(@"Add Record", nil);
		e3detail.Re3edit = e3obj;
		if (Pe4shop) {
			e3detail.PiAdd = 3; // (3)Shop固定
		} else if (Pe5category) {
			e3detail.PiAdd = 4; // (4)Category固定
		} else {
			e3detail.PiAdd = 1; // (1)New Add
		}
	}

#ifdef  AzPAD
	[Mpopover release], Mpopover = nil;
	Mpopover = [[PadPopoverInNaviCon alloc] initWithContentViewController:e3detail];
	Mpopover.popoverContentSize = CGSizeMake(450, 600);
	Mpopover.delegate = self;	// popoverControllerDidDismissPopover:を呼び出してもらうため
	MindexPathEdit = indexPath;
	CGRect rc = [self.tableView rectForRowAtIndexPath:indexPath];
	rc.size.width /= 2;
	rc.origin.y += 10;	rc.size.height -= 20;
	[Mpopover presentPopoverFromRect:rc
							  inView:self.tableView  permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
#else
	//[e3detail setHidesBottomBarWhenPushed:YES]; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:YES];
#endif
	[e3detail release];
}

- (void)setMe3list:(NSDate *)dateMiddle // この日時が画面中央になるように前後最大50行読み込み表示する
{
	
	NSCalendar *cal = [NSCalendar currentCalendar];	// 言語設定のタイムゾーンに従う
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
	| NSHourCalendarUnit; // タイムゾーン変換させるため「時」が必須
	
	NSLog(@"setMe3list: dateMiddle=%@", dateMiddle);
	if (dateMiddle==nil) {
		dateMiddle = [NSDate dateWithTimeIntervalSinceNow: -12 * 60 * 60]; //UTC 現在の12時間前
	}
	// ＜＜＜dateUse は,UTC(+0000)記録されている。比較や抽出などUTCで行うこと＞＞＞
	// NSDateは、常にUTC(+0000)協定世界時間である。
	
	// Temp Array
	NSMutableArray *mE3array = [NSMutableArray new];
	// Sorting
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"dateUse" ascending:YES];
	NSArray *sortAsc = [[NSArray alloc] initWithObjects:sort1,nil]; // 利用日昇順
	[sort1 release];
	sort1 = [[NSSortDescriptor alloc] initWithKey:@"dateUse" ascending:NO];
	NSArray *sortDesc = [[NSArray alloc] initWithObjects:sort1,nil]; // 利用日降順：Limit抽出に使用
	[sort1 release];
	NSArray *arFetch = nil;
	BOOL  bPrev = NO;
	BOOL  bNext = NO;
	
	if (Pe4shop) {
		// Pe4shop以下、最近の全E3
		arFetch = [MocFunctions select:@"E3record" 
								 limit:GD_E3_SELECT_LIMIT
								offset:0
								 where:[NSPredicate predicateWithFormat:@"e4shop == %@ AND dateUse <= %@", Pe4shop, dateMiddle]
								  sort:sortDesc];
		bPrev = (GD_E3_SELECT_LIMIT <= [arFetch count]);
		[mE3array setArray:arFetch];
		[mE3array sortUsingDescriptors:sortAsc]; // 降順から昇順にソートする
		arFetch = [MocFunctions select:@"E3record" 
								 limit:GD_E3_SELECT_LIMIT
								offset:0
								 where:[NSPredicate predicateWithFormat:@"e4shop == %@ AND dateUse > %@", Pe4shop, dateMiddle]
								  sort:sortAsc];
		bNext = (GD_E3_SELECT_LIMIT <= [arFetch count]);
		[mE3array addObjectsFromArray:arFetch]; // 昇順に昇順を追加
	}
	else if (Pe5category) {
		// Pe5category以下、最近の全E3
		arFetch = [MocFunctions select:@"E3record" 
								 limit:GD_E3_SELECT_LIMIT
								offset:0
								 where:[NSPredicate predicateWithFormat:@"e5category == %@ AND dateUse <= %@", Pe5category, dateMiddle]
								  sort:sortDesc];
		bPrev = (GD_E3_SELECT_LIMIT <= [arFetch count]);
		[mE3array setArray:arFetch];
		[mE3array sortUsingDescriptors:sortAsc]; // 降順から昇順にソートする
		arFetch = [MocFunctions select:@"E3record" 
								 limit:GD_E3_SELECT_LIMIT
								offset:0
								 where:[NSPredicate predicateWithFormat:@"e5category == %@ AND dateUse > %@", Pe5category, dateMiddle]
								  sort:sortAsc];
		bNext = (GD_E3_SELECT_LIMIT <= [arFetch count]);
		[mE3array addObjectsFromArray:arFetch]; // 昇順に昇順を追加
	}
	else if (Pe8bank) { 
		/*******************現在の仕様では、ここは通らない*****************/
		// Pe8bank以下、最近のE3
		arFetch = [MocFunctions select:@"E3record" 
								 limit:GD_E3_SELECT_LIMIT
								offset:0
								 where:[NSPredicate predicateWithFormat:@"e1card.e8bank == %@ AND dateUse <= %@", Pe8bank, dateMiddle]
								  sort:sortDesc];
		bPrev = (GD_E3_SELECT_LIMIT <= [arFetch count]);
		[mE3array setArray:arFetch];
		[mE3array sortUsingDescriptors:sortAsc]; // 降順から昇順にソートする
		arFetch = [MocFunctions select:@"E3record" 
								 limit:GD_E3_SELECT_LIMIT
								offset:0
								 where:[NSPredicate predicateWithFormat:@"e1card.e8bank == %@ AND dateUse > %@", Pe8bank, dateMiddle]
								  sort:sortAsc];
		bNext = (GD_E3_SELECT_LIMIT <= [arFetch count]);
		[mE3array addObjectsFromArray:arFetch]; // 昇順に昇順を追加
	}
	else 
	{
		arFetch = [MocFunctions select:@"E3record" 
								 limit:GD_E3_SELECT_LIMIT
								offset:0
								 where:[NSPredicate predicateWithFormat:@"dateUse <= %@", dateMiddle]
								  sort:sortDesc];
		bPrev = (GD_E3_SELECT_LIMIT <= [arFetch count]);
		[mE3array setArray:arFetch];
		[mE3array sortUsingDescriptors:sortAsc]; // 降順から昇順にソートする
		
		arFetch = [MocFunctions select:@"E3record" 
								 limit:GD_E3_SELECT_LIMIT
								offset:0
								 where:[NSPredicate predicateWithFormat:@"dateUse > %@", dateMiddle]
								  sort:sortAsc];
		bNext = (GD_E3_SELECT_LIMIT <= [arFetch count]);
		[mE3array addObjectsFromArray:arFetch]; // 昇順に昇順を追加
	}
	[sortAsc release];
	[sortDesc release];
	
	//---------------------------------Tableソース生成（クリア）
	// テーブル ソース
	if (RaE3list) {
		[RaE3list release]; RaE3list = nil;
	}
	RaE3list = [NSMutableArray new];
	// セクションヘッダ ソース
	if (RaSection) {
		[RaSection release]; RaSection = nil;
	}
	RaSection = [NSMutableArray new];
	// インデックス ソース
	if (RaIndex) {
		[RaIndex release]; RaIndex = nil;
	}
	RaIndex = [NSMutableArray new];
	
	if ([mE3array count] <= 0) {
		[mE3array release];
		// テーブルビューを更新「クリア」します。
		[self.tableView reloadData];
		// 明細なし ＞ ここではまだ表示されていないので、viewDidAppear にて Alert 表示している。
		return;
	}
	
	//---------------------------------------------------------ここから、mE3arrayを月別に2次元配列にする処理
	//---------------------------------Msection, Mindex 生成
	NSDateFormatter *df_section = [[NSDateFormatter alloc] init];
	[df_section setDateFormat:@"yyyy-M"]; // デフォルトのままで、iPhoneに設定されているタイムゾーンが使用される。
	NSDateFormatter *df_index = [[NSDateFormatter alloc] init];
	[df_index setDateFormat:@"M"];
	
	NSMutableArray *e3days = [NSMutableArray new];
	NSInteger iSec = 0;
	NSInteger iRow = 0;
	NSInteger iSecMiddle = -1;
	NSInteger iRowMiddle = 0;
	NSInteger iYear = 0;
	NSInteger iMonth = 0;
	
	if (bPrev) {
		E3record *e3 = [mE3array objectAtIndex:0];
		[e3days addObject:e3.dateUse]; // PREV表示時に中央にする日付
		[RaSection addObject:@"▲"];
		[RaIndex addObject:@"▲"];
	} else {
		[e3days addObject:[NSNull null]]; // No More
		[RaSection addObject:@"■Top"];
		[RaIndex addObject:@"■"];
	}
	
	// [RaE3list addObject:e3days] は、下記ループの最初に実行される。
	
	// 「明細」セクション
	for (E3record *e3 in mE3array) 
	{
		NSDateComponents *compSec = [cal components:unitFlags fromDate:e3.dateUse];
		if (iYear != compSec.year || iMonth != compSec.month) 
		{
			[RaE3list addObject:e3days];	// 直前までの e3days を確定し、RaE3list へ追加する
			[e3days release]; e3days = nil; // Me3list にaddしたものを切り離してMe3listに任せる。
			e3days = [NSMutableArray new]; // 新しいセクション領域を確保する。
			iYear = compSec.year;
			iMonth = compSec.month;
			compSec.day = 1;
			compSec.hour = 0;
			NSDate *dateSection = [cal dateFromComponents:compSec];
			AzLOG(@"-----:dateSection=[%@]", dateSection);
			[RaSection addObject:[df_section stringFromDate:dateSection]]; // セクションタイトルに使う
			[RaIndex addObject:[df_index stringFromDate:dateSection]]; // インデックスに使う
			iSec++;
			iRow = 0;
		}
		
		[e3days addObject:e3]; // 新セクションへ明細追加
		
		if (iSecMiddle < 0 && dateMiddle 
			&& [dateMiddle compare:e3.dateUse] != NSOrderedDescending) { // dateMiddle <= e3.dateUse ( ! > )
			iSecMiddle = iSec;
			iRowMiddle = iRow;
			AzLOG(@"-----:MIDDLE indexPath=(%d,%d)", iSecMiddle, iRowMiddle);
		}
		iRow++;
	}
	[RaE3list addObject:e3days]; // 最後の e3days を確定し、RaE3list へ追加する
	[e3days release];
	
	// 最後「さらに次へ」セクション
	e3days = [NSMutableArray new]; // 新しい領域を確保する。
	E3record *e3last = [mE3array lastObject];
	if (bNext && e3last) {
		[e3days addObject:e3last.dateUse]; // NEXT表示時に中央にする日付
		[RaSection addObject:@"▼"];
		[RaIndex addObject:@"▼"];
	} else {
		[e3days addObject:[NSNull null]]; // No More
		[RaSection addObject:@"■End"];
		[RaIndex addObject:@"■"];
	}
	[RaE3list addObject:e3days]; // Section=End になる
	[e3days release];
	//
	[mE3array release];
#ifdef AzDEBUG
	AzLOG(@"[RaSection count]=%d  [RaE3list count]=%d", [RaSection count], [RaE3list count]);
	for (int i=0 ; i<[RaE3list count] && i<[RaSection count] ; i++) {
		AzLOG(@"RaSection=(%@) RaE3list=[%d][%d]", 
			  [RaSection objectAtIndex:i],
			  i,
			  [[RaE3list objectAtIndex:i] count]);
	}
#endif
	
	[df_section release];
	[df_index release];
	// テーブルビューを更新
    [self.tableView reloadData];
	
	if (3 <= [RaE3list count]) { // 少なくとも、Top + Monthly + End の3セクションある
		NSIndexPath *indexPath;
		if (iSecMiddle < 0) { // 現在以降の明細が無いとき
			// 最新行（最終ページ）を表示する　＜＜最終行を画面下部に表示する＞＞  +Add行まで表示するためMiddleにした。
			indexPath = [NSIndexPath indexPathForRow:0 inSection:[RaE3list count]-1]; // 行末セクションへ
		} else {
			indexPath = [NSIndexPath indexPathForRow:iRowMiddle inSection:iSecMiddle];
		}
		[self.tableView scrollToRowAtIndexPath:indexPath			//  Middle 中央へ
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	}
}


#pragma mark - View lifecicle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStylePlain]; // セクションなしテーブル
	if (self) {
		// 初期化成功
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[app.Me3dateUse release], app.Me3dateUse = nil; //1.0.0//
		//
#ifdef FREE_AD
		RoAdMobView = nil;
#endif
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
    [super loadView];
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
	// なし
	
	// Tool Bar Button
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	UIBarButtonItem *buTop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-Top.png"]
															  style:UIBarButtonItemStylePlain  //Bordered
															 target:self action:@selector(barButtonTop)];
	UIBarButtonItem *buAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																		   target:self action:@selector(barButtonAdd)];
	UIBarButtonItem *buSet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon16-Setting.png"]
															  style:UIBarButtonItemStylePlain  //Bordered
															 target:self action:@selector(azSettingView)];
	NSArray *buArray = [NSArray arrayWithObjects: buTop, buFlex, buAdd, buFlex, buSet, nil];
	[self setToolbarItems:buArray animated:YES];
	[buSet release];
	[buAdd release];
	[buTop release];
	[buFlex release];
	
#ifdef FREE_AD
	RoAdMobView = [[GADBannerView alloc]
                   initWithFrame:CGRectMake(0, 0,			// TableCell用
                                            GAD_SIZE_320x50.width,
                                            GAD_SIZE_320x50.height)];
	//RoAdMobView.delegate = self;
	RoAdMobView.delegate = nil; //Delegateなし
	
	// Specify the ad's "unit identifier." This is your AdMob Publisher ID.
	RoAdMobView.adUnitID = AdMobID_iPhone;
	
	// Let the runtime know which UIViewController to restore after taking
	// the user wherever the ad goes and add it to the view hierarchy.
	RoAdMobView.rootViewController = self;
	
	// Initiate a generic request to load it with an ad.
	//[RoAdMobView loadRequest:[GADRequest request]];
	GADRequest *request = [GADRequest request];
	//[request setTesting:YES];
	[RoAdMobView loadRequest:request];	
#endif
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:YES];
	//[0.4]以降、ヨコでもツールバーを表示するようにした。
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	
	// テーブルソース セット
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (RaE3list==nil || app.Me3dateUse) {
		//NSAutoreleasePool *autoPool = [[NSAutoreleasePool alloc] init];
		NSLog(@"viewWillAppear: app.Me3dateUse=%@", app.Me3dateUse);
		[self setMe3list:app.Me3dateUse];
		//[autoPool release];
	}
	else if (0 < McontentOffsetDidSelect.y) {
		// app.Me3dateUse=nil のときや、メモリ不足発生時に元の位置に戻すための処理。
		// McontentOffsetDidSelect は、didSelectRowAtIndexPath にて記録している。
		self.tableView.contentOffset = McontentOffsetDidSelect;
	}
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	
	if ([RaE3list count] < 3) { // 少なくとも、Top + Monthly + End の3セクションあるから
		// 明細なし ＞ 前画面に戻す
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"E3list NoData",nil)
														message:NSLocalizedString(@"E3list NoData msg",nil)
													   delegate:self 
											  cancelButtonTitle:nil
											  otherButtonTitles:@"Roger", nil];
		alert.tag = ALERT_TAG_NoMore; // 前画面に戻る
		[alert show];
		[alert release];
		return;
	}
	
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
}


#pragma mark View - Rotate

// 回転の許可　ここでは許可、禁止の判定だけする
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifdef AzPAD
	return YES;
#else
	// 回転禁止でも、正面は常に許可しておくこと。
	return !MbOptAntirotation OR (interfaceOrientation == UIInterfaceOrientationPortrait);
#endif
}

#ifdef FREE_AD
// 回転を始める前に呼ばれる
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
								duration:(NSTimeInterval)duration
{	
	if (RoAdMobView) {
		CGRect rc = RoAdMobView.frame;
		if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
		{	// タテ
			rc.origin.x = 0;
		} else {
			rc.origin.x += (480 - GAD_SIZE_320x50.width)/2.0;		// ヨコのとき中央にする
		}	
		RoAdMobView.frame = rc;
	}
}
#endif

// 回転した後に呼び出される
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadData];  // cellLable位置調整する

#ifdef AzPAD
	// Popoverの位置を調整する　＜＜UIPopoverController の矢印が画面回転時にターゲットから外れてはならない＞＞
	if (Mpopover) {
		if (MindexPathEdit) { 
			//NSLog(@"MindexPathEdit=%@", MindexPathEdit);
			[self.tableView scrollToRowAtIndexPath:MindexPathEdit 
								  atScrollPosition:UITableViewScrollPositionMiddle animated:NO]; // YESだと次の座標取得までにアニメーションが終了せずに反映されない
			CGRect rc = [self.tableView rectForRowAtIndexPath:MindexPathEdit];
			rc.size.width /= 2;
			rc.origin.y += 10;	rc.size.height -= 20;
			[Mpopover presentPopoverFromRect:rc  inView:self.tableView 
					permittedArrowDirections:UIPopoverArrowDirectionLeft  animated:YES];
		} else {
			// 回転後のアンカー位置が再現不可なので閉じる
			[Mpopover dismissPopoverAnimated:YES];
			[Mpopover release], Mpopover = nil;
		}
	}
#endif
}

#pragma mark  View - Unload - dealloc

- (void)unloadRelease	// dealloc, viewDidUnload から呼び出される
{
	NSLog(@"--- unloadRelease --- E3recordTVC");
#ifdef FREE_AD
	if (RoAdMobView) {
		RoAdMobView.delegate = nil;  //受信STOP  ＜＜これが無いと破棄後に呼び出されて落ちる
		[RoAdMobView release], RoAdMobView = nil;
	}
#endif
	[RaE3list release],		RaE3list = nil;
	[RaSection release],	RaSection = nil;
	[RaIndex release],		RaIndex = nil;
}

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[self unloadRelease];
	//--------------------------------@property (retain)
	[Re0root release];
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


#pragma mark - TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [RaE3list count]; // [0]さらに前へ  [1〜End-1]E3record  [End]さらに次へ
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [[RaE3list objectAtIndex:section] count];
}


// セクションインデックスを表示する
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	// NSMutableArray を NSArray にする
	NSArray *ar = [[RaIndex copy] autorelease];
	return ar;
}


// TableView セクション名を応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	if (0 < section && section < [RaE3list count]-1 && 0 < [[RaE3list objectAtIndex:section] count]) 
	{
		// 年-月  月計 99,999,999
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle]; // 通貨スタイル
		[formatter setLocale:[NSLocale currentLocale]]; 
		NSString *zSum = [formatter stringFromNumber:[[RaE3list objectAtIndex:section] 
													  valueForKeyPath:@"@sum.nAmount"]];
		[formatter release];
		//
		NSString *zHeader = [NSString stringWithFormat:@"%@   %@ %@",
							 [RaSection objectAtIndex:section], 
							 NSLocalizedString(@"Monthly total",nil), zSum];
		return zHeader; // autoreleseされる
	}
	// 年-月
	return [RaSection objectAtIndex:section];
}


// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#ifdef FREE_AD
	if (indexPath.section <= 0 || [RaE3list count]-1 <= indexPath.section) {
		return GAD_SIZE_320x50.height; // AdMob
	}
#endif
	return 44; // デフォルト：44ピクセル
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *zCellTopEnd = @"CellTopEnd";
    static NSString *zCellE3record = @"CellE3record";
	static NSString *zCellAdMob = @"CellAdMob";
	UITableViewCell *cell = nil;
	UILabel *cellLabel = nil;
	
	
	if (indexPath.section <= 0 || [RaE3list count]-1 <= indexPath.section) {
		// Top End
		if ([[RaE3list objectAtIndex:indexPath.section] objectAtIndex:0] == [NSNull null]) {
			// No More & AdMob
			cell = [tableView dequeueReusableCellWithIdentifier:zCellAdMob];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											   reuseIdentifier:zCellAdMob] autorelease];
				
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
				cell.showsReorderControl = NO;		// Move禁止
				cell.textLabel.font = [UIFont systemFontOfSize:14];
				cell.textLabel.textAlignment = UITextAlignmentLeft;
				cell.textLabel.text = NSLocalizedString(@"E3list No More",nil);
#ifdef FREE_AD
				if (RoAdMobView) { // Request an AdMob ad for this table view cell
					[cell.contentView addSubview:RoAdMobView]; // unloadReleaseにて解放
				}
#endif
			}
#ifdef FREE_AD
			if (RoAdMobView) {
				CGRect rc = RoAdMobView.frame;
				if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
				{	// タテ
					rc.origin.x = 0;
				} else {
					rc.origin.x = (480 - rc.size.width) / 2.0;		// ヨコのとき中央にする
				}	
				RoAdMobView.frame = rc;
			}
#endif
		}
		else {
			// More...
			cell = [tableView dequeueReusableCellWithIdentifier:zCellTopEnd];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											   reuseIdentifier:zCellTopEnd] autorelease];
				cell.textLabel.font = [UIFont systemFontOfSize:14];
				cell.textLabel.textAlignment = UITextAlignmentLeft;
				cell.showsReorderControl = NO; // Move禁止
				cell.textLabel.text = NSLocalizedString(@"E3list More",nil);
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			}
		}
		return cell;
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:zCellE3record];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
											reuseIdentifier:zCellE3record] autorelease];
			// 行毎に変化の無い定義は、ここで最初に1度だけする
#ifdef AzPAD
			cell.textLabel.font = [UIFont systemFontOfSize:18];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
#else
			cell.textLabel.font = [UIFont systemFontOfSize:14];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
#endif
			cell.detailTextLabel.textAlignment = UITextAlignmentLeft; //金額が欠けないように左寄せにした
			cell.showsReorderControl = NO; // Move禁止

			cellLabel = [[UILabel alloc] init];
			cellLabel.textAlignment = UITextAlignmentRight;
			//cellLabel.textColor = [UIColor blackColor];
			cellLabel.backgroundColor = [UIColor clearColor];
#ifdef AzPAD
			cellLabel.font = [UIFont systemFontOfSize:20];
#else
			cellLabel.font = [UIFont systemFontOfSize:14];
#endif
			cellLabel.tag = -1;
			[cell addSubview:cellLabel]; [cellLabel release];
		 }
		else {
			cellLabel = (UILabel *)[cell viewWithTag:-1];
		}
		// 回転対応のため
#ifdef AzPAD
		cellLabel.frame = CGRectMake(self.tableView.frame.size.width-178, 12, 125, 22);
#else
		cellLabel.frame = CGRectMake(self.tableView.frame.size.width-108, 2, 75, 20);
#endif
		
		E3record *e3obj = [[RaE3list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		
		if (e3obj.e1card && 0 < [e3obj.e6parts count]) {
			BOOL bPaid = YES;
			for (E6part *e6node in e3obj.e6parts) {
				if (e6node.e2invoice.e7payment.e0unpaid) {
					bPaid = NO; // 1つでも未払いがあればNO
					break;
				}
			}
			if (bPaid) {
				cell.imageView.image = [UIImage imageNamed:@"Icon32-PAID"]; // PAID
			}
			else if (1 < [e3obj.e6parts count]) {
				if ([e3obj.sumNoCheck intValue]==0) {
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Check"];
				} else {
					cell.imageView.image = nil; //[UIImage imageNamed:@"CircleW32"];
				}
			}
			else {
				if ([e3obj.sumNoCheck intValue]==0) {
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Check"];
				} else {
#ifdef AzPAD
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Clear"]; //幅に余裕があるので、画像を入れて揃えた方が見栄え良いと判断した。
#else
					cell.imageView.image = nil; //左画像なし：少しでも幅広くするため。見栄えも問題なさそうだ。
#endif
				}
			}
		} else {
			// クイック追加にてカード(未定)のとき
			cell.imageView.image = nil;
		}
		
		// zDate 利用日
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		//[df setLocale:[NSLocale systemLocale]];これがあると曜日が表示されない。
		[df setDateFormat:NSLocalizedString(@"E3listDate",nil)];
		NSString *zDate = [df stringFromDate:e3obj.dateUse];
		[df release];
		// zName
		NSString *zName = @"";
		if (e3obj.zName != nil) zName = e3obj.zName;
		// Cell 1行目
		cell.textLabel.text = [NSString stringWithFormat:@"%@　%@", zDate, zName];
		// 金額
		if ([e3obj.nAmount doubleValue] == 0) {
			cellLabel.textColor = [UIColor redColor]; // これだけは赤にした。
			cellLabel.text = @"Zero! 0";
		} else {
			if ([e3obj.nAmount doubleValue] < 0) {
				cellLabel.textColor = [UIColor blueColor];
			} else {
				cellLabel.textColor = [UIColor blackColor];
			}
			// Amount
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			[formatter setNumberStyle:NSNumberFormatterDecimalStyle];  // CurrencyStyle]; // 通貨スタイル
			[formatter setLocale:[NSLocale currentLocale]]; 
			cellLabel.text = [formatter stringFromNumber:e3obj.nAmount];
			[formatter release];
		}

		// Cell 2行目
		NSString *zShop = @"";
		NSString *zCategory = @"";
		NSString *zRepeat = @"";
		if (e3obj.e4shop != nil) zShop = e3obj.e4shop.zName;
		if (e3obj.e5category != nil) zCategory = e3obj.e5category.zName;
		if (0 < [e3obj.nRepeat integerValue]) zRepeat = @"〃 ";
		if (e3obj.e1card) {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"  %@%@  %@  %@", zRepeat, e3obj.e1card.zName, 
										 zShop, zCategory];
			cell.detailTextLabel.textColor = [UIColor brownColor];
		} else {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"  %@  %@  %@", NSLocalizedString(@"Card Undecided",nil), 
										 zShop, zCategory];
			cell.detailTextLabel.textColor = [UIColor redColor];
		}
	}
	return cell;
}

/*
//=================================================================AdMob delegate
// 必要なFramework
// AudioToolbox.framework
// MediaPlayer.framework
// MessageUI.framework ⇒ 役割 "Weak" 変更すること
// QuartzCore.framework
//------------------------------------------------
- (NSString *)publisherIdForAd:(AdMobView *)adView {
	return @"a14d4c11a95320e"; // クレメモ　パブリッシャー ID
}
// AdMob
- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView {
	return self;
}
// AdMob
- (void)didReceiveAd:(AdMobView *)adView {
	NSLog(@"AdMob: Did receive ad");
}
// AdMob
- (void)didFailToReceiveAd:(AdMobView *)adView {
	NSLog(@"AdMob: Did fail to receive ad");
}
*/

// TableView Editボタンスタイル
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
/*	if (indexPath.row < [Me3list count]) {
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleInsert;
 */
	return UITableViewCellEditingStyleNone;
}

// TableView 行選択時の動作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

	// didSelect時のScrollView位置を記録する（viewWillAppearにて再現するため）
	McontentOffsetDidSelect = [tableView contentOffset];
	//NSLog(@"***didSelectRowAtIndexPath: McontentOffsetDidSelect=(%f,%f)", McontentOffsetDidSelect.x, McontentOffsetDidSelect.y);
	
	if (indexPath.section <=0)
	{	//「さらに前へ」
		id datePrev = [[RaE3list objectAtIndex:0] objectAtIndex:0];
		if (datePrev != [NSNull null]) {
			//0.5//NSAutoreleasePool *autoPool = [[NSAutoreleasePool alloc] init];
			[self setMe3list:[datePrev retain]]; [datePrev release]; // retain必要
			//0.5//[autoPool release];
		}
		return;
	}
	else if ([RaE3list count]-1 <= indexPath.section)
	{	//「さらに次へ」
		id dateNext = [[RaE3list objectAtIndex:indexPath.section] objectAtIndex:0];
		if (dateNext != [NSNull null]) {
			//0.5//NSAutoreleasePool *autoPool = [[NSAutoreleasePool alloc] init];
			[self setMe3list:[dateNext retain]]; [dateNext release]; // retain必要
			//0.5//[autoPool release];
		}
		return;
	}
	else
	{
/*		// Comback-L3 記録
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		long lPos = indexPath.section * GD_SECTION_TIMES + indexPath.row;
		if (Pe4shop OR Pe5category OR Pe8bank) {
			// (0)TopMenu >> (1)E4/E5 >> (2)This clear
			[appDelegate.RaComebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:lPos]];
			[appDelegate.RaComebackIndex replaceObjectAtIndex:3 withObject:[NSNumber numberWithLong:-1]];
		} else {
			// (0)TopMenu >> (1)This clear
			[appDelegate.RaComebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:lPos]];
			[appDelegate.RaComebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
		}*/
		// E3詳細画面へ
		[self e3detailView:indexPath]; // この中でAddにも対応
	}
}


#ifdef AzPAD
#pragma mark - <UIPopoverControllerDelegate>
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

