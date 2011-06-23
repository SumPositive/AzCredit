//
//  E8bankTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "E8bankTVC.h"
#import "E8bankDetailTVC.h"
#import "E2invoiceTVC.h"
#import "SettingTVC.h"
#import "WebSiteVC.h"

#define ACTIONSEET_TAG_DELETE	199

@interface E8bankTVC (PrivateMethods)
- (void)E8bankDatail:(NSIndexPath *)indexPath;
@end

@implementation E8bankTVC
@synthesize Re0root;
@synthesize Pe1card;


- (void)unloadRelease	// dealloc, viewDidUnload から呼び出される
{
	NSLog(@"--- unloadRelease --- E8bankTVC");
	[RaE8banks release], RaE8banks = nil;
}

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[self unloadRelease];
	//--------------------------------@property (retain)
	[Re0root release];
	[super dealloc];
}

#pragma mark View lifecycle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStylePlain]; // セクションなしテーブル
	if (self) {
		// 初期化成功
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
	[super loadView];
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
	MbuAdd = nil;		// ここ(loadView)で生成
	MbuTop = nil;		// ここ(loadView)で生成
	
	
	// Set up NEXT Left [Back] buttons.
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]
		   initWithImage:[UIImage imageNamed:@"Icon16-Return2.png"] // <<
		   style:UIBarButtonItemStylePlain  target:nil  action:nil] autorelease];

	if (Pe1card == nil) {
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		self.tableView.allowsSelectionDuringEditing = YES; // 編集モードに入ってる間にユーザがセルを選択できる
	}
	
	// Tool Bar Button
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	MbuAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																		   target:self action:@selector(barButtonAdd)];
	if (Pe1card) {  // !=nil:選択モード
		// 「未定」ボタン
		UIBarButtonItem *buUntitled = [[UIBarButtonItem alloc] 
									   initWithTitle:NSLocalizedString(@"Untitled",nil)
									   style:UIBarButtonItemStyleBordered
									   target:self action:@selector(barButtonUntitled)];
		NSArray *buArray = [NSArray arrayWithObjects: buUntitled, buFlex, MbuAdd, nil];
		[self setToolbarItems:buArray animated:YES];
		[buUntitled release];
	}
	else {
		MbuTop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-Top.png"]
												  style:UIBarButtonItemStylePlain  //Bordered
												 target:self action:@selector(barButtonTop)];
		NSArray *buArray = [NSArray arrayWithObjects: MbuTop, buFlex, MbuAdd, nil];
		[self setToolbarItems:buArray animated:YES];
		[MbuTop release];
	}
	[MbuAdd release];
	[buFlex release];
	// ToolBar表示は、viewWillAppearにて回転方向により制御している。
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	//[0.4]以降、ヨコでもツールバーを表示するようにした。
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	
	if (MbuTop) {
		// hasChanges時にTop戻りボタンを無効にする
		MbuTop.enabled = ![Re0root.managedObjectContext hasChanges]; // YES:contextに変更あり
		//MbuAdd.enabled = MbuTop.enabled;
	}
	
	// Me8banks Requery. 
	//--------------------------------------------------------------------------------
	// Sorting
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"nRow" ascending:YES];
	NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1, nil];
	[sort1 release];
	
	NSArray *arFetch = [MocFunctions select:@"E8bank" 
										limit:0
									   offset:0
										where:nil
										 sort:sortArray];
	[sortArray release];
	
	if (RaE8banks) {
		[RaE8banks release], RaE8banks = nil;
	}
	RaE8banks = [[NSMutableArray alloc] initWithArray:arFetch];
	
	// TableView Reflesh
	[self.tableView reloadData];

	if (0 < McontentOffsetDidSelect.y) {
		// app.Me3dateUse=nil のときや、メモリ不足発生時に元の位置に戻すための処理。
		// McontentOffsetDidSelect は、didSelectRowAtIndexPath にて記録している。
		self.tableView.contentOffset = McontentOffsetDidSelect;
	}
}


- (void)barButtonAdd {
	// Add Card
	[self E8bankDatail:nil]; // :(nil)Add mode
}

- (void)barButtonTop {
	[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
}

- (void)barButtonUntitled { // [未定]
	// 未定(nil)にする
	Pe1card.e8bank = nil; 
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

// 回転の許可　ここでは許可、禁止の判定だけする
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	// 回転禁止でも、正面は常に許可しておくこと。
	return !MbOptAntirotation OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる

/*	if (Pe1card == nil) {
		// Comback (-1)にして未選択状態にする
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		// (0)TopMenu >> (1)This clear
		[appDelegate.RaComebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:-1]];
	}*/
}
/*
// カムバック処理（復帰再現）：親から呼ばれる
- (void)viewComeback:(NSArray *)selectionArray
{
	// (0)TopMenu >> (1)This
	NSInteger lRow = [[selectionArray objectAtIndex:1] integerValue];
	if (lRow < 0) return; // この画面表示
	
	NSInteger lSec = lRow / GD_SECTION_TIMES;
	if (1 <= lSec) return; // 無効セクション
	
	lRow -= (lSec * GD_SECTION_TIMES);
	if ([RaE8banks count] <= lRow) return; // 無効セル（削除されたとか）

	// 次、 E3recordTVC だが、これ以上戻しても見難いだけなので、ここまでで止めることにした。
	// 前回選択行を画面中央にする。
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lRow inSection:lSec];
	[self.tableView scrollToRowAtIndexPath:indexPath 
						  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
}
*/

#pragma mark Local methods


// ディスクロージャボタンが押されたときの処理
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self E8bankDatail:indexPath];
}

- (void)E8bankDatail:(NSIndexPath *)indexPath
{
	E8bankDetailTVC *e8detail = [[E8bankDetailTVC alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	
	if (indexPath == nil) {
		E8bank *e8obj = [NSEntityDescription insertNewObjectForEntityForName:@"E8bank"
														inManagedObjectContext:Re0root.managedObjectContext];
		// Add
		e8detail.title = NSLocalizedString(@"Add Bank",nil);
		e8detail.PiAddRow = [RaE8banks count]; // 追加モード
		e8detail.Re8edit = e8obj;
		e8detail.Pe1edit = Pe1card; // 新規追加後、一気にE1まで戻るため
	} 
	else {
		if ([RaE8banks count] <= indexPath.row) {
			[e8detail release];
			return;  // Addボタン行などの場合パスする
		}
		e8detail.title = NSLocalizedString(@"Edit Bank",nil);
		e8detail.PiAddRow = (-1); // 修正モード
		e8detail.Re8edit = [RaE8banks objectAtIndex:indexPath.row]; //[MfetchE8bank objectAtIndexPath:indexPath];
	}
	
	if (Pe1card) {
		e8detail.PbSave = NO;	// 呼び出し元：E1cardDetailTVC側のsave:により保存
	} else {
		e8detail.PbSave = YES;	// マスタモード：
	}

	// 呼び出し側(親)にてツールバーを常に非表示にする
	e8detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする

	[self.navigationController pushViewController:e8detail animated:YES];
	[e8detail release]; // self.navigationControllerがOwnerになる
}

// UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// buttonIndexは、actionSheetの上から順に(0〜)付与されるようだ。
	if (actionSheet.tag == ACTIONSEET_TAG_DELETE && buttonIndex == 0) {
		//========== E1 削除実行 ==========
		// ＜注意＞ CoreDataモデルは、エンティティ間の削除ルールは双方「無効にする」を指定。（他にするとフリーズ）
		E8bank *e8objDelete = [RaE8banks objectAtIndex:MindexPathActionDelete.row];
		// E8bank 削除
		[RaE8banks removeObjectAtIndex:MindexPathActionDelete.row];
		[Re0root.managedObjectContext deleteObject:e8objDelete];
		// 削除行の次の行以下 E8.row 更新
		for (NSInteger i= MindexPathActionDelete.row + 1 ; i < [RaE8banks count] ; i++) 
		{  // .nRow + 1 削除行の次から
			E8bank *e8obj = [RaE8banks objectAtIndex:i];
			e8obj.nRow = [NSNumber numberWithInteger:i-1];     // .nRow--; とする
		}
		// Commit
		// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針＞＞
		/*NSError *error = nil;
		if (![Re0root.managedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}*/
		[MocFunctions commit];
		[self.tableView reloadData];
	}
}


#pragma mark TableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1; // 固定
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (MbuAdd.enabled) {
		return [RaE8banks count] + 1; // (+1)Add
	}
	return [RaE8banks count]; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *zCellCard = @"CellCard";
	static NSString *zCellAdd = @"CellAdd";
    UITableViewCell *cell = nil;

	NSInteger rows = [RaE8banks count] - indexPath.row;
	if (0 < rows) {
		// E8bank セル
		cell = [tableView dequeueReusableCellWithIdentifier:zCellCard];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] 
					 initWithStyle:UITableViewCellStyleValue1
					 reuseIdentifier:zCellCard] autorelease];

#ifdef AzPAD
			cell.textLabel.font = [UIFont systemFontOfSize:20];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
#else
			cell.textLabel.font = [UIFont systemFontOfSize:18];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
#endif

			cell.textLabel.textAlignment = UITextAlignmentLeft;
			cell.textLabel.textColor = [UIColor blackColor];
			
			cell.detailTextLabel.textAlignment = UITextAlignmentRight;
			cell.detailTextLabel.textColor = [UIColor blackColor];
		}
		
		E8bank *e8obj = [RaE8banks objectAtIndex:indexPath.row]; //[MfetchE8bank objectAtIndexPath:indexPath];
		
#ifdef AzDEBUG
		if ([e8obj.zName length] <= 0) 
			cell.textLabel.text = [NSString stringWithFormat:@"%ld) %@", 
								   (long)[e8obj.nRow integerValue], NSLocalizedString(@"(Untitled)", nil)];
		else
			cell.textLabel.text = [NSString stringWithFormat:@"%ld) %@", 
								   (long)[e8obj.nRow integerValue], e8obj.zName];
#else
		if ([e8obj.zName length] <= 0) 
			cell.textLabel.text = NSLocalizedString(@"(Untitled)", nil);
		else
			cell.textLabel.text = e8obj.zName;
#endif
		// 未払い金額
		//NSNumber *sumAmount = [e8obj valueForKeyPath:@"e1cards.@sum.e2unpaids.@sum.sumAmount"];
		NSDecimalNumber *sumAmount = [e8obj valueForKeyPath:@"e1cards.@sum.e2unpaids.@sum.sumAmount"];
		if ([sumAmount compare:[NSDecimalNumber zero]] == NSOrderedDescending)	// e7obj.sumAmount > 0
		{
			cell.detailTextLabel.textColor = [UIColor blackColor];
		} else {
			cell.detailTextLabel.textColor = [UIColor blueColor];
		}
		// Amount JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[formatter setLocale:[NSLocale currentLocale]]; 
		cell.detailTextLabel.text = [formatter stringFromNumber:sumAmount];
		[formatter release];
		
		if (Pe1card == nil) {
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; // ディスクロージャボタン
			cell.showsReorderControl = YES;		// Move有効
		}
	} 
	else {
		// Add ボタンセル
		cell = [tableView dequeueReusableCellWithIdentifier:zCellAdd];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault      // Default型
										   reuseIdentifier:zCellAdd] autorelease];
		}
#ifdef AzPAD
		cell.textLabel.font = [UIFont systemFontOfSize:20];
#else
		cell.textLabel.font = [UIFont systemFontOfSize:14];
#endif
		cell.textLabel.textAlignment = UITextAlignmentCenter; // 中央寄せ
		cell.textLabel.textColor = [UIColor blackColor];
		cell.imageView.image = [UIImage imageNamed:@"Icon32-GreenPlus.png"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
		cell.showsReorderControl = NO;
		if (rows == 0) {
			cell.textLabel.text = NSLocalizedString(@"Add Bank",nil);
		} else {
			cell.textLabel.text = @"Err";
		}
	}
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger rows = [RaE8banks count] - indexPath.row;
	if (0 < rows) {
		return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 非選択状態に戻す

	// didSelect時のScrollView位置を記録する（viewWillAppearにて再現するため）
	McontentOffsetDidSelect = [tableView contentOffset];

	if (indexPath.row < [RaE8banks count]) {
		if (Pe1card) {
			// 選択モード
			Pe1card.e8bank = [RaE8banks objectAtIndex:indexPath.row]; 
			[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
		}
		else if (self.editing) {
			[self E8bankDatail:indexPath];
		} 
		else {
/*			// Comback-L1 E8bank 記録
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			long lPos = indexPath.section * GD_SECTION_TIMES + indexPath.row;
			// (0)TopMenu >> (1)This
			[appDelegate.RaComebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:lPos]];
			[appDelegate.RaComebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
*/			
			// E2invoice へ
			E8bank *e8obj = [RaE8banks objectAtIndex:indexPath.row];
			E2invoiceTVC *tvc = [[E2invoiceTVC alloc] init];
#ifdef AzDEBUG
			tvc.title = [NSString stringWithFormat:@"E2 %@", e8obj.zName];
#else
			tvc.title = e8obj.zName;
#endif
			tvc.Re1select = nil;
			tvc.Re8select = e8obj;
			[self.navigationController pushViewController:tvc animated:YES];
			[tvc release];
		}
	}
	else {
		// Add Plan
		[self E8bankDatail:nil]; // :nil = Add mode
	}
}

// TableView Editモードの表示
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
    // この後、self.editing = YES になっている。
	// [self.tableView reloadData]だとアニメ効果が消される。　(OS 3.0 Function)を使って解決した。
//	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)]; // [0]セクションから1個
//	[self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade]; // (OS 3.0 Function)
}

// TableView Editモード処理
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
											forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		// 削除コマンド警告　==>> (void)actionSheet にて処理
		MindexPathActionDelete = indexPath;
		// 削除コマンド警告
		UIActionSheet *action = [[UIActionSheet alloc] 
								 initWithTitle:NSLocalizedString(@"DELETE Bank", nil)
								 delegate:self 
								 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
								 destructiveButtonTitle:NSLocalizedString(@"DELETE Bank button", nil)
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

/*
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// スワイプにより1行だけが編集モードに入るときに呼ばれる。
	// このオーバーライドにより、setEditting が呼び出されないようにしている。 Add行を出さないため
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// スワイプにより1行だけが編集モードに入り、それが解除されるときに呼ばれる。
	// このオーバーライドにより、setEditting が呼び出されないようにしている。 Add行を出さないため
}
*/

// Editモード時の行Edit可否　　 YESを返した行は、左にスペースが入って右寄りになる
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [RaE8banks count]) return YES;
	return NO;  // 最終行のAdd行は、右寄せさせない
}

// Editモード時の行移動の可否　　＜＜最終行のAdd専用行を移動禁止にしている＞＞
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.row < [RaE8banks count]) return YES;
	return NO;  // 最終行のAdd行は移動禁止
}

// Editモード時の行移動「先」を返す　　＜＜最終行のAdd専用行への移動ならば1つ前の行を返している＞＞
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)oldPath 
															toProposedIndexPath:(NSIndexPath *)newPath {
    NSIndexPath *target = newPath;
    // Add行が異動先になった場合、その1つ前の通常行を返すことにより、Add行への移動禁止となる。
	NSInteger rows = [RaE8banks count] - 1; // 移動可能な行数（Add行を除く）
	// セクション０限定仕様
	if (newPath.section != 0 || rows < newPath.row  ) {
        target = [NSIndexPath indexPathForRow:rows inSection:0];
    }
    return target;
}

// Editモード時の行移動処理　　＜＜CoreDataにつきArrayのように削除＆挿入ではダメ。ソート属性(row)を書き換えることにより並べ替えている＞＞
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)oldPath 
												  toIndexPath:(NSIndexPath *)newPath {
	// CoreDataは順序を保持しないため 属性"ascend"を昇順ソート表示している
	// この 属性"ascend"の値を行異動後に更新するための処理

	// RE8banks 更新 ==>> なんと、managedObjectContextも更新される。 ただし、削除や挿入は反映されない！！！
	E8bank *e8obj = [RaE8banks objectAtIndex:oldPath.row]; //[MfetchE8bank objectAtIndexPath:oldPath];

	[RaE8banks removeObjectAtIndex:oldPath.row];
	[RaE8banks insertObject:e8obj atIndex:newPath.row];
	
	NSInteger start = oldPath.row;
	NSInteger end = newPath.row;
	if (end < start) {
		start = newPath.row;
		end = oldPath.row;
	}
	for (NSInteger i = start; i <= end; i++) {
		e8obj = [RaE8banks objectAtIndex:i];
		e8obj.nRow = [NSNumber numberWithInteger:i];
	}
	
	// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針＞＞
	/*NSError *error = nil;
	if (![Re0root.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}*/
	[MocFunctions commit];
}

@end

