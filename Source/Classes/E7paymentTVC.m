//
//  E7paymentTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "E7paymentTVC.h"
#import "E6partTVC.h"

#define	TAG_ALERT_NoCheck		208
#define	TAG_ALERT_toPAY			217
#define	TAG_ALERT_toPAID		226


@interface E7paymentTVC (PrivateMethods)
- (void)viewDesign;
//- (void)cellLeftButton: (UIButton *)button;
@end

@implementation E7paymentTVC
@synthesize Re0root;


#pragma mark - Action

- (void)barButtonTop {
	[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
}

#ifdef xxxxxxxxxxxxxx
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (buttonIndex == alertView.cancelButtonIndex) return; // CANCEL
	if (Me7cellButton == nil) return;
	
	switch (alertView.tag) {
			/* 初版未対応！未チェックあれば禁止
			 case TAG_ALERT_NoCheck: // 未チェック分を翌月払いにする
			 if (Me7cellButton.e0unpaid) {
			 // このE7,E2を Paid にする                                ↓YES:未チェックE6の支払日を翌月以降へ
			 [EntityRelation e7paid:Me7cellButton inE6payNextMonth:YES]; // Paid <> Unpaid を切り替える
			 // context commit (SAVE)
			 [EntityRelation commit];
			 }
			 break;*/
			
		case TAG_ALERT_toPAID:	// PAIDにする
			if (Me7cellButton.e0unpaid) {
				// このE7,E2を Paid にする    [0.4]nRepeat対応
				[MocFunctions e7paid:Me7cellButton inE6payNextMonth:NO]; // Paid <> Unpaid を切り替える
				// context commit (SAVE)
				[MocFunctions commit];
			}
			break;
		case TAG_ALERT_toPAY:	// Unpaidに戻す
			if (Me7cellButton.e0paid) {
				// このE7,E2を Paid にする
				[MocFunctions e7paid:Me7cellButton inE6payNextMonth:NO]; // Paid <> Unpaid を切り替える
				// context commit (SAVE)
				[MocFunctions commit];
			}
			break;
	}
	
	MbFirstAppear = YES; // ボタン位置調整のため
	[self viewWillAppear:YES]; // Fech データセットさせるため
}
#endif

- (void)toPAID
{
	if ([RaE7list count] <= 1) return;	// Section
	if ([[RaE7list objectAtIndex:1] count] <= 0) return;	// Row
	E7payment* e7obj = [[RaE7list objectAtIndex:1] objectAtIndex:0]; // Unpaidの最上行

	if (e7obj && e7obj.e0unpaid) 
	{
		if (0 < [e7obj.sumNoCheck integerValue]) 
		{	// E7配下に未チェックあり禁止
			alertBox(NSLocalizedString(@"NoCheck",nil),
					 NSLocalizedString(@"NoCheck msg",nil),
					 NSLocalizedString(@"Roger",nil));
			return;
		}
		[MocFunctions e7paid:e7obj inE6payNextMonth:NO]; // Paid <> Unpaid を切り替える
		[MocFunctions commit];		// context commit (SAVE)
		// アニメ準備
		CGRect rc = MbuPaid.frame; rc.origin.y -= 44; MbuPaid.frame = rc;
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:nil context:context];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.0];
		// 再描画
		MbFirstAppear = YES; // ボタン位置調整のため
		[self viewWillAppear:NO]; // Fech データセットさせるため
		// アニメ開始
		[UIView commitAnimations];
	}
}

- (void)toUnpaid
{
	if ([RaE7list count] <= 0) return;	// Section
	NSInteger iRowBottom = [[RaE7list objectAtIndex:0] count] - 1;
	if (iRowBottom < 0) return;
	E7payment* e7obj = [[RaE7list objectAtIndex:0] objectAtIndex:iRowBottom]; // PAIDの最下行
	if (e7obj && e7obj.e0paid) {
		[MocFunctions e7paid:e7obj inE6payNextMonth:NO]; // Paid <> Unpaid を切り替える
		[MocFunctions commit];		// context commit (SAVE)
		// アニメ準備
		CGRect rc = MbuUnpaid.frame; rc.origin.y += 44; MbuUnpaid.frame = rc;
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:nil context:context];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.0];
		// 再描画
		MbFirstAppear = YES; // ボタン位置調整のため
		[self viewWillAppear:NO]; // Fech データセットさせるため
		// アニメ開始
		[UIView commitAnimations];
	}
}



#pragma mark - View lifecicle

static UIColor *MpColorBlue(float percent) {
	float red = percent * 255.0f;
	float green = (red + 20.0f) / 255.0f;
	float blue = (red + 45.0f) / 255.0f;
	if (green > 1.0) green = 1.0f;
	if (blue > 1.0f) blue = 1.0f;
	
	return [UIColor colorWithRed:percent green:green blue:blue alpha:1.0f];
}

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStyleGrouped]; // セクションありテーブル
	if (self) {
		// 初期化成功
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

	//self.tableView.backgroundColor = [UIColor clearColor];

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
	
#ifdef AzPAD
	// Tool Bar Button なし
#else
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	UIBarButtonItem *buTop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-Top.png"]
															  style:UIBarButtonItemStylePlain  //Bordered
															 target:self action:@selector(barButtonTop)];
	NSArray *buArray = [NSArray arrayWithObjects: buTop, buFlex, nil];
	[self setToolbarItems:buArray animated:YES];
	[buTop release];
	[buFlex release];
#endif
	
	// PAID  ボタン
	if (MbuPaid==nil) {
		MbuPaid = [UIButton buttonWithType:UIButtonTypeCustom]; //Autorelease
		[MbuPaid setBackgroundImage:[UIImage imageNamed:@"Icon90x70-toPAID"] forState:UIControlStateNormal];
		//[MbuPaid setBackgroundImage:[UIImage imageNamed:@"Icon90x70-toPAID"] forState:UIControlStateHighlighted];
		[MbuPaid addTarget:self action:@selector(toPAID) forControlEvents:UIControlEventTouchUpInside];
		[self.tableView addSubview:MbuPaid];
	}
	
	// Unpaid ボタン
	if (MbuUnpaid==nil) {
		MbuUnpaid = [UIButton buttonWithType:UIButtonTypeCustom]; //Autorelease
		[MbuUnpaid setBackgroundImage:[UIImage imageNamed:@"Icon90x70-toUnpaid"] forState:UIControlStateNormal];
		//[MbuUnpaid setBackgroundImage:[UIImage imageNamed:@"Icon90x70-toUnpaid"] forState:UIControlStateHighlighted];
		[MbuUnpaid addTarget:self action:@selector(toUnpaid) forControlEvents:UIControlEventTouchUpInside];
		[self.tableView addSubview:MbuUnpaid];
	}
}

- (void)viewDesign		//初期表示および回転時に位置調整して描画する
{
	// PAID ,Unpaid ボタン設置
	CGRect rc = [self.tableView rectForFooterInSection:0];
	MbuPaid.frame = CGRectMake(rc.size.width/2-70, rc.origin.y+10,  90,70);
	MbuUnpaid.frame = CGRectMake(rc.size.width/2+40, rc.origin.y-15, 90,70);
	
	MbuUnpaid.hidden = ([Re0root.e7paids count] <= 0);
	MbuPaid.hidden = ([Re0root.e7unpaids count] <= 0);

	[self.tableView bringSubviewToFront:MbuPaid];
	[self.tableView bringSubviewToFront:MbuUnpaid];
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:YES];
	//[0.4]以降、ヨコでもツールバーを表示するようにした。
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];


	// Me7list : Pe1select.e2invoices 全データ取得 >>> (0)支払済セクション　(1)未払いセクション に分割
	if (RaE7list) {
		[RaE7list release], RaE7list = nil;
	}
	
	//E7E2クリーンアップ
	[MocFunctions e7e2clean];		//E2配下E6が無ければE2削除する & E7配下E2が無ければE7削除する

	// E2 Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"nYearMMDD" ascending:YES];
	NSArray *sortAsc = [[NSArray alloc] initWithObjects:sort1,nil]; // 支払日昇順
	[sort1 release];

	sort1 = [[NSSortDescriptor alloc] initWithKey:@"nYearMMDD" ascending:NO];
	NSArray *sortDesc = [[NSArray alloc] initWithObjects:sort1,nil]; // 支払日降順：Limit抽出に使用
	[sort1 release];
	
	NSArray *arFetch = [MocFunctions select:@"E7payment" 
										limit:GD_PAIDLIST_MAX
									   offset:0
										where:[NSPredicate predicateWithFormat:@"e0paid == %@", Re0root]
										 sort:sortDesc];
	
	NSMutableArray *muE7tmp = [[NSMutableArray alloc] initWithArray:arFetch];
	[muE7tmp sortUsingDescriptors:sortAsc];
	RaE7list = [[NSMutableArray alloc] initWithObjects:muE7tmp,nil]; // [0][muE7tmp]  RaE7list は、Read Only.
	[muE7tmp release];
	
	// E7未払い　（全て）
	muE7tmp = [[NSMutableArray alloc] initWithArray:[Re0root.e7unpaids allObjects]];
	[muE7tmp sortUsingDescriptors:sortAsc];
	[RaE7list addObject:muE7tmp];	// [1][muE7tmp]
	[muE7tmp release];
	[sortAsc release];
	[sortDesc release];
	
	// テーブルビューを更新します。
    [self.tableView reloadData];

	if (MbFirstAppear && 2 <= [RaE7list count] && 1 <= [[RaE7list objectAtIndex:1] count]) {
		MbFirstAppear = NO;
		// 未払いの先頭を画面中央に表示する
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
	}
	else if (0 < McontentOffsetDidSelect.y) {
		// app.Me3dateUse=nil のときや、メモリ不足発生時に元の位置に戻すための処理。
		// McontentOffsetDidSelect は、didSelectRowAtIndexPath にて記録している。
		self.tableView.contentOffset = McontentOffsetDidSelect;
	}
	
	[self viewDesign];
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
	
	// Comback (-1)にして未選択状態にする
	//	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	// (0)TopMenu >> (1)This clear
	//	[appDelegate.RaComebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:-1]];
}


#pragma mark View - Rotate

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
	//[self.tableView reloadData]; ここではダメ　＜＜cellLable位置調整されない＞＞
	[self viewDesign];
}

// 回転した後に呼び出される
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadData];  // cellLable位置調整するため
}


#pragma mark  View - Unload - dealloc

- (void)unloadRelease	// dealloc, viewDidUnload から呼び出される
{
	NSLog(@"--- unloadRelease --- E7paymentTVC");
	[RaE7list release], RaE7list = nil;
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

/*
// カムバック処理（復帰再現）：親から呼ばれる
- (void)viewComeback:(NSArray *)selectionArray
{
	// (0)TopMenu >> (1)This
	NSInteger lRow = [[selectionArray objectAtIndex:1] integerValue];
	if (lRow < 0) return; // この画面に留まる
	NSInteger lSec = lRow / GD_SECTION_TIMES;
	lRow -= (lSec * GD_SECTION_TIMES);

	if ([RaE7list count] <= lSec) return; // section OVER
	if ([[RaE7list objectAtIndex:lSec] count] <= lRow) return; // row OVER（Addや削除されたとか）

	// 選択行を画面中央付近に表示する
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lRow inSection:lSec];
	[self.tableView scrollToRowAtIndexPath:indexPath 
						  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO

	E7payment *e7obj = [[RaE7list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	// (0)TopMenu >> (1)E1card >> (2)This >> (3)E6partTVC へ
	E6partTVC *tvc = [[E6partTVC alloc] init];
	tvc.title = GstringYearMMDD( [e7obj.nYearMMDD integerValue] );
	tvc.Pe7select = e7obj;	// カード別明細一覧（支払日の変更はできない）
	tvc.PiFirstSection = 0;
	[self.navigationController pushViewController:tvc animated:NO];
	// viewComeback を呼び出す
	[tvc viewWillAppear:NO]; // Fech データセットさせるため
	[tvc viewComeback:selectionArray];
	[tvc release];
}
*/


#pragma mark - TableView lifecicle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [RaE7list count];  // Me7listは、(0)e2paids (1)e2unpaids の二次元配列
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [[RaE7list objectAtIndex:section] count];
}

// TableView セクション名を応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			return NSLocalizedString(@"Paid header",nil);
			break;
		case 1:
			// E7 未払い総額
			if ([Re0root.e7unpaids count] <= 0) {
				return NSLocalizedString(@"Following unpaid nothing",nil);
			}
			return NSLocalizedString(@"Unpaid",nil);
	/*		else {
				//NSNumber *nUnpaid = [Re0root valueForKeyPath:@"e7unpaids.@sum.sumAmount"];
				// Amount JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
				NSDecimalNumber *decUnpaid = [Re0root valueForKeyPath:@"e7unpaids.@sum.sumAmount"];
				NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
				[formatter setNumberStyle:NSNumberFormatterCurrencyStyle]; // 通貨スタイル
				//NSLocale *localeJP = [[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"];
				//[formatter setLocale:localeJP];
				//[localeJP release];
				[formatter setLocale:[NSLocale currentLocale]]; 
				NSString *str = [NSString stringWithFormat:@"%@ %@", 
								 NSLocalizedString(@"Following unpaid",nil), 
								 [formatter stringFromNumber:decUnpaid]];
				[formatter release];
				return str;
			}
			break; */
	}
	return nil;
}

// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			//return NSLocalizedString(@"E2paidFooter",nil);
			return @"\n";
			break;
#ifdef FREE_AD_PAD
		case 1:
			return @"\n\n\n\n\n\n\n\n\n\n\n\n\n\n";	// 大型AdMobスペースのための下部余白
			break;
#endif
	}
	return nil;
}

/*
 // セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 44; // デフォルト：44ピクセル
}*/

/*Global.m
// 文字列から画像を生成する
static UIImage* GimageFromString(NSString* str)
{
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
*/

/*
- (void)cellLeftButton: (UIButton *)button   // E7: Unpaid <--切替--> Paid
{
	AzLOG(@"button.tag=%ld", (long)button.tag);
	if (button.tag < 0) return;
	
	NSInteger iSec = button.tag / GD_SECTION_TIMES;
	if ([RaE7list count] <= iSec) return;
	NSInteger iRow = button.tag - (iSec * GD_SECTION_TIMES);
	if ([[RaE7list objectAtIndex:iSec] count] <= iRow) return;
	
	Me7cellButton = [[RaE7list objectAtIndex:iSec] objectAtIndex:iRow];
	
	if (Me7cellButton.e0paid) {
		// E2 PAID -->> PAYに戻す
#if AzDEBUG
		if (Me7cellButton.e0unpaid) {
			AzLOG(@"LOGIC ERR: cellLeftButton: Me7cellButton.e0unpaid NG");
			return;
		}
#endif
		// これより後に paid があれば禁止		"最下行から PAY に戻せます"
		for (E7payment *e7 in Me7cellButton.e0paid.e7paids) {
			if ([Me7cellButton.nYearMMDD integerValue] < [e7.nYearMMDD integerValue]) {
				alertBox(NSLocalizedString(@"E2 to PAY NG",nil),
						 NSLocalizedString(@"E2 to PAY NG msg",nil),
						 NSLocalizedString(@"Roger",nil));
				return; // 禁止
			}
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"E2 to PAY",nil) 
														message:NSLocalizedString(@"E2 to PAY msg",nil) 
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
											  otherButtonTitles:@"OK", nil];
		alert.tag = TAG_ALERT_toPAY;
		[alert show];
		[alert release];
	}
	else if (Me7cellButton.e0unpaid) {
#if AzDEBUG
		if (Me7cellButton.e0paid) {
			AzLOG(@"LOGIC ERR: cellLeftButton: Me7cellButton.e0paid NG");
			return;
		}
#endif
		// "最上行から PAID にできます"
		for (E7payment *e7 in Me7cellButton.e0unpaid.e7unpaids) {
			// これより前に unpaid があるので禁止
			if ([e7.nYearMMDD integerValue] < [Me7cellButton.nYearMMDD integerValue]) {
				alertBox(NSLocalizedString(@"E2 to PAID NG",nil),
						 NSLocalizedString(@"E2 to PAID NG msg",nil),
						 NSLocalizedString(@"Roger",nil));
				return; // 禁止
			}
		}
		if (0 < [Me7cellButton.sumNoCheck integerValue]) {
			// E2配下に未チェックあり、「未チェック分を翌月払いにしますか？」 >>> alertView:clickedButtonAtIndex:メソッドが呼び出される
			// 初版未対応とする！未チェックあれば禁止
			alertBox(NSLocalizedString(@"NoCheck",nil),
					 NSLocalizedString(@"NoCheck msg",nil),
					 NSLocalizedString(@"Roger",nil));
			return;
		}
		// E2 PAY -->> PAID
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"E2 to PAID",nil) 
														message:NSLocalizedString(@"E2 to PAID msg",nil) 
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
											  otherButtonTitles:@"OK", nil];
		alert.tag = TAG_ALERT_toPAID;
		[alert show];
		[alert release];
	}
	else {
		AzLOG(@"LOGIC ERR: Me7cellButton.e0paid = e0unpaid = nil 孤立状態");
		return;
	}
}
*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *zCellIndex = @"CellE7payment";
	UITableViewCell *cell = nil;
	UILabel *cellLabel = nil;
	
	cell = [tableView dequeueReusableCellWithIdentifier:zCellIndex];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:zCellIndex] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
		cell.showsReorderControl = NO; // Move禁止

#ifdef AzPAD
		cell.textLabel.font = [UIFont systemFontOfSize:20];
#else
		cell.textLabel.font = [UIFont systemFontOfSize:16];
#endif
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.textColor = [UIColor blackColor];
		
		cellLabel = [[UILabel alloc] init];
		cellLabel.textAlignment = UITextAlignmentRight;
		//cellLabel.textColor = [UIColor blackColor];
		cellLabel.backgroundColor = [UIColor clearColor];
#ifdef AzPAD
		cellLabel.font = [UIFont systemFontOfSize:20];
#else
		cellLabel.font = [UIFont systemFontOfSize:14];
#endif
		cellLabel.tag = -1;
		[cell addSubview:cellLabel]; [cellLabel release];
	}
	else {
		cellLabel = (UILabel *)[cell viewWithTag:-1];
	}
	// 回転対応のため
#ifdef AzPAD
	cellLabel.frame = CGRectMake(self.tableView.frame.size.width-215, 12, 125, 22);
#else
	cellLabel.frame = CGRectMake(self.tableView.frame.size.width-108, 12, 75, 20);
#endif
	
/*	// 左ボタン --------------------＜＜cellLabelのようにはできない！.tagに個別記録するため＞＞
	UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom]; // autorelease
	cellButton.frame = CGRectMake(0,0, 44,44);
	[cellButton addTarget:self action:@selector(cellLeftButton:) forControlEvents:UIControlEventTouchUpInside];
	cellButton.backgroundColor = [UIColor clearColor]; //背景透明
	cellButton.showsTouchWhenHighlighted = YES;
	cellButton.tag = indexPath.section * GD_SECTION_TIMES + indexPath.row;
	[cell.contentView addSubview:cellButton]; //[bu release]; buttonWithTypeにてautoreleseされるため不要。UIButtonにinitは無い。
	// 左ボタン ------------------------------------------------------------------ */
	
	E7payment *e7obj = [[RaE7list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

	// 支払日
	if (e7obj.e0paid) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", GstringYearMMDD([e7obj.nYearMMDD integerValue]),
																		NSLocalizedString(@"Pre",nil)];
	} else {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", GstringYearMMDD([e7obj.nYearMMDD integerValue]), 
																		NSLocalizedString(@"Due",nil)];
	}

	// 金額
	if ([e7obj.sumAmount compare:[NSDecimalNumber zero]] == NSOrderedDescending)	// e7obj.sumAmount > 0
	{
		cellLabel.textColor = [UIColor blackColor];
	} else {
		cellLabel.textColor = [UIColor blueColor];
	}
	// Amount JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // CurrencyStyle]; // 通貨スタイル
//	NSLocale *localeJP = [[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"];
//	[formatter setLocale:localeJP];
//	[localeJP release];
	[formatter setLocale:[NSLocale currentLocale]]; 
	cellLabel.text = [formatter stringFromNumber:e7obj.sumAmount];
	[formatter release];


	if (indexPath.section == 0) {
		cell.imageView.image = [UIImage imageNamed:@"Icon32-PAID.png"];  // PAID 支払済
	}
	else {
		//cell.imageView.image = [UIImage imageNamed:@"Unpaid32.png"]; // 未払い
		// sumNoCheck を Circle 内に表示
		NSInteger lNoCheck = [e7obj.sumNoCheck integerValue];
		if (0 < lNoCheck) {
			UIImageView *imageView1 = [[UIImageView alloc] init];
			UIImageView *imageView2 = [[UIImageView alloc] init];
			imageView1.image = [UIImage imageNamed:@"Icon32-CircleUnpaid.png"];	// Unpaid
			imageView2.image = GimageFromString([NSString stringWithFormat:@"%ld", (long)lNoCheck]);
			
			if (UIGraphicsBeginImageContextWithOptions != NULL) { // iOS4.0以上
				UIGraphicsBeginImageContextWithOptions(imageView1.image.size, NO, 0.0); //[0.4.18]Retina対応
			} else { // Old
				UIGraphicsBeginImageContext(imageView1.image.size);
			}			
			
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
		//else if ([e7obj.sumAmount compare:[NSDecimalNumber zero]] == NSOrderedDescending)	// e7obj.sumAmount > 0
		else if (0.0 < [e7obj.sumAmount doubleValue])	// e7obj.sumAmount > 0
		{
			cell.imageView.image = [UIImage imageNamed:@"Icon32-CircleChkUnpaid.png"];  // Unpaid & Check
		}
		else {
			cell.imageView.image = [UIImage imageNamed:@"Icon32-Circle.png"];  // Nothing
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

	// didSelect時のScrollView位置を記録する（viewWillAppearにて再現するため）
	McontentOffsetDidSelect = [tableView contentOffset];
	
/*	// Comback-L2 E2invoice 記録
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	long lPos = indexPath.section * GD_SECTION_TIMES + indexPath.row;
	// (0)TopMenu >> (1)This >> (2)Clear
	[appDelegate.RaComebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:lPos]];
	[appDelegate.RaComebackIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithLong:-1]];
*/
	E7payment *e7obj = [[RaE7list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	// (0)TopMenu >> (1)E7payment >> (2)E6part(CardMixMode) へ
	E6partTVC *tvc = [[E6partTVC alloc] init];
	tvc.Pe7select = e7obj;	// カード別明細一覧（支払日の変更はできない）
	tvc.PiFirstSection = 0;
	// セルから取得してタイトル名にする
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
#ifdef AzDEBUG
	tvc.title = [NSString stringWithFormat:@"E6 %@", cell.textLabel.text];
#else
	tvc.title = cell.textLabel.text;  // GstringYearMMDD( [e7obj.nYearMMDD integerValue] );
#endif
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

