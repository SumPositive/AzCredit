//
//  E2invoiceTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "E2invoiceTVC.h"
#import "E6partTVC.h"

//#ifdef AzPAD
#import "TopMenuTVC.h"
//#endif

#define	TAG_ALERT_NoCheck		109
#define	TAG_ALERT_toPAY			118
#define	TAG_ALERT_toPAID		127


#pragma mark - E2temp
//-------------------------------------------E2invoiceTVCローカル使用一時作業クラス定義
@interface E2temp : NSObject
@property (nonatomic, assign) NSInteger			iYearMMDD;
@property (nonatomic, assign) BOOL				bPaid;
@property (nonatomic, strong) NSDecimalNumber	*decSum;
@property (nonatomic, assign) NSInteger			iNoCheck;
@property (nonatomic, strong) NSMutableSet		*e2invoices;
// init禁止
- (id)init __attribute__((unavailable("init is not available")));
- (instancetype)initWithYearMMDD:(NSInteger)iY inPaid:(BOOL)bP NS_DESIGNATED_INITIALIZER;
@end
//-------------------------------------------E2invoiceTVCローカル使用一時作業クラス実装
@implementation E2temp

- (instancetype)initWithYearMMDD:(NSInteger)iY inPaid:(BOOL)bP {
	self = [super init];
	if (self != nil) {
		self.iYearMMDD = iY;
		self.bPaid = bP;
		//iSum = 0;
		self.decSum = [NSDecimalNumber zero]; // dealloc で release されるため。
		self.iNoCheck = 0;
		self.e2invoices = [NSMutableSet new];
	}
	return self;
}
@end


#pragma mark - E2invoiceTVC

@interface E2invoiceTVC ()
{
    NSMutableArray		*RaE2list;
    UIButton		*MbuPaid;
    UIButton		*MbuUnpaid;
    AppDelegate *appDelegate;
    BOOL		MbFirstAppear;
    BOOL		MbAction;		// 連続タッチされると落ちるので、その対策
    CGPoint		McontentOffsetDidSelect; // didSelect時のScrollView位置を記録
}
- (void)viewDesign:(BOOL)animated;
@end

@implementation E2invoiceTVC

#pragma mark - Action

#ifdef xxxxxxxxxxxxx
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (buttonIndex == alertView.cancelButtonIndex) return; // CANCEL
	if (Me2cellButton == nil) return;
	
	switch (alertView.tag) {
			/* 初版未対応！未チェックあれば禁止
			 case TAG_ALERT_NoCheck: // 未チェック分を翌月払いにする
			 if (Me2cellButton.e1unpaid) {
			 // このE2を Paid にする                                ↓YES:未チェックE6の支払日を翌月以降へ
			 [EntityRelation e2paid:Me2cellButton inE6payNextMonth:YES]; // Paid <> Unpaid を切り替える
			 // context commit (SAVE)
			 [EntityRelation commit];
			 }
			 break;*/
			
		case TAG_ALERT_toPAID:	// PAIDにする
			if (Me2cellButton.bPaid == NO) {
				// このE2を PAID にする
				for (E2invoice *e2 in [Me2cellButton.e2invoices allObjects]) {
					[MocFunctions e2paid:e2 inE6payNextMonth:NO]; // Paid <> Unpaid を切り替える
				}
				// context commit (SAVE)
				[MocFunctions commit];
			}
			break;
		case TAG_ALERT_toPAY:	// Unpaidに戻す
			//if (Me2cellButton.e1paid) {
			if (Me2cellButton.bPaid == YES) {
				// このE2を Unpaid に戻す
				for (E2invoice *e2 in [Me2cellButton.e2invoices allObjects]) {
					[MocFunctions e2paid:e2 inE6payNextMonth:NO]; // Paid <> Unpaid を切り替える
				}
				// context commit (SAVE)
				[MocFunctions commit];
			}
			break;
	}
	// 再描画
	MbFirstAppear = YES; // ボタン位置調整のため
	[self viewWillAppear:YES]; // Fech データセットさせるため
}
#endif

- (void)barButtonTop 
{
	[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
}

- (void)deselectRow:(NSIndexPath*)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態を解除する
}


- (void)toPAID
{
	if (MbAction) return;	// 処理中につき拒否
	MbAction = YES;	// 連続操作を拒否するため
	
	//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

	assert(1 < [RaE2list count]); // Section:1
	assert(0 < [RaE2list[1] count]); // Section:1 Row:0
	E2temp* e2obj = RaE2list[1][0]; // Unpaidの最上行
	assert(e2obj);
	assert(e2obj.bPaid==NO);
	if (0 < e2obj.iNoCheck) 
	{	// E2配下に未チェックあり禁止
		//[appDelegate audioPlayer:@"Tock.caf"];  // キークリック音
		alertBox(NSLocalizedString(@"NoCheck",nil),
				 NSLocalizedString(@"NoCheck msg",nil),
				 NSLocalizedString(@"Roger",nil));
		MbAction = NO; // Action操作許可
		return;
	}
	
	//[appDelegate audioPlayer:@"unlock.caf"];  // ロック解除音

	// 移動元の Unpaid 最上行Cell
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
	[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	[self performSelector:@selector(toPAID_After) withObject:nil afterDelay:0.5];
	
	// 内部移動処理
	// このE2を PAID にする
	for (E2invoice *e2 in (e2obj.e2invoices).allObjects) {
		[MocFunctions e2paid:e2 inE6payNextMonth:NO]; // Paid <> Unpaid を切り替える
	}
	[MocFunctions commit];		// context commit (SAVE)
	// RaE7list が更新される。
}

- (void)toPAID_After
{
	// アニメ準備
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(toPAID_After_AnimeEnd)]; //アニメーション終了後に呼び出す＜＜setAnimationDelegate必要

	CGRect rc = MbuPaid.frame; rc.origin.y -= 40; MbuPaid.frame = rc;
	
	// 再描画
	MbFirstAppear = YES; // ボタン位置調整のため
	[self viewWillAppear:NO]; // RaE2list データ更新させるため
	[self viewDesign:NO];

	// 移動先の PAID 最下行Cell
	assert(0 < [RaE2list count]); // Section:0
	assert(0 < [RaE2list[0] count]); // Section:0 Row:Bottom
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[RaE2list[0] count]-1 inSection:0];
	[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	[self performSelector:@selector(deselectRow:) withObject:indexPath afterDelay:0.8]; // 選択状態を解除する
	
    if (IS_PAD) {
        // TopMenuTVCにある 「未払合計額」を再描画するための処理
        //AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController* naviLeft = [appDelegate.mainSplit.viewControllers objectAtIndex:0];	//[0]Left
        TopMenuTVC* tvc = (TopMenuTVC *)[naviLeft.viewControllers objectAtIndex:0]; //<<<.topViewControllerではダメ>>>
        if ([tvc respondsToSelector:@selector(refreshTopMenuTVC)]) {	// メソッドの存在を確認する
            [tvc refreshTopMenuTVC]; // 「未払合計額」再描画を呼び出す
        }
    }
	// アニメ開始
	[UIView commitAnimations];

	//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate audioPlayer:@"mail-sent.caf"];  // Mail.appの送信音
}

- (void)toPAID_After_AnimeEnd
{	// アニメ終了後、
	//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate audioPlayer:@"lock.caf"];  // ロック音
	MbAction = NO; // Action操作許可
}

- (void)toUnpaid
{
	if (MbAction) return;	// 処理中につき拒否
	MbAction = YES;	// 連続操作を拒否するため
	
	//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

	assert(0 < [RaE2list count]); // Section:0
	assert(0 < [RaE2list[0] count]); // Section:0 Row:Bottom
	NSInteger iRowBottom = [RaE2list[0] count] - 1;
	E2temp* e2obj = RaE2list[0][iRowBottom]; // PAIDの最下行
	assert(e2obj);
	assert(e2obj.bPaid==YES);

	//[appDelegate audioPlayer:@"unlock.caf"];  // ロック解除音

	// 移動元の PAID 最下行Cell
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:iRowBottom inSection:0];
	[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	[self performSelector:@selector(toUnpaid_After) withObject:nil afterDelay:0.5];
	// 内部移動処理
	// このE2を Unpaid に戻す
	for (E2invoice *e2 in (e2obj.e2invoices).allObjects) {
		[MocFunctions e2paid:e2 inE6payNextMonth:NO]; // Paid <> Unpaid を切り替える
	}
	[MocFunctions commit];		// context commit (SAVE)
	// RaE7list が更新される。
}

- (void)toUnpaid_After
{
	// アニメ準備
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(toUnpaid_After_AnimeEnd)]; //アニメーション終了後に呼び出す＜＜setAnimationDelegate必要
	
	CGRect rc = MbuUnpaid.frame; rc.origin.y += 40; MbuUnpaid.frame = rc;
	
	// 再描画
	MbFirstAppear = YES; // ボタン位置調整のため
	[self viewWillAppear:NO]; // RaE2list データ更新させるため
	[self viewDesign:NO];
	
	// 移動先の Unpaid 最上行Cell
	assert(1 < [RaE2list count]); // Section:1
	assert(0 < [RaE2list[1] count]); // Section:1 Row:0
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
	[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	[self performSelector:@selector(deselectRow:) withObject:indexPath afterDelay:0.8]; // 0.5s後に選択状態を解除する
	
    if (IS_PAD) {
        // TopMenuTVCにある 「未払合計額」を再描画するための処理
        //AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController* naviLeft = [appDelegate.mainSplit.viewControllers objectAtIndex:0];	//[0]Left
        TopMenuTVC* tvc = (TopMenuTVC *)[naviLeft.viewControllers objectAtIndex:0]; //<<<.topViewControllerではダメ>>>
        if ([tvc respondsToSelector:@selector(refreshTopMenuTVC)]) {	// メソッドの存在を確認する
            [tvc refreshTopMenuTVC]; // 「未払合計額」再描画を呼び出す
        }
    }
	// アニメ開始
	[UIView commitAnimations];

	//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate audioPlayer:@"ReceivedMessage.caf"];  // Mail.appの受信音
}

- (void)toUnpaid_After_AnimeEnd
{	// アニメ終了後、
	//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate audioPlayer:@"lock.caf"];  // ロック音
	MbAction = NO; // Action操作許可
}


#pragma mark - View lifecicle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (instancetype)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStyleGrouped]; // セクションありテーブル
	if (self) {
		// 初期化成功
		appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
		MbFirstAppear = YES; // Load後、最初に1回だけ処理するため
		MbAction = NO; // Action操作許可
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
//【Tips】ここでaddSubviewするオブジェクトは全てautoreleaseにすること。メモリ不足時には自動的に解放後、改めてここを通るので、初回同様に生成するだけ。
- (void)loadView
{
    [super loadView];

    if (IS_PAD) {
        // Set up NEXT Left Back [<<] buttons.
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithImage:[UIImage imageNamed:@"Icon16-Return2.png"]
                                                  style:UIBarButtonItemStylePlain  target:nil  action:nil];
    }else{
        // Set up NEXT Left Back [<<<] buttons.
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithImage:[UIImage imageNamed:@"Icon16-Return3.png"]
                                                 style:UIBarButtonItemStylePlain  target:nil  action:nil];
    }
	
    if (IS_PAD) {
        // Tool Bar Button なし
    }else{
        // Tool Bar Button
        UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil action:nil];
        UIBarButtonItem *buTop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-Top.png"]
                                                                  style:UIBarButtonItemStylePlain  //Bordered
                                                                 target:self action:@selector(barButtonTop)];
        NSArray *buArray = @[buTop, buFlex];
        [self setToolbarItems:buArray animated:YES];
    }

	//【Tips】UIButtonは、Autoreleaseである。ゆえに、addSubview後のrelease禁止！。かつ、メモリ不足時には自動的に解放後、改めてloadViewを通るので、初回同様に生成する。
	// PAID  ボタン
	MbuPaid = [UIButton buttonWithType:UIButtonTypeCustom]; //Autorelease
	[MbuPaid setBackgroundImage:[UIImage imageNamed:@"Icon90x70-toPAID"] forState:UIControlStateNormal];
	[MbuPaid addTarget:self action:@selector(toPAID) forControlEvents:UIControlEventTouchUpInside];
	[self.tableView addSubview:MbuPaid];

	// Unpaid ボタン
	MbuUnpaid = [UIButton buttonWithType:UIButtonTypeCustom]; //Autorelease
	[MbuUnpaid setBackgroundImage:[UIImage imageNamed:@"Icon90x70-toUnpaid"] forState:UIControlStateNormal];
	[MbuUnpaid addTarget:self action:@selector(toUnpaid) forControlEvents:UIControlEventTouchUpInside];
	[self.tableView addSubview:MbuUnpaid];
}

- (void)viewDesign:(BOOL)animated 		//初期表示および回転時に位置調整して描画する
{
	// PAID ,Unpaid ボタン設置
	CGRect rc = [self.tableView rectForFooterInSection:0];
	if ([[UIDevice currentDevice].systemVersion compare:@"6.0"]==NSOrderedAscending) { // ＜ "6.0"
		MbuPaid.frame = CGRectMake(rc.size.width/2-70, rc.origin.y+10,  90,70);
	} else {
		MbuPaid.frame = CGRectMake(rc.size.width/2-70, rc.origin.y+17,  90,70);
	}
	MbuUnpaid.frame = CGRectMake(rc.size.width/2+40, rc.origin.y-15, 90,70);
	
	MbuUnpaid.hidden = ([RaE2list[0] count] <= 0);		// Index: 0=Paid 1=Unpaid
	MbuPaid.hidden = ([RaE2list[1] count] <= 0);			// Index: 0=Paid 1=Unpaid
	
	[self.tableView bringSubviewToFront:MbuPaid];	//改めてtitleForFooterInSection:でも呼び出している
	[self.tableView bringSubviewToFront:MbuUnpaid];
	
	if (animated) {
		MbuPaid.alpha = 0;
		MbuUnpaid.alpha = 0;
		// アニメ準備
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:nil context:context];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.7];
		
		MbuPaid.alpha = 1.0;
		MbuUnpaid.alpha = 1.0;
		
		// アニメ開始
		[UIView commitAnimations];
	}
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

	if (_Re1select && _Re8select) {
		AzLOG(@"Exit ERROR: Pe1select,Re8select != nil");
//		GA_TRACK_EVENT_ERROR(@"Exit ERROR: Pe1select,Re8select != nil",0);
		exit(-1);  // Fail
	}
	
	// Me2list : Pe1select.e2invoices 全データ取得 >>> (0)支払済セクション　(1)未払いセクション に分割
	if (RaE2list != nil) {
		RaE2list = nil;
	}

	//E7E2クリーンアップ
	[MocFunctions e7e2clean];		//E2配下E6が無ければE2削除する & E7配下E2が無ければE7削除する

	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"nYearMMDD" ascending:YES];
	NSArray *sortAsc = @[sort1]; // 支払日昇順
	sort1 = [[NSSortDescriptor alloc] initWithKey:@"nYearMMDD" ascending:NO];
	NSArray *sortDesc = @[sort1]; // 支払日降順：Limit抽出に使用
	
	NSArray *arFetch = nil;
	if (_Re1select) {	//------------------------------E1card
		assert(_Re8select==nil);
		NSMutableArray *muE2tmp = nil;
		// E2paid 支払済（直近の20件）
		arFetch = [MocFunctions select:@"E2invoice" 
								   limit:GD_PAIDLIST_MAX
								  offset:0
								   where:[NSPredicate predicateWithFormat:@"e1paid == %@", _Re1select]
									sort:sortDesc]; // 日付降順の先頭から20件抽出
		muE2tmp = [NSMutableArray new];
		for (E2invoice *e2 in [arFetch reverseObjectEnumerator]) { // arFetchは降順なのでreverseしている
			E2temp *e2t = [[E2temp alloc] initWithYearMMDD:(e2.nYearMMDD).integerValue inPaid:YES];
			e2t.decSum = e2.sumAmount;
			e2t.iNoCheck = (e2.sumNoCheck).integerValue;
			[e2t.e2invoices addObject:e2];
			[muE2tmp addObject:e2t];
		}
		RaE2list = [[NSMutableArray alloc] initWithObjects:muE2tmp,nil]; // 一次元追加
		// E2unpaid 未払い（全件）
		arFetch = [MocFunctions select:@"E2invoice" 
								   limit:0 // 全件
								  offset:0
								   where:[NSPredicate predicateWithFormat:@"e1unpaid == %@", _Re1select]
									sort:sortAsc]; // 日付昇順で全件抽出
		muE2tmp = [NSMutableArray new];
		for (E2invoice *e2 in arFetch) { // arFetchは昇順
			E2temp *e2t = [[E2temp alloc] initWithYearMMDD:(e2.nYearMMDD).integerValue inPaid:NO];
			e2t.decSum = e2.sumAmount;
			e2t.iNoCheck = (e2.sumNoCheck).integerValue;
			[e2t.e2invoices addObject:e2];
			[muE2tmp addObject:e2t];
		}
		[RaE2list addObject:muE2tmp]; // 一次元追加
	}
	else if (_Re8select) { //---------------------------E8bank
		assert(_Re1select==nil);
		NSMutableArray *muE2paid = [NSMutableArray new];
		NSMutableArray *muE2unpaid = [NSMutableArray new];
		// E2paid 支払済（直近の20件）
		arFetch = [MocFunctions select:@"E2invoice" 
								   limit:GD_PAIDLIST_MAX
								  offset:0
								   where:[NSPredicate predicateWithFormat:@"e1paid.e8bank == %@", _Re8select]
									sort:sortDesc]; // 日付降順の先頭から20件抽出
		[muE2paid addObjectsFromArray:arFetch];
		// E2unpaid 未払い（全件）
		arFetch = [MocFunctions select:@"E2invoice" 
								   limit:0 // 全件
								  offset:0
								   where:[NSPredicate predicateWithFormat:@"e1unpaid.e8bank == %@", _Re8select]
									sort:sortAsc]; // 日付昇順で全件抽出
		[muE2unpaid addObjectsFromArray:arFetch];
		// PAID .nYearMMDD 昇順ソート
		[muE2paid sortUsingDescriptors:sortAsc];
		// 日付の重複を取り除く ＜＜高速列挙で削除は危険！以下のように末尾から削除すること＞＞
		// Paid
		NSMutableArray *muE2tmp = [NSMutableArray new];
		E2temp *e2t = nil;
		for (E2invoice *e2 in muE2paid) {
			if (e2t==nil OR e2t.iYearMMDD != (e2.nYearMMDD).integerValue) {
				if (e2t) {
					[muE2tmp addObject:e2t];
				}
				e2t = [[E2temp alloc] initWithYearMMDD:(e2.nYearMMDD).integerValue inPaid:YES];
			}
			e2t.decSum = [e2t.decSum decimalNumberByAdding:e2.sumAmount];
			e2t.iNoCheck += (e2.sumNoCheck).integerValue;
			[e2t.e2invoices addObject:e2];
		}
		if (e2t) {
			[muE2tmp addObject:e2t];
		}
		RaE2list = [[NSMutableArray alloc] initWithObjects:muE2tmp,nil]; // 一次元追加
		// Paid
		muE2tmp = [NSMutableArray new];
		e2t = nil;
		for (E2invoice *e2 in muE2unpaid) {
			if (e2t==nil OR e2t.iYearMMDD != (e2.nYearMMDD).integerValue) {
				if (e2t) {
					[muE2tmp addObject:e2t];
				}
				e2t = [[E2temp alloc] initWithYearMMDD:(e2.nYearMMDD).integerValue inPaid:NO];
			}
			//e2t.iSum += [e2.sumAmount integerValue];
			e2t.decSum = [e2t.decSum decimalNumberByAdding:e2.sumAmount];
			e2t.iNoCheck += (e2.sumNoCheck).integerValue;
			[e2t.e2invoices addObject:e2];
		}
		if (e2t) {
			[muE2tmp addObject:e2t];
		}
		[RaE2list addObject:muE2tmp]; // 一次元追加
	}
	else {
		AzLOG(@"Exit ERROR: Pe1select,Re8select == nil");
//		GA_TRACK_EVENT_ERROR(@"Exit ERROR: Pe1select,Re8select == nil",0);
		exit(-1);  // Fail
	}
	
	// テーブルビューを更新します。
    [self.tableView reloadData];

	if (!MbFirstAppear OR RaE2list.count < 2) return;

	if (1 <= [RaE2list[1] count]) {  
		// Unpaid の先頭へ
		MbFirstAppear = NO;
		// 未払いの先頭を画面中央に表示する
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
	}
	else if (1 <= [RaE2list[0] count]) {
		// PAID の末尾へ
		MbFirstAppear = NO;
		// 未払いの先頭を画面中央に表示する
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[RaE2list[0] count]-1 inSection:0];
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
	}
	else if (0 < McontentOffsetDidSelect.y) {
		// app.Me3dateUse=nil のときや、メモリ不足発生時に元の位置に戻すための処理。
		// McontentOffsetDidSelect は、didSelectRowAtIndexPath にて記録している。
		self.tableView.contentOffset = McontentOffsetDidSelect;
	}
	
	//[self viewDesign]; ここだとセル外部が表示されない不具合発生 ⇒ viewDidAppearへ移した。
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
    if (IS_PAD) {
        // viewWillAppear:に入れると再描画時に通ってBarが乱れるため、ここにした。 loadViewに入れると配下から戻ったときダメ
        // SplitViewタテのとき [Menu] button を表示する
        //AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.barMenu) {
            UIBarButtonItem* buFlexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem* buTitle = [[UIBarButtonItem alloc] initWithTitle: self.title  style:UIBarButtonItemStylePlain target:nil action:nil];
            NSMutableArray* items = [[NSMutableArray alloc] initWithObjects: appDelegate.barMenu, buFlexible, buTitle, buFlexible, nil];
            UIToolbar* toolBar = [[UIToolbar alloc] init];
            toolBar.barStyle = UIBarStyleDefault;
            [toolBar setItems:items animated:NO];
            [toolBar sizeToFit];
            self.navigationItem.titleView = toolBar;
        }
    }

	[self viewDesign:animated];	// viewWillAppearだと一部が描画されない不具合発生のためここにした。
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる

	// Comback (-1)にして未選択状態にする
	//	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	// (0)TopMenu >> (1)E1card/E7payment >> (2)This clear
	//	[appDelegate.RaComebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
}


#pragma mark  View - Rotate

// 回転の許可　ここでは許可、禁止の判定だけする
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (IS_PAD) {
        return YES;
    }else{
        // 回転禁止でも、正面は常に許可しておくこと。
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

/*
// 回転を始める前にこの処理が呼ばれる。
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
								duration:(NSTimeInterval)duration {
 // この時点では self.View は、まだ回転前の状態
}

// 回転の最初の半分が始まる前にこの処理が呼ばれる。
- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
													duration:(NSTimeInterval)duration {
	// この時点では self.View は、まだ回転前の状態
}
 */

// 回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration {
	// この時点で self.View は、回転後の状態になっている
	//[self.tableView reloadData]; ここではダメ　＜＜cellLable位置調整されない＞＞
	[self viewDesign:NO];
}

// 回転した後に呼び出される
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadData];  // cellLable位置調整するため
}

/*
// カムバック処理（復帰再現）：親から呼ばれる
- (void)viewComeback:(NSArray *)selectionArray
{
	// (0)TopMenu >> (1)E1card >> (2)This
	NSInteger lRow = [[selectionArray objectAtIndex:2] integerValue];
	if (lRow < 0) return; // この画面に留まる
	NSInteger lSec = lRow / GD_SECTION_TIMES;
	lRow -= (lSec * GD_SECTION_TIMES);

	if ([RaE2list count] <= lSec) return; // section OVER
	if ([[RaE2list objectAtIndex:lSec] count] <= lRow) return; // row OVER（Addや削除されたとか）

	// 選択行を画面中央付近に表示する
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lRow inSection:lSec];
	[self.tableView scrollToRowAtIndexPath:indexPath 
						  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO

	E2temp *e2t = [[RaE2list objectAtIndex:lSec] objectAtIndex:lRow];
	if ([e2t.e2invoices count] <= 0) return;

	// (0)TopMenu >> (1)E1card >> (2)This >> (3)E6partTVC へ
	E6partTVC *tvc = [[E6partTVC alloc] init];
	if (Re1select) {
		tvc.title =  Re1select.zName;
		// 編集移動により支払日の変更が可能
		tvc.Pe2select = [[e2t.e2invoices allObjects] objectAtIndex:0];  //[[Me2list objectAtIndex:lSec] objectAtIndex:lRow];
	} else {
		NSInteger iYear = e2t.iYearMMDD / 10000;
		NSInteger iDD = e2t.iYearMMDD - (iYear * 10000);
		NSInteger iMM = iDD / 100;
		iDD -= (iMM * 100);
		if (e2t.bPaid) {
			tvc.title = [NSString stringWithFormat:@"(%d-%d%@) %@",
						 (int)iMM, (int)iDD, NSLocalizedString(@"Pre",nil), Re8select.zName];
		} else {
			tvc.title = [NSString stringWithFormat:@"(%d-%d%@) %@", 
						 (int)iMM, (int)iDD, NSLocalizedString(@"Due",nil), Re8select.zName];
		}
		// 支払日一覧と同様のカード別一覧（支払日の変更はできない）
		tvc.Pe2invoices = e2t.e2invoices;
	}
	tvc.PiFirstSection = lSec;
	[self.navigationController pushViewController:tvc animated:NO];
	// viewComeback を呼び出す
	[tvc viewWillAppear:NO]; // Fech データセットさせるため
	[tvc viewComeback:selectionArray];
	[tvc release];
}
*/

//#pragma mark  View - Unload - dealloc
//
//- (void)unloadRelease {	// dealloc, viewDidUnload から呼び出される
//	//【Tips】loadViewでautorelease＆addSubviewしたオブジェクトは全てself.viewと同時に解放されるので、ここでは解放前の停止処理だけする。
//	NSLog(@"--- unloadRelease --- E2invoiceTVC");
//	//【Tips】デリゲートなどで参照される可能性のあるデータなどは破棄してはいけない。
//	// 他オブジェクトからの参照無く、viewWillAppearにて生成されるので破棄可能
//	RaE2list = nil;
//}
//
//- (void)dealloc    // 生成とは逆順に解放するのが好ましい
//{
//	[self unloadRelease];
//	//--------------------------------@property (retain)
//}
//
//// メモリ不足時に呼び出されるので不要メモリを解放する。 ただし、カレント画面は呼ばない。
//- (void)viewDidUnload 
//{
//	//NSLog(@"--- viewDidUnload ---"); 
//	// メモリ不足時、裏側にある場合に呼び出される。addSubviewされたOBJは、self.viewと同時に解放される
//	[self unloadRelease];
//	[super viewDidUnload];
//	// この後に loadView ⇒ viewDidLoad ⇒ viewWillAppear がコールされる
//}


#pragma mark - TableView lifecicle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return RaE2list.count;  // Me2listは、(0)e2paids (1)e2unpaids の二次元配列
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [RaE2list[section] count];
}

// TableView セクション名を応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			return [NSString stringWithFormat:NSLocalizedString(@"Paid header",nil), (long)GD_PAIDLIST_MAX];
			break;
		case 1:
			// E2 未払い総額
			if ([RaE2list[1] count] <= 0) {  // Index: 0=Paid 1=Unpaid
				return NSLocalizedString(@"Following unpaid nothing",nil);
			} 
			return NSLocalizedString(@"Unpaid",nil);
			break;
	}
	return @"Err";
}

// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			[self.tableView bringSubviewToFront:MbuPaid];		//iPhone//これが無いと範囲外に出てから戻ると背景裏に隠されてしまう
			[self.tableView bringSubviewToFront:MbuUnpaid];			//iPad//隠れないがタッチ無反応になる
			return @"\n";
			break;
		case 1: {
			NSString* str; 
			if (_Re1select) {
				str = NSLocalizedString(@"E2unpaidFooter",nil);
			} else {
				// "支払日の変更は、\nカード一覧から可能です。"
				str = NSLocalizedString(@"E2unpaidFromE8",nil);
			}
#if defined (FREE_AD)
            if (IS_PAD) {
                return [str stringByAppendingString:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n"];	// 大型AdMobスペースのための下部余白
            }
            return str;
#else
			return str;
#endif
		} break;
	}
	return nil;
}

/*
 // セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 44; // デフォルト：44ピクセル
}*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *zCellIndex = @"CellE2invoice";
	UITableViewCell *cell = nil;
	UILabel *cellLabel = nil;
	
	cell = [tableView dequeueReusableCellWithIdentifier:zCellIndex];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:zCellIndex];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
		cell.showsReorderControl = NO; // Move禁止

        if (IS_PAD) {
            cell.textLabel.font = [UIFont systemFontOfSize:20];
        }else{
            cell.textLabel.font = [UIFont systemFontOfSize:16];
        }
		cell.textLabel.textAlignment = NSTextAlignmentLeft;
		cell.textLabel.textColor = [UIColor blackColor];

		cellLabel = [[UILabel alloc] init];
		cellLabel.textAlignment = NSTextAlignmentRight;
		//cellLabel.textColor = [UIColor blackColor];
		cellLabel.backgroundColor = [UIColor clearColor];
        if (IS_PAD) {
            cellLabel.font = [UIFont systemFontOfSize:20];
        }else{
            cellLabel.font = [UIFont systemFontOfSize:14];
        }
		cellLabel.tag = -1;
		[cell addSubview:cellLabel]; 
	}
	else {
		cellLabel = (UILabel *)[cell viewWithTag:-1];
	}
	// 回転対応のため
    if (IS_PAD) {
        cellLabel.frame = CGRectMake(self.tableView.frame.size.width-215, 12, 125, 22);
    }else{
        cellLabel.frame = CGRectMake(self.tableView.frame.size.width-108, 12, 75, 20);
    }

/*	// 左ボタン --------------------＜＜cellLabelのようにはできない！.tagに個別記録するため＞＞
	UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom]; // autorelease
	cellButton.frame = CGRectMake(0,0, 44,44);
	[cellButton addTarget:self action:@selector(cellLeftButton:) forControlEvents:UIControlEventTouchUpInside];
	cellButton.backgroundColor = [UIColor clearColor]; //背景透明
	cellButton.showsTouchWhenHighlighted = YES;
	cellButton.tag = indexPath.section * GD_SECTION_TIMES + indexPath.row;
	[cell.contentView addSubview:cellButton]; //[bu release]; buttonWithTypeにてautoreleseされるため不要。UIButtonにinitは無い。
	// 左ボタン ------------------------------------------------------------------ */

	//E2invoice *e2obj = [[Me2list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	E2temp *e2obj = RaE2list[indexPath.section][indexPath.row];

	// 支払日
	if (e2obj.bPaid) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", GstringYearMMDD(e2obj.iYearMMDD),
																	NSLocalizedString(@"Pre",nil)];
	} else {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", GstringYearMMDD(e2obj.iYearMMDD),
																	NSLocalizedString(@"Due",nil)];
	}

	// 金額
	//if ([e2obj.sumAmount integerValue] <= 0) {
	//if (e2obj.iSum <= 0) 
	if ([e2obj.decSum compare:[NSDecimalNumber zero]] == NSOrderedDescending)	// e7obj.sumAmount > 0
	{
		cellLabel.textColor = [UIColor blackColor];
	} else {
		cellLabel.textColor = [UIColor blueColor];
	}
	//[0.4] Amount 多通貨対応
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	formatter.numberStyle = NSNumberFormatterDecimalStyle;
	formatter.locale = [NSLocale currentLocale]; 
	cellLabel.text = [formatter stringFromNumber:e2obj.decSum];
	
	if (indexPath.section == 0) {
		cell.imageView.image = [UIImage imageNamed:@"Icon32-PAID.png"];  // PAID 支払済
	}
	else {
		//cell.imageView.image = [UIImage imageNamed:@"Unpaid32.png"]; // 未払い
		// sumNoCheck を Circle 内に表示
		//NSInteger lNoCheck = [e2obj.sumNoCheck integerValue];
		NSInteger lNoCheck = e2obj.iNoCheck;
		if (0 < lNoCheck) {
			UIImageView *imageView1 = [[UIImageView alloc] init];
			UIImageView *imageView2 = [[UIImageView alloc] init];
			imageView1.image = [UIImage imageNamed:@"Icon32-CircleUnpaid.png"];
			imageView2.image = GimageFromString([NSString stringWithFormat:@"%ld", (long)lNoCheck]);

			UIGraphicsBeginImageContextWithOptions(imageView1.image.size, NO, 0.0); //[0.4.18]Retina対応

			CGRect rect = CGRectMake(0, 0, imageView1.image.size.width, imageView1.image.size.height);
			[imageView1.image drawInRect:rect];  
			[imageView2.image drawInRect:rect blendMode:kCGBlendModeMultiply alpha:1.0];  
			UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();  
			UIGraphicsEndImageContext();  
			(cell.imageView).image = resultingImage;
//			AzRETAIN_CHECK(@"E1 lNoCheck:imageView1", imageView1, 1)
//			AzRETAIN_CHECK(@"E1 lNoCheck:imageView2", imageView2, 1)
//			AzRETAIN_CHECK(@"E1 lNoCheck:resultingImage", resultingImage, 2) //=2:releaseするとフリーズ
		}
		//else if ([e2obj.decSum compare:[NSDecimalNumber zero]] == NSOrderedDescending)	// e2obj.decSum > 0
		else if (0.0 < (e2obj.decSum).doubleValue)	// e2obj.decSum > 0
		{
			cell.imageView.image = [UIImage imageNamed:@"Icon32-CircleChkUnpaid.png"];  // PAY
		} else {
			cell.imageView.image = [UIImage imageNamed:@"Icon32-Circle.png"];  // Nothing
		}
	}
	return cell;
}

/*
- (void)cellLeftButton: (UIButton *)button		// PAID or Unpaid ボタン
{
	//AzLOG(@"button.tag=%ld", (long)button.tag);
	if (button.tag < 0) return;
	NSInteger iSec = button.tag / GD_SECTION_TIMES;
	if ([RaE2list count] <= iSec) return;
	NSInteger iRow = button.tag - (iSec * GD_SECTION_TIMES);
	if ([[RaE2list objectAtIndex:iSec] count] <= iRow) return;
	// E2temp : Paid <<<CHANGE>>> Unpaid
	Me2cellButton = [[RaE2list objectAtIndex:iSec] objectAtIndex:iRow]; 
	
	//if (Me2cellButton.e1paid) {
	if (Me2cellButton.bPaid) {
		// E2 PAID -->> PAYに戻す
#if AzDEBUG
		//if (Me2cellButton.e1unpaid OR !Me2cellButton.e7payment.e0paid OR Me2cellButton.e7payment.e0unpaid) {
		//	AzLOG(@"LOGIC ERR: E2.e1paid NG");
		//	return;
		//}
		for (E2invoice *e2 in [Me2cellButton.e2invoices allObjects]) {
			if (e2.e1unpaid OR e2.e7payment.e0unpaid) {
				AzLOG(@"LOGIC ERR: E2.e1paid NG");
				return;
			}
		}
#endif
		// これより後に paid があれば禁止		"最下行から PAY に戻せます"
		//for (E2invoice *e2 in Me2cellButton.e1paid.e2paids) {
		for (E2temp *e2t in [RaE2list objectAtIndex:0]) {
			if (Me2cellButton.iYearMMDD < e2t.iYearMMDD) {
				alertBox(NSLocalizedString(@"E2 to PAY NG",nil),
						 NSLocalizedString(@"E2 to PAY NG msg",nil),
						 NSLocalizedString(@"Roger",nil));
				return; // 禁止
			}
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"E2 to PAY",nil) 
														 message:NSLocalizedString(@"E2 to PAY msg",nil) 
														delegate:self
											   cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
											   otherButtonTitles:@"OK", nil];
		alert.tag = TAG_ALERT_toPAY;
		[alert show];
		[alert release];
	}
	else {  //if (Me2cellButton.e1unpaid) {
#if AzDEBUG
		//if (Me2cellButton.e1paid OR Me2cellButton.e7payment.e0paid OR !Me2cellButton.e7payment.e0unpaid) {
		//	AzLOG(@"LOGIC ERR: E2.e1unpaid NG");
		//	return;
		//}
		for (E2invoice *e2 in [Me2cellButton.e2invoices allObjects]) {
			if (e2.e1paid OR e2.e7payment.e0paid) {
				AzLOG(@"LOGIC ERR: E2.e1unpaid NG");
				return;
			}
		}
#endif
		// "最上行から PAID にできます"
		//for (E2invoice *e2 in Me2cellButton.e1unpaid.e2unpaids) {
		for (E2temp *e2t in [RaE2list objectAtIndex:1]) {
			//if ([e2.nYearMMDD integerValue] < [Me2cellButton.nYearMMDD integerValue]) {
			if (e2t.iYearMMDD < Me2cellButton.iYearMMDD) {
				// これより前に unpaid があるので禁止
				alertBox(NSLocalizedString(@"E2 to PAID NG",nil),
						 NSLocalizedString(@"E2 to PAID NG msg",nil),
						 NSLocalizedString(@"Roger",nil));
				return; // 禁止
			}
		}
		//if (0 < [Me2cellButton.sumNoCheck integerValue]) {
		if (0 < Me2cellButton.iNoCheck) {
			// E2配下に未チェックあり、「未チェック分を翌月払いにしますか？」 >>> alertView:clickedButtonAtIndex:メソッドが呼び出される
			// 初版未対応とする！未チェックあれば禁止
			alertBox(NSLocalizedString(@"NoCheck",nil),
					 NSLocalizedString(@"NoCheck msg",nil),
					 NSLocalizedString(@"Roger",nil));
			return; // 禁止
		}
		// E2 PAY -->> PAID
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"E2 to PAID",nil) 
														 message:NSLocalizedString(@"E2 to PAID msg",nil) 
														delegate:self
											   cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
											   otherButtonTitles:@"OK", nil];
		alert.tag = TAG_ALERT_toPAID;
		[alert show];
		[alert release];
	}
	//else {
	//	AzLOG(@"LOGIC ERR: E2.e1paid = e1unpaid = nil 孤立状態");
	//	return;
	//}
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

	// didSelect時のScrollView位置を記録する（viewWillAppearにて再現するため）
	McontentOffsetDidSelect = tableView.contentOffset;

	//E2invoice *e2obj = [[Me2list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	E2temp *e2t = RaE2list[indexPath.section][indexPath.row];
	if ((e2t.e2invoices).count <= 0) return;
	// E6parts へ
	E6partTVC *tvc = [[E6partTVC alloc] init];
	if (_Re1select) {
#ifdef AzDEBUG
		tvc.title = [NSString stringWithFormat:@"E6 %@", _Re1select.zName];
#else
		tvc.title =  _Re1select.zName;
#endif
		// 編集移動により支払日の変更が可能
		tvc.Pe2select = (e2t.e2invoices).allObjects[0];  //[[Me2list objectAtIndex:lSec] objectAtIndex:lRow];
	} else {
		NSInteger iYear = e2t.iYearMMDD / 10000;
		NSInteger iDD = e2t.iYearMMDD - (iYear * 10000);
		NSInteger iMM = iDD / 100;
		iDD -= (iMM * 100);
		if (e2t.bPaid) {
			tvc.title = [NSString stringWithFormat:@"(%d-%d%@) %@",
						 (int)iMM, (int)iDD, NSLocalizedString(@"Pre",nil), _Re8select.zName];
		} else {
			tvc.title = [NSString stringWithFormat:@"(%d-%d%@) %@", 
						 (int)iMM, (int)iDD, NSLocalizedString(@"Due",nil), _Re8select.zName];
		}
#ifdef AzDEBUG
		tvc.title = [NSString stringWithFormat:@"E6 %@", tvc.title];
#endif
		// 支払日一覧と同様のカード別一覧（支払日の変更はできない）
		tvc.Pe2invoices = e2t.e2invoices; 
	}
	tvc.PiFirstSection = indexPath.section;
	[self.navigationController pushViewController:tvc animated:YES];
}

@end

