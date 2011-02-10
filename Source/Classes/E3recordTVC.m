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
#import "EntityRelation.h"
#import "SettingTVC.h"
#import "E3recordTVC.h"
#import "E3recordDetailTVC.h"

@interface E3recordTVC (PrivateMethods)
- (void)azSettingView;
- (void)e3detailView:(NSIndexPath *)indexPath;
- (void)cellButton: (UIButton *)button;
@end

@implementation E3recordTVC
@synthesize Re0root;
@synthesize Pe4shop;
@synthesize Pe5category;
@synthesize Pe8bank;


- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[Me3list release];
	[Msection release];
	[Mindex release];
	
	// @property (retain)
	[Re0root release];

	[MautoreleasePool release];
	[super dealloc];
}

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStylePlain]) {  // セクションなしテーブル
		// 初期化成功
		MautoreleasePool = [[NSAutoreleasePool alloc] init];	// [0.3]autorelease独自解放のため
		MiForTheFirstSection = (-1);  // viewWillAppearにてMe2list Reload時にセット
		MbFirstAppear = YES; // Load後、最初に1回だけ処理するため
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
	UIBarButtonItem *buTop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Bar32-Top.png"]
															  style:UIBarButtonItemStylePlain  //Bordered
															 target:self action:@selector(barButtonTop)];
	UIBarButtonItem *buAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																		   target:self action:@selector(barButtonAdd)];
	UIBarButtonItem *buSet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Setting-icon16.png"]
															  style:UIBarButtonItemStylePlain  //Bordered
															 target:self action:@selector(azSettingView)];
	NSArray *buArray = [NSArray arrayWithObjects: buTop, buFlex, buAdd, buFlex, buSet, nil];
	[self setToolbarItems:buArray animated:YES];
	[buSet release];
	[buAdd release];
	[buTop release];
	[buFlex release];
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:YES];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	
	//没 AzPackingのE3同様に、全E2セクション表示かつ全E3表示　＜没：E2支払済みが大量になる危険性および必要性が低く複雑になりすぎるため没＞
	//以上から、Pe2selectの前後1ノード計3ノードだけで十分と判断した。

	// Me3list
	//----------------------------------------------------------------------------CoreData Loading
	// 当月の1年前の1日以降を抽出する
	NSCalendar *cal = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *dtc = [cal components:unitFlags fromDate:[NSDate date]];
	dtc.year--; // 前年
	// dtc.month   同月
	dtc.day = 1; // 1日
	NSDate *dtTop = [cal dateFromComponents:dtc];
	dtc.month++; // 翌月
	NSDate *dtNext = [cal dateFromComponents:dtc];
	//[dtc release]; autorelease
	AzLOG(@"Me3list:dtTop=[%@]", [dtTop description]);
	AzLOG(@"Me3list:dtNext=[%@]", [dtNext description]);
	
	// Temp Array
	NSMutableArray *mE3array = [NSMutableArray new];
	// Sorting
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"dateUse" ascending:YES];
	NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
	[sort1 release];

	if (Pe4shop) {
		// Pe4shop以下、最近の全E3
		//Me3list = [[NSMutableArray alloc] initWithArray:[Pe4shop.e3records allObjects]];
		//[Me3list sortUsingDescriptors:sortArray];
		for (E3record *e3 in Pe4shop.e3records) {
			if ([dtTop compare:e3.dateUse] == NSOrderedAscending) {
				// dtTop <= e3.dateUse
				[mE3array addObject:e3];
			}
		}
		[mE3array sortUsingDescriptors:sortArray];
	}
	else if (Pe5category) {
		// Pe5category以下、最近の全E3
		//Me3list = [[NSMutableArray alloc] initWithArray:[Pe5category.e3records allObjects]];
		//[Me3list sortUsingDescriptors:sortArray];
		for (E3record *e3 in Pe5category.e3records) {
			if ([dtTop compare:e3.dateUse] == NSOrderedAscending) {
				// dtTop <= e3.dateUse
				[mE3array addObject:e3];
			}
		}
		[mE3array sortUsingDescriptors:sortArray];
	}
	else if (Pe8bank) {
		// Pe8bank以下、最近の全E3
		for (E1card *e1 in Pe8bank.e1cards) {
			for (E3record *e3 in e1.e3records) {
				if ([dtTop compare:e3.dateUse] == NSOrderedAscending) {
					// dtTop <= e3.dateUse
					[mE3array addObject:e3];
				}
			}
		}
		[mE3array sortUsingDescriptors:sortArray];
	}
	else 
	{
		// 利用明細一覧用：最近の全E3
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"E3record" 
												  inManagedObjectContext:Re0root.managedObjectContext];
		[fetchRequest setEntity:entity];
		//[0.3]検索により抽出する
//		[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(%@ <= dateUse)", [dtTop description]]];
		[fetchRequest setSortDescriptors:sortArray];
		NSError *error = nil;
		NSArray *arFetch = [Re0root.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (error) {
			AzLOG(@"Error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		[fetchRequest release];
		[mE3array setArray:arFetch];
	}
	[sortArray release];
	
	//---------------------------------Me3list 生成
	if (Me3list != nil) {
		[Me3list release];
		Me3list = nil;
	}
	Me3list = [NSMutableArray new];
	//---------------------------------Msection, Mindex 生成
	if (Msection != nil) {
		[Msection release];
		Msection = nil;
	}
	if (Mindex != nil) {
		[Mindex release];
		Mindex = nil;
	}
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-M"];
	Msection = [[NSMutableArray alloc] initWithObjects:[df stringFromDate:dtTop], nil];
	[df setDateFormat:@"M"];
	Mindex = [[NSMutableArray alloc] initWithObjects:[df stringFromDate:dtTop], nil];
	[df release];
	//
	// mE3array --> Me3list 年月分類
	NSMutableArray *e3days = [NSMutableArray new];
	for (E3record *e3 in mE3array) 
	{
		while ([e3.dateUse compare:dtNext] != NSOrderedAscending) 
		{
			// セクション
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateFormat:@"yyyy-M"];
			[Msection addObject:[df stringFromDate:dtNext]]; // セクションタイトルに使う
			[df setDateFormat:@"M"];
			[Mindex addObject:[df stringFromDate:dtNext]]; // セクションタイトルに使う
			[df release];
			//
			[Me3list addObject:e3days];
			[e3days release]; // Me3list にaddしたものを切り離してMe3listに任せる。
			e3days = [NSMutableArray new]; // 新しい領域を確保する。
			//
			// dtNext <= e3.dateUse : 翌月へ
			dtc.month++; // 翌月
			dtNext = [cal dateFromComponents:dtc];
			AzLOG(@"Me3list:dtNext=[%@]", [dtNext description]);
		}
		[e3days addObject:e3];
	}
	[Me3list addObject:e3days]; // 2次元配列
	[e3days release];
	// End of line. セクションインデックスのために必要
	[Msection addObject:NSLocalizedString(@"Bottom line",nil)]; // セクションタイトルに使う
	[Mindex addObject:NSLocalizedString(@"index End",nil)]; // End「末」
	e3days = [NSMutableArray new]; // 新しい領域を確保する。
	[Me3list addObject:e3days]; // End & iAdセクション
	[e3days release];
	//
	[mE3array release];
#ifdef AzDEBUG
	AzLOG(@"[Msection count]=%d  [Me3list count]=%d", [Msection count], [Me3list count]);
	for (int i=0 ; i<[Me3list count] && i<[Msection count] ; i++) {
		AzLOG(@"Msection=(%@) Me3list=[%d][%d]", 
			  [Msection objectAtIndex:i],
			  i,
			  [[Me3list objectAtIndex:i] count]);
	}
#endif
	
	// テーブルビューを更新します。
    [self.tableView reloadData];

	if ([Me3list count] <= 0) {
		// 明細なし ＞ 前画面へ戻る
		[self.navigationController dismissModalViewControllerAnimated:YES]; // 現モーダルViewを閉じて前に戻る
	}
	else if (MbFirstAppear && 0 < [Me3list count]) {
		MbFirstAppear = NO;
		// 最新行（最終ページ）を表示する　＜＜最終行を画面下部に表示する＞＞  +Add行まで表示するためMiddleにした。
		//NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[Me3list count]-1 inSection:0];
		// Bottom section : iAd Line
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:[Me3list count]-1];
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
	}
}

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

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		// 正面（ホームボタンが画面の下側にある状態）
		[self.navigationController setToolbarHidden:NO animated:YES]; // ツールバー表示
		return YES; // この方向だけは常に許可する
	} 
	else if (MbOptAntirotation) return NO; // 回転禁止
	
	if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		// 逆面（ホームボタンが画面の上側にある状態）
		[self.navigationController setToolbarHidden:NO animated:YES]; // ツールバー表示
	} else {
		// 横方向や逆向きのとき
		[self.navigationController setToolbarHidden:YES animated:YES]; // ツールバー非表示=YES
	}
	return YES;
	// 現在の向きは、self.interfaceOrientation で取得できる
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	[self.tableView reloadData];
}

/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
								duration:(NSTimeInterval)duration
{
	if (MbannerView) {
		if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
			MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
		} else {
			MbannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
		}
		MbannerView.frame = CGRectZero;
	}
}
*/

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる

	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (Pe4shop OR Pe5category OR Pe8bank) {
		// (0)TopMenu >> (1)E4/E5 >> (2)This clear
		[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
	} else {
		// (0)TopMenu >> (1)This clear
		[appDelegate.comebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:-1]];
	}

	if (0 <= MiForTheFirstSection) {
		if (0 < [Me3list count]) {
			// 最近の利用明細一覧：末尾を表示
			//NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[Me3list count]-1 inSection:0];
			// Bottom section : iAd Line
			NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:[Me3list count]-1];
			[self.tableView scrollToRowAtIndexPath:indexPath 
								  atScrollPosition:UITableViewScrollPositionBottom animated:NO];  // 実機検証結果:NO
		}
		MiForTheFirstSection = (-2);  // 最初一度だけ通り、二度と通らないようにするため
	}
}

// カムバック処理（復帰再現）：親から呼ばれる
- (void)viewComeback:(NSArray *)selectionArray
{
	NSInteger lRow;
	if (Pe4shop OR Pe5category OR Pe8bank) {
		// (0)TopMenu >> (1)E4/E5 >> (2)This clear
		lRow = [[selectionArray objectAtIndex:2] integerValue];
	} else {
		// (0)TopMenu >> (1)This clear
		lRow = [[selectionArray objectAtIndex:1] integerValue];
	}
	if (lRow < 0) { // この画面に留まる
		return;
	}
	NSInteger lSec = lRow / GD_SECTION_TIMES;
	lRow -= (lSec * GD_SECTION_TIMES);
	
	if ([Me3list count]-1 <= lSec) return;  // -1 : 行末(iAd)セクションを除くため
	if ([[Me3list objectAtIndex:lSec] count] <= lRow) return; // OVER
	
	// 選択行を画面中央付近に表示する
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lRow inSection:lSec];
	[self.tableView scrollToRowAtIndexPath:indexPath 
						  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
	
	// ドリルダウン
	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init];
	e3detail.title = self.title;
	e3detail.Re3edit = [[Me3list objectAtIndex:lSec] objectAtIndex:lRow]; ;
	e3detail.PiAdd = 0; // (0)Edit mode
	//e3detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:NO];
	// 末尾につき viewComeback なし
	[e3detail release];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [Me3list count]; // 末尾は、行末(iAd)セクション
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section < [Me3list count]-1) {  // -1 : 行末(iAd)セクションを除くため
		return [[Me3list objectAtIndex:section] count];
	} else {
		return 1; // iAd
	}
}


// セクションインデックスを表示する
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	// NSMutableArray を NSArray にする
	NSArray *ar = [[Mindex copy] autorelease];
	return ar;
}


// TableView セクション名を応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	if (section < [Me3list count])
	{
		if (0 < [[Me3list objectAtIndex:section] count]) {
			// 年-月  月計 99,999,999
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			[formatter setNumberStyle:NSNumberFormatterDecimalStyle];  // CurrencyStyle]; // 通貨スタイル
			NSString *zSum = [formatter stringFromNumber:[[Me3list objectAtIndex:section] 
														  valueForKeyPath:@"@sum.nAmount"]];
			[formatter release];
			//
			NSString *zHeader = [NSString stringWithFormat:@"%@   %@ %@",
								 [Msection objectAtIndex:section], 
								 NSLocalizedString(@"Monthly total",nil), zSum];
			return zHeader; // autoreleseされる
		}
		else {
			// 年-月
			return [Msection objectAtIndex:section];
		}
	}
	return nil;
}


// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if ([Me3list count]-1 <= indexPath.section) {
		return 5; // End of line
	}
	return 44; // デフォルト：44ピクセル
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *zCellE3record = @"CellE3record";
    static NSString *zCellEnd = @"CellEnd";
	UITableViewCell *cell = nil;
	UILabel *cellLabel = nil;
	
	
	if (indexPath.section < [Me3list count]-1) 
	{
		cell = [tableView dequeueReusableCellWithIdentifier:zCellE3record];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
											reuseIdentifier:zCellE3record] autorelease];
			// 行毎に変化の無い定義は、ここで最初に1度だけする
			cell.textLabel.font = [UIFont systemFontOfSize:14];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
			cell.detailTextLabel.textAlignment = UITextAlignmentLeft; //金額が欠けないように左寄せにした
			cell.showsReorderControl = NO; // Move禁止

			cellLabel = [[UILabel alloc] init];
			cellLabel.textAlignment = UITextAlignmentRight;
			cellLabel.font = [UIFont systemFontOfSize:14];
			cellLabel.tag = -1;
			[cell addSubview:cellLabel]; [cellLabel release];
		 }
		else {
			cellLabel = (UILabel *)[cell viewWithTag:-1];
		}
		// 回転対応のため
		cellLabel.frame = CGRectMake(self.tableView.frame.size.width-108, 2, 75, 20);

		E3record *e3obj = [[Me3list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		
		if ([e3obj.nReservType integerValue] == 0) {	// [0.3]
			cell.textLabel.textColor = [UIColor blackColor];	// 利用明細
		} else {
			cell.textLabel.textColor = [UIColor grayColor];		// 予約明細
			assert([e3obj.e6parts count] <= 0);  // 予約明細にはE6なし、これによりE2,E7sum集計させない。
		}

		if (e3obj.e1card && 0 < [e3obj.e6parts count]) {
			BOOL bPaid = YES;
			for (E6part *e6node in e3obj.e6parts) {
				if (e6node.e2invoice.e7payment.e0unpaid) {
					bPaid = NO; // 1つでも未払いがあればNO
					break;
				}
			}
			if (bPaid) {
				cell.imageView.image = [UIImage imageNamed:@"Paid32.png"]; // PAID
			}
			else if (1 < [e3obj.e6parts count]) {
				if ([e3obj.sumNoCheck intValue]==0) {
					cell.imageView.image = [UIImage imageNamed:@"Check32.png"];
				} else {
					cell.imageView.image = nil; //[UIImage imageNamed:@"CircleW32.png"];
				}
			}
			else {
				if ([e3obj.sumNoCheck intValue]==0) {
					cell.imageView.image = [UIImage imageNamed:@"Check32.png"];
				} else {
					cell.imageView.image = nil; //[UIImage imageNamed:@"Circle32.png"];
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
		if ([e3obj.nAmount integerValue] == 0) {
			cellLabel.textColor = [UIColor redColor]; // これだけは赤にした。
			cellLabel.text = @"Zero! 0";
		} else {
			if ([e3obj.nAmount integerValue] <= 0) {
				cellLabel.textColor = [UIColor blueColor];
			} else {
				cellLabel.textColor = [UIColor blackColor];
			}
			// Amount JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			[formatter setNumberStyle:NSNumberFormatterDecimalStyle];  // CurrencyStyle]; // 通貨スタイル
			//NSLocale *localeJP = [[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"];
			//[formatter setLocale:localeJP];
			//[localeJP release];
			cellLabel.text = [formatter stringFromNumber:e3obj.nAmount];
			[formatter release];
		}

		// Cell 2行目
		NSString *zShop = @"";
		NSString *zCategory = @"";
		if (e3obj.e4shop != nil) zShop = e3obj.e4shop.zName;
		if (e3obj.e5category != nil) zCategory = e3obj.e5category.zName;
		if (e3obj.e1card) {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@.%@.%@", e3obj.e1card.zName, 
										 zShop, zCategory];
			cell.detailTextLabel.textColor = [UIColor blackColor];
		} else {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@.%@.%@", NSLocalizedString(@"Card Undecided",nil), 
										 zShop, zCategory];
			cell.detailTextLabel.textColor = [UIColor redColor];
		}
	}
	else {
		// Bottom セル
		cell = [tableView dequeueReusableCellWithIdentifier:zCellEnd];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:zCellEnd] autorelease];
			cell.textLabel.text = nil; //NSLocalizedString(@"Bottom line",nil); 
			//cell.textLabel.textAlignment = UITextAlignmentCenter; // 中央寄せ
			//cell.textLabel.font = [UIFont systemFontOfSize:14];
			cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
			cell.showsReorderControl = NO; // Move禁止
		}
	}
	return cell;
}

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

	if (indexPath.section < [Me3list count]-1) 
	{
		// Comback-L3 記録
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		long lPos = indexPath.section * GD_SECTION_TIMES + indexPath.row;
		if (Pe4shop OR Pe5category OR Pe8bank) {
			// (0)TopMenu >> (1)E4/E5 >> (2)This clear
			[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:lPos]];
			[appDelegate.comebackIndex replaceObjectAtIndex:3 withObject:[NSNumber numberWithLong:-1]];
		} else {
			// (0)TopMenu >> (1)This clear
			[appDelegate.comebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:lPos]];
			[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
		}
		// E3詳細画面へ
		[self e3detailView:indexPath]; // この中でAddにも対応
	}
}

- (void)e3detailView:(NSIndexPath *)indexPath 
{
	// ドリルダウン
	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init];
	// 以下は、E3detailTVCの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
	if (indexPath != nil && indexPath.section < [Me3list count]-1  
						 && indexPath.row < [[Me3list objectAtIndex:indexPath.section] count]) {
		// Edit Item
		e3detail.title = NSLocalizedString(@"Edit Record", nil);
		e3detail.Re3edit = [[Me3list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		e3detail.PiAdd = 0; // (0)Edit mode
	}
	else {
		// Add E3
		E3record *e3obj = [NSEntityDescription insertNewObjectForEntityForName:@"E3record"
														   inManagedObjectContext:Re0root.managedObjectContext];
		e3obj.dateUse = [NSDate date]; // 迷子にならないように念のため
		e3obj.nReservType = [NSNumber numberWithInt:0]; // (0)利用
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
	//e3detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:YES];
	[e3detail release];
}

/*
// TableView Editモード処理
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
											forRowAtIndexPath:(NSIndexPath *)indexPath 
{

}

// Editモード時の行Edit可否
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES; // 行編集許可
}

// Editモード時の行移動の可否　　＜＜最終行のAdd専用行を移動禁止にしている＞＞
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// E3recordTVC は、利用明細を利用日順に表示するため移動はなし。　E2間移動（支払日変更）は、E6partTVC で行う。
//	if (indexPath.row < [Me3list count]) {
//		return YES; // Move 対象
//	}
	
	return NO;  // 移動禁止
}
*/

/*E3recordTVC は、利用明細を利用日順に表示するため移動はなし。　E2間移動（支払日変更）は、E6partTVC で行う。
// Editモード時の行移動「先」を応答　　＜＜最終行のAdd行への移動ならば1つ前の行を応答している＞＞
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)oldPath 
																		 toProposedIndexPath:(NSIndexPath *)newPath 
{
	// Add行が異動先になった場合、その1つ前の通常行を返すことにより、Add行への移動禁止となる。
	NSInteger rows = [Me3list count];  // 移動可能な行数（Add行を除く）
	if (oldPath.section == newPath.section && 0 < rows) rows--; // 同セクション内では元行が減るため (beginUpdates-endUpdatesを使う方法もある）
	if (rows <= newPath.row) {
		// Add行ならば、E3ノードの最終行(row-1)を応答する
		newPath = [NSIndexPath indexPathForRow:rows inSection:newPath.section];
	}
    return newPath;
}
*/

/*
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
*/

/*E3recordTVC は、利用明細を利用日順に表示するため移動はなし。　E2間移動（支払日変更）は、E6partTVC で行う。
// Editモード時の行移動処理　　＜＜CoreDataにつきArrayのように削除＆挿入ではダメ。ソート属性(row)を書き換えることにより並べ替えている＞＞
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)oldPath 
											  	  toIndexPath:(NSIndexPath *)newPath 
{
	// セクションを跨いだ移動に対応
	//--------------------------------------------------(1)MutableArrayの移動
	E3record *e3obj = [Me3list objectAtIndex:oldPath.row];
	// 移動元から削除
	[Me3list removeObjectAtIndex:oldPath.row];
	// 移動先へ挿入　＜＜newPathは、targetIndexPathForMoveFromRowAtIndexPath にて[Gray]行の回避処理した行である＞＞
	[Me3list insertObject:e3obj atIndex:newPath.row];
	// E2-E3 リンク更新
	e3obj.e2invoice = [Me2list objectAtIndex:newPath.section];
	
	//---------------------------------------------------------------
	// E3には.nRow は無いので、セクション(E2支払)間移動のために実装した。
	//---------------------------------------------------------------
	
	//-----------------------------------E2セクション間移動のとき、新旧sum項目の再集計
	if (oldPath.section != newPath.section) {
		// 旧 E2 sum 更新
		E2invoice *e2obj = [Me2list objectAtIndex:oldPath.section];
		e2obj.sumNoCheck = [e2obj valueForKeyPath:@"e3records.@sum.nNoCheck"];
		e2obj.sumAmount = [e2obj valueForKeyPath:@"e3records.@sum.nAmount"];
		// 新 E2 sum 更新
		e2obj = [Me2list objectAtIndex:newPath.section];
		e2obj.sumNoCheck = [e2obj valueForKeyPath:@"e3records.@sum.nNoCheck"];
		e2obj.sumAmount = [e2obj valueForKeyPath:@"e3records.@sum.nAmount"];
		// E1 に影響は無いのでなにもしない
		// ここで再表示したいがreloadDataするとFreezeなので、editing:にて編集完了時にreloadしている
	}
	
	// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針である＞＞
	NSError *error = nil;
	if (![Pe2select.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}
*/


@end

