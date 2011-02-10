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
#import "EntityRelation.h"
#import "E6partTVC.h"
#import "E3recordDetailTVC.h"

#define ACTIONSEET_TAG_DELETE	199

@interface E6partTVC (PrivateMethods)
- (void)e3detailView:(NSIndexPath *)indexPath;
- (void)cellButton: (UIButton *)button;
@end

@implementation E6partTVC
//@synthesize Re2invoices;
@synthesize Pe2select;
@synthesize Pe7select;
//@synthesize PiMode;
@synthesize PiFirstSection;

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[Me2invoices release];
	[Me6parts release];
	
	// @property (retain)
//	[Re2invoices release];
	[super dealloc];
}

- (void)viewDidUnload 
{
	// メモリ不足時、裏側にある場合に呼び出されるので、Private Allocで生成したObjを解放する。
	[Me2invoices release];		Me2invoices = nil;
	[Me6parts release];			Me6parts = nil;
	
	// @property (retain) は解放しない。
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"viewDidUnload" 
													 message:@"E6partTVC" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"didReceiveMemoryWarning" 
													 message:@"E6partTVC" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
    [super didReceiveMemoryWarning];
}


// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStylePlain]) {  // セクションなしテーブル
		MiForTheFirstSection = (-1);  // viewWillAppearにてMe2invoices Reload時にセット
	}
	// 初期化
	Me2e1card = nil;
	Me7e0root = nil;
	MbFirstOne = YES;
	return self;
}

- (void)barButtonTop {
	[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
}

// viewDidLoadメソッドは，TableViewContorllerオブジェクトが生成された後，実際に表示される際に呼び出されるメソッド
- (void)viewDidLoad 
{
    [super viewDidLoad];
	Me2invoices = nil;
	Me6parts = nil;
	

	// ここは、alloc直後に呼ばれるため、下記のようなパラは未セット状態である。==>> viewWillAppearで参照すること

	// Tool Bar Button
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	UIBarButtonItem *buTop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Bar16-TopView.png"]
															   style:UIBarButtonItemStylePlain  //Bordered
															  target:self action:@selector(barButtonTop)];
	NSArray *buArray = [NSArray arrayWithObjects: buTop, buFlex, nil];
	[self setToolbarItems:buArray animated:YES];
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

	//----------------------------------------------------------------------------CoreData Loading
	//---------------------------------Me2invoices 生成
	if (Me2invoices) {
		[Me2invoices release];
		Me2invoices = nil;
	}
	Me2invoices = [[NSMutableArray alloc] init];
	
	//---------------------------------Me6parts 生成
	if (Me6parts != nil) {
		[Me6parts release];
		Me6parts = nil;
	}
	Me6parts = [[NSMutableArray alloc] init];

	if (Pe7select) {
		Pe2select = nil; // 他方は必ずnil
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
		if ([Me2invoices count] <= 0) {
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
			[Me2invoices setArray:[Pe7select.e2invoices allObjects]];
			// E2.e1card.nRow 昇順ソート
			NSSortDescriptor *sort1;
			if (Pe7select.e0paid) {
				sort1 = [[NSSortDescriptor alloc] initWithKey:@"e1paid.nRow" ascending:YES];
			} else {
				sort1 = [[NSSortDescriptor alloc] initWithKey:@"e1unpaid.nRow" ascending:YES];
			}
			NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
			[Me2invoices sortUsingDescriptors:sortArray];
			[sortArray release];
			[sort1 release];
		}
	}
	else if (Pe2select) {
		Pe7select = nil; // 他方は必ずnil
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
		if ([Me2invoices count] <= 0) {
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
				[Me2invoices addObject:Pe2select];
			}
			else if (Pe2select.e1unpaid) {
				{	// E6一覧の編集モードで移動により支払日を変更できるようにするため。
					// 前月が無ければ追加する
					NSInteger iYearMMDD = GiAddYearMMDD([Pe2select.nYearMMDD integerValue], 0, -1, 0); // 前月へ
					[EntityRelation e2invoice:Me2e1card inYearMMDD:iYearMMDD]; // E2無ければ追加する
					// E2最終のさらに翌月が無ければ追加する
					iYearMMDD = [[Pe2select.e1unpaid valueForKeyPath:@"e2unpaids.@max.nYearMMDD"] integerValue];
					iYearMMDD = GiAddYearMMDD(iYearMMDD, 0, +1, 0); // 翌月へ
					[EntityRelation e2invoice:Me2e1card inYearMMDD:iYearMMDD]; // E2無ければ追加する
					[EntityRelation commit]; //--------------SAVE
					// 最終的に未使用のE2は、viewWillDisappear:にて削除している。
				}
				// E1配下のE2
				[Me2invoices setArray:[Pe2select.e1unpaid.e2unpaids allObjects]];
				// E2.nYearMMDD 昇順ソート
				NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"nYearMMDD" ascending:YES];
				NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
				[Me2invoices sortUsingDescriptors:sortArray];
				[sortArray release];
				[sort1 release];
			}
			if (Pe2select.e1unpaid) {
				// Unpaidならば [編集]モードＯＮ
				self.navigationItem.rightBarButtonItem = self.editButtonItem;
				self.tableView.allowsSelectionDuringEditing = YES; // 編集モードに入ってる間にユーザがセルを選択できる
			}
		}
	}

	if (0 < [Me2invoices count]) {
		// E6.e3record.dateUse 昇順ソート
		NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"e3record.dateUse" ascending:YES];
		NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
		// muE2list配下の全E6抽出＆ソート
		for (E2invoice *e2 in Me2invoices) {
			NSMutableArray *e6arry = [[NSMutableArray alloc] initWithArray:[e2.e6parts allObjects]];
			[e6arry sortUsingDescriptors:sortArray];
			[Me6parts addObject:e6arry]; [e6arry release];
		}
		[sortArray release];
		[sort1 release];
	}
/*	else {    ＜＜ここでpopすると早すぎて戻るボタンに不具合発生するため、viewDidAppear:で処理するように改めた。
		// 最終的にE2が無い場合、前画面に戻る。　　E3にて利用日を変更した場合などに発生する可能性あり
		[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
		return;
	}*/

	
	// テーブルビューを更新します。
    [self.tableView reloadData];
	
	// 指定位置までテーブルビューの行をスクロールさせる初期処理　＜＜レコードセット後でなければならないので、この位置になった＞＞
	if (MbFirstOne && Pe2select && 1 < [Me2invoices count]) {
		MbFirstOne = NO; // 最初に1度だけ通すため  (initWithStyle:にてYESに初期化している）
		NSInteger iSec = 0;
		for (E2invoice *e2 in Me2invoices) {
			if (e2 == Pe2select) break;
			iSec++;
		}
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:iSec];
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
	}
}

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		// 正面（ホームボタンが画面の下側にある状態）
		[self.navigationController setToolbarHidden:NO animated:YES]; // ツールバー表示する
		return YES; // この方向だけは常に許可する
	} 
	else if (!MbOptAntirotation) {
		// 横方向や逆向きのとき
		[self.navigationController setToolbarHidden:YES animated:YES]; // ツールバー消す
	}
	// 現在の向きは、self.interfaceOrientation で取得できる
	return !MbOptAntirotation;
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	[self.tableView reloadData];
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる

	// Comback (-1)にして未選択状態にする
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	// PiMode: (0)E1<E2<E6:同カードの支払日違い  (1)E7<E2<E6:同支払日のカード違い
	if (Pe2select) {
		// (0)TopMenu >> (1)E1card >> (2)E2invoice >> (3)This clear
		[appDelegate.comebackIndex replaceObjectAtIndex:3 withObject:[NSNumber numberWithLong:-1]];
	} else {
		// (0)TopMenu >> (1)E7payment >> (2)This clear
		[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
	}
	
	if (0 <= MiForTheFirstSection && 0 <= PiFirstSection && PiFirstSection < [Me6parts count]) {
		// 選択行を画面中央付近に表示する
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:PiFirstSection];
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
		MiForTheFirstSection = (-2);  // 最初一度だけ通り、二度と通らないようにするため
	}

	if ([Me2invoices count] <= 0) {
		// 最終的にE2が無い場合、前画面に戻る。　　E3にて利用日を変更した場合などに発生する可能性あり
		[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
		return;
	}
}

// カムバック処理（復帰再現）：親から呼ばれる
- (void)viewComeback:(NSArray *)selectionArray
{
	//----------------------------------------L3
	NSInteger lRow = [[selectionArray objectAtIndex:3] integerValue];
	if (lRow < 0) return; // この画面に留まる
	NSInteger lSec = lRow / GD_SECTION_TIMES;
	lRow -= (lSec * GD_SECTION_TIMES);

	if ([Me6parts count] <= lSec) return; // section OVER
	if ([[Me6parts objectAtIndex:lSec] count] <= lRow) return; // row OVER（Addや削除されたとか）
	
	// 選択行を画面中央付近に表示する
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lRow inSection:lSec];
	[self.tableView scrollToRowAtIndexPath:indexPath 
						  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
	
	E6part *e6obj = [[Me6parts objectAtIndex:lSec] objectAtIndex:lRow];
	// ドリルダウン
	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init];
	e3detail.title = self.title;
	// Edit Item
	e3detail.Re3edit = e6obj.e3record;
	e3detail.PbAdd = NO;
	//e3detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:NO];
	// 末尾につき viewComeback なし
	[e3detail release];
}

// ビューが非表示にされる前や解放される前ににこの処理が呼ばれる。
// 次(前)画面が表示される前に処理される。
- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
	// E2(Unpaid)配下のE6が無ければ削除する。　　viewWillAppear:にて追加された前月と翌月のE2を削除するのが目的。
	NSArray *aE2 = [NSArray arrayWithArray:[Me2e1card.e2unpaids allObjects]];
	for (E2invoice *e2 in aE2) {
		if ([e2.e6parts count] <= 0) {
			[EntityRelation e2delete:e2]; // E2,E7削除
		}
	}
	[EntityRelation commit]; //--------------SAVE----------MOVE結果もこれにて保存される
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [Me6parts count];  // Me6partsは、[E2invoices]×[E3records] の二次元配列
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	E2invoice *e2obj = [Me2invoices objectAtIndex:section];
	if (e2obj.e1paid) {
		return [[Me6parts objectAtIndex:section] count]; // PAIDにつきAdd行なし
	} else {
		return [[Me6parts objectAtIndex:section] count] + 1; // +1:Add行
	}
}

// TableView セクション名を応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	//E6part *e6obj = [[Me6parts objectAtIndex:section] objectAtIndex:0]; ＜＜E6が空の場合がある＞＞
	E2invoice *e2obj = [Me2invoices objectAtIndex:section];
	
	// JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle]; // 通貨スタイル
	NSLocale *localeJP = [[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"];
	[formatter setLocale:localeJP];
	[localeJP release];
	NSString *zSum = [formatter stringFromNumber:e2obj.sumAmount];
	[formatter release];
	
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
	if ([[Me6parts objectAtIndex:indexPath.section] count] <= indexPath.row) {
		return 30; // Add Record
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
	
	if (indexPath.row < [[Me6parts objectAtIndex:indexPath.section] count]) 
	{
		cell = [tableView dequeueReusableCellWithIdentifier:zCellE6part];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
											reuseIdentifier:zCellE6part] autorelease];
			// 行毎に変化の無い定義は、ここで最初に1度だけする
			cell.textLabel.font = [UIFont systemFontOfSize:14];
			//cell.textLabel.textAlignment = UITextAlignmentLeft;
			//cell.textLabel.textColor = [UIColor blackColor];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
			cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
			cell.detailTextLabel.textColor = [UIColor blackColor];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // ＞
			cell.showsReorderControl = YES; // MoveOK

			cellLabel = [[UILabel alloc] init];
			cellLabel.textAlignment = UITextAlignmentRight;
			cellLabel.textColor = [UIColor blackColor];
			//cellLabel.backgroundColor = [UIColor grayColor]; //DEBUG範囲チェック用
			cellLabel.font = [UIFont systemFontOfSize:14];
			cellLabel.tag = -1;
			[cell addSubview:cellLabel]; [cellLabel release];
		}
		else {
			cellLabel = (UILabel *)[cell viewWithTag:-1];
		}
		// 回転対応のため
		cellLabel.frame = CGRectMake(self.tableView.frame.size.width-125, 2, 80, 20);

		// 左ボタン --------------------＜＜cellLabelのようにはできない！.tagに個別記録するため＞＞
		UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom]; // autorelease
		cellButton.frame = CGRectMake(0,0, 44,44);
		[cellButton addTarget:self action:@selector(cellButton:) forControlEvents:UIControlEventTouchUpInside];
		cellButton.backgroundColor = [UIColor clearColor]; //背景透明
		cellButton.showsTouchWhenHighlighted = YES;
		cellButton.tag = indexPath.section * GD_SECTION_TIMES + indexPath.row;
		[cell.contentView addSubview:cellButton]; //[bu release]; buttonWithTypeにてautoreleseされるため不要。UIButtonにinitは無い。
		// 左ボタン ------------------------------------------------------------------
		
		E6part *e6obj = [[Me6parts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		E3record *e3obj = e6obj.e3record;
		
		if (e6obj.e2invoice.e7payment.e0paid) {
			cell.imageView.image = [UIImage imageNamed:@"Paid32.png"]; // PAID 変更禁止
			cellButton.enabled = NO;
		}
		else if ([e6obj.nNoCheck intValue] == 1) {
			cell.imageView.image = [UIImage imageNamed:@"Circle32.png"]; // No check
			cellButton.enabled = YES;
		} 
		else if ([e6obj.nNoCheck intValue] == 0) {
			cell.imageView.image = [UIImage imageNamed:@"Circle32-check.png"]; // Checked
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
		if (e3obj.e4shop != nil) zShop = e3obj.e4shop.zName;
		if (e3obj.e5category != nil) zCategory = e3obj.e5category.zName;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", zShop, zCategory];
		
		// 金額
		// Amount JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // CurrencyStyle]; // 通貨スタイル
		NSLocale *localeJP = [[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"];
		[formatter setLocale:localeJP];
		[localeJP release];
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
		cell.textLabel.font = [UIFont systemFontOfSize:12];
		cell.textLabel.textAlignment = UITextAlignmentCenter; // 中央寄せ
		cell.textLabel.textColor = [UIColor blackColor];
		cell.imageView.image = nil;
		cell.accessoryType = UITableViewCellEditingStyleInsert; // (+)
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
		cell.showsReorderControl = NO; // Move禁止
	}
	return cell;
}

- (void)cellButton: (UIButton *)button 
{
	if (button.tag < 0) return;
	
	NSInteger iSec = button.tag / GD_SECTION_TIMES;
	NSInteger iRow = button.tag - (iSec * GD_SECTION_TIMES);
	
	E6part *e6obj = [[Me6parts objectAtIndex:iSec] objectAtIndex:iRow];
	// E6 Check
	if (0 < [e6obj.nNoCheck intValue]) {
		[EntityRelation e6check:YES inE6obj:e6obj inAlert:YES];
	} else {
		[EntityRelation e6check:NO inE6obj:e6obj inAlert:YES];
	}
	// SAVE & Commit!
	[EntityRelation commit];

	[self.tableView reloadData];
}

// TableView Editボタンスタイル
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (Pe2select) {
		if (indexPath.row < [[Me6parts objectAtIndex:indexPath.section] count]) {
			return UITableViewCellEditingStyleNone;  //Delete;
		}
		return UITableViewCellEditingStyleInsert;
	}
	else return UITableViewCellEditingStyleNone; // E7一覧配下のとき編集なし
}

// TableView 行選択時の動作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

	if (indexPath.row < [[Me6parts objectAtIndex:indexPath.section] count]) 
	{
		// Comback 記録
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		long lPos = indexPath.section * GD_SECTION_TIMES + indexPath.row;
		if (Pe2select) {
			// (0)TopMenu >> (1)E1card >> (2)E2invoice >> (3)This >> (4)Clear
			[appDelegate.comebackIndex replaceObjectAtIndex:3 withObject:[NSNumber numberWithLong:lPos]];
			[appDelegate.comebackIndex replaceObjectAtIndex:4 withObject:[NSNumber numberWithLong:-1]];
		} else {
			// (0)TopMenu >> (1)E7payment >> (2)This >> (3)Clear
			[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:lPos]];
			[appDelegate.comebackIndex replaceObjectAtIndex:3 withObject:[NSNumber numberWithLong:-1]];
		}
	}
	// E3詳細画面へ
	[self e3detailView:indexPath]; // この中でAddにも対応
}

- (void)e3detailView:(NSIndexPath *)indexPath 
{
	// ドリルダウン
	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init];
	// 以下は、E3detailTVCの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
	if (indexPath.row < [[Me6parts objectAtIndex:indexPath.section] count]) 
	{
		E6part *e6obj = [[Me6parts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		// Edit Item
		e3detail.title = NSLocalizedString(@"Edit Record", nil);
		e3detail.Re3edit = e6obj.e3record;
		e3detail.PbAdd = NO;
	}
	else {
		// Add E3
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		E3record *e3obj = [NSEntityDescription insertNewObjectForEntityForName:@"E3record"
														   inManagedObjectContext:appDelegate.managedObjectContext];
		//E6part *e6obj = [[Me6parts objectAtIndex:indexPath.section] objectAtIndex:0];
		//E6が無い場合あり、E2だけでも処理可能にする
		E2invoice *e2obj = [Me2invoices objectAtIndex:indexPath.section];
		if (e2obj.e1paid) {
			e3obj.e1card = e2obj.e1paid;
		} else if (e2obj.e1unpaid) {
			e3obj.e1card = e2obj.e1unpaid;
		} else {
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
		e3detail.PbAdd = YES; // Add mode
		e3detail.PiFirstYearMMDD = [e2obj.nYearMMDD integerValue]; // E2,E7配下から追加されるとき、支払日をこのE2に合わせるため。
	}
	//e3detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:YES];
	[e3detail release];
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

// Editモード時の行Edit可否
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES; // 行編集許可
}

// Editモード時の行移動の可否　　＜＜最終行のAdd専用行を移動禁止にしている＞＞
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if ([[Me6parts objectAtIndex:indexPath.section] count] <= indexPath.row) {
		return NO;  // Add行
	}
	return YES;  // Add行なしにつき、すべて移動可能
}


// Editモード時の行移動「先」を応答　　＜＜Add行なし＞＞
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)oldPath 
																		 toProposedIndexPath:(NSIndexPath *)newPath 
{
	if (oldPath.section == newPath.section && oldPath.row == newPath.row) {
		return newPath; // 元の位置
	}
	else if (oldPath.section < newPath.section  
			OR (oldPath.section == newPath.section && oldPath.row < newPath.row)) {
		// 繰り越し移動
		NSInteger iSec = oldPath.section + 1;
		if (iSec < [Me6parts count]) {
			return [NSIndexPath indexPathForRow:0 inSection:iSec]; // 翌月
		}
	}
	else {
		// 前月へ移動
		NSInteger iSec = oldPath.section - 1;
		if (0 <= iSec) {
			NSInteger iRow = [[Me6parts objectAtIndex:iSec] count];  // 移動可能な行数==>末尾になる
			return [NSIndexPath indexPathForRow:iRow inSection:iSec]; // 前月
		}
	}
    return oldPath; // 移動なし
}


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

// Editモード時の行移動処理　　＜＜CoreDataにつきArrayのように削除＆挿入ではダメ。ソート属性(row)を書き換えることにより並べ替えている＞＞
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)oldPath 
											  	  toIndexPath:(NSIndexPath *)newPath 
{
	// セクションを跨いだ移動に対応
	//--------------------------------------------------(1)MutableArrayの移動
	E6part *e6obj = [[Me6parts objectAtIndex:oldPath.section] objectAtIndex:oldPath.row];
	// 移動元から削除
	[[Me6parts objectAtIndex:oldPath.section] removeObjectAtIndex:oldPath.row];
	// 移動先へ挿入　＜＜newPathは、targetIndexPathForMoveFromRowAtIndexPath にて[Gray]行の回避処理した行である＞＞
	[[Me6parts objectAtIndex:newPath.section] insertObject:e6obj atIndex:newPath.row];
	// E2-E3 リンク更新
	e6obj.e2invoice = [Me2invoices objectAtIndex:newPath.section];
	
	//---------------------------------------------------------------
	// E6には.nRow は無いので、セクション(E2支払)間移動のために実装した。
	//---------------------------------------------------------------
	
	//-----------------------------------E2セクション間移動のとき、新旧sum項目の再集計
	if (oldPath.section != newPath.section) {
		// 旧 E2,E7 sum 更新
		E2invoice *e2obj = [Me2invoices objectAtIndex:oldPath.section];
		e2obj.sumNoCheck = [e2obj valueForKeyPath:@"e6parts.@sum.nNoCheck"];
		e2obj.sumAmount = [e2obj valueForKeyPath:@"e6parts.@sum.nAmount"];
		E7payment *e7obj = e2obj.e7payment;
		e7obj.sumNoCheck = [e7obj valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
		e7obj.sumAmount = [e7obj valueForKeyPath:@"e2invoices.@sum.sumAmount"];
		// 新 E2,E7 sum 更新
		e2obj = [Me2invoices objectAtIndex:newPath.section];
		e2obj.sumNoCheck = [e2obj valueForKeyPath:@"e6parts.@sum.nNoCheck"];
		e2obj.sumAmount = [e2obj valueForKeyPath:@"e6parts.@sum.nAmount"];
		e7obj = e2obj.e7payment;
		e7obj.sumNoCheck = [e7obj valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
		e7obj.sumAmount = [e7obj valueForKeyPath:@"e2invoices.@sum.sumAmount"];
		// E1 に影響は無いのでなにもしない
		// ここで再表示したいがreloadDataするとFreezeなので、editing:にて編集完了時にreloadしている
	}
	
	// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針である＞＞
	NSError *error = nil;
	if (![e6obj.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}


@end

