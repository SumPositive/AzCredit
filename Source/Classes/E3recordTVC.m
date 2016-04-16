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
@synthesize PbAddMode;
#ifdef AzPAD
@synthesize delegate;
@synthesize selfPopover;
//@synthesize PbFirstAdd;
#endif


#pragma mark - Delegate

#ifdef AzPAD
- (void)refreshE3recordTVC:(BOOL)bSameDate
{
	if (bSameDate && MindexPathEdit) {	// 日付に変更なく、行位置が有効ならば、修正行だけを再表示する
		//NSArray* ar = [NSArray arrayWithObject:MindexPathEdit];
		//[self.tableView reloadRowsAtIndexPaths:ar withRowAnimation:YES];
		//上↑では、セクションヘッダが更新されない。
		[self.tableView reloadData];
	} else {
		// 日付変更など行位置が変わる場合は、コンテナ配列から更新する必要あり
		[self viewWillAppear:YES];
	}
}

/*- (void)e3modified:(BOOL)bModified
{
	MbModified = bModified;
}*/

#endif


#pragma mark - Action

- (void)azSettingView
{
#ifdef  AzPAD
	if ([MpopSetting isPopoverVisible]==NO) {
		if (!MpopSetting) { //無ければ1度だけ生成する
			SettingTVC* vc = [[SettingTVC alloc] init];  //[1.0.2]Pad対応に伴いControllerにした。
			MpopSetting = [[UIPopoverController alloc] initWithContentViewController:vc];
			[vc release];
		}
		MpopSetting.delegate = nil;	// popoverControllerDidDismissPopover:を呼び出すと！落ちる！
		CGRect rcArrow;
		if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
			rcArrow = CGRectMake(768-32, 1027-60, 32,32);
		} else {
			rcArrow = CGRectMake(1024-320-32, 768-60, 32,32);
		}
		[MpopSetting presentPopoverFromRect:rcArrow  inView:self.navigationController.view  
				   permittedArrowDirections:UIPopoverArrowDirectionDown  animated:YES];
	}
#else
	SettingTVC *view = [[SettingTVC alloc] init];
	//view.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:view animated:YES];
	[view release];
#endif
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
		//autoreleaseにより不要//[app.Me3dateUse release], app.Me3dateUse = nil; //1.0.0//
		app.Me3dateUse = [[e3detail.Re3edit.dateUse copy] autorelease];
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

	AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	apd.entityModified = NO;  //リセット

#ifdef  AzPAD
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:e3detail];
	Mpopover = [[UIPopoverController alloc] initWithContentViewController:nc];
	Mpopover.delegate = self;	// popoverControllerDidDismissPopover:を呼び出してもらうため
	[nc release];
	
	//MindexPathEdit = indexPath;
	[MindexPathEdit release], MindexPathEdit = [indexPath copy];
	
	CGRect rc;
	if (indexPath) {
		rc = [self.tableView rectForRowAtIndexPath:indexPath];
		rc.size.width /= 2;
		rc.origin.y += 10;	rc.size.height -= 20;
		[Mpopover presentPopoverFromRect:rc inView:self.tableView  
				permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
	} else {
		// [+]Add mode
		rc = self.view.bounds;  //  .navigationController.toolbar.frame;
		rc.origin.x += (rc.size.width/2 + 2);				rc.size.width = 1;
		rc.origin.y += (rc.size.height + 10);		rc.size.height = 1;
		//NSLog(@"*** rc.origin.(x, y)=(%f, %f)", rc.origin.x, rc.origin.y);
		[Mpopover presentPopoverFromRect:rc  inView:self.view	//<<<<<.view !!!
				permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES]; //表示開始
	}
	e3detail.selfPopover = Mpopover;  [Mpopover release]; //(retain)  内から閉じるときに必要になる
	e3detail.delegate = self;		// refresh callback
#else
	//[e3detail setHidesBottomBarWhenPushed:YES]; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:YES];
#endif
	[e3detail release];
}

- (void)setMe3list:(NSDate *)dateMiddle // この日時が画面の(MmoreScrollPosition)位置になるように前後最大50行読み込み表示する
{
	NSLog(@"setMe3list: dateMiddle=%@", dateMiddle);
	//BOOL bTargetBrink = YES; // 指定行を反転ブリンクさせる
	if (dateMiddle==nil) {
		//bTargetBrink = NO;
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
	//[1.1.2]システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]; //「明細」セクションでも使っているため、df_sectionと同じ所でreleseしている。
	[df_section setCalendar:calendar];
	[df_index setCalendar:calendar];

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
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit; // タイムゾーン変換させるため「時」が必須
	// 「明細」セクション
	for (E3record *e3 in mE3array) 
	{
		NSDateComponents *compSec = [calendar components:unitFlags fromDate:e3.dateUse];
		if (iYear != compSec.year || iMonth != compSec.month) 
		{
			[RaE3list addObject:e3days];	// 直前までの e3days を確定し、RaE3list へ追加する
			[e3days release]; e3days = nil; // Me3list にaddしたものを切り離してMe3listに任せる。
			e3days = [NSMutableArray new]; // 新しいセクション領域を確保する。
			iYear = compSec.year;
			iMonth = compSec.month;
			compSec.day = 1;
			compSec.hour = 0;
			NSDate *dateSection = [calendar dateFromComponents:compSec];
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
	[calendar release];
	
	// テーブルビューを更新
    [self.tableView reloadData];
	
	if (3 <= [RaE3list count]) { // 少なくとも、Top + Monthly + End の3セクションある
		NSIndexPath *indexPath;
		if (iSecMiddle < 0) { // 現在以降の明細が無いとき
			// 最新行（最終ページ）を表示する　＜＜最終行を画面下部に表示する＞＞  +Add行まで表示するためMiddleにした。
			indexPath = [NSIndexPath indexPathForRow:0 inSection:[RaE3list count]-1]; // 行末セクションへ
			[self.tableView scrollToRowAtIndexPath:indexPath			//  Middle 中央へ
								  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
		} else {
			switch (MmoreScrollPosition) {
				case UITableViewScrollPositionTop:
					// 前の行へ
					if (0 < iRowMiddle) {
						iRowMiddle--;
					} else {
						if (0 < iSecMiddle) {
							iSecMiddle--;
							iRowMiddle = [[RaE3list objectAtIndex:iSecMiddle] count] - 1;
						}
					}
					break;
				case UITableViewScrollPositionBottom:
					// 次の行へ
					if (iRowMiddle < [[RaE3list objectAtIndex:iSecMiddle] count] - 1) {
						iRowMiddle++;
					} else {
						if (iSecMiddle < [RaE3list count] - 1) {
							iSecMiddle++;
							iRowMiddle = 0;
						}
					}
					break;
				default:
					break;
			}
			indexPath = [NSIndexPath indexPathForRow:iRowMiddle inSection:iSecMiddle];
//			if (bTargetBrink) {
				[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:MmoreScrollPosition];
				[self performSelector:@selector(deselectRow:) withObject:indexPath afterDelay:0.5]; // 0.5s後に選択状態を解除する
//			} else {
//				[self.tableView scrollToRowAtIndexPath:indexPath
//									  atScrollPosition:UITableViewScrollPositionMiddle animated:NO]; // Middle固定
//			}
		}
	}
}

- (void)deselectRow:(NSIndexPath*)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態を解除する
}


#pragma mark - View lifecicle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStylePlain]; // セクションなしテーブル
	if (self) {
		// 初期化
		self.Pe4shop = nil;
		self.Pe5category = nil;
		self.Pe8bank = nil;
		self.PbAddMode = NO;
		MmoreScrollPosition = UITableViewScrollPositionMiddle;
		
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		//[Me3dateUse release],// autoreleseにしたので解放不要（すれば落ちる）
		app.Me3dateUse = nil; //1.0.0//
		//
#ifdef FREE_AD
//		RoAdMobView = nil;
#endif
#ifdef AzPAD
//		PbFirstAdd = NO;
#endif
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
//【Tips】ここでaddSubviewするオブジェクトは全てautoreleaseにすること。メモリ不足時には自動的に解放後、改めてここを通るので、初回同様に生成するだけ。
- (void)loadView
{
    [super loadView];
	
	//self.title =  親からセットする。 E4,E5などから呼び出されるため
	
	// Tool Bar Button
	UIBarButtonItem *buFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			 target:nil action:nil] autorelease];
	UIBarButtonItem *buAdd = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																			target:self action:@selector(barButtonAdd)] autorelease];
#ifdef AzPAD
	NSArray *buArray = [NSArray arrayWithObjects: buFlex, buAdd, buFlex, nil];
	[self setToolbarItems:buArray animated:YES];
#else
	UIBarButtonItem *buTop = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-Top.png"]
															  style:UIBarButtonItemStylePlain  //Bordered
															  target:self action:@selector(barButtonTop)] autorelease];
	UIBarButtonItem *buSet = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon16-Setting.png"]
															  style:UIBarButtonItemStylePlain  //Bordered
															  target:self action:@selector(azSettingView)] autorelease];
	NSArray *buArray = [NSArray arrayWithObjects: buTop, buFlex, buAdd, buFlex, buSet, nil];
	[self setToolbarItems:buArray animated:YES];
#endif

	// TableCell表示で使う日付フォーマッタを定義する
	assert(RcellDateFormatter==nil);
	RcellDateFormatter = [[NSDateFormatter alloc] init];
	//[1.1.2]システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[RcellDateFormatter setCalendar:calendar];
	[calendar release];
	//[df setLocale:[NSLocale systemLocale]];これがあると曜日が表示されない。
	[RcellDateFormatter setDateFormat:NSLocalizedString(@"E3listDate",nil)];

	// TableCell表示で使う金額フォーマッタを定義する
	assert(RcellNumberFormatter==nil);
	RcellNumberFormatter = [[NSNumberFormatter alloc] init];
	[RcellNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];  // CurrencyStyle]; // 通貨スタイル
	[RcellNumberFormatter setLocale:[NSLocale currentLocale]]; 

	
//#if defined (FREE_AD) && !defined (AzPAD) //Not iPad//
//	assert(RoAdMobView==nil);
//	RoAdMobView = [[GADBannerView alloc]
//                   initWithFrame:CGRectMake(0, 0,			// TableCell用
//                                            GAD_SIZE_320x50.width,
//                                            GAD_SIZE_320x50.height)]; // autoreleaseだめ：cellへaddSubする前に破棄されてしまうので、自己管理している
//	RoAdMobView.delegate = nil; //Delegateなし
//	RoAdMobView.adUnitID = AdMobID_iPhone;
//	RoAdMobView.rootViewController = self;
//	GADRequest *request = [GADRequest request];
//	[RoAdMobView loadRequest:request];	
//#endif
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:YES];
	//[0.4]以降、ヨコでもツールバーを表示するようにした。
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示
	
	// 画面表示に関係する Option Setting を取得する
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	
#ifdef AzPAD
	if (Pe4shop || Pe5category || Pe8bank) {
		self.navigationItem.hidesBackButton = NO;
	} else {
		self.navigationItem.hidesBackButton = YES;
	}
#endif
	
	// テーブルソース セット
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (RaE3list==nil || app.Me3dateUse) {
		//NSAutoreleasePool *autoPool = [[NSAutoreleasePool alloc] init];
		NSLog(@"viewWillAppear: app.Me3dateUse=%@", app.Me3dateUse);
		MmoreScrollPosition = UITableViewScrollPositionMiddle;
		[self setMe3list:app.Me3dateUse];
		//[autoPool release];
	}
	else if (0 < McontentOffsetDidSelect.y) {
		// app.Me3dateUse=nil のときや、メモリ不足発生時に元の位置に戻すための処理。
		// McontentOffsetDidSelect は、didSelectRowAtIndexPath にて記録している。
		self.tableView.contentOffset = McontentOffsetDidSelect;
	}

/****************　UITableView Pull-To-Reload の実験
	NSLog(@"self.tableView.frame=(%f,%f,%f,%f) contentOffset=(%f,%f)  contentSize=(%f,%f)", 
		  self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height,
		  self.tableView.contentOffset.x, self.tableView.contentOffset.y,
		  self.tableView.contentSize.width, self.tableView.contentSize.height );

	self.tableView.pagingEnabled = YES;
 */
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
#ifdef AzPAD
	// viewWillAppear:に入れると再描画時に通ってBarが乱れるため、ここにした。 loadViewに入れると配下から戻ったときダメ
	// SplitViewタテのとき [Menu] button を表示する
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (app.barMenu) {
		UIBarButtonItem* buFlexible = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		UIBarButtonItem* buTitle = [[[UIBarButtonItem alloc] initWithTitle: self.title  style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
		NSMutableArray* items = [[NSMutableArray alloc] initWithObjects: app.barMenu, buFlexible, buTitle, buFlexible, nil];
		UIToolbar* toolBar = [[[UIToolbar alloc] init] autorelease];
		toolBar.barStyle = UIBarStyleDefault;
		[toolBar setItems:items animated:NO];
		[toolBar sizeToFit];
		self.navigationItem.titleView = toolBar;
		[items release];
	}
#endif
	
    [super viewDidAppear:animated];
	
	if (self.PbAddMode==NO && [RaE3list count] < 3) { // 少なくとも、Top + Monthly + End の3セクションあるから
		// 明細なし ＞ 前画面に戻す
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"E3list NoData",nil)
														message:NSLocalizedString(@"E3list NoData msg",nil)
													   delegate:self 
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"Roger",nil), nil];
		alert.tag = ALERT_TAG_NoMore; // 前画面に戻る
		[alert show];
		[alert release];
		return;
	}
	
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
	
	if (self.PbAddMode) {
		self.PbAddMode = NO; //1度限り、さもなくばiPhoneでは抜け出せなくなる
		[self barButtonAdd];	//[+]
	}
}

#ifdef AzPAD
- (void)viewDidDisappear:(BOOL)animated
{
	if ([Mpopover isPopoverVisible]) 
	{	//[1.1.0]Popover(E3recordDetailTVC) あれば閉じる(Cancel) 　＜＜閉じなければ、アプリ終了⇒起動⇒パスワード画面にPopoverが現れてしまう。
		[MocFunctions rollBack];	// 修正取り消し
		[Mpopover dismissPopoverAnimated:NO];	//YES=だと残像が残る
	}
    [super viewWillDisappear:animated];
}
#endif


#pragma mark View - Rotate

// 回転の許可　ここでは許可、禁止の判定だけする
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifdef AzPAD
	return YES;
#else
	// 回転禁止でも、正面は常に許可しておくこと。
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
#endif
}

#ifdef FREE_AD
// 回転を始める前に呼ばれる
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
								duration:(NSTimeInterval)duration
{	
//	if (RoAdMobView) {
//		CGRect rc = RoAdMobView.frame;
//		if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
//		{	// タテ
//			rc.origin.x = 0;
//		} else {
//			rc.origin.x += (480 - GAD_SIZE_320x50.width)/2.0;		// ヨコのとき中央にする
//		}	
//		RoAdMobView.frame = rc;
//	}
}
#endif

// 回転した後に呼び出される
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadData];  // cellLable位置調整するため

#ifdef AzPAD
	if ([MpopSetting isPopoverVisible]) {
		[MpopSetting dismissPopoverAnimated:YES];
	}
	
	if ([Mpopover isPopoverVisible]) {
		// Popoverの位置を調整する　＜＜UIPopoverController の矢印が画面回転時にターゲットから外れてはならない＞＞
		if (MindexPathEdit) { 
			//NSLog(@"MindexPathEdit=%@", MindexPathEdit);
			[self.tableView scrollToRowAtIndexPath:MindexPathEdit 
								  atScrollPosition:UITableViewScrollPositionMiddle animated:NO]; // YESだと次の座標取得までにアニメーションが終了せずに反映されない
			CGRect rc = [self.tableView rectForRowAtIndexPath:MindexPathEdit];
			rc.size.width /= 2;
			rc.origin.y += 10;	rc.size.height -= 20;
			[Mpopover presentPopoverFromRect:rc  inView:self.tableView 
					permittedArrowDirections:UIPopoverArrowDirectionLeft  animated:YES]; //表示開始
		} else {
			// 回転後のアンカー位置が再現不可なので閉じる
			//[Mpopover dismissPopoverAnimated:YES];
			// アンカー位置 [+]
			CGRect rc = self.view.bounds;  //  .navigationController.toolbar.frame;
			rc.origin.x += (rc.size.width/2 + 2);				rc.size.width = 1;
			rc.origin.y += (rc.size.height + 10);		rc.size.height = 1;
			[Mpopover presentPopoverFromRect:rc  inView:self.view	//<<<<<.view !!!
					permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES]; //表示開始
		}
	}
#endif
}


#pragma mark  View - Unload - dealloc

- (void)unloadRelease {	// dealloc, viewDidUnload から呼び出される
	//【Tips】loadViewでautorelease＆addSubviewしたオブジェクトは全てself.viewと同時に解放されるので、ここでは解放前の停止処理だけする。
	NSLog(@"--- unloadRelease --- E3recordTVC");
#ifdef FREE_AD
//	if (RoAdMobView) {
//		RoAdMobView.delegate = nil;  //受信STOP  ＜＜これが無いと破棄後に呼び出されて落ちる
//		[RoAdMobView release], RoAdMobView = nil;	//cellへのaddSubなので、自己管理している。
//	}
#endif
	//【Tips】デリゲートなどで参照される可能性のあるデータなどは破棄してはいけない。
	// 他オブジェクトからの参照無く、viewWillAppearにて生成されるので破棄可能
	[RaE3list release],		RaE3list = nil;
	[RaSection release],	RaSection = nil;
	[RaIndex release],		RaIndex = nil;
	[RcellDateFormatter release], RcellDateFormatter = nil;
	[RcellNumberFormatter release], RcellNumberFormatter = nil;
}

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[self unloadRelease];
#ifdef AzPAD
	delegate = nil;
	[selfPopover release], selfPopover = nil;
	[MindexPathEdit release], MindexPathEdit = nil;
#endif
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
//	if (indexPath.section <= 0 || [RaE3list count]-1 <= indexPath.section) 
//	{	// 先頭と末尾
//		return GAD_SIZE_320x50.height; // AdMob
//	}
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
	
	
	if (indexPath.section <= 0 || [RaE3list count]-1 <= indexPath.section) 
	{
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
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				cell.textLabel.textColor = [UIColor grayColor];
				cell.textLabel.text = NSLocalizedString(@"E3list No More",nil);
#ifdef FREE_AD
//				if (RoAdMobView) { // Request an AdMob ad for this table view cell
//					[cell.contentView addSubview:RoAdMobView]; //自己管理ＯＢＪ： unloadReleaseにて解放
//				}
#endif
			}
#ifdef FREE_AD
//			if (RoAdMobView) {
//				CGRect rc = RoAdMobView.frame;
//				if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
//				{	// タテ
//					rc.origin.x = 0;
//				} else {
//					rc.origin.x = (480 - rc.size.width) / 2.0;		// ヨコのとき中央にする
//				}	
//				RoAdMobView.frame = rc;
//			}
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
				cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"E3list More",nil), (long)GD_E3_SELECT_LIMIT];
				cell.showsReorderControl = NO; // Move禁止
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
			cellLabel.backgroundColor = [UIColor whiteColor];
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
					cell.imageView.image = nil; //左画像なし：少しでも幅広くするため。見栄えも問題なさそうだ。
				}
			}
		} else {
			// クイック追加にてカード(未定)のとき
			cell.imageView.image = nil;
		}
#ifdef AzPAD
		if (cell.imageView.image==nil) {
			cell.imageView.image = [UIImage imageNamed:@"Icon32-Clear"]; //幅に余裕があるので、画像を入れて揃えた方が見栄え良いと判断した。
		}
#endif
		
		// zDate 利用日		RcellDateFormatterを事前生成することにより高速化
		NSString *zDate = [RcellDateFormatter stringFromDate:e3obj.dateUse];
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
			cellLabel.text = [RcellNumberFormatter stringFromNumber:e3obj.nAmount];
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
			MmoreScrollPosition = UITableViewScrollPositionTop;
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
			MmoreScrollPosition = UITableViewScrollPositionBottom;
			[self setMe3list:[dateNext retain]]; [dateNext release]; // retain必要
			//0.5//[autoPool release];
		}
		return;
	}
	else
	{
		// E3詳細画面へ
		[self e3detailView:indexPath]; // この中でAddにも対応
	}
}


#ifdef AzPAD
#pragma mark - <UIPopoverControllerDelegate>
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{	// Popoverの外部をタップして閉じる前に通知
	AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (apd.entityModified) {	// 変更あり
		alertBox(NSLocalizedString(@"Cancel or Save",nil), 
				 NSLocalizedString(@"Cancel or Save msg",nil), NSLocalizedString(@"Roger",nil));
		return NO; // Popover外部タッチで閉じるのを禁止 ＜＜追加MOCオブジェクトをＣａｎｃｅｌ時に削除する必要があるため＞＞
	}
	else {	// 変更なし
		// E3recordDetailTVC:cancelClose:【insertAutoEntity削除】を通ってないのでここで通す。
		if ([popoverController.contentViewController isMemberOfClass:[UINavigationController class]]) {
			UINavigationController* nav = (UINavigationController*)popoverController.contentViewController;
			if (0 < [nav.viewControllers count] && [[nav.viewControllers objectAtIndex:0] isMemberOfClass:[E3recordDetailTVC class]]) 
			{	// Popover外側をタッチしたとき cancelClose: を通っていないので、ここで通す。 ＜＜＜同じ処理が TopMenuTVC.m にもある＞＞＞
				E3recordDetailTVC* e3tvc = (E3recordDetailTVC *)[nav.viewControllers objectAtIndex:0]; //Root VC   <<<.topViewControllerではダメ>>>
				if ([e3tvc respondsToSelector:@selector(cancelClose:)]) {	// メソッドの存在を確認する
					[e3tvc cancelClose:nil];	// 【insertAutoEntity削除】
				}
			}
		}
		return YES;	// Popover外部タッチで閉じるのを許可
	}
}
#endif

@end

