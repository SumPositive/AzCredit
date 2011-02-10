//
//  E3viewController.m
//  iPack
//
//  Created by 松山 和正 on 09/12/06.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Elements.h"
#import "E3viewController.h"
#import "E3detailTVC.h"
//#import "E3edit.h"
#import "SettingTVC.h"
#import "ItemTouchV.h"

#define ACTIONSEET_TAG_DELETEITEM	199

@interface E3viewController (PrivateMethods)
	- (void)azSettingView;
	- (void)azReflesh;
	- (void)azItemsGrayHide: (UIBarButtonItem *)sender;
	- (void)e3detailView:(NSIndexPath *)indexPath;
	- (void)cellButton: (UIButton *)button ;
	- (void)alertWeightOver;
//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray	*Me3array;
//----------------------------------------------Owner移管につきdealloc時のrelese不要
//----------------------------------------------assign
	NSIndexPath	  *MindexPathActionDelete; // 削除するIndexPath
	BOOL MbFirstOne;
	BOOL MbOptShouldAutorotate;
	BOOL MbAzOptTotlWeightRound;
	BOOL MbAzOptShowTotalWeight;
	BOOL MbAzOptShowTotalWeightReq;
	BOOL MbAzOptItemsGrayShow;
	BOOL MbAzOptItemsQuickSort;
	BOOL MbAzOptCheckingAtEditMode;
@end
@implementation E3viewController
@synthesize  Pe2array;
@synthesize  Pe1selected;
@synthesize  Pe2selected;
@synthesize  PiFirstSection;
@synthesize  PiSortType;

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	AzRETAIN_CHECK(@"E3 Me3array", Me3array, 1)
	[Me3array release];

	// @property (retain)
	AzRETAIN_CHECK(@"E3 Pe2selected", Pe2selected, 5) // 4 or 5
	[Pe2selected release];
	AzRETAIN_CHECK(@"E3 Pe1selected", Pe1selected, 4) // 3 or 4
	[Pe1selected release];
	AzRETAIN_CHECK(@"E3 Pe2array", Pe2array, 1)
	[Pe2array release];
    
	[super dealloc];
}

- (void)viewDidUnload {
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。
	[Me3array release];			Me3array = nil;
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"viewDidUnload" 
													 message:@"E3viewController" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
}


// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStylePlain]) {  // セクションなしテーブル
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

- (void)azReflesh
{
	if (MbAzOptItemsQuickSort == NO) {
		MbAzOptItemsQuickSort = YES; // viewWillAppear内でデータ取得(ソート)を通るようにするため
		// 再表示: データ再取得（ソート）して表示する
		[self viewWillAppear:YES];
		MbAzOptItemsQuickSort = NO; // 戻しておく
	}
}

- (void)azItemsGrayHide: (UIBarButtonItem *)sender 
{
	MbAzOptItemsGrayShow = !(MbAzOptItemsGrayShow); // 反転

	if (MbAzOptItemsGrayShow) {
		sender.image = [UIImage imageNamed:@"ItemGrayShow.png"]; // Gray Show
	} else {
		sender.image = [UIImage imageNamed:@"ItemGrayHide.png"]; // Gray Hide
	}

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:MbAzOptItemsGrayShow forKey:GD_OptItemsGrayShow];
	
	// 再表示 -------------------------------------------------------------------
	// 表示行数が変化するための処理　　 表示最上行を取得する
	NSArray *arCells = [self.tableView indexPathsForVisibleRows]; // 現在見えているセル群
	NSIndexPath *topPath = nil;
	for (NSInteger i=0 ; i<[arCells count] ; i++) {
		topPath = [arCells objectAtIndex:i]; 
		if (topPath.row < [[Me3array objectAtIndex:topPath.section] count]) {
			E3 *e3obj = [[Me3array objectAtIndex:topPath.section] objectAtIndex:topPath.row];
			if ([e3obj.need intValue] != 0) {
				// 必要数が0でない「Grayでない」セル発見
				break;
			}
		}
	}
	
	// 再表示
	[self viewWillAppear:YES];
	
	// 元の最上行を再現する
	if (topPath) [self.tableView scrollToRowAtIndexPath:topPath 
				  atScrollPosition:UITableViewScrollPositionTop animated:NO];  
}


// viewDidLoadメソッドは，TableViewContorllerオブジェクトが生成された後，実際に表示される際に1度だけ呼び出されるメソッド
- (void)viewDidLoad 
{
	[super viewDidLoad];
	Me3array = nil;
	
	MbFirstOne = YES; // 最初に1度だけ通すため

	//self.title = 
	// Set up NEXT Left [] buttons.
	// Set up Left [Edit] buttons.
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.allowsSelectionDuringEditing = YES;
	
	//以下をしてもTouchイベント取得できず
	//	self.view.backgroundColor = [UIColor whiteColor];
	//	[self.view becomeFirstResponder];
	
	// viewDidLoad内で参照しているため。 基本的には、viewWillAppearで取得すること
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbAzOptItemsGrayShow = [defaults boolForKey:GD_OptItemsGrayShow];
	MbAzOptItemsQuickSort = [defaults boolForKey:GD_OptItemsQuickSort];
	
	// Set up NEXT Left [Back] buttons.
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]
									   initWithImage:[UIImage imageNamed:@"simpleLeft3-icon16.png"]
									   style:UIBarButtonItemStylePlain  target:nil  action:nil];
	self.navigationItem.backBarButtonItem = backButtonItem;
	[backButtonItem release];		

	// Tool Bar Button
	UIBarButtonItem *buFlex = [[[UIBarButtonItem alloc] 
								initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
															target:nil action:nil] autorelease];
	UIBarButtonItem *buSetting = [[[UIBarButtonItem alloc] 
								   initWithImage:[UIImage imageNamed:@"Setting-icon16.png"]
														style:UIBarButtonItemStylePlain
									  target:self action:@selector(azSettingView)] autorelease];

	// セグメントが回転に対応せず不具合（高さが変わる）発生するため、ボタンに戻した。
	UIImage *img;
	if (MbAzOptItemsGrayShow) {
		img = [UIImage imageNamed:@"ItemGrayShow.png"]; // Gray Show
	} else {
		img = [UIImage imageNamed:@"ItemGrayHide.png"]; // Gray Hide
	}
	UIBarButtonItem *buGray = [[[UIBarButtonItem alloc] initWithImage:img
																style:UIBarButtonItemStylePlain
																target:self 
															   action:@selector(azItemsGrayHide:)] 
							   autorelease];

	NSArray *aArray;
	if (0 <= self.PiSortType && MbAzOptItemsQuickSort == NO) {
		UIBarButtonItem *buRefresh = [[[UIBarButtonItem alloc] 
									   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
									   target:self action:@selector(azReflesh)] autorelease];
		
		aArray = [NSArray arrayWithObjects:  buGray, buFlex, buRefresh, buFlex, buSetting, nil];
	} else {
		aArray = [NSArray arrayWithObjects:  buGray, buFlex, buSetting, nil];
	}
	self.navigationController.toolbarHidden = NO;
	[self setToolbarItems:aArray animated:YES];

/* imageNamed:はキャッシュされるので、十分効率良い。よって以下没
	// ＜高速化＞ アイコン イメージ プリ ロード
	MimgCheckCircle = [UIImage imageNamed:@"Check32-Circle.png"];
	MimgCheckOk	= [UIImage imageNamed:@"Check32-Ok.png"];
	MimgCheckOver = [UIImage imageNamed:@"Check32-Over.png"];
	MimgCheckGray = [UIImage imageNamed:@"Check32-Gray.png"];
*/
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される　　＜＜見せない処理をする＞＞
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptShouldAutorotate = [defaults boolForKey:GD_OptShouldAutorotate];
	MbAzOptTotlWeightRound = [defaults boolForKey:GD_OptTotlWeightRound]; // YES=四捨五入 NO=切り捨て
	MbAzOptShowTotalWeight = [defaults boolForKey:GD_OptShowTotalWeight];
	MbAzOptCheckingAtEditMode = [defaults boolForKey:GD_OptCheckingAtEditMode];
	
	//self.title = ;　呼び出す側でセット済み。　変化させるならばココで。
	
	
	if (0 <= PiSortType && MbAzOptItemsQuickSort == NO && Me3array != nil) {
		// 読み込み(ソート)せずに、既存テーブルビューを更新します。
		[self.tableView reloadData];  // これがないと、次のセクションスクロールでエラーになる
		return; 
	}
	
	if ([Pe2array count] <= 0) return;  // NoGroup

	// 最新データ取得＆TV更新：Add直後などに再取得が必要なのでここで処理。　＜＜viewDidLoadだとAdd後呼び出されない＞＞
	//----------------------------------------------------------------------------CoreData Loading
	NSMutableArray *muE3arry = [[NSMutableArray alloc] init];

	if (PiSortType < 0) {
		// セクション(Group)別リスト
		for (E2 *e2obj in Pe2array) {
			//---------------------------------------------------------------------------- E3 Section
			// SELECT & ORDER BY　　テーブルの行番号を記録した属性"row"で昇順ソートする
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES];
			NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
			// 選択中の E2(e2selected) の子となる E3(e2selected.childs) を抽出する。
			NSMutableArray *muSection = [[NSMutableArray alloc] initWithArray:[e2obj.childs allObjects]];
			// 並べ替えを実行してlistContentに格納します。
			[muSection sortUsingDescriptors:sortDescriptors]; // NSMutableArray内ソート　NSArrayはダメ
			[muE3arry addObject:muSection];  // 二次元追加　addObjectsFromArray:にすると同次元になってしまう。
			[muSection release];
			[sortDescriptors release];
			[sortDescriptor release];
		} 
	}
	else {
		// 全体ソートリスト　＜＜セクション[0]に全アイテムを入れてソートする＞＞
		NSMutableArray *muSect0 = nil;
		for (E2 *e2obj in Pe2array) {
			//---------------------------------------------------------------------------- E3 Section
			// 選択中の E2(e2obj) の子となる E3(e2obj.childs) を抽出する。
			NSMutableArray *muSection = [[NSMutableArray alloc] initWithArray:[e2obj.childs allObjects]];

			if (muSect0 == nil) {
				[muE3arry addObject:muSection];  // Section[0]を新たに追加
				muSect0 = [muE3arry objectAtIndex:0]; // Section[0]のArray
			} else {
				[muSect0 addObjectsFromArray:muSection]; // Section[0]のArray末尾に追加
			}
			[muSection release];
		}
		// SELECT & ORDER BY　　テーブルの行番号を記録した属性"row"で昇順ソートする
		// Sort条件セット
		NSString *zSortKey;
		BOOL bSortAscending;
		switch (PiSortType) {
			case 0:
				zSortKey = @"lack";   //NSLocalizedString(@"Sort0key", nil);
				bSortAscending = NO;  //[NSLocalizedString(@"Sort0ascending", nil) isEqualToString:@"YES"];
				break;
			case 1:
				zSortKey = @"weightLack";  //NSLocalizedString(@"Sort1key", nil);
				bSortAscending = NO;       //[NSLocalizedString(@"Sort1ascending", nil) isEqualToString:@"YES"];
				break;
			case 2:
				zSortKey = @"weightStk";  //NSLocalizedString(@"Sort2key", nil);
				bSortAscending = NO;      //[NSLocalizedString(@"Sort2ascending", nil) isEqualToString:@"YES"];
				break;
//			case 3:
//				zSortKey = @"weightNed";  //NSLocalizedString(@"Sort3key", nil);
//				bSortAscending = NO;      //[NSLocalizedString(@"Sort3ascending", nil) isEqualToString:@"YES"];
//				break;
			default:
				zSortKey = @"row";
				bSortAscending = YES;
				break;
		}
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:zSortKey ascending:bSortAscending];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
		// 並べ替えを実行
		[muSect0 sortUsingDescriptors:sortDescriptors]; // muE3arry[0]をソートしていることになる
		[sortDescriptor release];
		[sortDescriptors release];
	}

	if (Me3array != muE3arry) {
		[Me3array release];
		Me3array = [muE3arry retain];
	}
	[muE3arry release];
	
	// テーブルビューを更新します。
    [self.tableView reloadData];  // これがないと、次のセクションスクロールでエラーになる

	// 指定位置までテーブルビューの行をスクロールさせる初期処理　＜＜レコードセット後でなければならないので、この位置になった＞＞
	if (MbFirstOne && PiSortType < 0) {
		MbFirstOne = NO; // 最初に1度だけ通すため
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:PiFirstSection];
		[self.tableView scrollToRowAtIndexPath:indexPath 
						atScrollPosition:UITableViewScrollPositionTop animated:NO];  // 実機検証結果:NO
	}
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる　＜＜魅せる処理をする＞＞
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

	// (-1,-1)にしてE3を未選択状態にする
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.comebackIndex replaceObjectAtIndex:4 withObject:[NSNumber numberWithInteger:-1]];
	[appDelegate.comebackIndex replaceObjectAtIndex:5 withObject:[NSNumber numberWithInteger:-1]];

	if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
		// ホームボタンが画面の下側にある状態。通常
		[self.navigationController setToolbarHidden:NO animated:NO]; // ツールバー表示する
	} else {
		// 横方向や逆向きのとき
		[self.navigationController setToolbarHidden:YES animated:NO]; // ツールバー消す
	}
	
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
}

/* // 編集モードから戻ったときに呼び出される ????????
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
}*/
	
	/*
// タッチイベント開始：左端のアイコン部のクリックを検出するため
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	//[super touchesBegan:touches withEvent:event];
	//[self.nextResponder touchesBegan:touches withEvent:event];
	
	MpointBegin = [[touches anyObject] locationInView:self.tableView];
}
*/


// カムバック処理（復帰再現）：E2 から呼ばれる
- (void)viewComeback:(NSArray *)selectionArray
{
	NSInteger iSec = [[selectionArray objectAtIndex:4] intValue];
	NSInteger iRow = [[selectionArray objectAtIndex:5] intValue];
	if (iSec < 0) return; // この画面表示
	if (iRow < 0) return; // fail.
	
	if ([Me3array count] <= iSec) return; // 無効セクション
	if ([[Me3array objectAtIndex:iSec] count] <= iRow) return; // 無効セル（削除されたとか）

	// 前回選択したセル位置
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:iRow inSection:iSec];
	// 指定位置までテーブルビューの行をスクロールさせる初期処理
	[self.tableView scrollToRowAtIndexPath:indexPath
								atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	// さらに、E3detail まで復元する。
	[self e3detailView:indexPath];
}

/*
- (void)e3add:(NSInteger)section 
{
	// ContextにE3ノードを追加する　E2edit内でCANCELならば削除している
	E3 *e3newObj = [NSEntityDescription insertNewObjectForEntityForName:@"E3"
												 inManagedObjectContext:Pe2selected.managedObjectContext];
    // NEW 編集用のビューを作る
	//E3edit *e3editView = [[[E3edit alloc] init] autorelease];
	if (Me3editView == nil) {
		Me3editView = [[E3edit alloc] init];
	}
	Me3editView.title = NSLocalizedString(@"Add Item", @"アイテム追加");
	Me3editView.Pe2array = Pe2array;
	Me3editView.Pe3array = Me3array;
	Me3editView.Pe1selected = Pe1selected;
	Me3editView.Pe2selected = [Pe2array objectAtIndex:section];  //e2selected ではない！
	Me3editView.Pe3target = e3newObj;
	Me3editView.PbAddObj = YES;
	Me3editView.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:Me3editView animated:MbAzOptEditAnimation];
}

- (void)e3editView:(NSIndexPath *)indexPath
{
	if ([[Me3array objectAtIndex:indexPath.section] count] <= indexPath.row) return;  // Addボタン行の場合パスする
	
	E3 *e3obj = [[Me3array objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
    // EDIT 編集対象のオブジェクトを渡す
	//E3edit *PrE3editView = [[[E3edit alloc] init] autorelease];
	if (Me3editView == nil) {
		Me3editView = [[E3edit alloc] init];
	}
    Me3editView.title = NSLocalizedString(@"Edit Item", @"アイテム編集");
	Me3editView.Pe2array = Pe2array;
	Me3editView.Pe3array = Me3array;
	Me3editView.Pe1selected = Pe1selected;
	Me3editView.Pe2selected = [Pe2array objectAtIndex:indexPath.section];  //e2selected ではない！
	Me3editView.Pe3target = e3obj;
    Me3editView.PbAddObj = NO;
	Me3editView.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:Me3editView animated:MbAzOptEditAnimation];
}
*/

// TableView セクション数を応答
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return [Me3array count];
}

// TableView セクションの行数を応答
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	NSInteger rows = [[Me3array objectAtIndex:section] count];
	if (PiSortType < 0) rows++; // [Add行]表示 （編集時のアニメション不良に対応するため）
	return rows;
}

// TableView セクション名を応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	if (PiSortType < 0) {
		// Group E2以下の Sum(E3.weightStk) と Sum(E3.weightNed) の集計値を得ている。
		E2 *e2obj = [Pe2array objectAtIndex:section];
		double dWeightStk;
		double dWeightReq;
		if (MbAzOptShowTotalWeight) {
			long lWeightStk = [[e2obj valueForKeyPath:@"sumWeightStk"] longValue];
			if (MbAzOptTotlWeightRound) {
				// 四捨五入　＜＜ %.1f により小数第2位が丸められる＞＞ 
				dWeightStk = (double)lWeightStk / 1000.0f;
			} else {
				// 切り捨て                       ↓これで下2桁が0になる
				dWeightStk = (double)(lWeightStk / 100) / 10.0f;
			}
		}
		if (MbAzOptShowTotalWeightReq) {
			long lWeightReq = [[e2obj valueForKeyPath:@"sumWeightNed"] longValue];
			if (MbAzOptTotlWeightRound) {
				// 四捨五入　＜＜ %.1f により小数第2位が丸められる＞＞ 
				dWeightReq = (double)lWeightReq / 1000.0f;
			} else {
				// 切り捨て                       ↓これで下2桁が0になる
				dWeightReq = (double)(lWeightReq / 100) / 10.0f;
			}
		}
		if (MbAzOptShowTotalWeight && MbAzOptShowTotalWeightReq) {
			return [NSString stringWithFormat:@"%@  %.1f／%.1fKg", e2obj.name, dWeightStk, dWeightReq];
		} else if (MbAzOptShowTotalWeight) {
			return [NSString stringWithFormat:@"%@  %.1fKg", e2obj.name, dWeightStk];
		} else if (MbAzOptShowTotalWeightReq) {
			return [NSString stringWithFormat:@"%@  ／%.1fKg", e2obj.name, dWeightReq];
		} else {
			return [NSString stringWithFormat:@"%@", e2obj.name];
		}
	}
	else {
		switch (PiSortType) {
			case 0:
				return NSLocalizedString(@"Shortage Qty list", @"不足個数一覧");
				break;
			case 1:
				return NSLocalizedString(@"Shortage Weight list",@"不足重量一覧");
				break;
			case 2:
				return NSLocalizedString(@"Stock Weight list",@"収納重量一覧");
				break;
//			case 3:
//				return NSLocalizedString(@"Sort3", @"Shortage Qty list");
//				break;
		}
	}
	return @"Err";
}
/*
// TableView セクションインデックスを表示
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return 　E2.name だけの配列を返すこと
}
*/
// セルの高さを指示する  ＜＜ [Gray Hide] 高さ0にする＞＞
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger rows = [[Me3array objectAtIndex:indexPath.section] count];
	if (rows <= indexPath.row) {
		return 35; // [Add行]
	}
	else if (!MbAzOptItemsGrayShow) {
		// Gray Hide
		E3 *e3obj = [[Me3array objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		if ([e3obj.need integerValue] == 0) return 0; // Hide さらに cell をクリアにしている
	}
	return 44; // デフォルト：44ピクセル
}

// TableView 指定されたセルを生成＆表示
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *zCellHiddon = @"CellE3Hiddon";  // 高さ0非表示用セル
	static NSString *zCellE3item = @"CellE3item";
	static NSString *zCellDefault = @"CellDefault";
    UITableViewCell *cell = nil;

	//AzLOG(@"E3 cell Section=%d Row=%d Begin", indexPath.section, indexPath.row);
	
	if (indexPath.row < [[Me3array objectAtIndex:indexPath.section] count]) {
		// E3 Node Object
		E3 *e3obj = [[Me3array objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		// E3ノードセル
		if (!MbAzOptItemsGrayShow && [e3obj.need integerValue] == 0) {
			// 高さ0非表示用セル　＜＜専用セルを作って高速化＞＞
			cell = [tableView dequeueReusableCellWithIdentifier:zCellHiddon];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											   reuseIdentifier:zCellHiddon] autorelease];
				cell.textLabel.text = @"";
				cell.detailTextLabel.text = @"";
				cell.imageView.image = nil;
				cell.accessoryType = UITableViewCellAccessoryNone;	// なし
				cell.showsReorderControl = NO; // Move禁止
			}
			return cell;
		}
		
		cell = [tableView dequeueReusableCellWithIdentifier:zCellE3item];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle		// サブタイトル型(3.0)
												reuseIdentifier:zCellE3item] autorelease];
			// 行毎に変化の無い定義は、ここで最初に1度だけする
			cell.textLabel.font = [UIFont systemFontOfSize:16];
			cell.textLabel.textAlignment = UITextAlignmentLeft;
			//cell.textLabel.textColor = [UIColor blackColor];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
			cell.textLabel.textAlignment = UITextAlignmentLeft;
			cell.detailTextLabel.textColor = [UIColor grayColor];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // ＞
			//cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; // ディスクロージャボタン
		}

		if ([e3obj.name length] <= 0) 
			cell.textLabel.text = NSLocalizedString(@"Untitled", nil);
		else
			cell.textLabel.text = e3obj.name;

		long lStock = [e3obj.stock longValue];
		long lNeed = [e3obj.need longValue];
		long lWeight = [e3obj.weight longValue];
		
		// 左ボタン ------------------------------------------------------------------
		UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom]; // autorelease
		bu.frame = CGRectMake(0,0, 44,44);
		//UIEdgeInsets inset;  ＜＜高速化のため省略＞＞
		//inset.top = inset.left = inset.right = inset.bottom = 4; //= (40 - 32) / 2
		//bu.contentEdgeInsets = inset;
		bu.tag = indexPath.section * GD_SECTION_TIMES + indexPath.row;
		[bu addTarget:self action:@selector(cellButton:) forControlEvents:UIControlEventTouchUpInside];
		bu.backgroundColor = [UIColor clearColor]; //背景透明
		bu.showsTouchWhenHighlighted = YES;
		[cell.contentView addSubview:bu];  
		//[bu release]; buttonWithTypeにてautoreleseされるため不要。UIButtonにinitは無い。

		if (lNeed == 0) {  // 必要なし
			cell.textLabel.textColor = [UIColor grayColor];
			cell.imageView.image = [UIImage imageNamed:@"Check32-Gray.png"];
		}
		else if (lStock < lNeed) {  // E3では数量比較できるから
			cell.textLabel.textColor = [UIColor blackColor];
			cell.imageView.image = [UIImage imageNamed:@"Check32-Circle.png"];
		}
		else {
			cell.textLabel.textColor = [UIColor blackColor];
			if (lStock == lNeed) {
				cell.imageView.image = [UIImage imageNamed:@"Check32-Ok.png"];
			} else {
				cell.imageView.image = [UIImage imageNamed:@"Check32-Over.png"];
			}
		}
		
		NSString *zNote;
		if (0 < [e3obj.note length]) zNote = e3obj.note;
		else zNote = @"";
		
		switch (PiSortType) {
			case 0: // 不足数量降順
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%4ld／%ld %6ldg  %@(%ld)%@ %@",
											 lStock,lNeed,lWeight,
											 NSLocalizedString(@"Shortage", @"不足"), 
											 [e3obj.lack longValue],
											 NSLocalizedString(@"Qty", @"個"), zNote];
				cell.showsReorderControl = NO;	  // Move禁止
				break;
			case 1: // 不足重量降順
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%4ld／%ld %6ldg  %@(%ld)g %@",
											 lStock,lNeed,lWeight,
											 NSLocalizedString(@"Shortage", @"不足"), 
											 [e3obj.weightLack longValue], zNote];
				cell.showsReorderControl = NO;	  // Move禁止
				break;
			case 2: // 在庫重量降順
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%4ld／%ld %6ldg  %@(%ld)g %@",
											 lStock,lNeed,lWeight,NSLocalizedString(@"Stock", @"収納"),
											 [e3obj.weightStk longValue], zNote];
				cell.showsReorderControl = NO;	  // Move禁止
				break;
			default:
#ifdef AzDEBUG
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%4ld／%ld %6ldg  %@ [%d]",
											 lStock,lNeed,lWeight,zNote,[e3obj.row intValue]];
#else
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%4ld／%ld %6ldg  %@",
											 lStock,lNeed,lWeight,zNote];
#endif
				cell.showsReorderControl = YES;  // Move許可
				break;
		}
	}
	else {
		// [Add行]セル
		cell = [tableView dequeueReusableCellWithIdentifier:zCellDefault];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault      // Default型
										   reuseIdentifier:zCellDefault] autorelease];
		}
		cell.textLabel.text = NSLocalizedString(@"Add Item",nil);
		cell.textLabel.font = [UIFont systemFontOfSize:12];
		cell.textLabel.textAlignment = UITextAlignmentCenter; // 中央寄せ
		cell.textLabel.textColor = [UIColor blackColor];
		cell.imageView.image = nil;
		cell.accessoryType = UITableViewCellEditingStyleInsert; // (+)
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
		cell.showsReorderControl = NO; // Move禁止
	}
	//AzLOG(@"E3 cell Section=%d Row=%d End", indexPath.section, indexPath.row);
	return cell;
}

- (void)cellButton: (UIButton *)button 
{
	if (MbAzOptCheckingAtEditMode && !self.editing) return; // 編集時のみ許可
	
	E3 *e3obj = nil;
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

	[self.tableView reloadData];
}

- (void)alertWeightOver
{
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WeightOver",nil)
													 message:NSLocalizedString(@"WeightOver message",nil)
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
}


// TableView Editボタンスタイル
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [[Me3array objectAtIndex:indexPath.section] count]) {
		if (!MbAzOptItemsGrayShow) {
			E3 *e3obj = [[Me3array objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
			if ([e3obj.need integerValue]==0) {
				return UITableViewCellEditingStyleNone; // なし
			}
		}
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleInsert;
}

// TableView 行選択時の動作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];		// 先ずは選択状態表示を解除する
	// 次回の画面復帰のための状態記録
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//						E1 replaceObjectAtIndex:0,1 は決定済み
	//						E2 replaceObjectAtIndex:2,3 は決定済み
	[appDelegate.comebackIndex replaceObjectAtIndex:4 withObject:[NSNumber numberWithInteger:indexPath.section]];
	[appDelegate.comebackIndex replaceObjectAtIndex:5 withObject:[NSNumber numberWithInteger:indexPath.row]];

//	if (self.editing) {
		// 編集選択およびディスクロージャボタン
		[self e3detailView:indexPath];
//	}
}

// UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (actionSheet.tag) {
		case ACTIONSEET_TAG_DELETEITEM: // E3アイテム削除
			// ＜＜Sortのとき、Pe2selected==nil である＞＞
			if (buttonIndex == actionSheet.destructiveButtonIndex && Pe2selected != nil) 
			{ //========== E3 削除実行 ==========
				// CoreDataモデル：エンティティ間の削除ルールは双方「無効にする」を指定。（他にするとフリーズ）
				// 削除対象の ManagedObject をチョイス
				E3 *e3objDelete = [[Me3array objectAtIndex:MindexPathActionDelete.section] 
												objectAtIndex:MindexPathActionDelete.row];
				// 該当行削除：　e3list 削除 ==>> しかし、managedObjectContextは削除されない！！！後ほど削除
				[[Me3array objectAtIndex:MindexPathActionDelete.section] 
						removeObjectAtIndex:MindexPathActionDelete.row];  // × removeObject:e3obj];
				// 該当行以下.row更新：　e3list 更新 ==>> なんと、managedObjectContextも更新される！！！
				for (NSInteger i = MindexPathActionDelete.row ; 
								i < [[Me3array objectAtIndex:MindexPathActionDelete.section] count] ; i++) {
					E3 *e3obj = [[Me3array objectAtIndex:MindexPathActionDelete.section] objectAtIndex:i];
					e3obj.row = [NSNumber numberWithInteger:i];
				}
				// e3listの削除はmanagedObjectContextに反映されないため、ここで削除する。
				[Pe2selected.managedObjectContext deleteObject:e3objDelete];
				
				// E2 sum属性　＜高速化＞ 親sum保持させる
				[Pe2selected setValue:[Pe2selected valueForKeyPath:@"childs.@sum.noGray"] forKey:@"sumNoGray"];
				[Pe2selected setValue:[Pe2selected valueForKeyPath:@"childs.@sum.noCheck"] forKey:@"sumNoCheck"];
				[Pe2selected setValue:[Pe2selected valueForKeyPath:@"childs.@sum.weightStk"] forKey:@"sumWeightStk"];
				[Pe2selected setValue:[Pe2selected valueForKeyPath:@"childs.@sum.weightNed"] forKey:@"sumWeightNed"];
				
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
		default:
			break;
	}
}

/* // ディスクロージャボタンが押されたときの処理
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
{
	[self e3detailView:indexPath];
}*/

- (void)e3detailView:(NSIndexPath *)indexPath 
{
	// E3detailTVC へドリルダウン
	E3detailTVC *e3detail = [[E3detailTVC alloc] init];
	// 以下は、E3detailTVCの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
	e3detail.title = self.title;  // NSLocalizedString(@"Items", nil);
	e3detail.Pe2array = Pe2array;
	e3detail.Pe3array = Me3array;
	if ([[Me3array objectAtIndex:indexPath.section] count] <= indexPath.row) {
		// Add Item
		// ContextにE3ノードを追加する　                               ＜＜Sortのとき、Pe2selected==nil である＞＞
		e3detail.Pe3target = [NSEntityDescription insertNewObjectForEntityForName:@"E3"
														   inManagedObjectContext:Pe1selected.managedObjectContext];
		e3detail.PiAddGroup = indexPath.section; // Add mode
	}
	else {
		// Edit Item
		e3detail.Pe3target = [[Me3array objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		e3detail.PiAddGroup = (-1); // Edit mode
	}
	e3detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:YES];
	[e3detail release];
}

// TableView Editモードの表示
- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
	[super setEditing:editing animated:animated];
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
								 destructiveButtonTitle:NSLocalizedString(@"DELETE Item", nil)
								 otherButtonTitles:nil];
		action.tag = ACTIONSEET_TAG_DELETEITEM;
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

// Editモード時の行Edit可否
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES; // 行編集許可
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

// Editモード時の行移動の可否　　＜＜最終行のAdd専用行を移動禁止にしている＞＞
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (0 <= PiSortType) return NO; // SortTypeでは常時移動禁止
	
	if (indexPath.row < [[Me3array objectAtIndex:indexPath.section] count]) {
		if (!MbAzOptItemsGrayShow) {
			E3 *e3obj = [[Me3array objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
			if ([e3obj.need integerValue]==0) {
				return NO;  // Gray行につき移動禁止
			}
		}
		return YES; // Move 対象
	}
	return NO;  // Add行につき移動禁止
}

// Editモード時の行移動「先」を応答　　＜＜最終行のAdd行への移動ならば1つ前の行を応答している＞＞
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)oldPath 
														toProposedIndexPath:(NSIndexPath *)newPath {
	//NSIndexPath *target = newPath;
	// Add行が異動先になった場合、その1つ前の通常行を返すことにより、Add行への移動禁止となる。
	// 同じく、Gray行が異動先になった場合、その1つ前の通常行を返すことにより、Gray行への移動禁止となる。
	NSInteger rows = [[Me3array objectAtIndex:newPath.section] count];  // 移動可能な行数（Add行を除く）
	if (oldPath.section == newPath.section && 0 < rows) rows--; // 同セクション内では元行が減るため (beginUpdates-endUpdatesを使う方法もある）
	if (rows <= newPath.row) {
		// Add行ならば、E3ノードの最終行(row-1)を応答する
		newPath = [NSIndexPath indexPathForRow:rows inSection:newPath.section];
	}
	// [Add]の上に[Gray]がある場合、次の処理も通る
	if (!MbAzOptItemsGrayShow) {
		AzLOG(@"newPath=(%d,%d)", newPath.section, newPath.row);
//		if (newPath.row==0) return newPath; // セクション先頭ならば即決定
//		if (oldPath.section==newPath.section && newPath.row==oldPath.row) return newPath; // 同セルならば、そのまま
		// [Gray Hide]対応：移動先が[Gray]ならば上に辿って、常に[Gray]の先頭が移動先になるようにする。
		NSInteger iRow = newPath.row;
//		NSInteger iOffset = 0;
		if ((oldPath.section==newPath.section && oldPath.row < newPath.row) OR oldPath.section < newPath.section) {
			// 下へ移動
//			iOffset = 0;
		} else {
			// 上へ移動
			while (0 < iRow) {
				AzLOG(@"---iRow=%d", iRow);
				// 1行上の.needを調べる
				E3 *e3new = [[Me3array objectAtIndex:newPath.section] objectAtIndex:iRow - 1];
				if ([e3new.need integerValue] != 0) {
					// 1行上が[Gray]でなければ、ここを移動先にする。これにより[Gray]行は移動行より下になる。
					break;
				}
				iRow--; // 1行上へ
			}
		}
		
		if (newPath.row != iRow) {
			newPath = [NSIndexPath indexPathForRow:iRow inSection:newPath.section];
		}
	}
    return newPath;
}

// Editモード時の行移動処理　　＜＜CoreDataにつきArrayのように削除＆挿入ではダメ。ソート属性(row)を書き換えることにより並べ替えている＞＞
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)oldPath 
													toIndexPath:(NSIndexPath *)newPath {
	// e3list 更新 ==>> なんと、managedObjectContextも更新される。 ただし、削除や挿入は反映されない！！！
	// セクションを跨いだ移動にも対応
	
	//--------------------------------------------------(1)MutableArrayの移動
	E3 *e3obj = [[Me3array objectAtIndex:oldPath.section] objectAtIndex:oldPath.row];
	// 移動元から削除
	[[Me3array objectAtIndex:oldPath.section] removeObjectAtIndex:oldPath.row];
	// 移動先へ挿入　＜＜newPathは、targetIndexPathForMoveFromRowAtIndexPath にて[Gray]行の回避処理した行である＞＞
	[[Me3array objectAtIndex:newPath.section] insertObject:e3obj atIndex:newPath.row];

	NSInteger i;
	//--------------------------------------------------(2)row 付け替え処理
	if (oldPath.section == newPath.section) {
		// 同セクション内での移動
		NSInteger start = oldPath.row;
		NSInteger end = newPath.row;
		if (end < start) {
			start = newPath.row;
			end = oldPath.row;
		}
		for (i = start ; i <= end ; i++) {
			e3obj = [[Me3array objectAtIndex:newPath.section] objectAtIndex:i];
			e3obj.row = [NSNumber numberWithInteger:i];
		}
	} else {
		// 異セクション間の移動　＜＜親(.e2selected)の変更が必要＞＞
		// 移動元セクション（親）から子を削除する
		[[Pe2array objectAtIndex:oldPath.section] removeChildsObject:e3obj];	// 元の親ノードにある子登録を抹消する
		// 異動先セクション（親）へ子を追加する
		[[Pe2array objectAtIndex:newPath.section] addChildsObject:e3obj];	// 新しい親ノードに子登録する
		// 異セクション間での移動： 双方のセクションで変化あったrow以降、全て更新する
		// 元のrow付け替え処理
		for (i = oldPath.row ; i < [[Me3array objectAtIndex:oldPath.section] count] ; i++) {
			e3obj = [[Me3array objectAtIndex:oldPath.section] objectAtIndex:i];
			e3obj.row = [NSNumber numberWithInteger:i];
		}
		// 先のrow付け替え処理
		for (i = newPath.row ; i < [[Me3array objectAtIndex:newPath.section] count] ; i++) {
			e3obj = [[Me3array objectAtIndex:newPath.section] objectAtIndex:i];
			e3obj.row = [NSNumber numberWithInteger:i];
		}
	}
	// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針である＞＞
	NSError *error = nil;
	// ＜＜Sortのとき、Pe2selected==nil であるからPe2selectedは使えない＞＞
	if (![Pe1selected.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"didReceiveMemoryWarning" 
													 message:@"E3viewController" 
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
