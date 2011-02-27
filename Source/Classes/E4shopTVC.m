//
//  E4shopTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "E4shopTVC.h"
#import "E4shopDetailTVC.h"
#import "E3recordTVC.h"


#define ACTIONSEET_TAG_DELETE_SHOP	199

@interface E4shopTVC (PrivateMethods)
- (void)e4shopDatail:(NSInteger)iE4index;
- (void)barButtonAdd;
- (void)requeryMe4shops:(NSString *)zSearch;
- (void)viewDesign;
@end

@implementation E4shopTVC
@synthesize Re0root;
@synthesize Pe3edit;

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	AzRETAIN_CHECK(@"TopMenuTVC RaE4shops", RaE4shops, 0)
	[RaE4shops release];
	
	// @property (retain)
	AzRETAIN_CHECK(@"TopMenuTVC Re0root", Re0root, 0)
	[Re0root release];
    
	[super dealloc];
}


#pragma mark View lifecycle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStylePlain]) {  // セクションなしテーブル
		// 初期化成功
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
    [super loadView];
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
	MbuTop = nil;		// ここ(loadView)で生成
	
	// Set up NEXT Left [Back] buttons.
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithImage:[UIImage imageNamed:@"Icon16-Return2.png"] // <<
											  style:UIBarButtonItemStylePlain  
											  target:nil  action:nil] autorelease];

	if (Pe3edit == nil) {
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		self.tableView.allowsSelectionDuringEditing = YES; // 編集モードに入ってる間にユーザがセルを選択できる
	}
	
	// Search Bar
	UISearchBar *searchBar = [[[UISearchBar alloc] init] autorelease];
	searchBar.frame = CGRectMake(0,0, self.tableView.bounds.size.width,0);
	searchBar.showsCancelButton = YES;
	searchBar.delegate = self;
	[searchBar sizeToFit];
	self.tableView.tableHeaderView = searchBar;
	
	// Search segmented
	NSArray *aItems = [[NSArray alloc] initWithObjects:
					   NSLocalizedString(@"Sort Recent",nil),
					   NSLocalizedString(@"Sort Views",nil),
					   NSLocalizedString(@"Sort Amount",nil),
					   NSLocalizedString(@"Sort Index",nil), nil];
	UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:aItems];
	segment.frame = CGRectMake(0,0, 210,30);
	segment.segmentedControlStyle = UISegmentedControlStyleBar;
	MiOptE4SortMode = 0; //[[NSUserDefaults standardUserDefaults] integerForKey:GD_OptE4SortMode];
	segment.selectedSegmentIndex = MiOptE4SortMode;
	// .selectedSegmentIndex 代入より後に addTarget:指定すること。 逆になると代入によりaction:コールされてしまう。
	[segment addTarget:self action:@selector(barSegmentSort:) forControlEvents:UIControlEventValueChanged];
	UIBarButtonItem *buSort = [[UIBarButtonItem alloc] initWithCustomView:segment];
	[segment release];
	[aItems release];
	
	// Tool Bar Button
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	UIBarButtonItem *buAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
															 target:self action:@selector(barButtonAdd)];
	if (Pe3edit) {
		MbuTop = nil;
		UIBarButtonItem *buUntitled = [[UIBarButtonItem alloc] 
									   initWithTitle:NSLocalizedString(@"Untitled",nil)
									   style:UIBarButtonItemStyleBordered
									   target:self action:@selector(barButtonUntitled)];
		NSArray *buArray = [NSArray arrayWithObjects: buUntitled, buFlex, buSort, buFlex, buAdd, nil];
		[self setToolbarItems:buArray animated:YES];
		[buUntitled release];
	}
	else {
		MbuTop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-Top.png"]
												  style:UIBarButtonItemStylePlain  //Bordered
												 target:self action:@selector(barButtonTop)];
		NSArray *buArray = [NSArray arrayWithObjects: MbuTop, buFlex, buSort, buFlex, buAdd, nil];
		[self setToolbarItems:buArray animated:YES];
		[MbuTop release];
	}
	[buAdd release];
	[buFlex release];
	[buSort release];
	
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
	}
	
	// Requery
	[self requeryMe4shops:nil];

	if (0 < McontentOffsetDidSelect.y) {
		// app.Me3dateUse=nil のときや、メモリ不足発生時に元の位置に戻すための処理。
		// McontentOffsetDidSelect は、didSelectRowAtIndexPath にて記録している。
		self.tableView.contentOffset = McontentOffsetDidSelect;
	}
}


- (void)requeryMe4shops:(NSString *)zSearch 
{	// Me4shops Requery. 

	// Where
	NSPredicate *predicate = nil;
	if (zSearch && 0 < [zSearch length]) {  // NSPredicateを使って、検索条件式を設定する
		predicate = [NSPredicate predicateWithFormat:
					 @"(sortName contains %@) OR (zName contains %@)", zSearch, zSearch];
	}
	
	// Sorting
	NSString *zKey;
	BOOL bAsc;
	switch (MiOptE4SortMode) {
		case 1:  zKey = @"sortCount";	bAsc = NO;	break; // 回数
		case 2:  zKey = @"sortAmount";	bAsc = NO;	break; // 金額
		case 3:  zKey = @"sortName";	bAsc = YES;	break; // かな　＜＜入力が面倒で使われない可能性が高いと思うから優先度を下げた＞＞
		default: zKey = @"sortDate";	bAsc = NO;	break; // 最近
	}
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:zKey ascending:bAsc];
	NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1, nil];
	[sort1 release];
	
	NSArray *arFetch = [MocFunctions select:@"E4shop" 
										limit:0
									   offset:0
										where:predicate
										 sort:sortArray];
	[sortArray release];
	//
	if (RaE4shops) {
		[RaE4shops release];
	}
	RaE4shops = [[NSMutableArray alloc] initWithArray:arFetch];
	// 
	[self viewDesign];
	[self.tableView reloadData];
}

// 検索バーへの文字入力の都度、呼び出される
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{
	// Requery
	[self requeryMe4shops:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	searchBar.text = @"";
	[searchBar resignFirstResponder]; // キーボードを非表示にする
}

- (void)barButtonTop {
	[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
}

- (void)barButtonAdd {
	// Add Shop
	[self e4shopDatail:(-1)]; // :(-1)Add mode
}

- (void)barButtonUntitled {
	// 未定(nil)にする
	Pe3edit.e4shop = nil; 
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

- (void)barSegmentSort:(id)sender {
	MiOptE4SortMode = [sender selectedSegmentIndex];
	// ソート条件を保存する　＜＜切り替えの都度、保存していたが[0.4]にてフリーズ症状発生＞＞
	//[[NSUserDefaults standardUserDefaults] setInteger:MiOptE4SortMode forKey:GD_OptE4SortMode];
	// Requery
	[self requeryMe4shops:nil];
}


// 回転の許可　ここでは許可、禁止の判定だけする
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	// 回転禁止でも、正面は常に許可しておくこと。
	return !MbOptAntirotation OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	[self viewDesign];
}

- (void)viewDesign
{
	// 回転によるリサイズ
	// SerchBar
	self.tableView.tableHeaderView.frame = CGRectMake(0,0, self.tableView.bounds.size.width,0);
	[self.tableView.tableHeaderView sizeToFit];
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる

	if (Pe3edit == nil) {
		// Comback (-1)にして未選択状態にする
//		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		// (0)TopMenu >> (1)This clear
//		[appDelegate.RaComebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:-1]];
	}
}
/*
// この画面が非表示になる直前（次の画面が表示される前）に呼ばれる
- (void)viewWillDisappear:(BOOL)animated
{
}
*/
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
	if ([RaE4shops count] <= lRow) return; // 無効セル（削除されたとか）

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
	[self e4shopDatail:indexPath.row];
}

- (void)e4shopDatail:(NSInteger)iE4index
{
	E4shopDetailTVC *e4detail = [[E4shopDetailTVC alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	
	if (iE4index < 0) {
		// Add
		e4detail.title = NSLocalizedString(@"Add Shop",nil);
		// ContextにE4ノードを追加する　E4edit内でCANCELならば DELETE している
		e4detail.Re4edit = [NSEntityDescription insertNewObjectForEntityForName:@"E4shop"
											  inManagedObjectContext:Re0root.managedObjectContext];
		e4detail.PbAdd = YES;
		e4detail.Pe3edit = Pe3edit; // 新規追加後、一気にE3まで戻るため
	}
	else if ([RaE4shops count] <= iE4index) {
		[e4detail release];
		return; // Add行以降、パスする
	}
	else {
		e4detail.title = NSLocalizedString(@"Edit Shop",nil);
		e4detail.Re4edit = [RaE4shops objectAtIndex:iE4index]; //[MfetchE1card objectAtIndexPath:indexPath];
		e4detail.PbAdd = NO;
		//e4detail.Pe3edit = nil;
	}
	
	if (Pe3edit) {
		e4detail.PbSave = NO;	// 呼び出し元：右上ボタン「完了」　E3recordDetailTVC側のsave:により保存
	} else {
		e4detail.PbSave = YES;	// マスタモード：右上ボタン「保存」
	}
	
	// 呼び出し側(親)にてツールバーを常に非表示にする
	e4detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする

	[self.navigationController pushViewController:e4detail animated:YES];
	[e4detail release]; // self.navigationControllerがOwnerになる
}

// UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// buttonIndexは、actionSheetの上から順に(0〜)付与されるようだ。
	if (actionSheet.tag == ACTIONSEET_TAG_DELETE_SHOP && buttonIndex == 0) {
		//========== E4 削除実行 ==========
		E4shop *e4objDelete = [RaE4shops objectAtIndex:MindexPathActionDelete.row];
		
		// E3は、削除せずに E4-E3 リンクを断つだけ
		// E4-E3 リンクは、以下のE4削除すれば全てnilされる
		// E4shop 削除
		[RaE4shops removeObjectAtIndex:MindexPathActionDelete.row];
		[Re0root.managedObjectContext deleteObject:e4objDelete];
		// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針＞＞
		NSError *error = nil;
		if (![Re0root.managedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
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
    return [RaE4shops count] + 1; // (+1)Add
}

/*
 // セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if ([Me4shops count] <= indexPath.row) {
		return 30; // Add Record
	}
	return 44; // デフォルト：44ピクセル
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *zCellNode = @"CellNode";
	static NSString *zCellAdd = @"CellAdd";
    UITableViewCell *cell = nil;

	// 末尾([Me4shops count])はAdd行
	if (indexPath.row < [RaE4shops count]) 
	{
		cell = [tableView dequeueReusableCellWithIdentifier:zCellNode];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] 
					 initWithStyle:UITableViewCellStyleValue1
					 reuseIdentifier:zCellNode] autorelease];

			cell.textLabel.font = [UIFont systemFontOfSize:18];
			//cell.textLabel.textAlignment = UITextAlignmentLeft;
			cell.textLabel.textColor = [UIColor blackColor];
			
			cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
			//cell.detailTextLabel.textAlignment = UITextAlignmentRight;
			cell.detailTextLabel.textColor = [UIColor blackColor];

			if (Pe3edit == nil) {
				cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; // ディスクロージャボタン
				cell.showsReorderControl = NO; // MOVE
			}
		}
		
		E4shop *e4obj = [RaE4shops objectAtIndex:indexPath.row];
		
		if ([e4obj.zName length] <= 0) 
			cell.textLabel.text = NSLocalizedString(@"(Untitled)", nil);
		else
			cell.textLabel.text = e4obj.zName;
	} 
	else {
		// Add ボタンセル
		cell = [tableView dequeueReusableCellWithIdentifier:zCellAdd];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault      // Default型
										   reuseIdentifier:zCellAdd] autorelease];
		}
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.textLabel.textAlignment = UITextAlignmentCenter; // 中央寄せ
		cell.textLabel.textColor = [UIColor blackColor];
		cell.imageView.image = [UIImage imageNamed:@"Icon32-GreenPlus.png"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
		cell.showsReorderControl = NO; // MOVE
		cell.textLabel.text = NSLocalizedString(@"Add Shop",nil);
	}
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// 末尾([Me4shops count])はAdd行
	if (indexPath.row < [RaE4shops count]) return UITableViewCellEditingStyleDelete;
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 非選択状態に戻す

	// didSelect時のScrollView位置を記録する（viewWillAppearにて再現するため）
	McontentOffsetDidSelect = [tableView contentOffset];

	// 末尾([Me4shops count])はAdd行
	if (indexPath.row < [RaE4shops count]) {
		if (Pe3edit) {
			// 選択モード
			Pe3edit.e4shop = [RaE4shops objectAtIndex:indexPath.row]; 
			[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
		}
		else if (self.editing) {
			[self e4shopDatail:indexPath.row];
		} else {
/*			// Comback-L1 E4shop 記録
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			long lPos = indexPath.section * GD_SECTION_TIMES + indexPath.row;
			// (0)TopMenu >> (1)This >> (2)Clear
			[appDelegate.RaComebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:lPos]];
			[appDelegate.RaComebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
*/			
			// E3records へ
			E3recordTVC *tvc = [[E3recordTVC alloc] init];
			E4shop *e4obj = [RaE4shops objectAtIndex:indexPath.row];
#ifdef AzDEBUG
			tvc.title = [NSString stringWithFormat:@"E3 %@", e4obj.zName];
#else
			tvc.title =  e4obj.zName;
#endif
			tvc.Re0root = Re0root;
			//tvc.Pe1card = nil;  
			tvc.Pe4shop = e4obj;  // e4obj以下の全E3表示モード
			tvc.Pe5category = nil;
			[self.navigationController pushViewController:tvc animated:YES];
			[tvc release];
		}
	}
	else {
		// Add Plan
		[self e4shopDatail:(-1)]; // :(-1)Add mode
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
						 initWithTitle:NSLocalizedString(@"DELETE Shop", nil)
						 delegate:self 
						 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
						 destructiveButtonTitle:NSLocalizedString(@"DELETE Shop button", nil)
						 otherButtonTitles:nil];
		action.tag = ACTIONSEET_TAG_DELETE_SHOP;
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
 // Editモード時の行Edit可否　　＜＜特に不要。 最終Add行は、add処理が優先されるようだ＞＞
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

// Editモード時の行移動の可否　　＜＜最終行のAdd専用行を移動禁止にしている＞＞
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// 末尾([Me4shops count])はAdd行
	if (indexPath.row < [Me4shops count]) return YES;
	return NO;  // 最終行のAdd行は移動禁止
}

// Editモード時の行移動「先」を返す　　＜＜最終行のAdd専用行への移動ならば1つ前の行を返している＞＞
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)oldPath 
															toProposedIndexPath:(NSIndexPath *)newPath {
    NSIndexPath *target = newPath;
	// 末尾([Me4shops count])はAdd行
	// セクション０限定仕様
	if ([Me4shops count] < 0) {
		return newPath;
	}
	else if ([Me4shops count] <= newPath.row) {
		// 末尾ならば末尾-1行目を返す
        target = [NSIndexPath indexPathForRow:[Me4shops count]-1 inSection:0];
	}
    return target;
}

// Editモード時の行移動処理　　＜＜CoreDataにつきArrayのように削除＆挿入ではダメ。ソート属性(row)を書き換えることにより並べ替えている＞＞
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)oldPath 
												  toIndexPath:(NSIndexPath *)newPath {
	// CoreDataは順序を保持しないため 属性"ascend"を昇順ソート表示している
	// この 属性"ascend"の値を行異動後に更新するための処理

	// Re4shop 更新 ==>> なんと、managedObjectContextも更新される。 ただし、削除や挿入は反映されない！！！
	E4shop *e4obj = [Me4shops objectAtIndex:oldPath.row]; //[MfetchE1card objectAtIndexPath:oldPath];

	[Me4shops removeObjectAtIndex:oldPath.row];
	[Me4shops insertObject:e4obj atIndex:newPath.row];
	
	NSInteger start = oldPath.row;
	NSInteger end = newPath.row;
	if (end < start) {
		start = newPath.row;
		end = oldPath.row;
	}
	for (NSInteger i = start; i <= end; i++) {
		e4obj = [Me4shops objectAtIndex:i];
		e4obj.nRow = [NSNumber numberWithInteger:i];
	}
	
	// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針＞＞
	NSError *error = nil;
	if (![Re0root.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}
*/

@end

