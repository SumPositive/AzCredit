//
//  E2invoiceTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "EntityRelation.h"
#import "E2invoiceTVC.h"
#import "E6partTVC.h"

#define	TAG_ALERT_NoCheck		109
#define	TAG_ALERT_toPAY			118
#define	TAG_ALERT_toPAID		127


//-------------------------------------------E2invoiceTVCローカル使用一時作業クラス定義
@interface E2temp : NSObject
{
	NSInteger		iYearMMDD;
	BOOL			bPaid;
	NSInteger		iSum;
	NSInteger		iNoCheck;
	NSMutableSet	*e2invoices;
}
@property (nonatomic, assign) NSInteger		iYearMMDD;
@property (nonatomic, assign) BOOL			bPaid;
@property (nonatomic, assign) NSInteger		iSum;
@property (nonatomic, assign) NSInteger		iNoCheck;
@property (nonatomic, retain) NSMutableSet	*e2invoices;
- (void)dealloc;
- (id)initWithYearMMDD:(NSInteger)iY inPaid:(BOOL)bP;
@end
//-------------------------------------------E2invoiceTVCローカル使用一時作業クラス実装
@implementation E2temp
@synthesize iYearMMDD, bPaid, iSum, iNoCheck, e2invoices;

- (void)dealloc {   // 生成とは逆順に解放するのが好ましい
	[e2invoices release];
	[super dealloc];
}

- (id)initWithYearMMDD:(NSInteger)iY inPaid:(BOOL)bP {
	self = [super init];
	if (self != nil) {
		iYearMMDD = iY;
		bPaid = bP;
		iSum = 0;
		iNoCheck = 0;
		e2invoices = [NSMutableSet new];
	}
	return self;
}
@end


//-----------------------------------------------------------------------------------------------
@interface E2invoiceTVC (PrivateMethods)
- (void)viewDesign;
- (void)cellLeftButton: (UIButton *)button;
@end

@implementation E2invoiceTVC
@synthesize Re1select;
@synthesize Re8select;

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[Me2list release];
	
	// @property (retain)
	[Re1select release];
	[Re8select release];
	[MautoreleasePool release];
	[super dealloc];
}

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {  // セクションありテーブル
		// 初期化成功
		MautoreleasePool = [[NSAutoreleasePool alloc] init];	// [0.3]autorelease独自解放のため
		MbFirstAppear = YES; // Load後、最初に1回だけ処理するため
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
    [super loadView];
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
	// なし

	// Set up NEXT Left [Back] buttons.
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]
									   initWithImage:[UIImage imageNamed:@"simpleLeft3-icon16.png"]
									   style:UIBarButtonItemStylePlain  target:nil  action:nil];
	self.navigationItem.backBarButtonItem = backButtonItem;
	[backButtonItem release];		

	
	// Tool Bar Button
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	UIBarButtonItem *buTop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Bar32-Top.png"]
															  style:UIBarButtonItemStylePlain  //Bordered
															 target:self action:@selector(barButtonTop)];
	NSArray *buArray = [NSArray arrayWithObjects: buTop, buFlex, nil];
	[self setToolbarItems:buArray animated:YES];
	[buTop release];
	[buFlex release];
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:YES];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];

	if (Re1select && Re8select) {
		AzLOG(@"LOGIC ERROR: Pe1select,Re8select != nil");
		exit(-1);  // Fail
	}
	
	// Me2list : Pe1select.e2invoices 全データ取得 >>> (0)支払済セクション　(1)未払いセクション に分割
	if (Me2list != nil) {
		[Me2list release];
		Me2list = nil;
	}

	//[0.3]E7E2クリーンアップ
	[EntityRelation e7e2clean];

	if (Re1select) {	//------------------------------E1card
		assert(Re8select==nil);
		// E2temp Sort条件
		NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"iYearMMDD" ascending:YES];
		NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
		[sort1 release];

		NSMutableArray *muE2tmp = nil;
		// E2paid 支払済
		muE2tmp = [NSMutableArray new];
		for (E2invoice *e2 in Re1select.e2paids) {
			E2temp *e2t = [[E2temp alloc] initWithYearMMDD:[e2.nYearMMDD integerValue] inPaid:YES];
			e2t.iSum = [e2.sumAmount integerValue];
			e2t.iNoCheck = [e2.sumNoCheck integerValue];
			[e2t.e2invoices addObject:e2];
			[muE2tmp addObject:e2t];
			[e2t release];
		}
		[muE2tmp sortUsingDescriptors:sortArray];
		Me2list = [[NSMutableArray alloc] initWithObjects:muE2tmp,nil]; // 一次元追加
		[muE2tmp release];
		// E2unpaid 支払済
		muE2tmp = [NSMutableArray new];
		for (E2invoice *e2 in Re1select.e2unpaids) {
			E2temp *e2t = [[E2temp alloc] initWithYearMMDD:[e2.nYearMMDD integerValue] inPaid:NO];
			e2t.iSum = [e2.sumAmount integerValue];
			e2t.iNoCheck = [e2.sumNoCheck integerValue];
			[e2t.e2invoices addObject:e2];
			[muE2tmp addObject:e2t];
			[e2t release];
		}
		[muE2tmp sortUsingDescriptors:sortArray];
		[Me2list addObject:muE2tmp]; // 一次元追加
		[muE2tmp release];
		[sortArray release];
	}
	else if (Re8select) { //---------------------------E8bank
		assert(Re1select==nil);
		// E2 Sort条件
		NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"nYearMMDD" ascending:YES];
		NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
		[sort1 release];
		NSMutableArray *muE2paid = [NSMutableArray new];
		NSMutableArray *muE2unpaid = [NSMutableArray new];
		// E2paid 支払済
		for (E1card *e1 in Re8select.e1cards) {
			[muE2paid addObjectsFromArray:[e1.e2paids allObjects]];
			[muE2unpaid addObjectsFromArray:[e1.e2unpaids allObjects]];
		}
		//.nYearMMDD 昇順ソート
		[muE2paid sortUsingDescriptors:sortArray];	
		[muE2unpaid sortUsingDescriptors:sortArray];
		[sortArray release];
		// 日付の重複を取り除く ＜＜高速列挙で削除は危険！以下のように末尾から削除すること＞＞
		// Paid
		NSMutableArray *muE2tmp = [NSMutableArray new];
		E2temp *e2t = nil;
		for (E2invoice *e2 in muE2paid) {
			if (e2t==nil OR e2t.iYearMMDD != [e2.nYearMMDD integerValue]) {
				if (e2t) {
					[muE2tmp addObject:e2t];
					[e2t release];
				}
				e2t = [[E2temp alloc] initWithYearMMDD:[e2.nYearMMDD integerValue] inPaid:YES];
			}
			e2t.iSum += [e2.sumAmount integerValue];
			e2t.iNoCheck += [e2.sumNoCheck integerValue];
			[e2t.e2invoices addObject:e2];
		}
		if (e2t) {
			[muE2tmp addObject:e2t];
			[e2t release];
		}
		Me2list = [[NSMutableArray alloc] initWithObjects:muE2tmp,nil]; // 一次元追加
		[muE2tmp release];
		[muE2paid release];
		// Paid
		muE2tmp = [NSMutableArray new];
		e2t = nil;
		for (E2invoice *e2 in muE2unpaid) {
			if (e2t==nil OR e2t.iYearMMDD != [e2.nYearMMDD integerValue]) {
				if (e2t) {
					[muE2tmp addObject:e2t];
					[e2t release];
				}
				e2t = [[E2temp alloc] initWithYearMMDD:[e2.nYearMMDD integerValue] inPaid:NO];
			}
			e2t.iSum += [e2.sumAmount integerValue];
			e2t.iNoCheck += [e2.sumNoCheck integerValue];
			[e2t.e2invoices addObject:e2];
		}
		if (e2t) {
			[muE2tmp addObject:e2t];
			[e2t release];
		}
		[Me2list addObject:muE2tmp]; // 一次元追加
		[muE2tmp release];
		[muE2unpaid release];
	}
	else {
		AzLOG(@"LOGIC ERROR: Pe1select,Re8select == nil");
		exit(-1);  // Fail
	}
	
	// テーブルビューを更新します。
    [self.tableView reloadData];

	if (!MbFirstAppear OR [Me2list count] < 2) return;

	if (1 <= [[Me2list objectAtIndex:1] count]) {  
		// Unpaid の先頭へ
		MbFirstAppear = NO;
		// 未払いの先頭を画面中央に表示する
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
	}
	else if (1 <= [[Me2list objectAtIndex:0] count]) {
		// PAID の末尾へ
		MbFirstAppear = NO;
		// 未払いの先頭を画面中央に表示する
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[[Me2list objectAtIndex:0] count]-1 inSection:0];
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
	}
}

- (void)barButtonTop {
	[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
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

/*
// 回転を始める前にこの処理が呼ばれる。
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
								duration:(NSTimeInterval)duration {
 // この時点では self.View は、まだ回転前の状態
}

// 回転の最初の半分が始まる前にこの処理が呼ばれる。
- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
													duration:(NSTimeInterval)duration {
	// この時点では self.View は、まだ回転前の状態
}
 */

// 回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration {
	// この時点で self.View は、回転後の状態になっている
	[self.tableView reloadData];  // self.View の状態に従って描画しているので、ここが最も早いタイミングになる。
}

/*
- (void)viewDesign
{
	// 回転によるリサイズ
//	McellLabel.frame = CGRectMake(self.tableView.frame.size.width-115, 12, 80, 20);
}
*/

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる

	// Comback (-1)にして未選択状態にする
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	// (0)TopMenu >> (1)E1card/E7payment >> (2)This clear
	[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
}

// カムバック処理（復帰再現）：親から呼ばれる
- (void)viewComeback:(NSArray *)selectionArray
{
	// (0)TopMenu >> (1)E1card >> (2)This
	NSInteger lRow = [[selectionArray objectAtIndex:2] integerValue];
	if (lRow < 0) return; // この画面に留まる
	NSInteger lSec = lRow / GD_SECTION_TIMES;
	lRow -= (lSec * GD_SECTION_TIMES);

	if ([Me2list count] <= lSec) return; // section OVER
	if ([[Me2list objectAtIndex:lSec] count] <= lRow) return; // row OVER（Addや削除されたとか）

	// 選択行を画面中央付近に表示する
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lRow inSection:lSec];
	[self.tableView scrollToRowAtIndexPath:indexPath 
						  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO

	E2temp *e2t = [[Me2list objectAtIndex:lSec] objectAtIndex:lRow];
	if ([e2t.e2invoices count] <= 0) return;

	// (0)TopMenu >> (1)E1card >> (2)This >> (3)E6partTVC へ
	E6partTVC *tvc = [[E6partTVC alloc] init];
	if (Re1select) {
		tvc.title =  Re1select.zName;
		// 編集移動により支払日の変更が可能
		tvc.Pe2select = [[e2t.e2invoices allObjects] objectAtIndex:0];  //[[Me2list objectAtIndex:lSec] objectAtIndex:lRow];
	} else {
		NSInteger iYear = e2t.iYearMMDD / 10000;
		NSInteger iDD = e2t.iYearMMDD - (iYear * 10000);
		NSInteger iMM = iDD / 100;
		iDD -= (iMM * 100);
		if (e2t.bPaid) {
			tvc.title = [NSString stringWithFormat:@"(%d-%d%@) %@",
						 (int)iMM, (int)iDD, NSLocalizedString(@"Pre",nil), Re8select.zName];
		} else {
			tvc.title = [NSString stringWithFormat:@"(%d-%d%@) %@", 
						 (int)iMM, (int)iDD, NSLocalizedString(@"Due",nil), Re8select.zName];
		}
		// 支払日一覧と同様のカード別一覧（支払日の変更はできない）
		tvc.Pe2invoices = e2t.e2invoices;
	}
	tvc.PiFirstSection = lSec;
	[self.navigationController pushViewController:tvc animated:NO];
	// viewComeback を呼び出す
	[tvc viewWillAppear:NO]; // Fech データセットさせるため
	[tvc viewComeback:selectionArray];
	[tvc release];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [Me2list count];  // Me2listは、(0)e2paids (1)e2unpaids の二次元配列
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [[Me2list objectAtIndex:section] count];
}

// TableView セクション名を応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			return NSLocalizedString(@"Paid header",nil);
			break;
		case 1:
			// E2 未払い総額
			//if ([Re1select.e2unpaids count] <= 0) {
			if ([[Me2list objectAtIndex:1] count] <= 0) {  // Index: 0=Paid 1=Unpaid
				return NSLocalizedString(@"Following unpaid nothing",nil);
			} 
			else {
				NSNumber *nUnpaid;
				if (Re1select) { // E1card
					nUnpaid = [Re1select valueForKeyPath:@"e2unpaids.@sum.sumAmount"];
				} else { // E8bank
					nUnpaid = [Re8select valueForKeyPath:@"e1cards.@sum.e2unpaids.@sum.sumAmount"];
				}
				// Amount JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
				NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
				[formatter setNumberStyle:NSNumberFormatterCurrencyStyle]; // 通貨スタイル
				NSLocale *localeJP = [[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"];
				[formatter setLocale:localeJP];
				[localeJP release];
				NSString *str = [NSString stringWithFormat:@"%@ %@", 
								 NSLocalizedString(@"Following unpaid",nil), 
								 [formatter stringFromNumber:nUnpaid]];
				[formatter release];
				return str;
			}
			break;
	}
	return @"Err";
}

// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			return NSLocalizedString(@"E2paidFooter",nil);
			break;
		case 1:
			if (Re1select) {
				return NSLocalizedString(@"E2unpaidFooter",nil);
			} else {
				// "支払日の変更は、\nカード一覧から可能です。"
				return NSLocalizedString(@"E2unpaidFromE8",nil);
			}

			break;
	}
	return nil;
}

/*
 // セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 44; // デフォルト：44ピクセル
}*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *zCellIndex = @"CellE2invoice";
	UITableViewCell *cell = nil;
	UILabel *cellLabel = nil;
	
	cell = [tableView dequeueReusableCellWithIdentifier:zCellIndex];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:zCellIndex] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
		cell.showsReorderControl = NO; // Move禁止

		cell.textLabel.font = [UIFont systemFontOfSize:16];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.textColor = [UIColor blackColor];

		cellLabel = [[UILabel alloc] init];
		cellLabel.textAlignment = UITextAlignmentRight;
		//cellLabel.textColor = [UIColor blackColor];
		//cellLabel.backgroundColor = [UIColor grayColor]; //DEBUG範囲チェック用
		cellLabel.font = [UIFont systemFontOfSize:14];
		cellLabel.tag = -1;
		[cell addSubview:cellLabel]; [cellLabel release];
	}
	else {
		cellLabel = (UILabel *)[cell viewWithTag:-1];
	}
	// 回転対応のため
	cellLabel.frame = CGRectMake(self.tableView.frame.size.width-125, 12, 90, 20);

	// 左ボタン --------------------＜＜cellLabelのようにはできない！.tagに個別記録するため＞＞
	UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom]; // autorelease
	cellButton.frame = CGRectMake(0,0, 44,44);
	[cellButton addTarget:self action:@selector(cellLeftButton:) forControlEvents:UIControlEventTouchUpInside];
	cellButton.backgroundColor = [UIColor clearColor]; //背景透明
	cellButton.showsTouchWhenHighlighted = YES;
	cellButton.tag = indexPath.section * GD_SECTION_TIMES + indexPath.row;
	[cell.contentView addSubview:cellButton]; //[bu release]; buttonWithTypeにてautoreleseされるため不要。UIButtonにinitは無い。
	// 左ボタン ------------------------------------------------------------------

	//E2invoice *e2obj = [[Me2list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	E2temp *e2obj = [[Me2list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

	// 支払日
/*	if (e2obj.e1paid) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", GstringYearMMDD([e2obj.nYearMMDD integerValue]),
							   NSLocalizedString(@"Pre",nil)];
	} else {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", GstringYearMMDD([e2obj.nYearMMDD integerValue]),
							   NSLocalizedString(@"Due",nil)];
	}*/
	if (e2obj.bPaid) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", GstringYearMMDD(e2obj.iYearMMDD),
																	NSLocalizedString(@"Pre",nil)];
	} else {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", GstringYearMMDD(e2obj.iYearMMDD),
																	NSLocalizedString(@"Due",nil)];
	}

	// 金額
	//if ([e2obj.sumAmount integerValue] <= 0) {
	if (e2obj.iSum <= 0) {
		cellLabel.textColor = [UIColor blueColor];
	} else {
		cellLabel.textColor = [UIColor blackColor];
	}
	// Amount JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // CurrencyStyle]; // 通貨スタイル
	cellLabel.text = [formatter stringFromNumber:[NSNumber numberWithInteger:e2obj.iSum]];  //e2obj.sumAmount];
	[formatter release];
	
	if (indexPath.section == 0) {
		cell.imageView.image = [UIImage imageNamed:@"Paid32.png"];  // PAID 支払済
	}
	else {
		//cell.imageView.image = [UIImage imageNamed:@"Unpaid32.png"]; // 未払い
		// sumNoCheck を Circle 内に表示
		//NSInteger lNoCheck = [e2obj.sumNoCheck integerValue];
		NSInteger lNoCheck = e2obj.iNoCheck;
		if (0 < lNoCheck) {
			UIImageView *imageView1 = [[UIImageView alloc] init];
			UIImageView *imageView2 = [[UIImageView alloc] init];
			imageView1.image = [UIImage imageNamed:@"Circle32-NoCheck.png"];
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
		else if	(0 < e2obj.iSum) {  // [e2obj.sumAmount integerValue]) {
			cell.imageView.image = [UIImage imageNamed:@"Circle32-Unpaid.png"];  // PAY
		} 
		else {
			cell.imageView.image = [UIImage imageNamed:@"Circle32.png"];  // Nothing
		}
	}
	return cell;
}

- (void)cellLeftButton: (UIButton *)button		// PAID or Unpaid ボタン
{
	//AzLOG(@"button.tag=%ld", (long)button.tag);
	if (button.tag < 0) return;
	NSInteger iSec = button.tag / GD_SECTION_TIMES;
	if ([Me2list count] <= iSec) return;
	NSInteger iRow = button.tag - (iSec * GD_SECTION_TIMES);
	if ([[Me2list objectAtIndex:iSec] count] <= iRow) return;
	// E2temp : Paid <<<CHANGE>>> Unpaid
	Me2cellButton = [[Me2list objectAtIndex:iSec] objectAtIndex:iRow]; 
	
	//if (Me2cellButton.e1paid) {
	if (Me2cellButton.bPaid) {
		// E2 PAID -->> PAYに戻す
#if AzDEBUG
		//if (Me2cellButton.e1unpaid OR !Me2cellButton.e7payment.e0paid OR Me2cellButton.e7payment.e0unpaid) {
		//	AzLOG(@"LOGIC ERR: E2.e1paid NG");
		//	return;
		//}
		for (E2invoice *e2 in [Me2cellButton.e2invoices allObjects]) {
			if (e2.e1unpaid OR e2.e7payment.e0unpaid) {
				AzLOG(@"LOGIC ERR: E2.e1paid NG");
				return;
			}
		}
#endif
		// これより後に paid があれば禁止		"最下行から PAY に戻せます"
		//for (E2invoice *e2 in Me2cellButton.e1paid.e2paids) {
		for (E2temp *e2t in [Me2list objectAtIndex:0]) {
			if (Me2cellButton.iYearMMDD < e2t.iYearMMDD) {
				UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"E2 to PAY NG",nil) 
																 message:NSLocalizedString(@"E2 to PAY NG msg",nil) 
																delegate:nil
													   cancelButtonTitle:nil
													   otherButtonTitles:@"OK", nil] autorelease];
				[alert show];
				return; // 禁止
			}
		}
		
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"E2 to PAY",nil) 
														 message:NSLocalizedString(@"E2 to PAY msg",nil) 
														delegate:self
											   cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
											   otherButtonTitles:@"OK", nil] autorelease];
		alert.tag = TAG_ALERT_toPAY;
		[alert show];
	}
	else {  //if (Me2cellButton.e1unpaid) {
#if AzDEBUG
		//if (Me2cellButton.e1paid OR Me2cellButton.e7payment.e0paid OR !Me2cellButton.e7payment.e0unpaid) {
		//	AzLOG(@"LOGIC ERR: E2.e1unpaid NG");
		//	return;
		//}
		for (E2invoice *e2 in [Me2cellButton.e2invoices allObjects]) {
			if (e2.e1paid OR e2.e7payment.e0paid) {
				AzLOG(@"LOGIC ERR: E2.e1unpaid NG");
				return;
			}
		}
#endif
		// "最上行から PAID にできます"
		//for (E2invoice *e2 in Me2cellButton.e1unpaid.e2unpaids) {
		for (E2temp *e2t in [Me2list objectAtIndex:1]) {
			//if ([e2.nYearMMDD integerValue] < [Me2cellButton.nYearMMDD integerValue]) {
			if (e2t.iYearMMDD < Me2cellButton.iYearMMDD) {
				// これより前に unpaid があるので禁止
				UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"E2 to PAID NG",nil) 
																 message:NSLocalizedString(@"E2 to PAID NG msg",nil) 
																delegate:nil
													   cancelButtonTitle:nil
													   otherButtonTitles:@"OK", nil] autorelease];
				[alert show];
				return; // 禁止
			}
		}
		//if (0 < [Me2cellButton.sumNoCheck integerValue]) {
		if (0 < Me2cellButton.iNoCheck) {
			// E2配下に未チェックあり、「未チェック分を翌月払いにしますか？」 >>> alertView:clickedButtonAtIndex:メソッドが呼び出される
			// 初版未対応とする！未チェックあれば禁止
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoCheck",nil) 
															 message:NSLocalizedString(@"NoCheck msg",nil) 
															delegate:nil  //self
												   cancelButtonTitle:nil  //NSLocalizedString(@"Cancel",nil)
												   otherButtonTitles:@"OK", nil] autorelease];
			//alert.tag = TAG_ALERT_NoCheck;
			[alert show];
			return; // 禁止
		}
		// E2 PAY -->> PAID
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"E2 to PAID",nil) 
														 message:NSLocalizedString(@"E2 to PAID msg",nil) 
														delegate:self
											   cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
											   otherButtonTitles:@"OK", nil] autorelease];
		alert.tag = TAG_ALERT_toPAID;
		[alert show];
	}
	//else {
	//	AzLOG(@"LOGIC ERR: E2.e1paid = e1unpaid = nil 孤立状態");
	//	return;
	//}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (buttonIndex == alertView.cancelButtonIndex) return; // CANCEL
	if (Me2cellButton == nil) return;
	
	switch (alertView.tag) {
		/* 初版未対応！未チェックあれば禁止
		case TAG_ALERT_NoCheck: // 未チェック分を翌月払いにする
			if (Me2cellButton.e1unpaid) {
				// このE2を Paid にする                                ↓YES:未チェックE6の支払日を翌月以降へ
				[EntityRelation e2paid:Me2cellButton inE6payNextMonth:YES]; // Paid <> Unpaid を切り替える
				// context commit (SAVE)
				[EntityRelation commit];
			}
			break;*/
			
		case TAG_ALERT_toPAID:	// PAIDにする
			//if (Me2cellButton.e1unpaid) {
			if (Me2cellButton.bPaid == NO) {
				// このE2を PAID にする
				//[EntityRelation e2paid:Me2cellButton inE6payNextMonth:NO]; // Paid <> Unpaid を切り替える
				for (E2invoice *e2 in [Me2cellButton.e2invoices allObjects]) {
					[EntityRelation e2paid:e2 inE6payNextMonth:NO]; // Paid <> Unpaid を切り替える
				}
				// context commit (SAVE)
				[EntityRelation commit];
			}
			break;
		case TAG_ALERT_toPAY:	// Unpaidに戻す
			//if (Me2cellButton.e1paid) {
			if (Me2cellButton.bPaid == YES) {
				// このE2を Unpaid に戻す
				//[EntityRelation e2paid:Me2cellButton inE6payNextMonth:NO]; // Paid <> Unpaid を切り替える
				for (E2invoice *e2 in [Me2cellButton.e2invoices allObjects]) {
					[EntityRelation e2paid:e2 inE6payNextMonth:NO]; // Paid <> Unpaid を切り替える
				}
				// context commit (SAVE)
				[EntityRelation commit];
			}
			break;
	}

	[self viewWillAppear:NO]; // Fech データセットさせるため
	//[self.tableView reloadData];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

	// Comback 記録
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	long lPos = indexPath.section * GD_SECTION_TIMES + indexPath.row;
	// (0)TopMenu >> (1)E1card/E7payment >> (2)This >> (3)Clear
	[appDelegate.comebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:lPos]];
	[appDelegate.comebackIndex replaceObjectAtIndex:3 withObject:[NSNumber numberWithLong:-1]];

	//E2invoice *e2obj = [[Me2list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	E2temp *e2t = [[Me2list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	if ([e2t.e2invoices count] <= 0) return;
	// E6parts へ
	E6partTVC *tvc = [[E6partTVC alloc] init];
	if (Re1select) {
		tvc.title =  Re1select.zName;
		// 編集移動により支払日の変更が可能
		tvc.Pe2select = [[e2t.e2invoices allObjects] objectAtIndex:0];  //[[Me2list objectAtIndex:lSec] objectAtIndex:lRow];
	} else {
		NSInteger iYear = e2t.iYearMMDD / 10000;
		NSInteger iDD = e2t.iYearMMDD - (iYear * 10000);
		NSInteger iMM = iDD / 100;
		iDD -= (iMM * 100);
		if (e2t.bPaid) {
			tvc.title = [NSString stringWithFormat:@"(%d-%d%@) %@",
						 (int)iMM, (int)iDD, NSLocalizedString(@"Pre",nil), Re8select.zName];
		} else {
			tvc.title = [NSString stringWithFormat:@"(%d-%d%@) %@", 
						 (int)iMM, (int)iDD, NSLocalizedString(@"Due",nil), Re8select.zName];
		}
		// 支払日一覧と同様のカード別一覧（支払日の変更はできない）
		tvc.Pe2invoices = e2t.e2invoices;
	}
	tvc.PiFirstSection = indexPath.section;
	[self.navigationController pushViewController:tvc animated:YES];
	[tvc release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end

