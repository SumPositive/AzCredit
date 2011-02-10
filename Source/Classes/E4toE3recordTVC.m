//
//  E4toE3recordTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "E4toE3recordTVC.h"
#import "E3recordDetailTVC.h"

#define ACTIONSEET_TAG_DELETE	199

@interface E4toE3recordTVC (PrivateMethods)
- (void)e3detailView:(NSIndexPath *)indexPath;
- (void)cellButton: (UIButton *)button;
@end

@implementation E4toE3recordTVC
@synthesize Pe4shop;

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[Me3list release];
//	[Me2list release];
	
	// @property (retain)
	
	[super dealloc];
}

- (void)viewDidUnload 
{
	// メモリ不足時、裏側にある場合に呼び出されるので、Private Allocで生成したObjを解放する。
	[Me3list release];		Me3list = nil;
//	[Me2list release];		Me2list = nil;
	
	// @property (retain) は解放しない。
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"viewDidUnload" 
													 message:@"E4toE3recordTVC" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"didReceiveMemoryWarning" 
													 message:@"E4toE3recordTVC" 
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
		MbForTheFirstTime = YES;  // viewWillAppearにてMe2list Reload時にセット
	}
	return self;
}

// viewDidLoadメソッドは，TableViewContorllerオブジェクトが生成された後，実際に表示される際に呼び出されるメソッド
- (void)viewDidLoad 
{
    [super viewDidLoad];
	Me3list = nil;
//	Me2list = nil;
	

	// ここは、alloc直後に呼ばれるため、下記のようなパラは未セット状態である。==>> viewWillAppearで参照すること

/*	// Set up NEXT Left [Back] buttons.
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]
									   initWithImage:[UIImage imageNamed:@"simpleLeft3-icon16.png"]
									   style:UIBarButtonItemStylePlain  target:nil  action:nil];
	self.navigationItem.backBarButtonItem = backButtonItem;
	[backButtonItem release];		
*/
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.allowsSelectionDuringEditing = YES; // 編集モードに入ってる間にユーザがセルを選択できる
	
/*	// CANCELボタンを左側に追加する  Navi標準の戻るボタンでは cancel:処理ができないため
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
											  target:self action:@selector(cancel:)] autorelease];
	// SAVEボタンを右側に追加する
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
											   target:self action:@selector(save:)] autorelease];
*/
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:YES];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptShouldAutorotate = [defaults boolForKey:GD_OptShouldAutorotate];
	
	//没 AzPackingのE3同様に、全E2セクション表示かつ全E3表示　＜没：E2支払済みが大量になる危険性および必要性が低く複雑になりすぎるため没＞
	//以上から、Pe2selectの前後1ノード計3ノードだけで十分と判断した。

	// Me3list : Me2listに含まれるE2セクション以下の全E3
	//----------------------------------------------------------------------------CoreData Loading
	//---------------------------------Me3list 生成
	if (Me3list == nil) {
		Me3list = [[NSMutableArray alloc] init];
	} else {
		[Me3list removeAllObjects]; // 全要素削除
	}
	// E3 Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"dateUse" ascending:YES];
	NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
	
	// 選択された E4(Pe4shop) の子となる E3(Pe4shop.e3records) を抽出する。
	NSMutableArray *muSection = [[NSMutableArray alloc] initWithArray:[Pe4shop.e3records allObjects]];
	[muSection sortUsingDescriptors:sortArray];
	[Me3list addObject:muSection];  // 二次元追加　addObjectsFromArray:にすると同次元になってしまう。
	[muSection release];
	[sortArray release];
	[sort1 release];
	
	// テーブルビューを更新します。
    [self.tableView reloadData];
}

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// 回転禁止でも万一ヨコからはじまった場合、タテにはなるようにしてある。
	return MbOptShouldAutorotate OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる

	// Comback-L2 (-1)にして未選択状態にする
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
	
	if (MbForTheFirstTime) {
		// 最終行を表示する
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[Me3list count]-1 inSection:0];
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
		MbForTheFirstTime = NO;  // 二度と通らないようにするため
	}
}

// カムバック処理（復帰再現）：親から呼ばれる
- (void)viewComeback:(NSArray *)selectionArray
{
	//----------------------------------------L3
	long lRow = [[selectionArray objectAtIndex:3] longValue];
	if (lRow < 0) return; // この画面に留まる
	long lSec = lRow / GD_SECTION_TIMES;
	lRow -= (lSec * GD_SECTION_TIMES);

	if (0 < lSec) return;
	if ([Me3list count] <= lRow) return; // row OVER（Addや削除されたとか）
	
	// 選択行を画面中央付近に表示する
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lRow inSection:lSec];
	[self.tableView scrollToRowAtIndexPath:indexPath 
						  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
	
	// ドリルダウン
	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init];
	e3detail.title = self.title;
	// Edit Item
	e3detail.Pe3own = [[Me3list objectAtIndex:lSec] objectAtIndex:lRow];
	e3detail.PbAdd = NO;
	e3detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:NO];
	// 末尾につき viewComeback なし
	[e3detail release];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;  // Me3listは、[E2invoices]×[E3records] の二次元配列
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [Me3list count] + 1;  // (+1)Add行
}

static long addYearMM( long lYearMM, long lMonth )
{
	long lYear = lYearMM / 100;
	long lMM = lYearMM - (lYear * 100);
	lMM += lMonth;
	lYear += (lMM / 12);
	lMM = lMM - ((lMM / 12) * 12);
	return lYear * 100 + lMM;
}


// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if ([Me3list count] <= indexPath.row) {
		return 33; // Add Record
	}
	return 44; // デフォルト：44ピクセル
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *zCellE3record = @"CellE3record";
    static NSString *zCellAdd = @"CellAdd";
	UITableViewCell *cell = nil;

	if (indexPath.row < [[Me3list objectAtIndex:indexPath.section] count]) 
	{
		cell = [tableView dequeueReusableCellWithIdentifier:zCellE3record];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
											reuseIdentifier:zCellE3record] autorelease];
			// 行毎に変化の無い定義は、ここで最初に1度だけする
			cell.textLabel.font = [UIFont systemFontOfSize:14];
			//cell.textLabel.textAlignment = UITextAlignmentLeft;
			//cell.textLabel.textColor = [UIColor blackColor];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
			cell.detailTextLabel.textAlignment = UITextAlignmentRight;
			cell.detailTextLabel.textColor = [UIColor blackColor];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // ＞
			cell.showsReorderControl = YES; // Move可能
		}
		
		// 左ボタン ------------------------------------------------------------------
		UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom]; // autorelease
		bu.frame = CGRectMake(0,0, 44,44);
		bu.tag = indexPath.section * GD_SECTION_TIMES + indexPath.row;
		[bu addTarget:self action:@selector(cellButton:) forControlEvents:UIControlEventTouchUpInside];
		bu.backgroundColor = [UIColor clearColor]; //背景透明
		bu.showsTouchWhenHighlighted = YES;
		[cell.contentView addSubview:bu];
		//[bu release]; buttonWithTypeにてautoreleseされるため不要。UIButtonにinitは無い。

		E3record *e3obj = [[Me3list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		
		if ([e3obj.nNoCheck intValue] == 1) {
			cell.imageView.image = [UIImage imageNamed:@"Check32-Circle.png"];
		} else {
			cell.imageView.image = [UIImage imageNamed:@"Check32-Ok.png"];
		}
		
		// zDate 利用日
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setLocale:[NSLocale systemLocale]];
		[df setDateFormat:NSLocalizedString(@"E3listDate",nil)];
		NSString *zDate = [df stringFromDate:e3obj.dateUse];
		[df release];
		if (e3obj.zName != nil) {
			cell.textLabel.text = [NSString stringWithFormat:@"%@　%@", zDate, e3obj.zName];
		} else {
			cell.textLabel.text = zDate;
		}
		
		// 金額
		// Amount JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle]; // 通貨スタイル
		NSLocale *localeJP = [[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"];
		[formatter setLocale:localeJP];
		[localeJP release];
		NSString *zAmount = [formatter stringFromNumber:e3obj.nAmount];
		[formatter release];
		// zShop 店舗名
		if (e3obj.e4shop != nil) {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", e3obj.e4shop.zName, zAmount];
		} else {
			cell.detailTextLabel.text = zAmount;
		}
	}
	else {
		// [Add行]セル
		cell = [tableView dequeueReusableCellWithIdentifier:zCellAdd];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault      // Default型
										   reuseIdentifier:zCellAdd] autorelease];
		}
		cell.textLabel.text = NSLocalizedString(@"Add Record",nil);
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
//	if (MbAzOptCheckingAtEditMode && !self.editing) return; // 編集時のみ許可
	
/*	E3record *e3obj = nil;
	// 現在表示されているセル群
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *path in visiblePaths) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
		if (cell.imageView.image != nil) { // Add行を除外するため
			NSArray *aSub = [NSArray arrayWithArray:cell.contentView.subviews];
			//if (button == [aSub objectAtIndex:1]) {
			if ([aSub indexOfObject:button] != NSNotFound) { // 位置が変わるケースがあったので、こうした。
				//このbuttonが含まれるセル発見
				e3obj = [[Me3array objectAtIndex:path.section] objectAtIndex:path.row];
				//AzLOG(@"cellButton -B- .row=%ld", (long)path.row);
				break;
			}
		}
	}
	if (e3obj == nil) return;
	if (e3obj.need <= 0) return;
	//AzLOG(@"cellButton -B- e3obj.row=%ld", (long)[e3obj.row integerValue]);
	
	NSInteger lStock  = [e3obj.stock integerValue];
	NSInteger lNeed   = [e3obj.need integerValue];
	NSInteger lWeight = [e3obj.weight integerValue];
	
	if (lStock < lNeed) {
		// OK
		//iStock++;		カウントアップは没。　将来的にはOption設定にするかも
		lStock = lNeed; // ワンタッチＯＫにした。
	} else {
		// Non
		lStock = 0;
	}
	
	if (lStock == [e3obj.stock integerValue] && lNeed == [e3obj.need integerValue]) return; //変化なし
	
	// ここで、Stock は Need 以下にしかならないからオーバーチェックは不要のはず。
	// しかし、今後の変更でNeedを超えるようになったとき忘れないように入れておく。
	//[0.2c]プラン総重量制限
	if (0 < lWeight) {  // longオーバーする可能性があるため商は求めない
		if (AzMAX_PLAN_WEIGHT / lWeight < lStock OR AzMAX_PLAN_WEIGHT / lWeight < lNeed) {
			[self alertWeightOver];
			return;
		}
	}
	
	// SAVE ----------------------------------------------------------------------
	[e3obj setValue:[NSNumber numberWithInteger:(lStock)] forKey:@"stock"];
	[e3obj setValue:[NSNumber numberWithInteger:(lNeed)] forKey:@"need"];
	
	[e3obj setValue:[NSNumber numberWithInteger:(lWeight*lStock)] forKey:@"weightStk"];
	[e3obj setValue:[NSNumber numberWithInteger:(lWeight*lNeed)] forKey:@"weightNed"];
	[e3obj setValue:[NSNumber numberWithInteger:(lNeed-lStock)] forKey:@"lack"]; // 不足数
	[e3obj setValue:[NSNumber numberWithInteger:(lWeight*(lNeed-lStock))] forKey:@"weightLack"]; // 不足重量
	
	NSInteger iNoGray = 0;
	if (0 < lNeed) iNoGray = 1;
	[e3obj setValue:[NSNumber numberWithInteger:iNoGray] forKey:@"noGray"]; // 有効(0<必要)アイテム
	
	NSInteger iNoCheck = 0;
	if (0 < lNeed && lStock < lNeed) iNoCheck = 1;
	[e3obj setValue:[NSNumber numberWithInteger:iNoCheck] forKey:@"noCheck"]; // 不足アイテム
	
	// E2 sum属性　＜高速化＞ 親sum保持させる
	E2 *e2obj = e3obj.parent;
	[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.noGray"] forKey:@"sumNoGray"];
	[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.noCheck"] forKey:@"sumNoCheck"];
	[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.weightStk"] forKey:@"sumWeightStk"];
	[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.weightNed"] forKey:@"sumWeightNed"];
	
	// E1 sum属性　＜高速化＞ 親sum保持させる
	E1 *e1obj = e2obj.parent;
	[e1obj setValue:[e1obj valueForKeyPath:@"childs.@sum.sumNoGray"] forKey:@"sumNoGray"];
	[e1obj setValue:[e1obj valueForKeyPath:@"childs.@sum.sumNoCheck"] forKey:@"sumNoCheck"];
	NSNumber *sumWeStk = [e1obj valueForKeyPath:@"childs.@sum.sumWeightStk"];
	NSNumber *sumWeNed = [e1obj valueForKeyPath:@"childs.@sum.sumWeightNed"];
	//[0.2c]プラン総重量制限
	if (AzMAX_PLAN_WEIGHT < [sumWeStk integerValue] OR AzMAX_PLAN_WEIGHT < [sumWeNed integerValue]) {
		[self alertWeightOver];
		return;
	}
	[e1obj setValue:sumWeStk forKey:@"sumWeightStk"];
	[e1obj setValue:sumWeNed forKey:@"sumWeightNed"];
	
	// SAVE : e3edit,e2list は ManagedObject だから更新すれば ManagedObjectContext に反映されている
	NSError *err = nil;
	if (![e3obj.managedObjectContext save:&err]) {
		NSLog(@"Unresolved error %@, %@", err, [err userInfo]);
		abort();
	}
*/	
	[self.tableView reloadData];
}

// TableView Editボタンスタイル
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.row < [[Me3list objectAtIndex:indexPath.section] count]) {
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleInsert;
}

// TableView 行選択時の動作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

	if (indexPath.row < [[Me3list objectAtIndex:indexPath.section] count]) 
	{
		// Comback-L2 記録
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		long lPos = indexPath.section * GD_SECTION_TIMES + indexPath.row;
		//											   L0 TopMenu記録済み
		//											   L1 E4shop 記録済み
		[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:lPos]];
		[appDelegate.comebackIndex replaceObjectAtIndex:3 withObject:[NSNumber numberWithLong:-1]];
	}
	// E3詳細画面へ
	[self e3detailView:indexPath]; // この中でAddにも対応
}

- (void)e3detailView:(NSIndexPath *)indexPath 
{
	// ドリルダウン
	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init];
	// 以下は、E3detailTVCの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
	e3detail.title = self.title;  // NSLocalizedString(@"Items", nil);
	if (indexPath.row < [[Me3list objectAtIndex:indexPath.section] count]) {
		// Edit Item
		e3detail.Pe3own = [[Me3list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		e3detail.PbAdd = NO;
	}
	else {
		// Add E3
		E3record *e3obj = [NSEntityDescription insertNewObjectForEntityForName:@"E3record"
														   inManagedObjectContext:Pe4shop.managedObjectContext];
		//e3obj.e1card = nil;
		//e3obj.e2invoice = nil;
		//e3obj.e4shop = Pe4shop;
		//e3obj.e5category = nil;
		// Args
		e3detail.Pe3own = e3obj;
		e3detail.PbAdd = YES; // Add mode
	}
	e3detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:YES];
	[e3detail release];
}

// TableView Editモード処理
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
											forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		// 削除コマンド警告　==>> (void)actionSheet にて処理
		MindexPathActionDelete = indexPath;
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
	
	// セクションタイトルの再描画が必要なため
	[self.tableView reloadData];

}

// UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet.tag == ACTIONSEET_TAG_DELETE) { // E3アイテム削除
		if (buttonIndex != actionSheet.destructiveButtonIndex) return;
		if (Pe4shop == nil) return;
		//========== E3 削除実行 ==========
		// CoreDataモデル：エンティティ間の削除ルールは双方「無効にする」を指定。（他にするとフリーズ）
		// 削除対象の ManagedObject をチョイス
		E3record *e3objDelete = [Me3list objectAtIndex:MindexPathActionDelete.row];
		// 該当行削除：　e3list 削除 ==>> しかし、managedObjectContextは削除されない！！！後ほど削除
		[Me3list removeObjectAtIndex:MindexPathActionDelete.row];
		// E3record.nRownなし
		// e3listの削除はmanagedObjectContextに反映されないため、ここで削除する。
		[Pe4shop.managedObjectContext deleteObject:e3objDelete];
		// E2 sum　＜高速化＞ 親sum保持させる
		E2invoice *e2obj = e3objDelete.e2invoice;
		e2obj.sumNoCheck = [e2obj valueForKeyPath:@"e3records.@sum.nNoCheck"];
		e2obj.sumAmount = [e2obj valueForKeyPath:@"e3records.@sum.nAmount"];
		// E1 sum
		E1card *e1obj = e2obj.e1card;
		e1obj.sumNoCheck = [e1obj valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
		// Paid,Unpaidを求める
		long lPaid = 0;
		long lUnpaid = 0;
		for (E2invoice *e2obj in e1obj.e2invoices) {
			if (e2obj.bPaid) {
				lPaid += [e2obj.sumAmount longValue];
			} else {
				lUnpaid += [e2obj.sumAmount longValue];
			}
		}
		e1obj.sumPaid = [NSNumber numberWithLong:lPaid];
		e1obj.sumUnpaid = [NSNumber numberWithLong:lUnpaid];
		
		// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針＞＞
		NSError *error = nil;
		if (![Pe4shop.managedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		// テーブルビューから選択した行を削除します。
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:MindexPathActionDelete] 
							  withRowAnimation:UITableViewRowAnimationFade];
	}
}

// Editモード時の行Edit可否
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES; // 行編集許可
}


@end

