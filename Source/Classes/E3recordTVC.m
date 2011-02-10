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
#import "E3recordTVC.h"
#import "E3recordDetailTVC.h"

@interface E3recordTVC (PrivateMethods)
- (void)e3detailView:(NSIndexPath *)indexPath;
- (void)cellButton: (UIButton *)button;
@end

@implementation E3recordTVC
@synthesize Re0root;
@synthesize Pe4shop;
@synthesize Pe5category;

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[Me3list release];
	
	// @property (retain)
	[Re0root release];
	[super dealloc];
}

- (void)viewDidUnload 
{
	// メモリ不足時、裏側にある場合に呼び出されるので、Private Allocで生成したObjを解放する。
	[Me3list release];		Me3list = nil;
	
	// @property (retain) は解放しない。
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"viewDidUnload" 
													 message:@"E3recordTVC" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"didReceiveMemoryWarning" 
													 message:@"E3recordTVC" 
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
		//self.navigationItem.rightBarButtonItem = self.editButtonItem;
		//self.tableView.allowsSelectionDuringEditing = YES;
		MiForTheFirstSection = (-1);  // viewWillAppearにてMe2list Reload時にセット
	}
	MbFirstAppear = YES; // Load後、最初に1回だけ処理するため
	return self;
}

- (void)barButtonTop {
	[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
}

- (void)barButtonAdd {
	// Add Card
	[self e3detailView:nil]; // :(nil)Add mode
}

// viewDidLoadメソッドは，TableViewContorllerオブジェクトが生成された後，実際に表示される際に呼び出されるメソッド
- (void)viewDidLoad 
{
    [super viewDidLoad];
	Me3list = nil;
	

	// ここは、alloc直後に呼ばれるため、下記のようなパラは未セット状態である。==>> viewWillAppearで参照すること

	// Tool Bar Button
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	UIBarButtonItem *buTop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Bar16-TopView.png"]
															  style:UIBarButtonItemStylePlain  //Bordered
															 target:self action:@selector(barButtonTop)];
	UIBarButtonItem *buAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																		   target:self action:@selector(barButtonAdd)];
	NSArray *buArray = [NSArray arrayWithObjects: buTop, buFlex, buAdd, nil];
	[self setToolbarItems:buArray animated:YES];
	[buAdd release];
	[buTop release];
	[buFlex release];
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:YES];
	
//	if (Pe1card != nil) {
//		self.navigationItem.rightBarButtonItem = self.editButtonItem;
//		self.tableView.allowsSelectionDuringEditing = YES; // 編集モードに入ってる間にユーザがセルを選択できる
//	}
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	
	//没 AzPackingのE3同様に、全E2セクション表示かつ全E3表示　＜没：E2支払済みが大量になる危険性および必要性が低く複雑になりすぎるため没＞
	//以上から、Pe2selectの前後1ノード計3ノードだけで十分と判断した。

	// Me3list
	//----------------------------------------------------------------------------CoreData Loading
	//---------------------------------Me3list 生成
	if (Me3list != nil) {
		[Me3list release];
		Me3list = nil;
	}
	// Sorting
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"dateUse" ascending:YES];
	NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];

/*	if (Pe1card) {
		// Pe1card以下、最近の全E3
		Me3list = [[NSMutableArray alloc] initWithArray:[Pe1card.e3records allObjects]];
		[Me3list sortUsingDescriptors:sortArray];
	}
	else */
	
	if (Pe4shop) {
		// Pe4shop以下、最近の全E3
		Me3list = [[NSMutableArray alloc] initWithArray:[Pe4shop.e3records allObjects]];
		[Me3list sortUsingDescriptors:sortArray];
	}
	else if (Pe5category) {
		// Pe5category以下、最近の全E3
		Me3list = [[NSMutableArray alloc] initWithArray:[Pe5category.e3records allObjects]];
		[Me3list sortUsingDescriptors:sortArray];
	}
	else {
		//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		// 利用明細一覧用：最近の全E3
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"E3record" 
												  inManagedObjectContext:Re0root.managedObjectContext];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortArray];
		// Fitch
		NSError *error = nil;
		NSArray *arFetch = [Re0root.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (error) {
			AzLOG(@"Error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		[fetchRequest release];
		Me3list = [[NSMutableArray alloc] initWithArray:arFetch];
	}
	[sortArray release];
	[sort1 release];
	
	// テーブルビューを更新します。
    [self.tableView reloadData];
	
	if (MbFirstAppear && 1 <= [Me3list count]) {
		MbFirstAppear = NO;
		// 最新行（最終ページ）を表示する　＜＜最終行を画面下部に表示する＞＞  +Add行まで表示するためMiddleにした。
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[Me3list count]-1 inSection:0];
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

	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (Pe4shop OR Pe5category) {
		// (0)TopMenu >> (1)E4/E5 >> (2)This clear
		[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
	} else {
		// (0)TopMenu >> (1)This clear
		[appDelegate.comebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:-1]];
	}

	if (0 <= MiForTheFirstSection) {
		if (3 < [Me3list count]) {
			// 最近の利用明細一覧：末尾を表示
			NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[Me3list count]-1 inSection:0];
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
	if (Pe4shop OR Pe5category) {
		// (0)TopMenu >> (1)E4/E5 >> (2)This clear
		lRow = [[selectionArray objectAtIndex:2] integerValue];
	} else {
		// (0)TopMenu >> (1)This clear
		lRow = [[selectionArray objectAtIndex:1] integerValue];
	}
	if (lRow < 0) return; // この画面に留まる
	NSInteger lSec = lRow / GD_SECTION_TIMES;
	lRow -= (lSec * GD_SECTION_TIMES);
	
	if (0 < lSec) return;
	if ([Me3list count] <= lRow) return; // OVER
	
	// 選択行を画面中央付近に表示する
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lRow inSection:lSec];
	[self.tableView scrollToRowAtIndexPath:indexPath 
						  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
	
	// ドリルダウン
	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init];
	e3detail.title = self.title;
	e3detail.Re3edit = [Me3list objectAtIndex:lRow];
	e3detail.PbAdd = NO;
	//e3detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:NO];
	// 末尾につき viewComeback なし
	[e3detail release];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [Me3list count] + 1;  // (+1)Add行
}

/*static long addYearMM( long lYearMM, long lMonth )
{
	long lYear = lYearMM / 100;
	long lMM = lYearMM - (lYear * 100);
	lMM += lMonth;
	lYear += (lMM / 12);
	lMM = lMM - ((lMM / 12) * 12);
	return lYear * 100 + lMM;
}*/

/*
// TableView セクション名を応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	return NSLocalizedString(@"Recent record",nil);
}

// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if ([Me3list count] <= indexPath.row) {
		return 30; // Add Record
	}
	return 44; // デフォルト：44ピクセル
}
*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *zCellE3record = @"CellE3record";
    static NSString *zCellAdd = @"CellAdd";
	UITableViewCell *cell = nil;
	UILabel *cellLabel = nil;
//	UIButton *cellButton = nil;
//	NSInteger iButtonTag = indexPath.section * GD_SECTION_TIMES + indexPath.row;
	
	if (indexPath.row < [Me3list count]) 
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
			cell.detailTextLabel.textAlignment = UITextAlignmentLeft; //金額が欠けないように左寄せにした
			cell.detailTextLabel.textColor = [UIColor blackColor];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // ＞
			//cell.showsReorderControl = YES; // Move可能
			cell.showsReorderControl = NO; // Move禁止

			cellLabel = [[UILabel alloc] init];
			cellLabel.textAlignment = UITextAlignmentRight;
			cellLabel.textColor = [UIColor blackColor];
			//cellLabel.backgroundColor = [UIColor grayColor]; //DEBUG範囲チェック用
			cellLabel.font = [UIFont systemFontOfSize:14];
			cellLabel.tag = -1;
			[cell addSubview:cellLabel]; [cellLabel release];
			
			/*　チェック丸アイコンを非表示することで、ここではチェックできないことを知らせるようにした。
			// ここではチェックできないことを知らせるためのボタンを設置　＜＜全セル共通＞＞
			cellButton = [UIButton buttonWithType:UIButtonTypeCustom]; // autorelease
			cellButton.frame = CGRectMake(0,0, 44,44);
			[cellButton addTarget:self action:@selector(cellLeftButton:) forControlEvents:UIControlEventTouchUpInside];
			cellButton.backgroundColor = [UIColor clearColor]; //背景透明
			cellButton.showsTouchWhenHighlighted = YES;
			[cell.contentView addSubview:cellButton]; //[bu release]; buttonWithTypeにてautoreleseされるため不要。UIButtonにinitは無い。
			 */
		 }
		else {
			cellLabel = (UILabel *)[cell viewWithTag:-1];
		}
		// 回転対応のため
		cellLabel.frame = CGRectMake(self.tableView.frame.size.width-98, 2, 75, 20);

		E3record *e3obj = [Me3list objectAtIndex:indexPath.row];
		
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
		// Amount JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];  // CurrencyStyle]; // 通貨スタイル
		NSLocale *localeJP = [[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"];
		[formatter setLocale:localeJP];
		[localeJP release];
		cellLabel.text = [formatter stringFromNumber:e3obj.nAmount];
		[formatter release];

		// Cell 2行目
		NSString *zShop = @"";
		NSString *zCategory = @"";
		if (e3obj.e4shop != nil) zShop = e3obj.e4shop.zName;
		if (e3obj.e5category != nil) zCategory = e3obj.e5category.zName;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@.%@.%@", e3obj.e1card.zName, zShop, zCategory];
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

/*
// ここではチェックできないことを知らせるためのボタンを設置　＜＜全セル共通＞＞
- (void)cellLeftButton: (UIButton *)button 
{
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Check", nil)
													 message:NSLocalizedString(@"", nil) 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
}
*/

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

	if (indexPath.row < [Me3list count]) 
	{
		// Comback-L3 記録
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		long lPos = indexPath.section * GD_SECTION_TIMES + indexPath.row;
		if (Pe4shop OR Pe5category) {
			// (0)TopMenu >> (1)E4/E5 >> (2)This clear
			[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:lPos]];
			[appDelegate.comebackIndex replaceObjectAtIndex:3 withObject:[NSNumber numberWithLong:-1]];
		} else {
			// (0)TopMenu >> (1)This clear
			[appDelegate.comebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:lPos]];
			[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
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
	if (indexPath != nil && indexPath.row < [Me3list count]) {
		// Edit Item
		e3detail.title = NSLocalizedString(@"Edit Record", nil);
		e3detail.Re3edit = [Me3list objectAtIndex:indexPath.row];
		e3detail.PbAdd = NO;
	}
	else {
		// Add E3
		E3record *e3obj = [NSEntityDescription insertNewObjectForEntityForName:@"E3record"
														   inManagedObjectContext:Re0root.managedObjectContext];
		e3obj.e1card = nil;
		e3obj.e4shop = Pe4shop;
		e3obj.e5category = Pe5category;
		e3obj.e6parts = nil;
		// Args
		e3detail.title = NSLocalizedString(@"Add Record", nil);
		e3detail.Re3edit = e3obj;
		e3detail.PbAdd = YES; // Add mode
	}
	//e3detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:YES];
	[e3detail release];
}

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
	/*E3recordTVC は、利用明細を利用日順に表示するため移動はなし。　E2間移動（支払日変更）は、E6partTVC で行う。
	if (indexPath.row < [Me3list count]) {
		return YES; // Move 対象
	}*/
	
	return NO;  // 移動禁止
}

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

