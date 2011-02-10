//
//  selectGroupTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "TopMenuTVC.h"
#import "E1cardTVC.h"
#import "GooDocsTVC.h"
#import "InformationView.h"
#import "SettingTVC.h"
#import "E2invoiceTVC.h"
#import "E3recordTVC.h"
#import "E3recordDetailTVC.h"
#import "E4shopTVC.h"
#import "E5categoryTVC.h"
#import "E7paymentTVC.h"
#import "WebSiteVC.h"


@interface TopMenuTVC (PrivateMethods) // メソッドのみ記述：ここに変数を書くとグローバルになる。他に同じ名称があると不具合発生する
- (void)azInformationView;
- (void)azSettingView;
- (void)e3recordAdd;
@end

@implementation TopMenuTVC
@synthesize Re0root;

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{

	// @property (retain)
	AzRETAIN_CHECK(@"TopMenuTVC Re0root", Re0root, 0)
	[Re0root release];
	[super dealloc];
}

- (void)viewDidUnload 
{
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。

	// @property (retain) は解放しない。
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {  // セクションありテーブル
		//self.navigationItem.rightBarButtonItem = self.editButtonItem;
		//self.tableView.allowsSelectionDuringEditing = YES;
	}
	return self;
}

- (void)barButtonAdd {
	// Add Card
	[self e3recordAdd];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
//	MfetchE1card = nil;

	MiE1cardCount = 0;

	// Set up NEXT Left [Back] buttons.
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]
									   initWithImage:[UIImage imageNamed:@"simpleLeft-icon16.png"]
									   style:UIBarButtonItemStylePlain  target:nil  action:nil];
	self.navigationItem.backBarButtonItem = backButtonItem;
	[backButtonItem release];

#ifndef AzMAKE_SPLASHFACE
	// Tool Bar Button
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	UIBarButtonItem *buInfo = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Information-icon16.png"]
															   style:UIBarButtonItemStylePlain  //Bordered
															  target:self action:@selector(azInformationView)];
	UIBarButtonItem *buAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																		   target:self action:@selector(barButtonAdd)];
	UIBarButtonItem *buSet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Setting-icon16.png"]
															  style:UIBarButtonItemStylePlain  //Bordered
															 target:self action:@selector(azSettingView)];
	NSArray *buArray = [NSArray arrayWithObjects: buInfo, buFlex, buAdd, buFlex, buSet, nil];
	[self setToolbarItems:buArray animated:YES];
	[buInfo release];
	[buAdd release];
	[buSet release];
	[buFlex release];
#endif	
	
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
	else if (MbOptAntirotation) return NO; // 回転禁止

	if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		// 逆面（ホームボタンが画面の上側にある状態）
		[self.navigationController setToolbarHidden:NO animated:YES]; // ツールバー表示
	} else {
		// 横方向や逆向きのとき
		[self.navigationController setToolbarHidden:YES animated:YES]; // ツールバー非表示=YES
		if (MinformationView) {
			[MinformationView hide]; // 正面でなければhide
		}
	}
	return YES;
	// 現在の向きは、self.interfaceOrientation で取得できる
}

- (void)viewWillAppear:(BOOL)animated 	// ＜＜見せない処理＞＞
{
    [super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	MbOptEnableSchedule = [defaults boolForKey:GD_OptEnableSchedule];
	MbOptEnableCategory = [defaults boolForKey:GD_OptEnableCategory];
	
	self.title = NSLocalizedString(@"Product Title",nil);
	

	//-----------------------------------------------------------------------------
	// E1card 件数を求める
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"E1card" 
											  inManagedObjectContext:Re0root.managedObjectContext];
	[fetchRequest setEntity:entity];
	// Fitch
	NSError *error = nil;
	NSArray *arFetch = [Re0root.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		AzLOG(@"Error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	MiE1cardCount = [arFetch count];
	[fetchRequest release];
	
	
	// TableView Reflesh
	[self.tableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated {	// ＜＜魅せる処理＞＞
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる

	// Comback (-1)にして未選択状態にする
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	// (0)This clear
	[appDelegate.comebackIndex replaceObjectAtIndex:0 withObject:[NSNumber numberWithLong:-1]];
}

// カムバック処理（復帰再現）：AppDelegate から呼ばれる
- (void)viewComeback:(NSArray *)selectionArray
{
	// L0
	NSInteger lRow = [[selectionArray objectAtIndex:0] integerValue];
	if (lRow < 0) return; // この画面表示
	
	NSInteger lSec = lRow / GD_SECTION_TIMES;
	if (lSec < 0) return; // この画面表示
	lRow -= (lSec * GD_SECTION_TIMES);
	
	if (MiE1cardCount <= 0) return; // No Card
	
	// didSelectRowAtIndexPath と同様の振り分けになる
	switch (lSec) {
		case 0: //---------------------------------------------SECTION 0
			switch (lRow) {
				case 0: // Add Deteil
					// なにもしない
					break;
				case 1: // E3recordTVC へ
					{
						E3recordTVC *tvc = [[E3recordTVC alloc] init];
						tvc.title =  NSLocalizedString(@"Record list", nil);
						tvc.Re0root = Re0root;
						//tvc.Pe1card = nil;  // =nil:最近の全E3表示モード　　=e1obj:指定E1以下を表示することができる
						tvc.Pe4shop = nil;
						tvc.Pe5category = nil;
						[self.navigationController pushViewController:tvc animated:NO];
						lRow = [[selectionArray objectAtIndex:1] integerValue];
						if (0 <= lRow) { // lRow<0:ならば「最近の明細：末尾」を表示する
							// viewComeback を呼び出す
							[tvc viewWillAppear:NO]; // Fechデータセットさせるため
							[tvc viewComeback:selectionArray];
						}
						[tvc release];
					}
					break;
				case 2: // E7paymentTVC へ
				{
					// E7paymentTVC へ
					E7paymentTVC *tvc = [[E7paymentTVC alloc] init];
					tvc.title =  NSLocalizedString(@"Payment list", nil);
					tvc.Re0root = Re0root;
					[self.navigationController pushViewController:tvc animated:NO];
					// viewComeback を呼び出す
					[tvc viewWillAppear:NO]; // Fechデータセットさせるため
					[tvc viewComeback:selectionArray];
					[tvc release];
				}
					break;
			}
			break;
		case 1: //---------------------------------------------SECTION 1
			switch (lRow) {
				case 0: // E1card へ
					{
						E1cardTVC *tvc = [[E1cardTVC alloc] init];
						tvc.title = NSLocalizedString(@"Card list",nil);
						tvc.Re0root = Re0root;
						tvc.Re3edit = nil;
						[self.navigationController pushViewController:tvc animated:NO];
						// viewComeback を呼び出す
						[tvc viewWillAppear:NO]; // Fechデータセットさせるため
						[tvc viewComeback:selectionArray];
						[tvc release];
					}
					break;
				case 1: // E4shop へ
				{
					E4shopTVC *tvc = [[E4shopTVC alloc] init];
					tvc.title = NSLocalizedString(@"Shop list",nil);
					tvc.Re0root = Re0root;
					tvc.Pe3edit = nil;
					[self.navigationController pushViewController:tvc animated:NO];
					// viewComeback を呼び出す
					[tvc viewWillAppear:NO]; // Fechデータセットさせるため
					[tvc viewComeback:selectionArray];
					[tvc release];
				}
					break;
				case 2: // Category list
					break;
			}
			break;
		case 2: //---------------------------------------------SECTION 2
			switch (lRow) {
				case 0:
				{
					GooDocsTVC *goodocs = [[GooDocsTVC alloc] init];
					goodocs.title = @"Google Document";
					goodocs.Re0root = Re0root;
					goodocs.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
					[self.navigationController pushViewController:goodocs animated:NO];
					[goodocs release];
				}
					break;
			}
			break;
	}
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // セクションは1つだけ section==0
#ifdef AzMAKE_SPLASHFACE
	return 0;
#else
	switch (section) {
		case 0:			// 利用明細
			if (MbOptEnableSchedule) return 3;
			else					 return 2;
			break;
		case 1:			// 集計
			if (MbOptEnableCategory) return 3;
			else					 return 2;
			break;
		case 2:			// 機能
			return 2;
			break;
	}
	return 0;
#endif
}

/*
// TableView セクションタイトルを応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	return nil;
}
*/

// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{
#ifndef AzMAKE_SPLASHFACE
	switch (section) {
		case 0: // 未払い総額を表示する
			// E7 未払い総額
			if ([Re0root.e7unpaids count] <= 0) {
				return NSLocalizedString(@"No unpaid",nil);
			} else {
				NSNumber *nUnpaid = [Re0root valueForKeyPath:@"e7unpaids.@sum.sumAmount"];
				// Amount JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
				NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
				[formatter setNumberStyle:NSNumberFormatterCurrencyStyle]; // 通貨スタイル
				NSLocale *localeJP = [[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"];
				[formatter setLocale:localeJP];
				[localeJP release];
				NSString *str = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Unpaid",nil), 
								 [formatter stringFromNumber:nUnpaid]];
				[formatter release];
				return str;
			}
			break;
		case 2:
			return	@"AzukiSoft Project\n"
					@"©2000-2010 Azukid";
			break;
	}
#endif
	return nil;
}


 // セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger iHeight = 58;
	if (MbOptEnableSchedule) iHeight -= 7;
	if (MbOptEnableCategory) iHeight -= 7;
	return iHeight; // デフォルト：44ピクセル
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"CellMenu";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier] autorelease];

		cell.textLabel.font = [UIFont systemFontOfSize:16];
		//cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.textColor = [UIColor blackColor];
		
//		cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
		//cell.detailTextLabel.textAlignment = UITextAlignmentRight;
//		cell.detailTextLabel.textColor = [UIColor blackColor];

		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	switch (indexPath.section) {
		case 0: //-------------------------------------------------------------Statement
		{
			switch (indexPath.row) {
				case 0:
					cell.imageView.image = [UIImage imageNamed:@"Cell32-Add.png"];
					cell.textLabel.text = NSLocalizedString(@"Add Record", nil);
					break;
				case 1:
					cell.imageView.image = [UIImage imageNamed:@"Statements32.png"];
					cell.textLabel.text = NSLocalizedString(@"Record list", nil);
					break;
				case 2:
					cell.imageView.image = [UIImage imageNamed:@"PaySchedule32.png"];
					cell.textLabel.text = NSLocalizedString(@"Payment list", nil);
					break;
			}
		}
			break;
		case 1: //-------------------------------------------------------------Groups
		{
			switch (indexPath.row) {
				case 0:
					cell.imageView.image = [UIImage imageNamed:@"Cards32.png"];
					cell.textLabel.text = NSLocalizedString(@"Card list", nil);
					break;
				case 1:
					cell.imageView.image = [UIImage imageNamed:@"Shop32.png"];
					cell.textLabel.text = NSLocalizedString(@"Shop list", nil);
					cell.detailTextLabel.text = nil;
					break;
				case 2:
					cell.imageView.image = [UIImage imageNamed:@"Category32.png"];
					cell.textLabel.text = NSLocalizedString(@"Category list", nil);
					cell.detailTextLabel.text = nil;
					break;
			}
		}
			break;
		case 2: //-------------------------------------------------------------Function
		{
			switch (indexPath.row) {
				case 0:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-Google.png"];
					cell.textLabel.text = NSLocalizedString(@"Backup Restore", nil);
					break;
//				case 1:
//					cell.imageView.image = [UIImage imageNamed:@"Check32-Circle.png"];
//					cell.textLabel.text = NSLocalizedString(@"CSV File", nil);
//					break;
				case 1:
					cell.imageView.image = [UIImage imageNamed:@"Icon32-WebSafari.png"];
					cell.textLabel.text = NSLocalizedString(@"Support Site", nil);
					break;
			}
		}
			break;
	}
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
	// Comback-L0 TopMenu 記録
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	long lPos = indexPath.section * GD_SECTION_TIMES + indexPath.row;
	// (0)This >> (1)Clear
	[appDelegate.comebackIndex replaceObjectAtIndex:0 withObject:[NSNumber numberWithLong:lPos]];
	[appDelegate.comebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:-1]];

	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

	switch (indexPath.section) {
		case 0:
		{
			switch (indexPath.row) {
				case 0: // Add Record
					[self e3recordAdd]; // E3record 新規追加
					break;
				case 1: // 利用日一覧　E3 < E3detail
				{
					// E3records へ
					E3recordTVC *tvc = [[E3recordTVC alloc] init];
					tvc.title =  cell.textLabel.text;
					tvc.Re0root = Re0root;
					//tvc.Pe1card = nil;  // =nil:最近の全E3表示モード　　=e1obj:指定E1以下を表示することができる
					tvc.Pe4shop = nil;
					tvc.Pe5category = nil;
					[self.navigationController pushViewController:tvc animated:YES];
					[tvc release];
				}
					break;
				case 2: // 支払日一覧　E7 < E2 < E6 < E3detail
				{
					// E7paymentTVC へ
					E7paymentTVC *tvc = [[E7paymentTVC alloc] init];
					tvc.title =  cell.textLabel.text;
					tvc.Re0root = Re0root;
					[self.navigationController pushViewController:tvc animated:YES];
					[tvc release];
				}
					break;
			}
		}
			break;
		case 1:
		{
			switch (indexPath.row) {
				case 0: // カード一覧  E1 < E2 < E6 < E3detail
				{
					// E1card へ
					E1cardTVC *tvc = [[E1cardTVC alloc] init];
					tvc.title = cell.textLabel.text;
					tvc.Re0root = Re0root;
					tvc.Re3edit = nil;
					[self.navigationController pushViewController:tvc animated:YES];
					[tvc release];
				}
					break;
				case 1: // 利用店一覧  E4 < E3 < E3detail
				{
					E4shopTVC *tvc = [[E4shopTVC alloc] init];
					tvc.title = cell.textLabel.text;
					tvc.Re0root = Re0root;
					tvc.Pe3edit = nil;
					[self.navigationController pushViewController:tvc animated:YES];
					[tvc release];
				}
					break;
				case 2: // 分類一覧  E4 < E3 < E3detail
				{
					E5categoryTVC *tvc = [[E5categoryTVC alloc] init];
					tvc.title = cell.textLabel.text;
					tvc.Re0root = Re0root;
					tvc.Pe3edit = nil;
					[self.navigationController pushViewController:tvc animated:YES];
					[tvc release];
				}
					break;
			}
		}
			break;
		case 2:
		{
			switch (indexPath.row) {
				case 0: // Google Document
				{
					GooDocsTVC *goodocs = [[GooDocsTVC alloc] init];
					// 以下は、GooDocsViewの viewDidLoad 後！、viewWillAppear の前に処理されることに注意！
					goodocs.title = cell.textLabel.text;
					goodocs.Re0root = Re0root;
					goodocs.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
					[self.navigationController pushViewController:goodocs animated:YES];
					[goodocs release];
				}
					break;
				case 1:
				{  // サポートWebサイトへ
					WebSiteVC *webSite = [[WebSiteVC alloc] init];
					webSite.title = cell.textLabel.text;
					webSite.hidesBottomBarWhenPushed = NO; // 次画面にToolBarが無い場合にはYES、ある場合にはNO（YESにすると次画面のToolBarが背面に残るようだ）
					[self.navigationController pushViewController:webSite animated:YES];
					[webSite release];
				} 
					break;
			}
		}
			break;
	}
}

- (void)azInformationView
{
	// ヨコ非対応につき正面以外は、hideするようにした。
	MinformationView = [[InformationView alloc] initWithFrame:[self.view.window bounds]];
	[self.view.window addSubview:MinformationView]; //回転しないが、.viewから出すとToolBarが隠れない
	[MinformationView release]; // addSubviewにてretain(+1)されるため、こちらはrelease(-1)して解放
	[MinformationView show];
}

- (void)azSettingView
{
	SettingTVC *view = [[SettingTVC alloc] init];
	//view.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:view animated:YES];
	[view release];
}

- (void)e3recordAdd
{
	if (MiE1cardCount <= 0) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Card",nil) 
														 message:NSLocalizedString(@"No Card msg",nil) 
														delegate:nil 
											   cancelButtonTitle:nil 
											   otherButtonTitles:@"OK", nil] autorelease];
		[alert show];
		return;
	}
	
	E3record *e3obj = [NSEntityDescription insertNewObjectForEntityForName:@"E3record"
													inManagedObjectContext:Re0root.managedObjectContext];
	e3obj.dateUse = [NSDate date]; // 迷子にならないように念のため
	e3obj.e1card = nil;
	e3obj.e4shop = nil;
	e3obj.e5category = nil;
	e3obj.e6parts = nil;

	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	e3detail.title = NSLocalizedString(@"Add Record", nil);
	e3detail.Re3edit = e3obj;
	e3detail.PiAdd = (1); // (1)New Add
	//e3detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
	[self.navigationController pushViewController:e3detail animated:YES];
	[e3detail release]; // self.navigationControllerがOwnerになる
}


@end

