//
//  E2viewController.m
//  iPack E2 Section
//
//  Created by 松山 和正 on 09/12/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Elements.h"
#import "E2viewController.h"
#import "E3viewController.h"
#import "E2edit.h"
#import "GooDocsTVC.h"
#import "SettingTVC.h"

#define ACTIONSEET_TAG_DELETEGROUP	999 // 適当な重複しない識別数値を割り当てている
#define ACTIONSEET_TAG_ALLZERO		998

@interface E2viewController (PrivateMethods)
	- (void)azSettingView;
	- (void)e2add;
	- (void)e2editView:(NSIndexPath *)indexPath;
//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray *Me2array;   // Rrは local alloc につき release 必須を示す
//----------------------------------------------Owner移管につきdealloc時のrelese不要
	E2edit *Me2editView;				// self.navigationControllerがOwnerになる
//----------------------------------------------assign
	NSIndexPath	  *MindexPathActionDelete; // 削除するIndexPath
	BOOL MbOptShouldAutorotate;
	BOOL MbAzOptTotlWeightRound;
	BOOL MbAzOptShowTotalWeight;
	BOOL MbAzOptShowTotalWeightReq;
	NSInteger MiSection0Rows; // E2レコード数　＜高速化＞
@end
@implementation E2viewController
@synthesize Pe1selected;

- (void)dealloc     // 生成とは逆順に解放するのが好ましい
{
	//AzRETAIN_CHECK(@"E2 Me2editView", Me2editView, 1)
	//[Me2editView release];
	
	AzRETAIN_CHECK(@"E2 Me2array", Me2array, 1)
	[Me2array release];
	
	// @property (retain)
	AzRETAIN_CHECK(@"E2 Pe1selected", Pe1selected, 4) // 2 or 3 or 4
	[Pe1selected release];

    [super dealloc];
}

- (void)viewDidUnload {
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。
	//[Me2editView release];		Me2editView = nil;
	[Me2array release];			Me2array = nil;
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"viewDidUnload" 
													 message:@"E2viewController" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
	// autorelease している。
#endif	
}


#pragma mark View lifecycle


// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {  // セクションありテーブル
		//self.navigationItem.rightBarButtonItem = self.editButtonItem;
		//self.tableView.allowsSelectionDuringEditing = YES;
	}
	return self;
}

- (void)azSettingView
{
	SettingTVC *vi = [[SettingTVC alloc] init];
	vi.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:vi animated:YES];
	[vi release];
}

// viewDidLoadメソッドは，TableViewContorllerオブジェクトが生成された後，実際に表示される際に呼び出されるメソッド
- (void)viewDidLoad 
{
	[super viewDidLoad];
	Me2editView = nil;
	Me2array = nil;
	
	// ここは、alloc直後に呼ばれるため、下記のようなパラは未セット状態である。==>> viewWillAppearで参照すること
	// self.title = seif.e1selected.name;

	// Set up NEXT Left [Back] buttons.
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]
									   initWithImage:[UIImage imageNamed:@"simpleLeft2-icon16.png"]
									   style:UIBarButtonItemStylePlain  target:nil  action:nil];
	self.navigationItem.backBarButtonItem = backButtonItem;
	[backButtonItem release];		

	// Set up Right [Edit] buttons.
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.allowsSelectionDuringEditing = YES;

	// Tool Bar Button
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	UIBarButtonItem *buSet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Setting-icon16.png"]
															  style:UIBarButtonItemStylePlain
															 target:self action:@selector(azSettingView)];
	NSArray *buArray = [NSArray arrayWithObjects: buFlex, buSet, nil];
	[self setToolbarItems:buArray animated:YES];
	[buSet release];
	[buFlex release];
	[self.navigationController setToolbarHidden:NO animated:YES]; // ツールバー表示する
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptShouldAutorotate = [defaults boolForKey:GD_OptShouldAutorotate];
	MbAzOptTotlWeightRound = [defaults boolForKey:GD_OptTotlWeightRound]; // YES=四捨五入 NO=切り捨て
	MbAzOptShowTotalWeight = [defaults boolForKey:GD_OptShowTotalWeight];
	MbAzOptShowTotalWeightReq = [defaults boolForKey:GD_OptShowTotalWeightReq];
	
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
		// ホームボタンが画面の下側にある状態。通常
		[self.navigationController setToolbarHidden:NO animated:NO]; // ツールバー表示する
	} else {
		// 横方向や逆向きのとき
		[self.navigationController setToolbarHidden:YES animated:NO]; // ツールバー消す
	}

	//self.title = ;　呼び出す側でセット済み。　変化させるならばココで。
	
	// 最新データ取得：Add直後などに再取得が必要なのでここで処理。　＜＜viewDidLoadだとAdd後呼び出されない＞＞
	//----------------------------------------------------------------------------CoreData Loading
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	
	// E2 = self.e1selected.childs

	NSMutableArray *sortArray = [[NSMutableArray alloc] initWithArray:[Pe1selected.childs allObjects]];
	[sortArray sortUsingDescriptors:sortDescriptors];
	if (Me2array != sortArray) {
		[Me2array release];
		Me2array = [sortArray retain];
	}
	[sortArray release];
	
	[sortDescriptor release];
	[sortDescriptors release];

	// ＜高速化＞ ここで行数を求めておけば、次回フィッチするまで不変。 ＜＜削除のとき-1している＞＞
	MiSection0Rows = [Me2array count];

	// テーブルビューを更新します。
    [self.tableView reloadData];	// これにより修正結果が表示される
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	// (-1,-1)にしてE2を未選択状態にする
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:-1]];
	[appDelegate.comebackIndex replaceObjectAtIndex:3 withObject:[NSNumber numberWithInteger:-1]];
}

// カムバック処理（復帰再現）：E1 から呼ばれる
- (void)viewComeback:(NSArray *)selectionArray
{
	NSInteger iSec = [[selectionArray objectAtIndex:2] intValue];
	NSInteger iRow = [[selectionArray objectAtIndex:3] intValue];
	if (iSec < 0) return; // この画面表示
	if (iRow < 0) return; // fail.
	
	if (iSec==0) {
		if (MiSection0Rows <= iRow) return; // 無効セル（削除されたとか）
	}
	else if (iSec==1) {
		if (GD_E2SORTLIST_COUNT <= iRow) return;
	}
	else return; // 無効セクション

	// 前回選択したセル位置
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:iRow inSection:iSec];
	// 指定位置までテーブルビューの行をスクロールさせる初期処理
	[self.tableView scrollToRowAtIndexPath:indexPath
							atScrollPosition:UITableViewScrollPositionMiddle animated:NO];

	switch (iSec) {
		case 0: // Group
			{
				E2 *e2obj = [Me2array objectAtIndex:iRow];
				// E3 へドリルダウン
				E3viewController *e3view = [[E3viewController alloc] initWithStyle:UITableViewStylePlain];
				// 以下は、E3viewControllerの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
				e3view.title = self.title;
				e3view.Pe2array = Me2array;
				e3view.Pe1selected = Pe1selected; // E1
				e3view.Pe2selected = e2obj; // E2
				e3view.PiFirstSection = iRow;  // Group.ROW ==>> E3で頭出しするセクション
				e3view.PiSortType = (-1);
				[self.navigationController pushViewController:e3view animated:NO];
				// E3 の viewComeback を呼び出す
				[e3view viewWillAppear:NO]; // Fech データセットさせるため
				[e3view viewComeback:selectionArray];
				[e3view release];
			}
			break;
		case 1: // Sort list
			if (0 < MiSection0Rows && 0 <= iRow && iRow < GD_E2SORTLIST_COUNT) 
			{
				// E3 SORT LIST へドリルダウン
				E3viewController *e3view = [[E3viewController alloc] initWithStyle:UITableViewStylePlain];
				// 以下は、E3viewControllerの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
				e3view.title = self.title;
				e3view.Pe2array = Me2array;
				e3view.Pe1selected = Pe1selected; // E1
				e3view.Pe2selected = nil;
				e3view.PiFirstSection = 0;  // Group.ROW ==>> E3で頭出しするセクション
				e3view.PiSortType = iRow;
				//self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
				[self.navigationController pushViewController:e3view animated:NO];
				// E3 の viewComeback を呼び出す
				[e3view viewWillAppear:NO]; // Fech データセットさせるため
				[e3view viewComeback:selectionArray];
				[e3view release];
			}
			break;
		default:
			return;
			break;
	}
}

#pragma mark Fetched results controller
/*
// Returns the fetched results controller. Creates and configures the controller if necessary.
- (NSFetchedResultsController *)fetchedE2 {
    
    if (fetchedE2 != nil) {
        return fetchedE2;
    }
    
	// Create and configure a fetch request with the Book entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"E2" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *sortRow = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES];
	NSArray *sortArray = [[NSArray alloc] initWithObjects:sortRow, nil];
	[fetchRequest setSortDescriptors:sortArray];
	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedRC = [[NSFetchedResultsController alloc] 
														initWithFetchRequest:fetchRequest 
													 managedObjectContext:managedObjectContext 
																sectionNameKeyPath:nil
																cacheName:@"E2nodes"];
	self.fetchedE2 = aFetchedRC;
	//	fetchedE2.delegate = self;　デリゲートを使わずに追加、削除、移動の処理時にTableView更新処理するようにした。
	
	// Memory management.
	[aFetchedRC release];
	[fetchRequest release];
	[sortRow release];
	[sortArray release];
	
	return fetchedE2;
}    
*/

#pragma mark Local methods

- (void)e2add
{
	// ContextにE2ノードを追加する　E2edit内でCANCELならば削除している
	E2 *e2newObj = [NSEntityDescription insertNewObjectForEntityForName:@"E2"
										inManagedObjectContext:Pe1selected.managedObjectContext];

	Me2editView = [[E2edit alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	Me2editView.title = NSLocalizedString(@"Add Group", @"GROUP追加");
	Me2editView.Pe1selected = Pe1selected;
	Me2editView.Pe2target = e2newObj;
	Me2editView.PiAddRow = MiSection0Rows;  // 追加される行番号(row) ＝ 現在の行数
	Me2editView.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:Me2editView animated:YES];
	[Me2editView release]; // self.navigationControllerがOwnerになる
}

- (void)e2editView:(NSIndexPath *)indexPath
{
	if (indexPath.section != 0) return;  // ここを通るのはセクション0だけ。
	if (MiSection0Rows <= indexPath.row) return;  // Addボタン行などの場合パスする
	
	E2 *e2obj = [Me2array objectAtIndex:indexPath.row];
	
	Me2editView = [[E2edit alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	Me2editView.title = NSLocalizedString(@"Edit Group", @"GROUP編集");
	Me2editView.Pe1selected = Pe1selected;
	Me2editView.Pe2target = e2obj;
	Me2editView.PiAddRow = (-1); // Edit mode
	Me2editView.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:Me2editView animated:YES];
	[Me2editView release]; // self.navigationControllerがOwnerになる
}


#pragma mark Local Function

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != 1) return; // CANCEL
	
	// TEST DATA ADD 10x10
    NSInteger ie2, ie3;
	NSInteger ie3Row;
	NSInteger ie2Row = MiSection0Rows;  // 開始row ＝ 現在ノード数
	NSInteger iStock;
	NSInteger iNeed;
	
	// E2ノード追加
	E2 *e2obj;
	E3 *e3obj;
	for (ie2=0 ; ie2 < 10 ; ie2++, ie2Row++)
	{
		// コンテキストに新規の E2エンティティのオブジェクトを挿入します。
		e2obj = [NSEntityDescription insertNewObjectForEntityForName:@"E2"
										   inManagedObjectContext:Pe1selected.managedObjectContext];
		
		[e2obj setValue:[NSString stringWithFormat:@"Group %d",ie2Row] forKey:@"name"];
		[e2obj setValue:[NSNumber numberWithInteger:ie2Row] forKey:@"row"];
		MiSection0Rows = ie2Row;

		// e1selected(E1) の childs に newObj を追加する
		[Pe1selected addChildsObject:e2obj];
		
		// E3ノード追加
		for (ie3=0, ie3Row=0 ; ie3 < 10 ; ie3++, ie3Row++)
		{
			// コンテキストに新規の E3エンティティのオブジェクトを挿入します。
			e3obj = [NSEntityDescription insertNewObjectForEntityForName:@"E3"
									   inManagedObjectContext:Pe1selected.managedObjectContext];
			
			[e3obj setValue:[NSString stringWithFormat:@"Item %d-%d",ie2Row,ie3Row] forKey:@"name"];
			[e3obj setValue:[NSString stringWithFormat:@"Item %d-%d Note",ie2Row,ie3Row] forKey:@"note"];
			
			iStock = ie3;
			iNeed = 9 - ie3;
			
			[e3obj setValue:[NSNumber numberWithInteger:iStock] forKey:@"weight"];
			[e3obj setValue:[NSNumber numberWithInteger:iStock] forKey:@"stock"];
			[e3obj setValue:[NSNumber numberWithInteger:iNeed] forKey:@"need"];
			[e3obj setValue:[NSNumber numberWithInteger:iStock*iStock] forKey:@"weightStk"];  // E3のみ　E1,E2のは不要になった。
			[e3obj setValue:[NSNumber numberWithInteger:iStock*iNeed] forKey:@"weightNed"];  // E3のみ　E1,E2のは不要になった。
			[e3obj setValue:[NSNumber numberWithInteger:iNeed-iStock] forKey:@"lack"];
			[e3obj setValue:[NSNumber numberWithInteger:(iNeed-iStock)*iStock] forKey:@"weightLack"];
			
			NSInteger iNoGray = 0;
			if (0 < iNeed) iNoGray = 1;
			[e3obj setValue:[NSNumber numberWithInteger:iNoGray] forKey:@"noGray"]; // NoGray:有効(0<必要数)アイテム
			
			NSInteger iNoCheck = 0;
			if (0 < iNeed && iStock < iNeed) iNoCheck = 1;
			[e3obj setValue:[NSNumber numberWithInteger:iNoCheck] forKey:@"noCheck"]; // NoCheck:不足アイテム

			[e3obj setValue:[NSNumber numberWithInteger:ie3Row] forKey:@"row"];  // row = indexPath.row
			
			// e1selected(E2) の childs に e3node を追加する
			[e2obj addChildsObject:e3obj];
		}
		
		// E2 sum属性　＜高速化＞ 親sum保持させる
		[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.noGray"] forKey:@"sumNoGray"];
		[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.noCheck"] forKey:@"sumNoCheck"];
		[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.weightStk"] forKey:@"sumWeightStk"];
		[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.weightNed"] forKey:@"sumWeightNed"];
	}

	// E1 sum属性　＜高速化＞ 親sum保持させる
	[Pe1selected setValue:[Pe1selected valueForKeyPath:@"childs.@sum.sumNoGray"] forKey:@"sumNoGray"];
	[Pe1selected setValue:[Pe1selected valueForKeyPath:@"childs.@sum.sumNoCheck"] forKey:@"sumNoCheck"];
	[Pe1selected setValue:[Pe1selected valueForKeyPath:@"childs.@sum.sumWeightStk"] forKey:@"sumWeightStk"];
	[Pe1selected setValue:[Pe1selected valueForKeyPath:@"childs.@sum.sumWeightNed"] forKey:@"sumWeightNed"];

	// SAVE
	 NSError *err = nil;
	 if (![Pe1selected.managedObjectContext save:&err]) {
	 NSLog(@"Unresolved error %@, %@", err, [err userInfo]);
		 abort();
	 }
	
    //[self.tableView reloadData];   // テーブルビューを更新
	// ROOR階層に戻る
	[self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark TableView methods

// TableView セクション数を応答
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;  // (0)Group (1)Sort list (2)Function
}

// TableView セクションの行数を応答
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	NSInteger rows = 0;
	switch (section) {
		case 0: // Group
			rows = MiSection0Rows + 1; // 常にAdd行を表示することにした
			break;
		case 1: // Sort list
			if (0 < MiSection0Rows) rows = GD_E2SORTLIST_COUNT + 1;  // Function数＋1
			else rows = 0;
			break;
		case 2: // Function
			rows = 2;   // (0)Google Upload  (1)All stock ZERO
#ifdef AzDEBUG
			rows += 1;  // (+1)Add TEST DATA
#endif
			break;
	}
    return rows;
}

// TableView セクションタイトルを応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	double dWeightStk;
	double dWeightReq;

	switch (section) {
		case 0:
			if (MbAzOptShowTotalWeight) {
				// ＜高速化＞ E3(Item)更新時、その親E2のsum属性、さらにその親E1のsum属性を更新することで整合および参照時の高速化を実現した。
				long lWeightStk = [[Pe1selected valueForKey:@"sumWeightStk"] longValue];
				if (MbAzOptTotlWeightRound) {
					// 四捨五入　＜＜ %.1f により小数第2位が丸められる＞＞ 
					dWeightStk = (double)lWeightStk / 1000.0f;
				} else {
					// 切り捨て                       ↓これで下2桁が0になる
					dWeightStk = (double)(lWeightStk / 100) / 10.0f;
				}
			}
			if (MbAzOptShowTotalWeightReq) {
				// ＜高速化＞ E3(Item)更新時、その親E2のsum属性、さらにその親E1のsum属性を更新することで整合および参照時の高速化を実現した。
				long lWeightReq = [[Pe1selected valueForKey:@"sumWeightNed"] longValue];
				if (MbAzOptTotlWeightRound) {
					// 四捨五入　＜＜ %.1f により小数第2位が丸められる＞＞ 
					dWeightReq = (double)lWeightReq / 1000.0f;
				} else {
					// 切り捨て                       ↓これで下2桁が0になる
					dWeightReq = (double)(lWeightReq / 100) / 10.0f;
				}
			}
			if (MbAzOptShowTotalWeight && MbAzOptShowTotalWeightReq) {
				return [NSString stringWithFormat:@"%@  %.1f／%.1fKg", 
												NSLocalizedString(@"Group total",nil), dWeightStk, dWeightReq];
			} else if (MbAzOptShowTotalWeight) {
				return [NSString stringWithFormat:@"%@  %.1fKg", 
												NSLocalizedString(@"Group total",nil), dWeightStk];
			} else if (MbAzOptShowTotalWeightReq) {
				return [NSString stringWithFormat:@"%@  ／%.1fKg", 
												NSLocalizedString(@"Group total",nil), dWeightReq];
			} else {
				return [NSString stringWithFormat:@"%@", NSLocalizedString(@"Group",nil)];
			}
			break;
		case 1:
			return NSLocalizedString(@"Sort list", @"並び替え");
			break;
		case 2:
			return NSLocalizedString(@"Group Function", @"グループ機能");
			break;
	}
	return @"ERR";
}

// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 2:
			return	@"AzukiSoft Project\n"
					@"Copyright © 2009-2010 Azukid.com";
			break;
	}
	return @"";
}

static UIImage* GimageFromString(NSString* str)
{
    // この辺は引数にするなり何なりで適当に。
    UIFont* font = [UIFont systemFontOfSize:12];
    CGSize size = [str sizeWithFont:font];
    int width = 32;
    int height = 32;
    int pitch = width * 4;
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 第一引数を NULL にすると、適切なサイズの内部イメージを自動で作ってくれる
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, pitch, 
												 colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
	CGAffineTransform transform = CGAffineTransformMake(1.0,0.0,0.0, -1.0,0.0,0.0); // 上下転置行列
	CGContextConcatCTM(context, transform);
	
	// 描画開始
    UIGraphicsPushContext(context);
    
	CGContextSetRGBFillColor(context, 255, 0, 0, 1.0f);
	[str drawAtPoint:CGPointMake(16.0f - (size.width / 2.0f), -23.0f) withFont:font];
	
	// 描画終了
	UIGraphicsPopContext();
	
    // イメージを取り出す
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
	
    // UIImage を生成
    UIImage* uiImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return uiImage;
}

// TableView 指定されたセルを生成＆表示
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *zCellDefault = @"CellDefault";
	static NSString *zCellSubtitle = @"CellSubtitle";
//	static NSString *zCellAdd = @"CellE2Add";
//	static NSString *zCellFunc = @"CellE2Func";
	static NSString *zCellWithSwitch = @"CellWithSwitch";
    UITableViewCell *cell = nil;

	//AzLOG(@"E2 cell Section=%d Row=%d Begin", indexPath.section, indexPath.row);

	switch (indexPath.section) {
		case 0: // section: Group
			if (indexPath.row < MiSection0Rows) {
				// 通常のノードセル
				cell = [tableView dequeueReusableCellWithIdentifier:zCellSubtitle];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] 
							 initWithStyle:UITableViewCellStyleSubtitle
							 reuseIdentifier:zCellSubtitle] autorelease];
				}
				// e2node
				E2 *e2obj = [Me2array objectAtIndex:indexPath.row];
				
#ifdef AzDEBUG
				if ([e2obj.name length] <= 0) 
					cell.textLabel.text = NSLocalizedString(@"Untitled", nil);
				else
					cell.textLabel.text = [NSString stringWithFormat:@"%ld) %@", 
										   (long)[e2obj.row integerValue], e2obj.name];
#else
				if ([e2obj.name length] <= 0) 
					cell.textLabel.text = NSLocalizedString(@"Untitled", nil);
				else
					cell.textLabel.text = e2obj.name;
#endif
				cell.textLabel.font = [UIFont systemFontOfSize:18];
				cell.textLabel.textAlignment = UITextAlignmentLeft;
				cell.textLabel.textColor = [UIColor blackColor];

				cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
				cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
				cell.detailTextLabel.textColor = [UIColor grayColor];
				
				NSInteger lNoGray = [e2obj.sumNoGray integerValue];
				NSInteger lNoCheck = [e2obj.sumNoCheck integerValue];
/*				if (0 < lNoCheck) {
					cell.detailTextLabel.textColor = [UIColor redColor];
				} else if (0 < lNoGray) {
					cell.detailTextLabel.textColor = [UIColor blueColor];
				} else {
					cell.detailTextLabel.textColor = [UIColor grayColor];
				}
*/				
				double dWeightStk;
				double dWeightReq;
				if (MbAzOptShowTotalWeight) {
					// ＜高速化＞ E3(Item)更新時、その親E2のsum属性、さらにその親E1のsum属性を更新することで整合および参照時の高速化を実現した。
					NSInteger lWeightStk = [e2obj.sumWeightStk integerValue];
					if (MbAzOptTotlWeightRound) {
						// 四捨五入　＜＜ %.1f により小数第2位が丸められる＞＞ 
						dWeightStk = (double)lWeightStk / 1000.0f;
					} else {
						// 切り捨て                       ↓これで下2桁が0になる
						dWeightStk = (double)(lWeightStk / 100) / 10.0f;
					}
				}
				if (MbAzOptShowTotalWeightReq) {
					// ＜高速化＞ E3(Item)更新時、その親E2のsum属性、さらにその親E1のsum属性を更新することで整合および参照時の高速化を実現した。
					NSInteger lWeightReq = [e2obj.sumWeightNed integerValue];
					if (MbAzOptTotlWeightRound) {
						// 四捨五入　＜＜ %.1f により小数第2位が丸められる＞＞ 
						dWeightReq = (double)lWeightReq / 1000.0f;
					} else {
						// 切り捨て                       ↓これで下2桁が0になる
						dWeightReq = (double)(lWeightReq / 100) / 10.0f;
					}
				}

				if (MbAzOptShowTotalWeight && MbAzOptShowTotalWeightReq) {
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f／%.1fKg  %@", 
												 dWeightStk, dWeightReq, e2obj.note];
				} else if (MbAzOptShowTotalWeight) {
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1fKg  %@", 
												 dWeightStk, e2obj.note];
				} else if (MbAzOptShowTotalWeightReq) {
					cell.detailTextLabel.text = [NSString stringWithFormat:@"／%.1fKg  %@", 
												 dWeightReq, e2obj.note];
				} else {
					cell.detailTextLabel.text = e2obj.note;
				}

				if (0 < lNoCheck) {
					//cell.imageView.image = [UIImage imageNamed:@"Check32-Circle.png"];
					UIImageView *imageView1 = [[UIImageView alloc] init];
					UIImageView *imageView2 = [[UIImageView alloc] init];
					imageView1.image = [UIImage imageNamed:@"Check32-Circle.png"];
					imageView2.image = GimageFromString([NSString stringWithFormat:@"%ld", (long)lNoCheck]);
					UIGraphicsBeginImageContext(imageView1.image.size);
					CGRect rect = CGRectMake(0, 0, imageView1.image.size.width, imageView1.image.size.height);
					[imageView1.image drawInRect:rect];  
					[imageView2.image drawInRect:rect blendMode:kCGBlendModeMultiply alpha:0.9];  
					UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();  
					UIGraphicsEndImageContext();  
					[cell.imageView setImage:resultingImage];
					AzRETAIN_CHECK(@"E2 lNoCheck:imageView1", imageView1, 1)
					[imageView1 release];
					AzRETAIN_CHECK(@"E2 lNoCheck:imageView2", imageView2, 1)
					[imageView2 release];
					AzRETAIN_CHECK(@"E2 lNoCheck:resultingImage", resultingImage, 2)
				}
				else if (0 < lNoGray) {
					cell.imageView.image = [UIImage imageNamed:@"Check32-Ok.png"];
				}
				else { // 全てGray
					cell.imageView.image = [UIImage imageNamed:@"Check32-Gray.png"];
				}
				
				//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
				cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; // ディスクロージャボタン
				cell.showsReorderControl = YES;		// Move許可
			} 
			else {
				// 追加ボタンセル　(+)Add Group
				cell = [tableView dequeueReusableCellWithIdentifier:zCellDefault];
				if (cell == nil) {
					cell = [[[UITableViewCell alloc] 
							 initWithStyle:UITableViewCellStyleDefault      // Default型
							 reuseIdentifier:zCellDefault] autorelease];
				}
				cell.textLabel.text = NSLocalizedString(@"Add Group", @"GROUP追加");
				cell.textLabel.font = [UIFont systemFontOfSize:14];
				cell.textLabel.textAlignment = UITextAlignmentCenter; // 中央寄せ
				cell.textLabel.textColor = [UIColor blackColor];
				cell.imageView.image = nil;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
				cell.showsReorderControl = NO;
			}
			break;

		case 1:	// section: Sort list
			cell = [tableView dequeueReusableCellWithIdentifier:zCellSubtitle];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle		// サブタイトル型(3.0)
											   reuseIdentifier:zCellSubtitle] autorelease];
			}
			cell.textLabel.font = [UIFont systemFontOfSize:16];
			cell.textLabel.textAlignment = UITextAlignmentLeft;
			cell.textLabel.textColor = [UIColor blackColor];

			cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
			cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
			cell.detailTextLabel.textColor = [UIColor grayColor];

			cell.imageView.image = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
			cell.showsReorderControl = NO;		// Move禁止
			
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"Shortage Qty list", @"不足個数一覧");
					cell.detailTextLabel.text = NSLocalizedString(@"in descending order by Qty", @"個数の多いもの順");
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"Shortage Weight list",@"不足重量一覧");
					cell.detailTextLabel.text = NSLocalizedString(@"in descending order by Weight",@"重量が大きいもの順");
					break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"Stock Weight list",@"収納重量一覧");
					cell.detailTextLabel.text = NSLocalizedString(@"in descending order by Weight",@"重量が大きいもの順");
					break;
//				case 3:
//					cell.textLabel.text = NSLocalizedString(@"Sort3", @"Required Weight list");
//					cell.detailTextLabel.text = NSLocalizedString(@"Sort3detail", @"Required (in descending order by Weight)");
//					break;
				case GD_E2SORTLIST_COUNT:
					// 編集後、すぐに並び替える  zCellWithSwitch スイッチ付き専用セル
					cell = [tableView dequeueReusableCellWithIdentifier:zCellWithSwitch];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle		// サブタイトル型(3.0)
													   reuseIdentifier:zCellWithSwitch] autorelease];
						// SWITCH
						UISwitch *swView = [[UISwitch alloc] init];
						BOOL bQuickSort = [[NSUserDefaults standardUserDefaults] boolForKey:GD_OptItemsQuickSort];
						[swView setOn:bQuickSort animated:NO]; // 初期値セット
						swView.tag = 999;
						CGPoint swCenter = cell.contentView.center;
						swCenter.x += 95;
						swView.center = swCenter;
						swView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
						| UIViewAutoresizingFlexibleLeftMargin 
						| UIViewAutoresizingFlexibleBottomMargin;
						[swView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
						[cell addSubview:swView];
						[swView release];
						
						cell.textLabel.font = [UIFont systemFontOfSize:16];
						cell.textLabel.textAlignment = UITextAlignmentLeft;
						cell.textLabel.textColor = [UIColor blackColor];
						
						cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
						cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
						cell.detailTextLabel.textColor = [UIColor grayColor];
						
						cell.accessoryType = UITableViewCellAccessoryNone ;	// なし
						cell.showsReorderControl = NO;		// Move禁止
						cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
					}
					cell.textLabel.text = NSLocalizedString(@"Quickly Sort", @"即時並べ替え");
					cell.detailTextLabel.text = NSLocalizedString(@"After editing, to quickly sort.", @"見失うかも知れません");
					break;
				default:
					cell.textLabel.text = @"Err";
					break;
			}
			break;
		case 2:	// section: Function
			cell = [tableView dequeueReusableCellWithIdentifier:zCellSubtitle];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle		// サブタイトル型(3.0)
											   reuseIdentifier:zCellSubtitle] autorelease];
			}
			cell.textLabel.font = [UIFont systemFontOfSize:16];
			cell.textLabel.textAlignment = UITextAlignmentLeft;
			//cell.textLabel.textColor = [UIColor blackColor];
			
			cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
			cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
			cell.detailTextLabel.textColor = [UIColor grayColor];

			cell.imageView.image = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
			cell.showsReorderControl = NO;		// Move禁止
			
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"Upload Google", @"Google保存");
					cell.textLabel.textColor = [UIColor blueColor];
					cell.detailTextLabel.text = NSLocalizedString(@"Uploaded to the Google Document.", @"Googleドキュメントへ保存");
					break;
				case 1: // 全在庫数量を、ゼロにする
					cell.textLabel.text = NSLocalizedString(@"All stock ZERO", @"全収納数を0にする");
					cell.textLabel.textColor = [UIColor redColor];
					// この操作は取り消しできません。　アップロードしておくことを推奨します。
					cell.detailTextLabel.text = NSLocalizedString(@"This action can not be undone.", @"この操作は復旧できません");
					break;
				case 2:
					cell.textLabel.text = @"Test Data Add 10x10";
					cell.textLabel.textColor = [UIColor blackColor];
					cell.detailTextLabel.text = @"テストデータを追加します";
					break;
			}
			break;
	}
	//AzLOG(@"E2 cell Section=%d Row=%d End", indexPath.section, indexPath.row);
	return cell;
}

// UISwitch Action
- (void)switchAction: (UISwitch *)sender
{
	if (sender.tag != 999) return;

	BOOL bQuickSort = [sender isOn];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:bQuickSort forKey:GD_OptItemsQuickSort];
}

// TableView Editボタンスタイル
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
		if (indexPath.row < MiSection0Rows) 
			return UITableViewCellEditingStyleDelete;
		else
			return UITableViewCellEditingStyleInsert;
	}
    return UITableViewCellEditingStyleNone;
}

// TableView 行選択時の動作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch (indexPath.section) {
		case 0: // GROUP
			if (MiSection0Rows <= indexPath.row) {
				// Add Group
				[self e2add];
			} 
			else if (self.editing) {
				[self e2editView:indexPath];
			} 
			else {
				// 次回の画面復帰のための状態記録
				AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
				//						E1 replaceObjectAtIndex:0,1 は決定済み
				[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:indexPath.section]];
				[appDelegate.comebackIndex replaceObjectAtIndex:3 withObject:[NSNumber numberWithInteger:indexPath.row]];
				[appDelegate.comebackIndex replaceObjectAtIndex:4 withObject:[NSNumber numberWithInteger:-1]];
				[appDelegate.comebackIndex replaceObjectAtIndex:5 withObject:[NSNumber numberWithInteger:-1]];
				// E2 : NSManagedObject
				E2 *e2obj = [Me2array objectAtIndex:indexPath.row];
				// E3 へドリルダウン
				E3viewController *e3view = [[E3viewController alloc] init];
				// 以下は、E3viewControllerの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
				e3view.title = self.title;  // NSLocalizedString(@"Items", nil);
				e3view.Pe2array = Me2array;
				e3view.Pe1selected = Pe1selected; // E1
				e3view.Pe2selected = e2obj; // E2
				e3view.PiFirstSection = indexPath.row;  // Group.ROW ==>> E3で頭出しするセクション
				e3view.PiSortType = (-1);
				self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
				[self.navigationController pushViewController:e3view animated:YES];
				[e3view release];
			}
			break;

		case 1: // Sort list
			if (0 < MiSection0Rows && 0 <= indexPath.row && indexPath.row < GD_E2SORTLIST_COUNT) 
			{
				// 次回の画面復帰のための状態記録
				AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
				//						E1 replaceObjectAtIndex:0,1 は決定済み
				[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:indexPath.section]];
				[appDelegate.comebackIndex replaceObjectAtIndex:3 withObject:[NSNumber numberWithInteger:indexPath.row]];
				[appDelegate.comebackIndex replaceObjectAtIndex:4 withObject:[NSNumber numberWithInteger:-1]];
				[appDelegate.comebackIndex replaceObjectAtIndex:5 withObject:[NSNumber numberWithInteger:-1]];
				
				// E2 : NSManagedObject
//				E2 *e2obj = [Me2array objectAtIndex:indexPath.row];
				// E3 へドリルダウン
				E3viewController *e3view = [[E3viewController alloc] initWithStyle:UITableViewStylePlain];
				// 以下は、E3viewControllerの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
				//e3view.managedObjectContext = managedObjectContext;
				e3view.title = self.title;  // NSLocalizedString(@"Items", nil);
				e3view.Pe2array = Me2array;
				e3view.Pe1selected = Pe1selected; // E1
				e3view.Pe2selected = nil; //e2obj; // E2
				e3view.PiFirstSection = 0;  // Group.ROW ==>> E3で頭出しするセクション
				e3view.PiSortType = indexPath.row;
				self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
				[self.navigationController pushViewController:e3view animated:YES];
				[e3view release];
			}
			break;
			
		case 2: // Function
			switch (indexPath.row) {
				case 0: // Upload Google
					if (0 < MiSection0Rows) {
						GooDocsView *goodocs = [[GooDocsView alloc] initWithStyle:UITableViewStylePlain];
						goodocs.title = self.title;
						goodocs.PmanagedObjectContext = nil;  // Upでは使用しない
						goodocs.Pe1selected = Pe1selected; // E1
						goodocs.PbUpload = YES;
						[self.navigationController pushViewController:goodocs animated:YES];
						[goodocs release];
					}
					break;
				case 1: // 全在庫数量を、ゼロにする
					{
						UIActionSheet *sheet = [[UIActionSheet alloc] 
												initWithTitle:NSLocalizedString(@"! CAUTION !", @"注意")
												delegate:self 
												cancelButtonTitle:NSLocalizedString(@"Cancel", @"中止")
												destructiveButtonTitle:NSLocalizedString(@"All stock ZERO", @"全収納数を0にする")
												otherButtonTitles:nil];
						sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
						sheet.tag = ACTIONSEET_TAG_ALLZERO;
						if (self.interfaceOrientation == UIInterfaceOrientationPortrait 
							OR self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
							// タテ：ToolBar表示
							[sheet showFromToolbar:self.navigationController.toolbar]; // ToolBarがある場合
						} else {
							// ヨコ：ToolBar非表示（TabBarも無い）　＜＜ToolBar無しでshowFromToolbarするとFreeze＞＞
							[sheet showInView:self.view]; //windowから出すと回転対応しない
						}
						[sheet release];
					}
					break;
				case 2: // TEST ADD 10x10
					{
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TEST ADD 10x10 00" 
																		message:@"Please Select" 
																	   delegate:self 
															  cancelButtonTitle:@"CANCEL" 
															  otherButtonTitles:@"OK", nil];
						[alert show];
						[alert release];
					}
					break;
			}
			break;
	}
}

// ディスクロージャボタンが押されたときの処理
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self e2editView:indexPath];
}

// TableView Editモードの表示
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
    // この後、self.editing = YES になっている。
	// [self.tableView reloadData]だとアニメ効果が消される。　(OS 3.0 Function)を使って解決した。
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)]; // [0]セクションから1個
	[self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade]; // (OS 3.0 Function)
}

// TableView Editモード処理
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
															forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		// 削除コマンド警告　==>> (void)actionSheet にて処理
		MindexPathActionDelete = indexPath;
		// 削除コマンド警告
		UIActionSheet *action = [[UIActionSheet alloc] 
								 initWithTitle:NSLocalizedString(@"CAUTION", nil)
								 delegate:self 
								 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
								 destructiveButtonTitle:NSLocalizedString(@"DELETE Group", nil)
								 otherButtonTitles:nil];
		action.tag = ACTIONSEET_TAG_DELETEGROUP;
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

// UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (actionSheet.tag) {
		case ACTIONSEET_TAG_DELETEGROUP: // E2グループ削除
			if (buttonIndex == actionSheet.destructiveButtonIndex) 
			{ //========== E2 削除実行 ==========
				// CoreDataモデル：エンティティ間の削除ルールは双方「無効にする」を指定。（他にするとフリーズ）
				// 削除対象の ManagedObject をチョイス
				E2 *e2objDelete = [Me2array objectAtIndex:MindexPathActionDelete.row];
				// 該当行削除：　e2list 削除 ==>> しかし、managedObjectContextは削除されない！！！後ほど削除
				[Me2array removeObjectAtIndex:MindexPathActionDelete.row];  // × removeObject:e2obj];
				MiSection0Rows--; // この削除により1つ減
				// 該当行以下.row更新：　RrE2array 更新 ==>> なんと、managedObjectContextも更新される！！！
				for (NSInteger i = MindexPathActionDelete.row ; i < MiSection0Rows ; i++) {
					E2 *e2obj = [Me2array objectAtIndex:i];
					e2obj.row = [NSNumber numberWithInteger:i];
				}
				// e2obj.childs を全て削除する  ＜＜managedObjectContext を直接削除している＞＞
				for (E3 *e3obj in e2objDelete.childs) {
					[Pe1selected.managedObjectContext deleteObject:e3obj];
				}
				// RrE2arrayの削除はmanagedObjectContextに反映されないため、ここで削除する。
				[Pe1selected.managedObjectContext deleteObject:e2objDelete];
				// E1 sum属性　＜高速化＞ 親sum保持させる
				[Pe1selected setValue:[Pe1selected valueForKeyPath:@"childs.@sum.sumNoGray"] forKey:@"sumNoGray"];
				[Pe1selected setValue:[Pe1selected valueForKeyPath:@"childs.@sum.sumNoCheck"] forKey:@"sumNoCheck"];
				[Pe1selected setValue:[Pe1selected valueForKeyPath:@"childs.@sum.sumWeightStk"] forKey:@"sumWeightStk"];
				[Pe1selected setValue:[Pe1selected valueForKeyPath:@"childs.@sum.sumWeightNed"] forKey:@"sumWeightNed"];
				// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針＞＞
				NSError *error = nil;
				if (![Pe1selected.managedObjectContext save:&error]) {
					NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					exit(-1);  // Fail
				}
				// テーブルビューから選択した行を削除します。
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:MindexPathActionDelete]
				 withRowAnimation:UITableViewRowAnimationFade];
			}
			break;
		case ACTIONSEET_TAG_ALLZERO:
			if (buttonIndex == actionSheet.destructiveButtonIndex && 0 < [Me2array count]) 
			{
				// 全在庫数量を、ゼロにする
				//----------------------------------------------------------------------------CoreData Loading
				for (E2 *e2obj in Me2array) {
					//---------------------------------------------------------------------------- E3 Section
					// SELECT & ORDER BY　　テーブルの行番号を記録した属性"row"で昇順ソートする
					NSMutableArray *e3array = [[NSMutableArray alloc] initWithArray:[e2obj.childs allObjects]];
					// ソートなしのまま、全e3の .stock を ZERO にする
					for (E3 *e3obj in e3array) {
						NSInteger lStock = 0; // ZERO clear
						NSInteger lWeight = [e3obj.weight integerValue];
						NSInteger lRequired = [e3obj.need integerValue];
						[e3obj setValue:[NSNumber numberWithInteger:lStock] forKey:@"stock"];
						[e3obj setValue:[NSNumber numberWithInteger:(lWeight*lStock)] forKey:@"weightStk"];
						[e3obj setValue:[NSNumber numberWithInteger:(lRequired-lStock)] forKey:@"lack"]; // 不足数
						[e3obj setValue:[NSNumber numberWithInteger:((lRequired-lStock)*lWeight)] forKey:@"weightLack"]; // 不足重量
						if (0 < lRequired) {
							[e3obj setValue:[NSNumber numberWithInteger:1] forKey:@"noGray"];
							[e3obj setValue:[NSNumber numberWithInteger:1] forKey:@"noCheck"];
						} else {
							[e3obj setValue:[NSNumber numberWithInteger:0] forKey:@"noGray"];
							[e3obj setValue:[NSNumber numberWithInteger:0] forKey:@"noCheck"];
						}
					}
					[e3array release];
					
					// E2 sum属性　＜高速化＞ 親sum保持させる
					[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.noGray"] forKey:@"sumNoGray"];
					[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.noCheck"] forKey:@"sumNoCheck"];
					[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.weightStk"] forKey:@"sumWeightStk"];
					[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.weightNed"] forKey:@"sumWeightNed"];
				}
				
				// E1 sum属性　＜高速化＞ 親sum保持させる
				[Pe1selected setValue:[Pe1selected valueForKeyPath:@"childs.@sum.sumNoGray"] forKey:@"sumNoGray"];
				[Pe1selected setValue:[Pe1selected valueForKeyPath:@"childs.@sum.sumNoCheck"] forKey:@"sumNoCheck"];
				[Pe1selected setValue:[Pe1selected valueForKeyPath:@"childs.@sum.sumWeightStk"] forKey:@"sumWeightStk"];
				[Pe1selected setValue:[Pe1selected valueForKeyPath:@"childs.@sum.sumWeightNed"] forKey:@"sumWeightNed"];
				
				// SAVE : e3edit,e2list は ManagedObject だから更新すれば ManagedObjectContext に反映されている
				NSError *err = nil;
				if (![Pe1selected.managedObjectContext save:&err]) {
					NSLog(@"Unresolved error %@, %@", err, [err userInfo]);
					abort();
				}
				[self viewWillAppear:YES];
				// 先頭を表示する
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
				[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
			}
			break;
		default:
			break;
	}
}

// Editモード時の行Edit可否
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 ) return YES; // 行編集許可
	return NO; // 行編集禁止
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// スワイプにより1行だけが編集モードに入るときに呼ばれる。
	// このオーバーライドにより、setEditting が呼び出されないようにしている。 Add行を出さないため
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// スワイプにより1行だけが編集モードに入り、それが解除されるときに呼ばれる。
	// このオーバーライドにより、setEditting が呼び出されないようにしている。 Add行を出さないため
}

// Editモード時の行移動の可否　　＜＜最終行のAdd専用行を移動禁止にしている＞＞
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row < MiSection0Rows) return YES;
	}
	return NO;  // 移動禁止
}

// Editモード時の行移動「先」を返す　　＜＜最終行のAdd専用行への移動ならば1つ前の行を返している＞＞
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)oldPath 
														toProposedIndexPath:(NSIndexPath *)newPath {
    NSIndexPath *target = newPath;
	NSInteger rows = MiSection0Rows - 1;  // 移動可能な行数（Add行を除く）
	// セクション０限定仕様
	if (newPath.section != 0 || rows < newPath.row  ) {
		// Add行が異動先になった場合、その1つ前の通常行を返すことにより、Add行への移動禁止となる。
		// Add行ならば、E2ノードの最終行(row-1)を応答する
		target = [NSIndexPath indexPathForRow:rows inSection:0];
	}
    return target;
}

// Editモード時の行移動処理　　＜＜CoreDataにつきArrayのように削除＆挿入ではダメ。ソート属性(row)を書き換えることにより並べ替えている＞＞
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)oldPath 
												  toIndexPath:(NSIndexPath *)newPath {
	// CoreDataは順序を保持しないため 属性"ascend"を昇順ソート表示している
	// この 属性"ascend"の値を行異動後に更新するための処理

	// e2list 更新 ==>> なんと、managedObjectContextも更新される。 ただし、削除や挿入は反映されない！！！
	E2 *e2obj = [Me2array objectAtIndex:oldPath.row];

	[Me2array removeObjectAtIndex:oldPath.row];
	[Me2array insertObject:e2obj atIndex:newPath.row];
	
	NSInteger start = oldPath.row;
	NSInteger end = newPath.row;
	if (end < start) {
		start = newPath.row;
		end = oldPath.row;
	}
	for (NSInteger i = start; i <= end; i++) {
		e2obj = [Me2array objectAtIndex:i];
		e2obj.row = [NSNumber numberWithInteger:i];
	}

	// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針＞＞
	NSError *error = nil;
	if (![Pe1selected.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"didReceiveMemoryWarning" 
													 message:@"E2viewController" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
    [super didReceiveMemoryWarning];
}

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		// ホームボタンが画面の下側にある状態。通常
		[self.navigationController setToolbarHidden:NO animated:YES]; // ツールバー表示する
		return YES; // この方向は常に許可する
	} 
	else if (MbOptShouldAutorotate) {
		// 横方向や逆向きのとき
		[self.navigationController setToolbarHidden:YES animated:YES]; // ツールバー消す
	}
	return MbOptShouldAutorotate;
}


@end
