//
//  E1cardTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "E1cardTVC.h"
#import "E1cardDetailTVC.h"
#import "E2invoiceTVC.h"
#import "SettingTVC.h"
#import "WebSiteVC.h"

#define ACTIONSEET_TAG_DELETE_CARD	199

@interface E1cardTVC (PrivateMethods)
- (void)e1cardDatail:(NSIndexPath *)indexPath;
@end

@implementation E1cardTVC
@synthesize Re0root;
@synthesize Re3edit;
#ifdef AzPAD
@synthesize delegate;
@synthesize selfPopover;
#endif


#pragma mark - Delegate

#ifdef AzPAD
- (void)refreshTable
{
	if (MindexPathEdit) {	// 行位置が有効ならば、修正行だけを再表示する
		NSArray* ar = [NSArray arrayWithObject:MindexPathEdit];
		[self.tableView reloadRowsAtIndexPaths:ar withRowAnimation:YES];
	} else {
		[self viewWillAppear:YES];
	}
}
#endif

#pragma mark - Action

- (void)barButtonAdd {
	// Add Card
	[self e1cardDatail:nil]; // :(nil)Add mode
}

- (void)barButtonTop {
	[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
}

- (void)barButtonUntitled {
	if (Re3edit.e1card && 0 < [Re3edit.e6parts count]) {
		AzLOG(@"LOGIC ERR:`Card未定禁止");	// このケースでは「未定」ボタンが無効で、ここを通らないハズ
		return;
	}
	// E3配下なし（新規追加中である） 未定(nil)にする
	Re3edit.e1card = nil; 
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

- (void)e1cardDatail:(NSIndexPath *)indexPath
{
	E1cardDetailTVC *e1detail = [[E1cardDetailTVC alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	
	if ([RaE1cards count] <= indexPath.row) {	// Add mode
		E1card *e1obj = [NSEntityDescription insertNewObjectForEntityForName:@"E1card"
													  inManagedObjectContext:Re0root.managedObjectContext];
		// Add
		e1detail.title = NSLocalizedString(@"Add Card",nil);
		e1detail.PiAddRow = [RaE1cards count]; // 追加モード
		e1detail.Re1edit = e1obj;
	} else {
		e1detail.title = NSLocalizedString(@"Edit Card",nil);
		e1detail.PiAddRow = (-1); // 修正モード
		e1detail.Re1edit = [RaE1cards objectAtIndex:indexPath.row]; //[MfetchE1card objectAtIndexPath:indexPath];
	}

#ifdef  AzPAD
	MindexPathEdit = indexPath;
	//PadPopoverInNaviCon* pop = [[PadPopoverInNaviCon alloc] initWithContentViewController:e1detail];
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:e1detail];
	Mpopover = [[UIPopoverController alloc] initWithContentViewController:nc];
	Mpopover.delegate = self;  //閉じたとき再描画するため
	[nc release];
	CGRect rc = [self.tableView rectForRowAtIndexPath:indexPath];
	rc.origin.x = rc.size.width - 40;	rc.size.width = 10;
	rc.origin.y += 10;	rc.size.height -= 20;
	//Mpopover.popoverContentSize = E1DETAILVIEW_SIZE;
	[Mpopover presentPopoverFromRect:rc inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight  animated:YES];
	e1detail.selfPopover = Mpopover; [Mpopover release];
	e1detail.delegate = self;
#else
	e1detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e1detail animated:YES];
#endif
	[e1detail release]; // self.navigationControllerがOwnerになる
}

// UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// buttonIndexは、actionSheetの上から順に(0〜)付与されるようだ。
	if (actionSheet.tag == ACTIONSEET_TAG_DELETE_CARD && buttonIndex == 0) {
		//========== E1 削除実行 ==========
		// ＜注意＞ CoreDataモデルは、エンティティ間の削除ルールは双方「無効にする」を指定。（他にするとフリーズ）
		E1card *e1objDelete = [RaE1cards objectAtIndex:MindexPathActionDelete.row];
		// E1,E2,E3,E6,E7 の関係を保ちながら E1削除 する
		[MocFunctions e1delete:e1objDelete];
		// 削除行の次の行以下 E1.row 更新
		for (NSInteger i= MindexPathActionDelete.row + 1 ; i < [RaE1cards count] ; i++) 
		{  // .nRow + 1 削除行の次から
			E1card *e1obj = [RaE1cards objectAtIndex:i];
			e1obj.nRow = [NSNumber numberWithInteger:i-1];     // .nRow--; とする
		}
		// Commit
		[MocFunctions commit];
		// 以上でcontextから削除されたが、TableView表示には残っている状態。最後に、TableView表示から削除する。
		[RaE1cards removeObjectAtIndex:MindexPathActionDelete.row];
		[self.tableView reloadData];
	}
}



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
- (void)loadView 
{
    [super loadView];
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
	//MbuTop = nil;	// ここ(loadView)で生成
	MbuAdd = nil;	// ここ(loadView)で生成
	
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
	
	if (Re3edit == nil) {	//編集モード
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		self.tableView.allowsSelectionDuringEditing = YES; // 編集モードに入ってる間にユーザがセルを選択できる
	}
	
	// Tool Bar Button
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	
	if (Re3edit == nil) {	//編集モード　／ 選択モードならば、MbuAdd = MbuTop = nill;
		MbuAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
															   target:self action:@selector(barButtonAdd)];
#ifdef AzPAD
		NSArray *buArray = [NSArray arrayWithObjects: buFlex, MbuAdd, nil];
		[self setToolbarItems:buArray animated:YES];
#else
		UIBarButtonItem *buTop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-Top.png"]
												  style:UIBarButtonItemStylePlain  //Bordered
												 target:self action:@selector(barButtonTop)];
		NSArray *buArray = [NSArray arrayWithObjects: buTop, buFlex, MbuAdd, nil];
		[self setToolbarItems:buArray animated:YES];
		[buTop release];
#endif
		[MbuAdd release];
	}
	else {  //選択モード
		// この「未定」ボタンは、「新規追加中」でE3配下のE6が無いときにだけ有効にする
		UIBarButtonItem *buUntitled = [[UIBarButtonItem alloc] 
									   initWithTitle:NSLocalizedString(@"Untitled",nil)
									   style:UIBarButtonItemStyleBordered
									   target:self action:@selector(barButtonUntitled)];
		NSArray *buArray = [NSArray arrayWithObjects: buUntitled, buFlex, nil];
		[self setToolbarItems:buArray animated:YES];
		[buUntitled release];
	}
	[buFlex release];

	// ToolBar表示は、viewWillAppearにて回転方向により制御している。
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
#ifdef AzPAD
	//Popover [Menu] button
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示する
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	
	// Me1cards Requery. 
	//--------------------------------------------------------------------------------
	if (RaE1cards) {
		[RaE1cards release], RaE1cards = nil;
	}
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"E1card" 
											  inManagedObjectContext:Re0root.managedObjectContext];
	[fetchRequest setEntity:entity];
	// Sorting
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"nRow" ascending:YES];
	NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1, nil];
	[fetchRequest setSortDescriptors:sortArray];
	[sortArray release];
	[sort1 release];
	// Fitch
	NSError *error = nil;
	NSArray *arFetch = [Re0root.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		AzLOG(@"Error %@, %@", error, [error userInfo]);
		//exit(-1);  // Fail
	}
	[fetchRequest release];
	//
	RaE1cards = [[NSMutableArray alloc] initWithArray:arFetch];
	
	// TableView Reflesh
	[self.tableView reloadData];
	
	if (0 < McontentOffsetDidSelect.y) {
		// app.Me3dateUse=nil のときや、メモリ不足発生時に元の位置に戻すための処理。
		// McontentOffsetDidSelect は、didSelectRowAtIndexPath にて記録している。
		self.tableView.contentOffset = McontentOffsetDidSelect;
	}
}


// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
	
	if (Re3edit == nil) {
		//	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		// (0)TopMenu >> (1)This clear
		//	[appDelegate.RaComebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:-1]];
	}
}

#pragma mark View Rotate

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

#ifdef AzPAD
// 回転した後に呼び出される
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if ([Mpopover isPopoverVisible]) {
	/*	// 配下の Popover が開いておれば強制的に閉じる。回転すると位置が合わなくなるため
		id nav = [Mpopover contentViewController];
		//NSLog(@"nav=%@", nav);
		if ([nav isMemberOfClass:[UINavigationController class]]) {
			if ([nav respondsToSelector:@selector(visibleViewController)]) { //念のためにメソッドの存在を確認
				id vc = [nav visibleViewController];
				//NSLog(@"vc=%@", vc);
				if ([vc respondsToSelector:@selector(closePopover)]) { //念のためにメソッドの存在を確認
					[vc closePopover];
				}
			}
		}*/
		
		// Popoverの位置を調整する　＜＜UIPopoverController の矢印が画面回転時にターゲットから外れてはならない＞＞
		if (MindexPathEdit) { 
			//NSLog(@"MindexPathEdit=%@", MindexPathEdit);
			[self.tableView scrollToRowAtIndexPath:MindexPathEdit 
								  atScrollPosition:UITableViewScrollPositionMiddle animated:NO]; // YESだと次の座標取得までにアニメーションが終了せずに反映されない
			CGRect rc = [self.tableView rectForRowAtIndexPath:MindexPathEdit];
			rc.origin.x = rc.size.width - 40;	rc.size.width = 10;
			rc.origin.y += 10;	rc.size.height -= 20;
			[Mpopover presentPopoverFromRect:rc  inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionRight  animated:YES]; //表示開始
/*			//　キーボードが出てサイズが小さくなった状態から復元するためには下記のように二段階処理が必要
			CGSize currentSetSizeForPopover = E1DETAILVIEW_SIZE; // 最終的に設定したいサイズ
			CGSize fakeMomentarySize = CGSizeMake(currentSetSizeForPopover.width - 1.0f, currentSetSizeForPopover.height - 1.0f);
			Mpopover.popoverContentSize = fakeMomentarySize;			// 変動させるための偽サイズ
			[Mpopover presentPopoverFromRect:rc  inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionRight  animated:YES]; //表示開始
			Mpopover.popoverContentSize = currentSetSizeForPopover; // 目的とするサイズ復帰 */
		}
		else {
			// 回転後のアンカー位置が再現不可なので閉じる
			[Mpopover dismissPopoverAnimated:YES];
		}
	}
}
#endif


#pragma mark  View - Unload - dealloc

- (void)unloadRelease	// dealloc, viewDidUnload から呼び出される
{
	NSLog(@"--- unloadRelease --- E1cardTVC");
	[RaE1cards release], RaE1cards = nil;
}

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
#ifdef AzPAD
	[selfPopover release], selfPopover = nil;
#endif
	[self unloadRelease];
	//--------------------------------@property (retain)
	[Re0root release];
	[Re3edit release];
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
	if ([RaE1cards count] <= lRow) return; // 無効セル（削除されたとか）

	// E2invoice へ
	E1card *e1obj = [RaE1cards objectAtIndex:lRow];
	E2invoiceTVC *tvc = [[E2invoiceTVC alloc] init];
	tvc.title = e1obj.zName;
	tvc.Re1select = e1obj;
	[self.navigationController pushViewController:tvc animated:NO];
	// viewComeback を呼び出す
	[tvc viewWillAppear:NO]; // Fech データセットさせるため
	[tvc viewComeback:selectionArray];
	[tvc release];
}
*/


#pragma mark - TableView lifecicle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1; // 固定
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (Re3edit) { //選択モード
		return [RaE1cards count]; 
	}
	return [RaE1cards count] + 2; // (+1)Add  (+2)Help
}

/*
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
}*/

/*
 // セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if ([Re1cards count] <= indexPath.row) {
		return 30; // Add Record
	}
	return 44; // デフォルト：44ピクセル
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *zCellCard = @"CellCard";
	static NSString *zCellAdd = @"CellAdd";
	static NSString *zCellHelp = @"CellHelp";
    UITableViewCell *cell = nil;

	//NSLog(@"RaE1cards=%@", RaE1cards);
	NSInteger rows = [RaE1cards count] - indexPath.row;
	if (0 < rows) {
		// E1card セル
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
		
		E1card *e1obj = [RaE1cards objectAtIndex:indexPath.row]; //[MfetchE1card objectAtIndexPath:indexPath];
		
#ifdef AzDEBUG
		if ([e1obj.zName length] <= 0) 
			cell.textLabel.text = [NSString stringWithFormat:@"%ld) %@", 
								   (long)[e1obj.nRow integerValue], NSLocalizedString(@"(Untitled)", nil)];
		else
			cell.textLabel.text = [NSString stringWithFormat:@"%ld) %@", 
								   (long)[e1obj.nRow integerValue], e1obj.zName];
#else
		if ([e1obj.zName length] <= 0) 
			cell.textLabel.text = NSLocalizedString(@"(Untitled)", nil);
		else
			cell.textLabel.text = e1obj.zName;
#endif
		// 金額
		//NSNumber *sumAmount = [e1obj valueForKeyPath:@"e2unpaids.@sum.sumAmount"];
		NSDecimalNumber *sumAmount = [e1obj valueForKeyPath:@"e2unpaids.@sum.sumAmount"];
		//if ([sumAmount integerValue] <= 0) 
		if ([sumAmount compare:[NSDecimalNumber zero]] == NSOrderedDescending)	// sumAmount > 0
		{
			cell.detailTextLabel.textColor = [UIColor blackColor];
		} else {
			cell.detailTextLabel.textColor = [UIColor blueColor];
		}
		// Amount JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[formatter setLocale:[NSLocale currentLocale]]; 
		if ([e1obj.nClosingDay intValue] <= 0) {
			// Debit
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
										 NSLocalizedString(@"Debit", nil),
										 [formatter stringFromNumber:sumAmount]];
		} else {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
										 GstringDay([e1obj.nPayDay intValue]),	// 支払日
										 [formatter stringFromNumber:sumAmount]];
		}
		[formatter release];
		
		if (Re3edit == nil) {
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; // ディスクロージャボタン
			cell.showsReorderControl = YES;		// Move有効
		}
	} 
	else if (rows==0) {
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
		cell.showsReorderControl = NO; // Move禁止
		cell.textLabel.text = NSLocalizedString(@"Add Card",nil);
	}
	else if (rows==(-1)) {
		// Helpセル
		cell = [tableView dequeueReusableCellWithIdentifier:zCellHelp];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault      // Default型
										   reuseIdentifier:zCellHelp] autorelease];
		}
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.textLabel.textAlignment = UITextAlignmentRight;
		cell.textLabel.textColor = [UIColor grayColor];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.showsReorderControl = NO; // Move禁止
		cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
		cell.textLabel.text = NSLocalizedString(@"Card Help",nil);
	} 
	else {
		cell = nil; // LOGIC ERROR
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 非選択状態に戻す
	
	// didSelect時のScrollView位置を記録する（viewWillAppearにて再現するため）
	McontentOffsetDidSelect = [tableView contentOffset];
	
	if (indexPath.row < [RaE1cards count]) {
		if (Re3edit) {			// 選択モード
			Re3edit.e1card = [RaE1cards objectAtIndex:indexPath.row]; 
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
		else if (self.editing) {
			[self e1cardDatail:indexPath];
		} 
		else {
			/*			// Comback-L1 E1card 記録
			 AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			 long lPos = indexPath.section * GD_SECTION_TIMES + indexPath.row;
			 // (0)TopMenu >> (1)This
			 [appDelegate.RaComebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:lPos]];
			 [appDelegate.RaComebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
			 */			
			// E2invoice へ
			E1card *e1obj = [RaE1cards objectAtIndex:indexPath.row];
			E2invoiceTVC *tvc = [[E2invoiceTVC alloc] init];
#ifdef AzDEBUG
			tvc.title = [NSString stringWithFormat:@"E2 %@", e1obj.zName];
#else
			tvc.title = e1obj.zName;
#endif
			tvc.Re1select = e1obj;
			tvc.Re8select = nil;
			[self.navigationController pushViewController:tvc animated:YES];
			[tvc release];
		}
	}
	else if (indexPath.row == [RaE1cards count]) {	// Add Plan
		[self e1cardDatail:indexPath]; // 改めて Add 判断している
	}
}

// ディスクロージャボタンが押されたときの処理
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self e1cardDatail:indexPath];
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger rows = [RaE1cards count] - indexPath.row;
	if (0 < rows) {
		return UITableViewCellEditingStyleDelete;
    }
//	else if (rows <= 0) {
//		return UITableViewCellEditingStyleInsert;
//	}
    return UITableViewCellEditingStyleNone;
}

// TableView Editモード処理
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
											forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		// 削除コマンド警告　==>> (void)actionSheet にて処理
		MindexPathActionDelete = indexPath;
		// 削除コマンド警告
		UIActionSheet *action = [[UIActionSheet alloc] 
						 initWithTitle:NSLocalizedString(@"DELETE Card", nil)
						 delegate:self 
						 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
						 destructiveButtonTitle:NSLocalizedString(@"DELETE Card button", nil)
						 otherButtonTitles:nil];
		action.tag = ACTIONSEET_TAG_DELETE_CARD;
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
	if (indexPath.row < [RaE1cards count]) return YES;
	return NO;  // 最終行のAdd行は右寄せさせない
}

#pragma mark  TableView - Moveing

// Editモード時の行移動の可否　　＜＜最終行のAdd専用行を移動禁止にしている＞＞
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.row < [RaE1cards count]) return YES;
	return NO;  // 最終行のAdd行は移動禁止
}

// Editモード時の行移動「先」を返す　　＜＜最終行のAdd専用行への移動ならば1つ前の行を返している＞＞
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)oldPath 
															toProposedIndexPath:(NSIndexPath *)newPath {
    NSIndexPath *target = newPath;
    // Add行が異動先になった場合、その1つ前の通常行を返すことにより、Add行への移動禁止となる。
	NSInteger rows = [RaE1cards count] - 1; // 移動可能な行数（Add行を除く）
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

	// Re1cards 更新 ==>> なんと、managedObjectContextも更新される。 ただし、削除や挿入は反映されない！！！
	E1card *e1obj = [RaE1cards objectAtIndex:oldPath.row]; //[MfetchE1card objectAtIndexPath:oldPath];

	[RaE1cards removeObjectAtIndex:oldPath.row];
	[RaE1cards insertObject:e1obj atIndex:newPath.row];
	
	NSInteger start = oldPath.row;
	NSInteger end = newPath.row;
	if (end < start) {
		start = newPath.row;
		end = oldPath.row;
	}
	for (NSInteger i = start; i <= end; i++) {
		e1obj = [RaE1cards objectAtIndex:i];
		e1obj.nRow = [NSNumber numberWithInteger:i];
	}
	
	// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針＞＞
	/*NSError *error = nil;
	if (![Re0root.managedObjectContext save:&error]) {
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
 // 内部(SAVE)から、dismissPopoverAnimated:で閉じた場合は呼び出されない。
	if ([popoverController.contentViewController isMemberOfClass:[UINavigationController class]]) {
		UINavigationController* nav = (UINavigationController*)popoverController.contentViewController;
		if (0 < [nav.viewControllers count] && [[nav.viewControllers objectAtIndex:0] isMemberOfClass:[E1cardDetailTVC class]]) 
		{	// Popover外側をタッチしたとき E1cardDetailTVC -　cancel を通っていないので、ここで通す。
			E1cardDetailTVC* tvc = (E1cardDetailTVC *)[nav.viewControllers objectAtIndex:0]; //Root VC   <<<.topViewControllerではダメ>>>
			if ([tvc respondsToSelector:@selector(cancelClose:)]) {	// メソッドの存在を確認する
				[tvc cancelClose:nil];	// 新しいObject破棄
			}
		}
	}
	return YES; // 閉じることを許可
*/
}
#endif


@end

