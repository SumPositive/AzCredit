//
//  E6partTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "E6partTVC.h"
#import "E3recordDetailTVC.h"


#define ACTIONSEET_TAG_DELETE	199

@interface E6partTVC (PrivateMethods)
- (void)MtableSource;
- (void)e3detailView:(NSIndexPath *)indexPath;
- (void)cellButton: (UIButton *)button;
@end

@implementation E6partTVC
@synthesize Pe2select;
@synthesize Pe7select;
@synthesize	Pe2invoices; // E8bank-->>E1-->>E2
@synthesize PiFirstSection;


#pragma mark - Delegate

#ifdef AzPAD
- (void)refreshE6partTVC:(BOOL)bSame	//=YES:支払先と支払日が変更なし、ならば行だけ再表示
{
	if (bSame && MindexPathEdit) {	// 日付に変更なく、行位置が有効ならば、修正行だけを再表示する
		NSArray* ar = [NSArray arrayWithObject:MindexPathEdit];
		[self.tableView reloadRowsAtIndexPaths:ar withRowAnimation:YES];
	} else {
		[self viewWillAppear:YES];
	}
}
#endif


#pragma mark - Action

// アラートボタンが押されたときに呼び出される
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.navigationController popViewControllerAnimated:YES]; 	// < 前のViewへ戻る
}

- (void)barButtonTop {
	[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
}

- (void)e3detailView:(NSIndexPath *)indexPath 
{
	// ドリルダウン
	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init];
	// 以下は、E3detailTVCの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
	if (indexPath.row < [[RaE6parts objectAtIndex:indexPath.section] count]) 
	{
		E6part *e6obj = [[RaE6parts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		// Edit Item
		e3detail.title = NSLocalizedString(@"Edit Record", nil);
		e3detail.Re3edit = e6obj.e3record;
		e3detail.PiAdd = 0; // (0)Edit mode
		e3detail.PiFirstYearMMDD = 0;
	}
	else {
		// Add E3　「この支払日になるように利用明細を追加」
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		E3record *e3obj = [NSEntityDescription insertNewObjectForEntityForName:@"E3record"
														inManagedObjectContext:appDelegate.managedObjectContext];
		//E6part *e6obj = [[Me6parts objectAtIndex:indexPath.section] objectAtIndex:0];
		//E6が無い場合あり、E2だけでも処理可能にする
		E2invoice *e2obj = [RaE2invoices objectAtIndex:indexPath.section];
		if (e2obj.e1paid) {
			e3obj.e1card = e2obj.e1paid;
		} else if (e2obj.e1unpaid) {
			e3obj.e1card = e2obj.e1unpaid;
		} else {
			[e3detail release];
			AzLOG(@"LOGIC ERR: e2obj-->E1 Nothing");
			return;
		}
		e3obj.e4shop = nil;
		e3obj.e5category = nil;
		// Args
		//e3detail.title = NSLocalizedString(@"Add Record", nil);
		e3detail.title = [NSString stringWithFormat:@"%@%@", 
						  GstringYearMMDD([e2obj.nYearMMDD integerValue]), 
						  NSLocalizedString(@"Due", nil)];
		e3detail.Re3edit = e3obj;
		e3detail.PiAdd = 2; // (2)Card固定Add
		e3detail.PiFirstYearMMDD = [e2obj.nYearMMDD integerValue]; // E2,E7配下から追加されるとき、支払日をこのE2に合わせるため。
	}
	
	MindexPathEdit = indexPath;

#ifdef  AzPAD
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:e3detail];
	Mpopover = [[UIPopoverController alloc] initWithContentViewController:nc];
	Mpopover.delegate = self;	// popoverControllerDidDismissPopover:を呼び出してもらうため
	[nc release];
	MindexPathEdit = indexPath;
	CGRect rc = [self.tableView rectForRowAtIndexPath:indexPath];
	rc.size.width /= 2;
	rc.origin.y += 10;	rc.size.height -= 20;
	[Mpopover presentPopoverFromRect:rc
							  inView:self.tableView  permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
	e3detail.selfPopover = Mpopover;  [Mpopover release]; //(retain)  内から閉じるときに必要になる
	e3detail.delegate = self;		// refreshTable: callback
#else
	//[e3detail setHidesBottomBarWhenPushed:YES]; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:YES];
#endif
	[e3detail release];
}



#pragma mark - View lifecicle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStylePlain]; // セクションなしテーブル
	if (self) {
		// 初期化成功
		MiForTheFirstSection = (-1);  // viewWillAppearにてMe2invoices Reload時にセット
		RaE2invoices = nil;
		RaE6parts = nil;
		Me2e1card = nil;
		Me7e0root = nil;
		MbFirstOne = YES;
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
	
#ifdef AzPAD
	// Tool Bar Button なし
#else
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	UIBarButtonItem *buTop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-Top.png"]
															   style:UIBarButtonItemStylePlain  //Bordered
															  target:self action:@selector(barButtonTop)];
	NSArray *buArray = [NSArray arrayWithObjects: buTop, buFlex, nil];
	[self setToolbarItems:buArray animated:YES];
	[buTop release];
	[buFlex release];
#endif
	
#ifdef FREE_AD
	RoAdMobView = [[GADBannerView alloc]
                   initWithFrame:CGRectMake(0, 0,			// TableCell用
                                            GAD_SIZE_320x50.width,
                                            GAD_SIZE_320x50.height)];
	//RoAdMobView.delegate = self;
	RoAdMobView.delegate = nil; //Delegateなし
	
	RoAdMobView.adUnitID = AdMobID_iPhone;
	
	// Let the runtime know which UIViewController to restore after taking
	// the user wherever the ad goes and add it to the view hierarchy.
	RoAdMobView.rootViewController = self;
	//	[self.view addSubview:RoAdMobView];
	
	// Initiate a generic request to load it with an ad.
	GADRequest *request = [GADRequest request];
	//[request setTesting:YES];
	[RoAdMobView loadRequest:request];	
#endif
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
#ifdef AzPAD
	//Popover [Menu] button
	//AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (app.barMenu) {
		UIBarButtonItem* buFlexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem* buFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		UIBarButtonItem* buTitle = [[UIBarButtonItem alloc] initWithTitle: self.title  style:UIBarButtonItemStylePlain target:nil action:nil];
		NSMutableArray* items = [[NSMutableArray alloc] initWithObjects: buFixed, app.barMenu, buFlexible, buTitle, buFlexible, nil];
		[buTitle release], buTitle = nil;
		[buFixed release], buFixed = nil;
		[buFlexible release], buFlexible = nil;
		UIToolbar* toolBar = [[UIToolbar alloc] init];
		toolBar.barStyle = UIBarStyleDefault;
		[toolBar setItems:items animated:NO];
		[toolBar sizeToFit];
		self.navigationItem.titleView = toolBar;
		[toolBar release];
	}
#endif
	//[0.4]以降、ヨコでもツールバーを表示するようにした。
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];

	// テーブルソース セット
	if (RaE6parts==nil || app.Me3dateUse) {  // 最初 または E3recordDetailTVCにてSAVEされたとき
		[self MtableSource];
		[self.tableView selectRowAtIndexPath:MindexPathEdit animated:NO scrollPosition:UITableViewScrollPositionMiddle];	//  Middle 選択状態
		[self performSelector:@selector(deselectRow:) withObject:MindexPathEdit afterDelay:0.5]; // 0.5s後に選択状態を解除する
	}
	else if (0 < McontentOffsetDidSelect.y) {  //.Y座標
		// app.Me3dateUse=nil のときや、メモリ不足発生時に元の位置に戻すための処理。
		// McontentOffsetDidSelect は、didSelectRowAtIndexPath にて記録している。
		self.tableView.contentOffset = McontentOffsetDidSelect;
	}
}

- (void)deselectRow:(NSIndexPath*)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態を解除する
}

- (void)MtableSource
{
	//---------------------------------Me2invoices 生成
	if (RaE2invoices) {
		[RaE2invoices release], RaE2invoices = nil;
	}
	RaE2invoices = [[NSMutableArray alloc] init];
	
	//---------------------------------Me6parts 生成
	if (RaE6parts) {
		[RaE6parts release], RaE6parts = nil;
	}
	RaE6parts = [[NSMutableArray alloc] init];

	//[0.3]E7E2クリーンアップ
	//禁止 [EntityRelation e7e2clean] ここではまだ削除してはダメ！上層に戻ってから。
	// Pe2invoices には、上層でセットされたE2が削除後も含まれているため。

	if (Pe7select) {
		assert(Pe2select==nil); // 他方は必ずnil
		// E3修正にてカード変更などによりE7,E2,E6が削除されて戻ってきたときに対応するための処理
		// この処理が無ければ、ここからドリルダウンしたE3修正にて、「カード変更」「利用日変更」などするとFreezeする
		if (Me7e0root == nil) {
			if (Pe7select.e0paid)	Me7e0root = Pe7select.e0paid;
			else					Me7e0root = Pe7select.e0unpaid;
			if (Me7e0root == nil) {
				AzLOG(@"LOGIC ERR: Me7e0root == nil");
				return;
			}
		}
		BOOL bAlive = NO;
		for (E7payment *e7 in Me7e0root.e7unpaids) {
			if (Pe7select == e7) {
				bAlive = YES; // Pe7selectは、e7unpaids に存在する
				break;
			}
		}
		if ([RaE2invoices count] <= 0) {
			for (E7payment *e7 in Me7e0root.e7paids) {
				if (Pe7select == e7) {
					bAlive = YES; // Pe7selectは、e7paids に存在する
					break;
				}
			}
		}
		// ここでようやく Pe7select が有効ならば、配下のE2を抽出している
		if (bAlive) { // Pe7select が存在（有効）であるとき
			// E7配下のE2
			[RaE2invoices setArray:[Pe7select.e2invoices allObjects]];
			// E2.e1card.nRow 昇順ソート
			NSSortDescriptor *sort1;
			if (Pe7select.e0paid) {
				sort1 = [[NSSortDescriptor alloc] initWithKey:@"e1paid.nRow" ascending:YES];
			} else {
				sort1 = [[NSSortDescriptor alloc] initWithKey:@"e1unpaid.nRow" ascending:YES];
			}
			NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
			[RaE2invoices sortUsingDescriptors:sortArray];
			[sortArray release];
			[sort1 release];
		}
	}
	else if (Pe2select) {
		assert(Pe7select==nil); // 他方は必ずnil
		// E3修正にてカード変更などによりE2,E6が削除されて戻ってきたときに対応するための処理
		// この処理が無ければ、ここからドリルダウンしたE3修正にて、「カード変更」「利用日変更」などするとFreezeする
		if (Me2e1card == nil) {
			if (Pe2select.e1paid)	Me2e1card = Pe2select.e1paid;
			else					Me2e1card = Pe2select.e1unpaid;
			if (Me2e1card == nil) {
				AzLOG(@"LOGIC ERR: Me2e1card == nil");
				return;
			}
		}
		
		BOOL bAlive = NO;
		for (E2invoice *e2 in Me2e1card.e2unpaids) {
			if (Pe2select == e2) {
				bAlive = YES; // Pe2selectは、e2unpaids に存在する
				break;
			}
		}
		if (bAlive==NO && [RaE2invoices count] <= 0) {
			for (E2invoice *e2 in Me2e1card.e2paids) {
				if (Pe2select == e2) {
					bAlive = YES; // Pe2selectは、e2paids に存在する
					break;
				}
			}
		}
		// ここでようやく Pe2select が有効ならば、E2を抽出している
		if (bAlive) { // Pe2select が存在（有効）であるとき
			if (Pe2select.e1paid) {
				[RaE2invoices addObject:Pe2select];
			}
			else if (Pe2select.e1unpaid) {
				{	// E6一覧の編集モードで移動により支払日を変更できるようにするため。
					//[1.0.0]E3detailにて支払日を自由に変更できるようにしたため、「登録支払日」と異なる日付になる場合あるが、ここでは常に「登録支払日」だけを追加する
					//　カード登録支払日
					E1card* e1 = Pe2select.e1unpaid;
					NSInteger iPayDay = [e1.nPayDay integerValue];	// 29=末日
					NSInteger iYearMMDD = [Pe2select.nYearMMDD integerValue];
					if (iPayDay != GiDay(iYearMMDD)) { // 「登録支払日」と違う
						// 日を「登録支払日」にする
						iYearMMDD = GiYearMMDD_ModifyDay( iYearMMDD, iPayDay );		// iDay>=29:月末
					}
					// 選択日の前月が無ければ追加する
					[MocFunctions e2invoice:Me2e1card inYearMMDD:GiAddYearMMDD(iYearMMDD, 0, -1, 0)]; // -1 前月へ E2無ければ追加する
					// 選択日の翌月が無ければ追加する
					[MocFunctions e2invoice:Me2e1card inYearMMDD:GiAddYearMMDD(iYearMMDD, 0, +1, 0)]; // +1 翌月へ E2無ければ追加する
					//--------------SAVE
					[MocFunctions commit]; 
					// 最終的に未使用のE2は、viewWillDisappear:にて削除している。
				}
				// E1配下のE2
				[RaE2invoices setArray:[Pe2select.e1unpaid.e2unpaids allObjects]];
				// E2.nYearMMDD 昇順ソート
				NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"nYearMMDD" ascending:YES];
				NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
				[sort1 release];
				[RaE2invoices sortUsingDescriptors:sortArray];
				[sortArray release];
			}
			if (Pe2select.e1unpaid) {
				// Unpaidならば [編集]モードＯＮ
				self.navigationItem.rightBarButtonItem = self.editButtonItem;
				self.tableView.allowsSelectionDuringEditing = YES; // 編集モードに入ってる間にユーザがセルを選択できる
			}
		}
	}
	else if (Pe2invoices) {  // E8bank追加により新設
		// 注意！E6削除の結果、その親E2も削除されたとき、Pe2invoicesには「その親E2」(根無し）が残っている！
		// [0.3]この解決のため、e3delete処理では、E2を削除しないようにした。
		// [0.4.15]さらに e3makeE6 にて、E6再生成時にE2を削除しないようにした。
		//NSLog(@"***Pe2invoices=%@", Pe2invoices);
		[RaE2invoices setArray:[Pe2invoices allObjects]];
		if (2 <= [RaE2invoices count]) {
			E2invoice *e2 = [RaE2invoices objectAtIndex:0];
			// E2.e1card.nRow 昇順ソート
			NSSortDescriptor *sort1;
			if (e2.e1paid) {
				sort1 = [[NSSortDescriptor alloc] initWithKey:@"e1paid.nRow" ascending:YES];
			} else {
				sort1 = [[NSSortDescriptor alloc] initWithKey:@"e1unpaid.nRow" ascending:YES];
			}
			NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
			[sort1 release];
			[RaE2invoices sortUsingDescriptors:sortArray];
			[sortArray release];
		}
	}
	else {
		AzLOG(@"LOGIC ERROR: Pe2select,Pe7select,Pe2invoices == nil");
		return; // Fail
	}

	
	if (0 < [RaE2invoices count]) {
		// E6.e3record.dateUse 昇順ソート
		NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"e3record.dateUse" ascending:YES];
		NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
		[sort1 release];
		// muE2list配下の全E6抽出＆ソート
		//NSLog(@"***RaE2invoices=%@", RaE2invoices);
		for (E2invoice *e2 in RaE2invoices) {
			// 選択月の前後月も表示するため0行の場合がある。
			NSMutableArray *e6arry = [[NSMutableArray alloc] initWithArray:[e2.e6parts allObjects]];
			[e6arry sortUsingDescriptors:sortArray];
			[RaE6parts addObject:e6arry]; [e6arry release];
		}
		[sortArray release];
	}
/*	else {    ＜＜ここでpopすると早すぎて戻るボタンに不具合発生するため、viewDidAppear:で処理するように改めた。
		// 最終的にE2が無い場合、前画面に戻る。　　E3にて利用日を変更した場合などに発生する可能性あり
		[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
		return;
	}*/

	
	// テーブルビューを更新します。
    [self.tableView reloadData];
	
	// 指定位置までテーブルビューの行をスクロールさせる初期処理　＜＜レコードセット後でなければならないので、この位置になった＞＞
	if (MbFirstOne && Pe2select && 1 < [RaE2invoices count]) {
		MbFirstOne = NO; // 最初に1度だけ通すため  (initWithStyle:にてYESに初期化している）
		NSInteger iSec = 0;
		for (E2invoice *e2 in RaE2invoices) {
			if (e2 == Pe2select) break;
			iSec++;
		}
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:iSec];
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
	}
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
	
	// Comback (-1)にして未選択状態にする
	//	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	// PiMode: (0)E1<E2<E6:同カードの支払日違い  (1)E7<E2<E6:同支払日のカード違い
	if (Pe2select) {
		// (0)TopMenu >> (1)E1card >> (2)E2invoice >> (3)This clear
		//		[appDelegate.RaComebackIndex replaceObjectAtIndex:3 withObject:[NSNumber numberWithLong:-1]];
	} else {
		// (0)TopMenu >> (1)E7payment >> (2)This clear
		//		[appDelegate.RaComebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
	}
	
	if (0 <= MiForTheFirstSection && 0 <= PiFirstSection && PiFirstSection < [RaE6parts count]) {
		// 選択行を画面中央付近に表示する
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:PiFirstSection];
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
		MiForTheFirstSection = (-2);  // 最初一度だけ通り、二度と通らないようにするため
	}
	
	//NSLog(@"***viewDidAppear:RaE2invoices=%@\n", RaE2invoices);
	BOOL bPreview = YES;
	for (E2invoice *e2 in RaE2invoices) {
		if (0 < [e2.e6parts count]) {
			bPreview = NO; // E6あり
			break;
		}
	}
	if (bPreview) {
		// E2配下のE6なし、前画面に戻る。
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Payment changed",nil)
														message:NSLocalizedString(@"Payment changed msg",nil)
													   delegate:self 
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"Roger",nil), nil];
		[alert show];
		[alert release];
		//[self.navigationController popViewControllerAnimated:YES]; 	alertデリゲートにて、前のViewへ戻る
	}
}

// ビューが非表示にされる前や解放される前ににこの処理が呼ばれる。
// 次(前)画面が表示される前に処理される。
- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
	
	
	/*[0.4.18]E3detailから Cancel で戻ったときに再読み込みしないようにしたため、ここでE2を削除すると落ちる場合あり。残しておくことにする。
	 [0.4.18]レス向上のためTopMenu:viewDidAppearにて[EntityRelation e7e2clean]している。
	 // E2(Unpaid)配下のE6が無ければ削除する。　　viewWillAppear:にて追加された前月と翌月のE2を削除するのが目的。
	 NSArray *aE2 = [NSArray arrayWithArray:[Me2e1card.e2unpaids allObjects]];
	 for (E2invoice *e2 in aE2) {
	 if ([e2.e6parts count] <= 0) {
	 [EntityRelation e2delete:e2]; // E2,E7削除
	 }
	 }
	 [EntityRelation commit]; //--------------SAVE----------MOVE結果もこれにて保存される
	 */
}


#pragma mark  View - Rotate

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

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	[self.tableView reloadData];
}

// 回転した後に呼び出される
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadData];  // cellLable位置調整する
	
#ifdef AzPAD
	if ([Mpopover isPopoverVisible]) {
		// Popoverの位置を調整する　＜＜UIPopoverController の矢印が画面回転時にターゲットから外れてはならない＞＞
		if (MindexPathEdit) { 
			[self.tableView scrollToRowAtIndexPath:MindexPathEdit 
								  atScrollPosition:UITableViewScrollPositionMiddle animated:NO]; // YESだと次の座標取得までにアニメーションが終了せずに反映されない
			CGRect rc = [self.tableView rectForRowAtIndexPath:MindexPathEdit];
			//rc.size.width /= 2;
			rc.origin.y += 10;	rc.size.height -= 20;
			[Mpopover presentPopoverFromRect:rc  inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionLeft  animated:YES]; //表示開始
		} 
		else {
			// 回転後のアンカー位置が再現不可なので閉じる
			[Mpopover dismissPopoverAnimated:YES];
		}
	}
#endif
}


/*
// カムバック処理（復帰再現）：親から呼ばれる
- (void)viewComeback:(NSArray *)selectionArray
{
	//----------------------------------------L3
	NSInteger lRow = [[selectionArray objectAtIndex:3] integerValue];
	if (lRow < 0) return; // この画面に留まる
	NSInteger lSec = lRow / GD_SECTION_TIMES;
	lRow -= (lSec * GD_SECTION_TIMES);

	if ([RaE6parts count] <= lSec) return; // section OVER
	if ([[RaE6parts objectAtIndex:lSec] count] <= lRow) return; // row OVER（Addや削除されたとか）
	
	// 選択行を画面中央付近に表示する
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lRow inSection:lSec];
	[self.tableView scrollToRowAtIndexPath:indexPath 
						  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
	
	E6part *e6obj = [[RaE6parts objectAtIndex:lSec] objectAtIndex:lRow];
	// ドリルダウン
	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init];
	e3detail.title = self.title;
	// Edit Item
	e3detail.Re3edit = e6obj.e3record;
	e3detail.PiAdd = 0; // (0)Edit mode
	//e3detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:NO];
	// 末尾につき viewComeback なし
	[e3detail release];
}
*/

#pragma mark  View - Unload - dealloc

- (void)unloadRelease	// dealloc, viewDidUnload から呼び出される
{
	NSLog(@"--- unloadRelease --- E6partTVC");
#ifdef FREE_AD
	if (RoAdMobView) {
		RoAdMobView.delegate = nil;  //[0.4.20]受信STOP  ＜＜これが無いと破棄後に呼び出されて落ちる
		[RoAdMobView release],	RoAdMobView = nil;
	}
#endif
	[RaE2invoices release], RaE2invoices = nil;
	[RaE6parts release],	RaE6parts = nil;
}

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[self unloadRelease];
	//--------------------------------@property (retain)
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


#pragma mark - TableView lifecicle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#ifdef FREE_AD
	return [RaE6parts count] + 1; // AdMob
#else
	return [RaE6parts count];  // Me6partsは、[E2invoices]×[E3records] の二次元配列
#endif
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
#ifdef FREE_AD
	if ([RaE6parts count] <= section) {
		return 1; // AdMob
	}
#endif

	E2invoice *e2obj = [RaE2invoices objectAtIndex:section];
	if (e2obj.e1paid) {
		return [[RaE6parts objectAtIndex:section] count]; // PAIDにつきAdd行なし
	} else {
		return [[RaE6parts objectAtIndex:section] count] + 1; // +1:Add行
	}
}

// TableView セクション名を応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
#ifdef FREE_AD
	if ([RaE6parts count] <= section) {
		return @"End"; // AdMob
	}
#endif

	NSString *zSum = @"-----";
	E2invoice *e2obj = [RaE2invoices objectAtIndex:section];
	NSLog(@"e2obj=%@", e2obj);
	if (e2obj && e2obj.e6parts && 0<[e2obj.e6parts count]) {    <<<<<<<<<<<<<<<<<<　Ｅ６partTVC：エルエスト（空の月あり）にて回転時に落ちる
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle]; // 通貨スタイル
		[formatter setLocale:[NSLocale currentLocale]];
		zSum = [formatter stringFromNumber:e2obj.sumAmount];
		[formatter release];
	}
	
	if (Pe2select) {	// (0)E1<E2<E6:同カードの支払日違い　＜＜表示：支払日＋支払未済＋金額＞＞
		// 支払日
		NSString *zPreDue;
		if (e2obj.e1paid) zPreDue = NSLocalizedString(@"Pre",nil);
		else			  zPreDue = NSLocalizedString(@"Due",nil);
		NSString *zDate = GstringYearMMDD([e2obj.nYearMMDD integerValue]);
		return [NSString stringWithFormat:@"%@ %@  %@", zDate, zPreDue, zSum];
	}
	else { //   (1)E7<E2<E6:同支払日のカード違い　＜＜表示：カード名＋支払未済＋金額＞＞
		if (e2obj.e1paid) {
			return [NSString stringWithFormat:@"%@  %@", e2obj.e1paid.zName, zSum];
		} else {
			return [NSString stringWithFormat:@"%@  %@", e2obj.e1unpaid.zName, zSum];
		}

	}
}


 // セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#ifdef FREE_AD
	if ([RaE6parts count] <= indexPath.section) {
		return GAD_SIZE_320x50.height; // AdMob
	}
#endif

	if ([[RaE6parts objectAtIndex:indexPath.section] count] <= indexPath.row) {
		return 33; // Add Record
	}
	return 44; // デフォルト：44ピクセル
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *zCellE6part = @"CellE6part";
    static NSString *zCellAdd = @"CellAdd";
	UITableViewCell *cell = nil;
	UILabel *cellLabel = nil;
	
#ifdef FREE_AD
    static NSString *zCellAdMob = @"CellAdMob";
	if ([RaE6parts count] <= indexPath.section) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:zCellAdMob];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:zCellAdMob] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.showsReorderControl = NO; // Move禁止
			cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
			if (RoAdMobView) { // Request an AdMob ad for this table view cell
				[cell.contentView addSubview:RoAdMobView];
			}
		}
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
		return cell; // AdMob
	}
#endif

	if (indexPath.row < [[RaE6parts objectAtIndex:indexPath.section] count]) 
	{
		cell = [tableView dequeueReusableCellWithIdentifier:zCellE6part];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
											reuseIdentifier:zCellE6part] autorelease];
			// 行毎に変化の無い定義は、ここで最初に1度だけする
#ifdef AzPAD
			cell.textLabel.font = [UIFont systemFontOfSize:18];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
			cell.accessoryType = UITableViewCellAccessoryNone;  // Popoverになるから
#else
			cell.textLabel.font = [UIFont systemFontOfSize:14];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // ＞
#endif
			//cell.textLabel.textAlignment = UITextAlignmentLeft;
			//cell.textLabel.textColor = [UIColor blackColor];
			cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
			cell.detailTextLabel.textColor = [UIColor brownColor];
			cell.showsReorderControl = YES; // MoveOK

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
		//cellLabel.frame = CGRectMake(self.tableView.frame.size.width-125, 2, 80, 20);
		cellLabel.frame = CGRectMake(self.tableView.frame.size.width-108, 2, 75, 20);
#endif

		// 左ボタン --------------------＜＜cellLabelのようにはできない！.tagに個別記録するため＞＞
		UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom]; // autorelease
		cellButton.frame = CGRectMake(0,0, 44,44);
		[cellButton addTarget:self action:@selector(cellButton:) forControlEvents:UIControlEventTouchUpInside];
		cellButton.backgroundColor = [UIColor clearColor]; //背景透明
		cellButton.showsTouchWhenHighlighted = YES;
		cellButton.tag = indexPath.section * GD_SECTION_TIMES + indexPath.row;
		[cell.contentView addSubview:cellButton]; //[bu release]; buttonWithTypeにてautoreleseされるため不要。UIButtonにinitは無い。
		// 左ボタン ------------------------------------------------------------------
		
		E6part *e6obj = [[RaE6parts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		E3record *e3obj = e6obj.e3record;
		
		if (e6obj.e2invoice.e7payment.e0paid) {
			cell.imageView.image = [UIImage imageNamed:@"Icon32-PAID.png"]; // PAID 変更禁止
			cellButton.enabled = NO;
		}
		else if ([e6obj.nNoCheck intValue] == 1) {
			cell.imageView.image = [UIImage imageNamed:@"Icon32-Circle.png"]; // No check
			cellButton.enabled = YES;
		} 
		else if ([e6obj.nNoCheck intValue] == 0) {
			cell.imageView.image = [UIImage imageNamed:@"Icon32-CircleCheck.png"]; // Checked
			cellButton.enabled = YES;
		} 
		else {
			cell.imageView.image = nil; // ERROR
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
		
		// Cell 2行目    ＜＜E6ではカード名不要：セクションタイトルに表示されるため＞＞
		NSString *zShop = @"";
		NSString *zCategory = @"";
		NSString *zRepeat = @"";
		if (e3obj.e4shop != nil) zShop = e3obj.e4shop.zName;
		if (e3obj.e5category != nil) zCategory = e3obj.e5category.zName;
		if (0 < [e3obj.nRepeat integerValue]) zRepeat = @"〃 ";
		cell.detailTextLabel.text = [NSString stringWithFormat:@"  %@%@ %@", zRepeat, zShop, zCategory];
		
		// 金額
		if ([e6obj.nAmount doubleValue] < 0) {
			cellLabel.textColor = [UIColor blueColor];
		} else {
			cellLabel.textColor = [UIColor blackColor];
		}
		// Amount
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[formatter setLocale:[NSLocale currentLocale]]; 
		cellLabel.text = [formatter stringFromNumber:e6obj.nAmount];
		[formatter release];
	}
	else {
		// [Add行]セル　＜＜section==0 PAID には不要＞＞
		cell = [tableView dequeueReusableCellWithIdentifier:zCellAdd];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault      // Default型
										   reuseIdentifier:zCellAdd] autorelease];
		}
		cell.textLabel.text = NSLocalizedString(@"PayDay Add Record",nil);
#ifdef AzPAD
		cell.textLabel.font = [UIFont systemFontOfSize:16];
		cell.accessoryType = UITableViewCellAccessoryNone;
#else
		cell.textLabel.font = [UIFont systemFontOfSize:12];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
#endif
		//cell.accessoryType = UITableViewCellEditingStyleInsert; // (+)
		cell.textLabel.textAlignment = UITextAlignmentCenter; // 中央寄せ
		cell.textLabel.textColor = [UIColor grayColor];
		cell.imageView.image = nil;
		cell.showsReorderControl = NO; // Move禁止
	}
	return cell;
}

/*************************
// AdMob
- (NSString *)publisherIdForAd:(AdMobView *)adView {
	return @"a14d4c11a95320e"; // クレメモ　パブリッシャー ID
}
// AdMob
- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView {
	return self;
}
*/

- (void)cellButton: (UIButton *)button 
{
	if (button.tag < 0) return;
	
	NSInteger iSec = button.tag / GD_SECTION_TIMES;
	NSInteger iRow = button.tag - (iSec * GD_SECTION_TIMES);
	
	E6part *e6obj = [[RaE6parts objectAtIndex:iSec] objectAtIndex:iRow];
	// E6 Check
	if (0 < [e6obj.nNoCheck intValue]) {
		[MocFunctions e6check:YES inE6obj:e6obj inAlert:YES];
	} else {
		[MocFunctions e6check:NO inE6obj:e6obj inAlert:YES];
	}
	// SAVE & Commit!
	[MocFunctions commit];
	
	//[self.tableView reloadData];
	//[0.4.18] レス向上のため、このセルだけ再描画
	NSArray *aIndex = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:iRow inSection:iSec]];
	[self.tableView reloadRowsAtIndexPaths:aIndex withRowAnimation:NO];
}

// TableView 行選択時の動作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
#ifdef FREE_AD
	if ([RaE6parts count] <= indexPath.section) {
		return; // AdMob
	}
#endif
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
	// didSelect時のScrollView位置を記録する（viewWillAppearにて再現するため）
	McontentOffsetDidSelect = [tableView contentOffset];
	
	// E3詳細画面へ
	[self e3detailView:indexPath]; // この中でAddにも対応
}


#pragma mark  TableView - Editting

// 編集モードに出入りするときとスワイプして削除モードに出入りするときに呼ばれる
- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
	if (editing) {
		// 編集モードに入るとき
	}
	else {
		// 編集モードを出るとき
		[self.tableView reloadData]; // セクション間移動があったとき、セクションタイトルの再表示が必要
	}
	[super setEditing:editing animated:YES];
}

// TableView Editボタンスタイル
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (Pe2select) {
		if (indexPath.row < [[RaE6parts objectAtIndex:indexPath.section] count]) {
			return UITableViewCellEditingStyleNone;  //Delete;
		}
		return UITableViewCellEditingStyleInsert;
	}
	else return UITableViewCellEditingStyleNone; // E7一覧配下のとき編集なし
}

/*E6削除なし
// TableView Editモード処理
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
											forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		// 削除対象
		Me6actionDelete = [[Me6parts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		// 削除コマンド警告
		UIActionSheet *action = [[UIActionSheet alloc] 
								 initWithTitle:NSLocalizedString(@"CAUTION", nil)
								 delegate:self 
								 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
								 destructiveButtonTitle:NSLocalizedString(@"DELETE Record", nil)
								 otherButtonTitles:nil];
		action.tag = ACTIONSEET_TAG_DELETE;
		if (self.interfaceOrientation == UIInterfaceOrientationPortrait 
			OR self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			// タテ：ToolBar表示
			[action showFromToolbar:self.navigationController.toolbar]; // ToolBarがある場合
		} else {
			// ヨコ：ToolBar非表示（TabBarも無い）　＜＜ToolBar無しでshowFromToolbarするとFreeze＞＞
			[action showInView:self.view]; //windowから出すと回転対応しない
		}
		[action release];
	}
}
*/

/*
 // UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != actionSheet.destructiveButtonIndex) return;
	
	if (Me6actionDelete && actionSheet.tag == ACTIONSEET_TAG_DELETE) { // Me6actionDelete 削除
		// このE6を含むE3を削除する
		E3record *e3del = Me6actionDelete.e3record;
		// E1,E2,E3,E6,E7 の関係を保ちながら E3削除 する
		[EntityRelation e3delete:e3del];
		[EntityRelation commit];
		//
		[self.tableView reloadData];
	}
}
*/

// Editモード時の行Edit可否　　 YESを返した行は、左にスペースが入って右寄りになる
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
#ifdef FREE_AD
	if ([RaE6parts count] <= indexPath.section) { //セクション
		return NO; // AdMob
	}
#endif
	//行
	if ( indexPath.row < [[RaE6parts objectAtIndex:indexPath.section] count]) return YES; //移動対象
	return NO;  // 最終行のAdd行以降は右寄せさせない
}

#pragma mark  TableView - Moveing

// Editモード時の行移動の可否　　＜＜最終行のAdd専用行を移動禁止にしている＞＞
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
#ifdef FREE_AD
	if ([RaE6parts count] <= indexPath.section) { //セクション
		return NO; // AdMob
	}
#endif
	//行
	if ( indexPath.row < [[RaE6parts objectAtIndex:indexPath.section] count]) return YES; //移動可能
	return NO;  // Add行以降禁止
}


// Editモード時の行移動「先」を応答　　＜＜Add行なし＞＞
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)oldPath 
																		 toProposedIndexPath:(NSIndexPath *)newPath 
{
#ifdef FREE_AD
	if ([RaE6parts count] <= newPath.section) {
		return oldPath; // AdMob: 移動なし
	}
#endif

	if (oldPath.section == newPath.section && oldPath.row == newPath.row) {
		return newPath; // 元の位置
	}
	else if (oldPath.section < newPath.section  
			OR (oldPath.section == newPath.section && oldPath.row < newPath.row)) {
		// 繰り越し移動
		NSInteger iSec = oldPath.section + 1;
		if (iSec < [RaE6parts count]) {
			return [NSIndexPath indexPathForRow:0 inSection:iSec]; // 翌月
		}
	}
	else {
		// 前月へ移動
		NSInteger iSec = oldPath.section - 1;
		if (0 <= iSec) {
			NSInteger iRow = [[RaE6parts objectAtIndex:iSec] count];  // 移動可能な行数==>末尾になる
			return [NSIndexPath indexPathForRow:iRow inSection:iSec]; // 前月
		}
	}
    return oldPath; // 移動なし
}


// Editモード時の行移動処理　　＜＜CoreDataにつきArrayのように削除＆挿入ではダメ。ソート属性(row)を書き換えることにより並べ替えている＞＞
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)oldPath 
											  	  toIndexPath:(NSIndexPath *)newPath 
{
	// セクションを跨いだ移動に対応
	//--------------------------------------------------(1)MutableArrayの移動
	E6part *e6obj = [[RaE6parts objectAtIndex:oldPath.section] objectAtIndex:oldPath.row];
	// 移動元から削除
	[[RaE6parts objectAtIndex:oldPath.section] removeObjectAtIndex:oldPath.row];
	// 移動先へ挿入　＜＜newPathは、targetIndexPathForMoveFromRowAtIndexPath にて[Gray]行の回避処理した行である＞＞
	[[RaE6parts objectAtIndex:newPath.section] insertObject:e6obj atIndex:newPath.row];
	// E2-E3 リンク更新
	e6obj.e2invoice = [RaE2invoices objectAtIndex:newPath.section];
	
	//---------------------------------------------------------------
	// E6には.nRow は無いので、セクション(E2支払)間移動のために実装した。
	//---------------------------------------------------------------
	
	//-----------------------------------E2セクション間移動のとき、新旧sum項目の再集計
	if (oldPath.section != newPath.section) {
		// 旧 E2,E7 sum 更新
		E2invoice *e2obj = [RaE2invoices objectAtIndex:oldPath.section];
		[MocFunctions e2e7update:e2obj]; //E6減
		// 新 E2,E7 sum 更新
		e2obj = [RaE2invoices objectAtIndex:newPath.section];
		[MocFunctions e2e7update:e2obj]; //E6増
		// E1 に影響は無いのでなにもしない
		// ここで再表示したいがreloadDataするとFreezeなので、editing:にて編集完了時にreloadしている
	}
	
	// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針である＞＞
	/*NSError *error = nil;
	if (![e6obj.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}*/
	[MocFunctions commit];
}


#ifdef AzPAD
#pragma mark - <UIPopoverControllerDelegate>
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{	// Popoverの外部をタップして閉じる前に通知
	return NO; // Popover外部タッチで閉じるのを禁止 ＜＜追加MOCオブジェクトをＣａｎｃｅｌ時に削除する必要があるため＞＞
/*
	if ([popoverController.contentViewController isMemberOfClass:[UINavigationController class]]) {
		UINavigationController* nav = (UINavigationController*)popoverController.contentViewController;
		if ([nav.topViewController isMemberOfClass:[E3recordDetailTVC class]]) {
			// Popover外側をタッチしたとき E3recordDetailTVC -　cancel を通っていないので、ここで通す。
			// PadPopoverInNaviCon を使っているから
			E3recordDetailTVC* e3tvc = (E3recordDetailTVC *)nav.topViewController;
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

