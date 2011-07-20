//
//  E5categoryTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "E5categoryTVC.h"
#import "E5categoryDetailTVC.h"
#import "E3recordTVC.h"

#ifdef AzPAD
//#import "PadPopoverInNaviCon.h"
#endif

#define ACTIONSEET_TAG_DELETE_SHOP	199

@interface E5categoryTVC (PrivateMethods)
- (void)e5categoryDatail:(NSIndexPath *)indexPath;
- (void)barButtonAdd;
- (void)requeryMe5categorys:(NSString *)zSearch;
- (void)viewDesign;
@end

@implementation E5categoryTVC
@synthesize Re0root;
@synthesize Pe3edit;
#ifdef AzPAD
@synthesize delegate;
@synthesize selfPopover;
#endif


#pragma mark - Delegate

#ifdef AzPAD
- (void)refreshTable
{
	if (MindexPathEdit && MindexPathEdit.row < [RaE5categorys count]) {	// 日付に変更なく、行位置が有効ならば、修正行だけを再表示する
		NSArray* ar = [NSArray arrayWithObject:MindexPathEdit];
		[self.tableView reloadRowsAtIndexPaths:ar withRowAnimation:YES];
	} else {
		// Add または行位置不明のとき
		[self viewWillAppear:YES];
	}
}
#endif


#pragma mark - Action

// UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// buttonIndexは、actionSheetの上から順に(0〜)付与されるようだ。
	if (actionSheet.tag == ACTIONSEET_TAG_DELETE_SHOP && buttonIndex == 0) {
		//========== 削除実行 ==========
		E5category *e5objDelete = [RaE5categorys objectAtIndex:MindexPathActionDelete.row];
		
		// 削除
		[RaE5categorys removeObjectAtIndex:MindexPathActionDelete.row];
		[Re0root.managedObjectContext deleteObject:e5objDelete];
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

- (void)e5categoryDatail:(NSIndexPath *)indexPath	//(NSInteger)iE5index
{
	E5categoryDetailTVC *e5detail = [[E5categoryDetailTVC alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	
	if (indexPath == nil) {	// Add
		e5detail.title = NSLocalizedString(@"Add Category",nil);
		// ContextにE1ノードを追加する　E4edit内でCANCELならば DELETE している
		e5detail.Re5edit = [NSEntityDescription insertNewObjectForEntityForName:@"E5category"
														 inManagedObjectContext:Re0root.managedObjectContext];
		e5detail.PbAdd = YES;
		e5detail.Pe3edit = Pe3edit;
#ifdef  AzPAD
		indexPath = [NSIndexPath indexPathForRow:[RaE5categorys count] inSection:0];	//Add行、回転時にPopoverの矢印位置のため
#endif
	}
	else if ([RaE5categorys count] <= indexPath.row) {
		[e5detail release];
		return; // Add行以降、パスする
	}
	else {
		e5detail.title = NSLocalizedString(@"Edit Category",nil);
		e5detail.Re5edit = [RaE5categorys objectAtIndex:indexPath.row]; //[MfetchE1card objectAtIndexPath:indexPath];
		e5detail.PbAdd = NO;
		e5detail.Pe3edit = nil;
	}
	
	if (Pe3edit) {
		e5detail.PbSave = NO;	// 呼び出し元：E3recordDetailTVC側のsave:により保存
	} else {
		e5detail.PbSave = YES;	// マスタモード：
	}
	
#ifdef  AzPAD
	if (Pe3edit) { // 選択モード
		e5detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
		[self.navigationController pushViewController:e5detail animated:YES];
	} else {
		AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		apd.entityModified = e5detail.PbAdd;

		MindexPathEdit = indexPath;
		UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:e5detail];
		Mpopover = [[UIPopoverController alloc] initWithContentViewController:nc];
		Mpopover.delegate = self;	// popoverControllerDidDismissPopover:を呼び出してもらうため
		[nc release];
		CGRect rc = [self.tableView rectForRowAtIndexPath:indexPath];
		rc.origin.x = rc.size.width - 40;	rc.size.width = 10;
		rc.origin.y += 10;	rc.size.height -= 20;
		[Mpopover presentPopoverFromRect:rc
								  inView:self.tableView  permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
		e5detail.selfPopover = Mpopover;  [Mpopover release]; //(retain)  内から閉じるときに必要になる
		e5detail.delegate = self;		// refreshTable callback
	}
#else
	// 呼び出し側(親)にてツールバーを常に非表示にする
	e5detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e5detail animated:YES];
#endif
	[e5detail release]; // self.navigationControllerがOwnerになる
}

- (void)barButtonTop {
	[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
}

- (void)barButtonAdd {
	// Add Shop
	[self e5categoryDatail:nil]; //Add mode
}

- (void)barButtonUntitled {
	// 未定(nil)にする
	Pe3edit.e5category = nil; 
#ifdef xxxAzPAD
	if (selfPopover) {
		if ([delegate respondsToSelector:@selector(viewWillAppear:)]) {	// メソッドの存在を確認する
			[delegate viewWillAppear:YES];// 再描画
		}
		[selfPopover dismissPopoverAnimated:YES];
	}
#else
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
#endif
}

- (void)barSegmentSort:(id)sender {
	MiOptE5SortMode = [sender selectedSegmentIndex];
	// Requery
	[self requeryMe5categorys:nil];
}

#ifdef AzPAD
- (void)cancelClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}
#endif


#pragma mark - View lifecicle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStylePlain]; // セクションなしテーブル
	if (self) {
		// 初期化成功
#ifdef AzPAD
		self.contentSizeForViewInPopover = GD_POPOVER_SIZE;
#endif
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
//【Tips】ここでaddSubviewするオブジェクトは全てautoreleaseにすること。メモリ不足時には自動的に解放後、改めてここを通るので、初回同様に生成するだけ。
- (void)loadView
{
	[super loadView];
	
#ifdef AzPAD
	self.navigationItem.hidesBackButton = YES;
	// Set up NEXT Left Back [<] buttons.
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithImage:[UIImage imageNamed:@"Icon16-Return1.png"]
											  style:UIBarButtonItemStylePlain  target:nil  action:nil] autorelease];
#else
	// Set up NEXT Left Back [<<] buttons.
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithImage:[UIImage imageNamed:@"Icon16-Return2.png"]
											  style:UIBarButtonItemStylePlain  target:nil  action:nil] autorelease];
#endif

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
	NSArray *aItems = [NSArray arrayWithObjects:
					   NSLocalizedString(@"Sort Recent",nil),
					   NSLocalizedString(@"Sort Views",nil),
					   NSLocalizedString(@"Sort Amount",nil),
					   NSLocalizedString(@"Sort Index",nil), nil]; // autorelease
	UISegmentedControl *segment = [[[UISegmentedControl alloc] initWithItems:aItems] autorelease];
	segment.frame = CGRectMake(0,0, 220,30);
	segment.segmentedControlStyle = UISegmentedControlStyleBar;
	MiOptE5SortMode = 0; //[[NSUserDefaults standardUserDefaults] integerForKey:GD_OptE5SortMode];
	segment.selectedSegmentIndex = MiOptE5SortMode;
	// .selectedSegmentIndex 代入より後に addTarget:指定すること。 逆になると代入によりaction:コールされてしまう。
	[segment addTarget:self action:@selector(barSegmentSort:) forControlEvents:UIControlEventValueChanged];
	UIBarButtonItem *buSort = [[[UIBarButtonItem alloc] initWithCustomView:segment] autorelease];
	//[segment release];
	
	// Tool Bar Button
	UIBarButtonItem *buFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			 target:nil action:nil] autorelease];
	UIBarButtonItem *buAdd = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																			target:self action:@selector(barButtonAdd)] autorelease];
	if (Pe3edit) {
		MbuTop = nil;
		UIBarButtonItem *buUntitled = [[[UIBarButtonItem alloc] 
									   initWithTitle:NSLocalizedString(@"Untitled",nil)
									   style:UIBarButtonItemStyleBordered
										target:self action:@selector(barButtonUntitled)] autorelease];
		NSArray *buArray = [NSArray arrayWithObjects: buUntitled, buFlex, buSort, buFlex, buAdd, nil];
		[self setToolbarItems:buArray animated:YES];
		//[buUntitled release];
	}
	else {
#ifdef AzPAD
		NSArray *buArray = [NSArray arrayWithObjects: buFlex, buSort, buFlex, buAdd, nil];
		[self setToolbarItems:buArray animated:YES];
#else
		MbuTop = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-Top.png"]
												  style:UIBarButtonItemStylePlain  //Bordered
												  target:self action:@selector(barButtonTop)] autorelease];
		NSArray *buArray = [NSArray arrayWithObjects: MbuTop, buFlex, buSort, buFlex, buAdd, nil];
		[self setToolbarItems:buArray animated:YES];
		//[MbuTop release];
#endif
	}
	//[buAdd release];
	//[buFlex release];
	//[buSort release];
	
	// ToolBar表示は、viewWillAppearにて回転方向により制御している。
}


- (void)requeryMe5categorys:(NSString *)zSearch 
{	// Me5categorys Requery. 

	// Where
	NSPredicate *predicate = nil;
	if (zSearch && 0 < [zSearch length]) {  // NSPredicateを使って、検索条件式を設定する
		predicate = [NSPredicate predicateWithFormat:
					 @"(sortName contains %@) OR (zName contains %@)", zSearch, zSearch];
	}
	
	// Sorting
	NSString *zKey;
	BOOL bAsc;
	switch (MiOptE5SortMode) {
		case 1:  zKey = @"sortCount";	bAsc = NO;	break; // 回数
		case 2:  zKey = @"sortAmount";	bAsc = NO;	break; // 金額
		case 3:  zKey = @"sortName";	bAsc = YES;	break; // かな　＜＜入力が面倒で使われない可能性が高いと思うから優先度を下げた＞＞
		default: zKey = @"sortDate";	bAsc = NO;	break; // 最近
	}
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:zKey ascending:bAsc];
	NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1, nil];
	[sort1 release];
	
	NSArray *arFetch = [MocFunctions select:@"E5category" 
										limit:0
									   offset:0
										where:predicate
										 sort:sortArray];
	[sortArray release];
	//
	if (RaE5categorys) {
		[RaE5categorys release], RaE5categorys = nil;
	}
	RaE5categorys = [[NSMutableArray alloc] initWithArray:arFetch];
	//
	[self viewDesign];
	[self.tableView reloadData];
}

- (void)viewDesign
{
	// 回転によるリサイズ
	// SerchBar
	self.tableView.tableHeaderView.frame = CGRectMake(0,0, self.tableView.bounds.size.width,0);
	[self.tableView.tableHeaderView sizeToFit];
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
	[self requeryMe5categorys:nil];
	
	if (0 < McontentOffsetDidSelect.y) {
		// app.Me3dateUse=nil のときや、メモリ不足発生時に元の位置に戻すための処理。
		// McontentOffsetDidSelect は、didSelectRowAtIndexPath にて記録している。
		self.tableView.contentOffset = McontentOffsetDidSelect;
	}

	if (Pe3edit) {
		sourceE5category = Pe3edit.e5category;		//初期値
	} else {
		sourceE5category = nil;
	}
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated
{
#ifdef AzPAD
	// viewWillAppear:に入れると再描画時に通ってBarが乱れるため、ここにした。 loadViewに入れると配下から戻ったときダメ
	// SplitViewタテのとき [Menu] button を表示する
	if (Pe3edit==nil) { // マスタモードのとき、だけ[Menu]ボタン表示
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
		}
	} else {
		// CANCELボタンを左側に追加する  Navi標準の戻るボタンでは cancelClose:処理ができないため
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
												  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
												  target:self action:@selector(cancelClose:)] autorelease];
	}
#endif
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
	
	/*	if (Pe3edit == nil) {
	 // Comback (-1)にして未選択状態にする
	 AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	 // (0)TopMenu >> (1)This clear
	 [appDelegate.RaComebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:-1]];
	 }*/
}
/*
 // この画面が非表示になる直前（次の画面が表示される前）に呼ばれる
 - (void)viewWillDisappear:(BOOL)animated
 {
 // ソート条件を保存する　＜＜切り替えの都度、保存していたが[0.4]にてフリーズ症状発生＞＞
 [[NSUserDefaults standardUserDefaults] setInteger:MiOptE5SortMode forKey:GD_OptE5SortMode];
 }
 */

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

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	[self viewDesign];
}

#ifdef AzPAD
// 回転した後に呼び出される
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if ([Mpopover isPopoverVisible]) {
		// Popoverの位置を調整する　＜＜UIPopoverController の矢印が画面回転時にターゲットから外れてはならない＞＞
		if (MindexPathEdit) { 
			[self.tableView scrollToRowAtIndexPath:MindexPathEdit 
								  atScrollPosition:UITableViewScrollPositionMiddle animated:NO]; // YESだと次の座標取得までにアニメーションが終了せずに反映されない
			CGRect rc = [self.tableView rectForRowAtIndexPath:MindexPathEdit];
			rc.origin.x = rc.size.width - 40;	rc.size.width = 10;
			rc.origin.y += 10;	rc.size.height -= 20;
			[Mpopover presentPopoverFromRect:rc  inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionRight  animated:YES]; //表示開始
		} 
		else {
			// 回転後のアンカー位置が再現不可なので閉じる
			[Mpopover dismissPopoverAnimated:YES];
		}
	}
}
#endif

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
	if ([RaE5categorys count] <= lRow) return; // 無効セル（削除されたとか）

	// 次、 E3recordTVC だが、これ以上戻しても見難いだけなので、ここまでで止めることにした。
	// 前回選択行を画面中央にする。
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lRow inSection:lSec];
	[self.tableView scrollToRowAtIndexPath:indexPath 
						  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
}
*/

#pragma mark  View - Unload - dealloc

- (void)unloadRelease	// dealloc, viewDidUnload から呼び出される
{
	//【Tips】loadViewでautorelease＆addSubviewしたオブジェクトは全てself.viewと同時に解放されるので、ここでは解放前の停止処理だけする。
	NSLog(@"--- unloadRelease --- E5categoryTVC");
	//【Tips】デリゲートなどで参照される可能性のあるデータなどは破棄してはいけない。
	// 他オブジェクトからの参照無く、viewWillAppearにて生成されるので破棄可能
	[RaE5categorys release], RaE5categorys = nil;
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


#pragma mark - UISearchBar

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	// Requery
	[self requeryMe5categorys:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	searchBar.text = @"";
	[searchBar resignFirstResponder]; // キーボードを非表示にする
}


#pragma mark - TableView lifecicle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1; // 固定
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [RaE5categorys count] + 1; // (+1)Add
}

#ifdef xxxxxxxxFREE_AD_PAD
// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{
	if (section==0) return @"\n\n\n\n\n\n\n\n\n\n\n\n\n\n";	// 大型AdMobスペースのための下部余白
	return nil;
}
#endif

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *zCellNode = @"CellNode";
	static NSString *zCellAdd = @"CellAdd";
    UITableViewCell *cell = nil;

	// 末尾([Me4shops count])はAdd行
	if (indexPath.row < [RaE5categorys count]) 
	{
		cell = [tableView dequeueReusableCellWithIdentifier:zCellNode];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] 
					 initWithStyle:UITableViewCellStyleValue1
					 reuseIdentifier:zCellNode] autorelease];

#ifdef AzPAD
			cell.textLabel.font = [UIFont systemFontOfSize:20];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
#else
			cell.textLabel.font = [UIFont systemFontOfSize:18];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
#endif
			//cell.textLabel.textAlignment = UITextAlignmentLeft;
			cell.textLabel.textColor = [UIColor blackColor];
			
			//cell.detailTextLabel.textAlignment = UITextAlignmentRight;
			cell.detailTextLabel.textColor = [UIColor blackColor];

			if (Pe3edit == nil) {
				cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; // ディスクロージャボタン
				cell.showsReorderControl = NO; // MOVE
			}
		}
		
		E5category *e5obj = [RaE5categorys objectAtIndex:indexPath.row];
		
		if ([e5obj.zName length] <= 0) 
			cell.textLabel.text = NSLocalizedString(@"(Untitled)", nil);
		else
			cell.textLabel.text = e5obj.zName;
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
		cell.textLabel.textColor = [UIColor grayColor];
		cell.imageView.image = [UIImage imageNamed:@"Icon32-GreenPlus.png"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
		cell.showsReorderControl = NO; // MOVE
		cell.textLabel.text = NSLocalizedString(@"Add Category",nil);
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 非選択状態に戻す

	// didSelect時のScrollView位置を記録する（viewWillAppearにて再現するため）
	McontentOffsetDidSelect = [tableView contentOffset];

	// 末尾([Me4shops count])はAdd行
	if (indexPath.row < [RaE5categorys count]) {
		if (Pe3edit) { // 選択モード
			Pe3edit.e5category = [RaE5categorys objectAtIndex:indexPath.row]; 
			if (sourceE5category != Pe3edit.e5category) {
				AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
				apd.entityModified = YES;	//変更あり
			}
			[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
		}
		else if (self.editing) {
			[self e5categoryDatail:indexPath];
		} else {
			// E3records へ
			E3recordTVC *tvc = [[E3recordTVC alloc] init];
			E5category *e5obj = [RaE5categorys objectAtIndex:indexPath.row];
#ifdef AzDEBUG
			tvc.title = [NSString stringWithFormat:@"E3 %@", e5obj.zName];
#else
			tvc.title =  e5obj.zName;
#endif
			tvc.Re0root = Re0root;
			//tvc.Pe1card = nil;  
			tvc.Pe4shop = nil;  // e4obj以下の全E3表示モード
			tvc.Pe5category = e5obj;
			[self.navigationController pushViewController:tvc animated:YES];
			[tvc release];
		}
	}
	else {
		// Add Plan
		[self e5categoryDatail:nil]; //Add mode
	}
}

// ディスクロージャボタンが押されたときの処理
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self e5categoryDatail:indexPath];
}

#pragma mark  TableView - Editting

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
						 initWithTitle:NSLocalizedString(@"DELETE Category", nil)
						 delegate:self 
						 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
						 destructiveButtonTitle:NSLocalizedString(@"DELETE Category button", nil)
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

// Editモード時の行Edit可否　　 YESを返した行は、左にスペースが入って右寄りになる
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [RaE5categorys count]) return YES;
	return NO;  // 最終行のAdd行は、右寄せさせない
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// 末尾([Me4shops count])はAdd行
	if (indexPath.row < [RaE5categorys count]) return UITableViewCellEditingStyleDelete;
	return UITableViewCellEditingStyleNone;
}

/**** 行移動なしである。
// Editモード時の行移動の可否　　＜＜最終行のAdd専用行を移動禁止にしている＞＞
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// 末尾([Me4shops count])はAdd行
	if (indexPath.row < [Me5categorys count]) return YES;
	return NO;  // 最終行のAdd行は移動禁止
}

// Editモード時の行移動「先」を返す　　＜＜最終行のAdd専用行への移動ならば1つ前の行を返している＞＞
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)oldPath 
															toProposedIndexPath:(NSIndexPath *)newPath {
    NSIndexPath *target = newPath;
	// 末尾([Me4shops count])はAdd行
	// セクション０限定仕様
	if ([Me5categorys count] < 0) {
		return newPath;
	}
	else if ([Me5categorys count] <= newPath.row) {
		// 末尾ならば末尾-1行目を返す
        target = [NSIndexPath indexPathForRow:[Me5categorys count]-1 inSection:0];
	}
    return target;
}

// Editモード時の行移動処理　　＜＜CoreDataにつきArrayのように削除＆挿入ではダメ。ソート属性(row)を書き換えることにより並べ替えている＞＞
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)oldPath 
												  toIndexPath:(NSIndexPath *)newPath {
	// CoreDataは順序を保持しないため 属性"ascend"を昇順ソート表示している
	// この 属性"ascend"の値を行異動後に更新するための処理

	// Re4shop 更新 ==>> なんと、managedObjectContextも更新される。 ただし、削除や挿入は反映されない！！！
	E5category *e5obj = [Me5categorys objectAtIndex:oldPath.row]; //[MfetchE1card objectAtIndexPath:oldPath];

	[Me5categorys removeObjectAtIndex:oldPath.row];
	[Me5categorys insertObject:e5obj atIndex:newPath.row];
	
	NSInteger start = oldPath.row;
	NSInteger end = newPath.row;
	if (end < start) {
		start = newPath.row;
		end = oldPath.row;
	}
	for (NSInteger i = start; i <= end; i++) {
		e5obj = [Me5categorys objectAtIndex:i];
		e5obj.nRow = [NSNumber numberWithInteger:i];
	}
	
	// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針＞＞
	[MocFunctions commit];
}
*/

#ifdef AzPAD
#pragma mark - <UIPopoverControllerDelegate>
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{	// Popoverの外部をタップして閉じる前に通知
	AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (apd.entityModified) {	// 追加または変更あり
		alertBox(NSLocalizedString(@"Cancel or Save",nil), NSLocalizedString(@"Cancel or Save msg",nil), NSLocalizedString(@"Roger",nil));
		return NO; // Popover外部タッチで閉じるのを禁止 ＜＜追加MOCオブジェクトをＣａｎｃｅｌ時に削除する必要があるため＞＞
	} else {	// 追加や変更なし
		return YES;	// Popover外部タッチで閉じるのを許可
	}
}
#endif


@end

