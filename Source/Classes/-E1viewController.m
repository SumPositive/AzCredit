//
//  E1viewController.m
//  iPack E1 Title
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Elements.h"
#import "E1viewController.h"
#import "E1edit.h"
#import "E2viewController.h"
#import "GooDocsTVC.h"
#import "SampleTVC.h"
#import "SettingTVC.h"
#import "InformationView.h"
#import "WebSiteVC.h"

#define ACTIONSEET_TAG_DELETEPACK	199

@interface E1viewController (PrivateMethods)
	- (void)azSettingView;
	- (void)e1add;
	- (void)e1editView:(NSIndexPath *)indexPath;
//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSFetchedResultsController *MfetchedE1;
//----------------------------------------------------------------Owner移管につきdealloc時のrelese不要
	E1edit *Me1editView;				// self.navigationControllerがOwnerになる
	InformationView *MinformationView;  // self.view.windowがOwnerになる
//----------------------------------------------------------------assign
	NSIndexPath	  *MindexPathActionDelete; // 削除するIndexPath
	BOOL MbOptShouldAutorotate;
	BOOL MbAzOptTotlWeightRound;
	BOOL MbAzOptShowTotalWeight;
	BOOL MbAzOptShowTotalWeightReq;
	NSInteger MiSection0Rows; // E1レコード数　＜高速化＞
@end
@implementation E1viewController
@synthesize RmanagedObjectContext;

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	//AzRETAIN_CHECK(@"E1 MinformationView", MinformationView , 0)
	//[MinformationView release]; addSub直後のreleaseにより、self.view.windowがOwnerになったので不要
	//AzRETAIN_CHECK(@"E1 Me1editView", Me1editView , 0)
	//[Me1editView release]; addSub直後のreleaseにより、self.view.windowがOwnerになったので不要

	AzRETAIN_CHECK(@"E1 MfetchedE1", MfetchedE1, 0)
	[MfetchedE1 release];

	// @property (retain)
	AzRETAIN_CHECK(@"E1 RmanagedObjectContext", RmanagedObjectContext, 0)
	[RmanagedObjectContext release];

    [super dealloc];
}

- (void)viewDidUnload {
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。
	AzLOG(@"***viewDidUnload> E1viewController");
	[MfetchedE1 release];			MfetchedE1 = nil;
	// @property (retain) は解放しない。
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"didReceiveMemoryWarning" 
													 message:@"E1viewController" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
    [super didReceiveMemoryWarning];
}


#pragma mark View lifecycle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStylePlain]) {  // セクションなしテーブル
		//self.navigationItem.rightBarButtonItem = self.editButtonItem;
		//self.tableView.allowsSelectionDuringEditing = YES;
	}
	return self;
}

- (void)azInformationView
{
	// ヨコ非対応につき正面以外は、hideするようにした。
	if (MinformationView==nil) { // self.view.windowが解放されるまで存在しているため
		MinformationView = [[InformationView alloc] initWithFrame:[self.view.window bounds]];
		[self.view.window addSubview:MinformationView]; //回転しないが、.viewから出すとToolBarが隠れない
		[MinformationView release]; // addSubviewにてretain(+1)されるため、こちらはrelease(-1)して解放
	}
	[MinformationView show];
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
	MinformationView = nil;
	Me1editView = nil;
	MfetchedE1 = nil;

	// ここは、alloc直後に呼ばれるため、パラは未セット状態である。==>> viewWillAppearで参照すること
	
	// Set up NEXT Left [Back] buttons.
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]
		   initWithImage:[UIImage imageNamed:@"simpleLeft-icon16.png"]
		   style:UIBarButtonItemStylePlain  target:nil  action:nil];
	self.navigationItem.backBarButtonItem = backButtonItem;
	[backButtonItem release];

	// Set up Right [Edit] buttons.
#ifdef AzMAKE_SPLASHFACE
	// No Button 国別で文字が変わるため
#else
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.allowsSelectionDuringEditing = YES; // 編集モードに入ってる間にユーザがセルを選択できる
#endif	
	
	// Tool Bar Button
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	UIBarButtonItem *buInfo = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Information-icon16.png"]
																style:UIBarButtonItemStylePlain  //Bordered
															  target:self action:@selector(azInformationView)];
	UIBarButtonItem *buSet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Setting-icon16.png"]
															  style:UIBarButtonItemStylePlain  //Bordered
															 target:self action:@selector(azSettingView)];
	NSArray *buArray = [NSArray arrayWithObjects: buInfo, buFlex, buSet, nil];
	[self setToolbarItems:buArray animated:YES];
	[buInfo release];
	[buSet release];
	[buFlex release];
	
	// ToolBar表示は、viewWillAppearにて回転方向により制御している。
}

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		// 正面（ホームボタンが画面の下側にある状態）
		[self.navigationController setToolbarHidden:NO animated:YES]; // ツールバー表示する
		return YES; // この方向だけは常に許可する
	} 
	else if (MbOptShouldAutorotate) {
		// 横方向や逆向きのとき
		[self.navigationController setToolbarHidden:YES animated:YES]; // ツールバー消す
	}
	// 現在の向きは、self.interfaceOrientation で取得できる
	if (MinformationView) {
		[MinformationView hide]; // 正面でなければhide
	}
	return MbOptShouldAutorotate;
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptShouldAutorotate = [defaults boolForKey:GD_OptShouldAutorotate];
	MbAzOptTotlWeightRound = [defaults boolForKey:GD_OptTotlWeightRound]; // YES=四捨五入 NO=切り捨て
	MbAzOptShowTotalWeight = [defaults boolForKey:GD_OptShowTotalWeight];
	MbAzOptShowTotalWeightReq = [defaults boolForKey:GD_OptShowTotalWeightReq];
	
	self.title = NSLocalizedString(@"Product Title",nil);
	
	if (MfetchedE1 == nil) {
		// Create and configure a fetch request with the Book entity.
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"E1" 
												  inManagedObjectContext:RmanagedObjectContext];
		[fetchRequest setEntity:entity];
		// Sorting
		NSSortDescriptor *sortRow = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES];
		NSArray *sortArray = [[NSArray alloc] initWithObjects:sortRow, nil];
		[fetchRequest setSortDescriptors:sortArray];
		[sortArray release];
		[sortRow release];
		// Create and initialize the fetch results controller.
		MfetchedE1 = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
										 managedObjectContext:RmanagedObjectContext 
															 sectionNameKeyPath:nil cacheName:@"E1nodes"];
		[fetchRequest release];
	}
	// 読み込み
	NSError *error;
	if (![MfetchedE1 performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	// 高速化のため、ここでE1レコード数（行数）を求めてしまう
    MiSection0Rows = 0;
	if (0 < [[MfetchedE1 sections] count]) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[MfetchedE1 sections] objectAtIndex:0];
		MiSection0Rows = [sectionInfo numberOfObjects];
	}
	
	[self.tableView reloadData];
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

	if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
		// ホームボタンが画面の下側にある状態。通常
		[self.navigationController setToolbarHidden:NO animated:NO]; // ツールバー表示する
	} else {
		// 横方向や逆向きのとき
		[self.navigationController setToolbarHidden:YES animated:NO]; // ツールバー消す
	}
	
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる

	// (-1,-1)にしてE1を未選択状態にする
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.comebackIndex replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:-1]];
	[appDelegate.comebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:-1]];
}

// カムバック処理（復帰再現）：AppDelegate から呼ばれる
- (void)viewComeback:(NSArray *)selectionArray
{
	NSInteger iSec = [[selectionArray objectAtIndex:0] intValue];
	NSInteger iRow = [[selectionArray objectAtIndex:1] intValue];
	if (iSec < 0) return; // この画面表示
	if (iRow < 0) return; // fail.

	if (1 <= iSec) return; // 無効セクション
	if (MiSection0Rows <= iRow) return; // 無効セル（削除されたとか）

	// 前回選択したセル位置
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:iRow inSection:iSec];

	// E1 : NSManagedObject
	E1 *e1obj = [MfetchedE1 objectAtIndexPath:indexPath];
	// E2 へドリルダウン
	E2viewController *e2view = [[E2viewController alloc] initWithStyle:UITableViewStylePlain];
	e2view.Pe1selected = e1obj;
	e2view.title = [e1obj valueForKey:@"name"];
	[self.navigationController pushViewController:e2view animated:NO];

	// E2 の viewComeback を呼び出す
	[e2view viewWillAppear:NO]; // Fech データセットさせるため
	[e2view viewComeback:selectionArray];

	[e2view release];
}


#pragma mark Local methods

- (void)e1add
{
	// ContextにE1ノードを追加する　E1edit内でCANCELならば削除している
	E1 *e1newObj = [NSEntityDescription insertNewObjectForEntityForName:@"E1"
								   inManagedObjectContext:self.RmanagedObjectContext];

	Me1editView = [[E1edit alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	Me1editView.title = NSLocalizedString(@"Add Plan", @"PLAN追加");
	Me1editView.Pe1target = e1newObj;
	Me1editView.PiAddRow = MiSection0Rows;  // 追加される行番号(row) ＝ 現在の行数 ＝ 現在の最大業番号＋1
	Me1editView.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:Me1editView animated:YES];
	[Me1editView release]; // self.navigationControllerがOwnerになる
}


// ディスクロージャボタンが押されたときの処理
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self e1editView:indexPath];
}

// E1edit View Call
- (void)e1editView:(NSIndexPath *)indexPath
{
	if (MiSection0Rows <= indexPath.row) return;  // Addボタン行などの場合パスする
	
	// E1 : NSManagedObject
	E1 *e1obj = [MfetchedE1 objectAtIndexPath:indexPath];
	
	Me1editView = [[E1edit alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	Me1editView.title = NSLocalizedString(@"Edit Plan",nil);
	Me1editView.Pe1target = e1obj;
	Me1editView.PiAddRow = (-1); // Edit mode.
	Me1editView.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:Me1editView animated:YES];
	[Me1editView release]; // self.navigationControllerがOwnerになる
}

// UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// buttonIndexは、actionSheetの上から順に(0〜)付与されるようだ。
	if (actionSheet.tag == ACTIONSEET_TAG_DELETEPACK && buttonIndex == 0) {
		//========== E1 削除実行 ==========
		// ＜注意＞ 選択行は、[self.tableView indexPathForSelectedRow] では得られない！didSelect直後に選択解除しているため。
		//         そのため、pppIndexPathActionDelete を使っている。
		// ＜注意＞ CoreDataモデルは、エンティティ間の削除ルールは双方「無効にする」を指定。（他にするとフリーズ）
		// 削除対象の ManagedObject をチョイス
		E1 *e1objDelete = [MfetchedE1 objectAtIndexPath:MindexPathActionDelete];
		// CoreDataモデル：削除ルール「無効にする」につき末端ノードより独自に削除する
		for (E2 *e2obj in e1objDelete.childs) {
			for (E3 *e3obj in e2obj.childs) {
				[self.RmanagedObjectContext deleteObject:e3obj];
			}
			[self.RmanagedObjectContext deleteObject:e2obj];
		}
		// 注意！performFetchするまで RrFetchedE1 は不変、削除もされていない！
		// 削除行の次の行以下 E1.row 更新
		NSIndexPath *ip;
		for (NSInteger i= MindexPathActionDelete.row + 1 ; i < MiSection0Rows ; i++) {  // .row + 1 削除行の次から
			ip = [NSIndexPath indexPathForRow:(NSUInteger)i inSection:MindexPathActionDelete.section];
			E1 *e1obj = [MfetchedE1 objectAtIndexPath:ip];
			e1obj.row = [NSNumber numberWithInteger:i-1];     // .row--; とする
		}
		// E1 削除
		[RmanagedObjectContext deleteObject:e1objDelete];
		MiSection0Rows--; // この削除により1つ減
		// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針＞＞
		NSError *error = nil;
		if (![RmanagedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		// 上で並び替えられた結果を再フィッチする（performFetch）  コンテキスト変更したときは再抽出する
		//NSError *error = nil;
		if (![MfetchedE1 performFetch:&error]) {
			NSLog(@"%@", error);
			exit(-1);  // Fail
		}
		// テーブルビューから選択した行を削除します。
		// ＜高速化＞　改めて削除後のE1レコード数（行数）を求める
		MiSection0Rows = 0;
		if (0 < [[MfetchedE1 sections] count]) {
			id <NSFetchedResultsSectionInfo> sectionInfo = [[MfetchedE1 sections] objectAtIndex:0];
			MiSection0Rows = [sectionInfo numberOfObjects];
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
#ifdef AzMAKE_SPLASHFACE
    return 0;
#else
    return MiSection0Rows + 4; // 常にAdd行ほか(+4行)表示する
#endif
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *zCellDefault = @"CellDefault";
	static NSString *zCellSubtitle = @"CellSubtitle";
    UITableViewCell *cell = nil;

	NSInteger rows = MiSection0Rows - indexPath.row;
	if (0 < rows) {
		// E1ノードセル
		cell = [tableView dequeueReusableCellWithIdentifier:zCellSubtitle];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] 
					 initWithStyle:UITableViewCellStyleSubtitle
					 reuseIdentifier:zCellSubtitle] autorelease];
		}
		// E1 : NSManagedObject
		E1 *e1obj = [MfetchedE1 objectAtIndexPath:indexPath];
		
#ifdef AzDEBUG
		if ([e1obj.name length] <= 0) 
			cell.textLabel.text = NSLocalizedString(@"Untitled", nil);
		else
			cell.textLabel.text = [NSString stringWithFormat:@"%ld) %@", 
							   (long)[e1obj.row integerValue], e1obj.name];
#else
		if ([e1obj.name length] <= 0) 
			cell.textLabel.text = NSLocalizedString(@"Untitled", nil);
		else
			cell.textLabel.text = e1obj.name;
#endif
		cell.textLabel.font = [UIFont systemFontOfSize:18];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.textColor = [UIColor blackColor];
		
		cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
		cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
		cell.detailTextLabel.textColor = [UIColor grayColor];

		// ＜高速化＞ E3(Item)更新時、その親E2のsum属性、さらにその親E1のsum属性を更新することで整合および参照時の高速化を実現した。
		NSInteger lNoGray = [e1obj.sumNoGray integerValue];
		NSInteger lNoCheck = [e1obj.sumNoCheck integerValue];
		// 重量
		double dWeightStk;
		double dWeightReq;
		if (MbAzOptShowTotalWeight) {
			NSInteger lWeightStk = [e1obj.sumWeightStk integerValue];
			if (MbAzOptTotlWeightRound) {
				// 四捨五入　＜＜ %.1f により小数第2位が丸められる＞＞ 
				dWeightStk = (double)lWeightStk / 1000.0f;
			} else {
				// 切り捨て                       ↓これで下2桁が0になる
				dWeightStk = (double)(lWeightStk / 100) / 10.0f;
			}
		}
		if (MbAzOptShowTotalWeightReq) {
			NSInteger lWeightReq = [e1obj.sumWeightNed integerValue];
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
										 dWeightStk, dWeightReq, e1obj.note];
		} else if (MbAzOptShowTotalWeight) {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1fKg  %@", 
										 dWeightStk, e1obj.note];
		} else if (MbAzOptShowTotalWeightReq) {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"／%.1fKg  %@", 
										 dWeightReq, e1obj.note];
		} else {
			cell.detailTextLabel.text = e1obj.note;
		}
		
		if (0 < lNoCheck) 
		{
			UIImageView *imageView1 = [[UIImageView alloc] init];
			UIImageView *imageView2 = [[UIImageView alloc] init];
			imageView1.image = [UIImage imageNamed:@"Check32-Circle.png"];
			imageView2.image = GimageFromString([NSString stringWithFormat:@"%ld", (long)lNoCheck]);
			UIGraphicsBeginImageContext(imageView1.image.size);
				//[imageView2  setTransform:CGAffineTransformMake(1,0,0, -1,0,0)];
				CGRect rect = CGRectMake(0, 0, imageView1.image.size.width, imageView1.image.size.height);
				[imageView1.image drawInRect:rect];  
				[imageView2.image drawInRect:rect blendMode:kCGBlendModeMultiply alpha:1.0];  
				UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();  
			UIGraphicsEndImageContext();  
			[cell.imageView setImage:resultingImage];
			AzRETAIN_CHECK(@"E1 lNoCheck:imageView1", imageView1, 1)
			[imageView1 release];
			AzRETAIN_CHECK(@"E1 lNoCheck:imageView2", imageView2, 1)
			[imageView2 release];
			AzRETAIN_CHECK(@"E1 lNoCheck:resultingImage", resultingImage, 2) //=2:releaseするとフリーズ
		} 
		else if (0 < lNoGray) {
			cell.imageView.image = [UIImage imageNamed:@"Check32-Ok.png"];
		}
		else { // 全てGray
			cell.imageView.image = [UIImage imageNamed:@"Check32-Gray.png"];
		}
		
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; // ディスクロージャボタン
		cell.showsReorderControl = YES;		// Move有効
	} 
	else {
		// Add iPack ボタンセル
		cell = [tableView dequeueReusableCellWithIdentifier:zCellDefault];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault      // Default型
										   reuseIdentifier:zCellDefault] autorelease];
		}
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.textLabel.textAlignment = UITextAlignmentCenter; // 中央寄せ
		cell.textLabel.textColor = [UIColor blackColor];
		cell.imageView.image = nil;
		cell.accessoryType = UITableViewCellAccessoryNone;  // なし、(+)マークはeditingStyleForRowAtIndexPathにて設定
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
		cell.showsReorderControl = NO;
		if (rows == 0) {
			cell.textLabel.text = NSLocalizedString(@"Add Plan", @"プラン追加");
		} else if (rows == -1) {
			cell.textLabel.text = NSLocalizedString(@"Download Google", nil);
		} else if (rows == -2) {
			cell.textLabel.text = NSLocalizedString(@"Download Sample", nil);
			if (MiSection0Rows == 0) {
				cell.textLabel.textColor = [UIColor blueColor];
				cell.textLabel.font = [UIFont systemFontOfSize:20];
			}
		} else if (rows == -3) {
			cell.textLabel.text = NSLocalizedString(@"Go to support", nil);
		} else {
			cell.textLabel.text = @"Err";
		}
	}
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger rows = MiSection0Rows - indexPath.row;
	if (0 < rows) {
		return UITableViewCellEditingStyleDelete;
    }
	else if (rows <= 0) {
		return UITableViewCellEditingStyleInsert;
	}
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 非選択状態に戻す

	NSInteger rows = MiSection0Rows - indexPath.row;
	if (0 < rows) {
		if (self.editing) {
			[self e1editView:indexPath];
		} else {
			// 次回の画面復帰のための状態記録
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate.comebackIndex replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:indexPath.section]];
			[appDelegate.comebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:indexPath.row]];
			[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:-1]];
			[appDelegate.comebackIndex replaceObjectAtIndex:3 withObject:[NSNumber numberWithInteger:-1]];
			[appDelegate.comebackIndex replaceObjectAtIndex:4 withObject:[NSNumber numberWithInteger:-1]];
			[appDelegate.comebackIndex replaceObjectAtIndex:5 withObject:[NSNumber numberWithInteger:-1]];
			// E1 : NSManagedObject
			E1 *e1obj = [MfetchedE1 objectAtIndexPath:indexPath];
			// E2 へドリルダウン
			E2viewController *e2view = [[E2viewController alloc] init];
			e2view.title = e1obj.name;
			e2view.Pe1selected = e1obj;
			[self.navigationController pushViewController:e2view animated:YES];
			[e2view release];
		}
	}
	else 
	{
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		if (rows == 0) {
			// Add Plan
			[self e1add]; // 追加される.row ＝ 現在のPlan行数
		} 
		else if (rows == -1) {
			// Download Google
			GooDocsView *goodocs = [[GooDocsView alloc] init];
			// 以下は、GooDocsViewの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
			goodocs.PmanagedObjectContext = self.RmanagedObjectContext;
			goodocs.PiSelectedRow = MiSection0Rows;  // Downloadの結果、新規追加される.row ＝ 現在のPlan行数
			goodocs.Pe1selected = nil; // DownloadのときはE1未選択であるから
			goodocs.PbUpload = NO;
			goodocs.title = cell.textLabel.text;
			goodocs.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
			[self.navigationController pushViewController:goodocs animated:YES];
			[goodocs release];
		} 
		else if (rows == -2) {  // サンプルプラン集
			SampleTVC *sample = [[SampleTVC alloc] init];
			// 以下は、GooDocsViewの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
			sample.PmanagedObjectContext = self.RmanagedObjectContext;
			sample.PiSelectedRow = MiSection0Rows;  // Downloadの結果、新規追加される.row ＝ 現在のPlan行数
			sample.title = cell.textLabel.text;
			sample.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
			[self.navigationController pushViewController:sample animated:YES];
			[sample release];
		} 
		else if (rows == -3) {  // サポートWebサイトへ
			WebSiteVC *webSite = [[WebSiteVC alloc] init];
			webSite.title = cell.textLabel.text;
			webSite.hidesBottomBarWhenPushed = NO; // 次画面にToolBarが無い場合にはYES、ある場合にはNO（YESにすると次画面のToolBarが背面に残るようだ）
			[self.navigationController pushViewController:webSite animated:YES];
			[webSite release];
		} 
	}
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
						 destructiveButtonTitle:NSLocalizedString(@"DELETE Pack", nil)
						 otherButtonTitles:nil];
		action.tag = ACTIONSEET_TAG_DELETEPACK;
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


- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// スワイプにより1行だけが編集モードに入るときに呼ばれる。
	// このオーバーライドにより、setEditting が呼び出されないようにしている。 Add行を出さないため
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	// スワイプにより1行だけが編集モードに入り、それが解除されるときに呼ばれる。
	// このオーバーライドにより、setEditting が呼び出されないようにしている。 Add行を出さないため
}

/*
 // Editモード時の行Edit可否　　＜＜特に不要。 最終Add行は、add処理が優先されるようだ＞＞
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

// Editモード時の行移動の可否　　＜＜最終行のAdd専用行を移動禁止にしている＞＞
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.row < MiSection0Rows) return YES;
	return NO;  // 最終行のAdd行は移動禁止
}

// Editモード時の行移動「先」を返す　　＜＜最終行のAdd専用行への移動ならば1つ前の行を返している＞＞
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)oldPath 
															toProposedIndexPath:(NSIndexPath *)newPath {
    NSIndexPath *target = newPath;
    // Add行が異動先になった場合、その1つ前の通常行を返すことにより、Add行への移動禁止となる。
	NSInteger rows = MiSection0Rows - 1; // 移動可能な行数（Add行を除く）
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

	// e1だけNSFetchedResultsControllerを使っているので、e2,e3とは異なる
	// E1 : NSManagedObject
	E1 *e1obj = [MfetchedE1 objectAtIndexPath:oldPath];
	e1obj.row = [NSNumber numberWithInteger:newPath.row];  // 指定セルを先に移動
	// 移動行間のE1エンティティ属性(row)を書き換える
	NSInteger i;
    NSIndexPath *ip = nil;
	if (oldPath.row < newPath.row) {
		// 後(下)へ移動
		for ( i=oldPath.row ; i < newPath.row ; i++) {
			ip = [NSIndexPath indexPathForRow:(NSUInteger)i+1 inSection:newPath.section];
			e1obj = [MfetchedE1 objectAtIndexPath:ip];
			e1obj.row = [NSNumber numberWithInteger:i];
		}
	} else {
		// 前(上)へ移動
		for (i = newPath.row ; i < oldPath.row ; i++) {
			ip = [NSIndexPath indexPathForRow:(NSUInteger)i inSection:newPath.section];
			e1obj = [MfetchedE1 objectAtIndexPath:ip];
			e1obj.row = [NSNumber numberWithInteger:i+1];
		}
	}
	// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針である＞＞
	NSError *error = nil;
	if (![self.RmanagedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	// 上で並び替えられた結果を再フィッチする（performFetch）  コンテキスト変更したときは再抽出する
	//NSError *error = nil;
	if (![MfetchedE1 performFetch:&error]) {
		NSLog(@"%@", error);
		exit(-1);  // Fail
	}
}

@end

