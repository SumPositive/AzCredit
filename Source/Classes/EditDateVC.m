//
//  EditDateVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "EditDateVC.h"
#import "E3recordDetailTVC.h"		// delegate
#import "CalcView.h"


@interface EditDateVC (PrivateMethods)
- (void)viewDesign;
- (void)buttonToday;
- (void)buttonYearTime;
- (void)done:(id)sender;
@end

@implementation EditDateVC
//@synthesize Rentity;
//@synthesize RzKey;
@synthesize delegate;
@synthesize PiMinYearMMDD;
@synthesize PiMaxYearMMDD;


#pragma mark - Action

- (void)buttonToday
{
	//MdatePicker.date = [NSDate date]; // Now
	[MdatePicker setDate:[NSDate date] animated:YES];
}

- (void)buttonYearTime
{
	if (Re3edit)
	{
		MbOptUseDateTime = !MbOptUseDateTime;  // Revers
		[[NSUserDefaults standardUserDefaults] setBool:MbOptUseDateTime forKey:GD_OptUseDateTime];
		
		if (MbOptUseDateTime) {
			[MbuYearTime setTitle:NSLocalizedString(@"Hide Time",nil) forState:UIControlStateNormal]; // 表示は逆
			MdatePicker.datePickerMode = UIDatePickerModeDateAndTime;
		} else {
			[MbuYearTime setTitle:NSLocalizedString(@"Show Time",nil) forState:UIControlStateNormal]; // 表示は逆
			MdatePicker.datePickerMode = UIDatePickerModeDate;
		}
	}
	else
	{	// 金額　：　電卓出現
		assert(Re6edit);
		if (McalcView==nil) {
			McalcView = [[CalcView alloc] initWithFrame:self.view.bounds withE3:nil];
			McalcView.Rlabel = MlbAmount;  // 結果もこのラベルに戻る
			McalcView.PoParentTableView = nil;
			McalcView.delegate = self;	// viewWillAppear:を呼び出すため
			//[self.navigationController.view addSubview:McalcView];	//[1.0.1]万一広告が残ってもキーが上になるようにした。
			[self.view addSubview:McalcView];
			[McalcView release]; // addSubviewにてretain(+1)されるため、こちらはrelease(-1)して解放
		}
		[McalcView show];
	}
}


// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
- (void)done:(id)sender
{
	if (Re3edit) 
	{
		//[Rentity setValue:MdatePicker.date forKey:RzKey];
		if (![Re3edit.dateUse isEqualToDate:MdatePicker.date]) 
		{	// 変更あり
			Re3edit.dateUse = MdatePicker.date;
		
			AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			apd.entityModified = YES;	//変更あり
			// E6更新
			if ([delegate respondsToSelector:@selector(remakeE6change:)]) {	// メソッドの存在を確認する
				[delegate remakeE6change:1];		// (1) dateUse変更 ⇒ 支払先条件通りにE6更新
			}
			// 再描画
			if ([delegate respondsToSelector:@selector(viewWillAppear:)]) {	// メソッドの存在を確認する
				[delegate viewWillAppear:YES];	
			}
		}
	}
	else if (Re6edit) 
	{	// E6part 変更モード
		BOOL bDuty = NO;
		E2invoice *e2old = Re6edit.e2invoice;  //変更前に属しているE2
		E3record *e3 = Re6edit.e3record;
		NSInteger iYearMMDD = GiYearMMDD(MdatePicker.date);
		E2invoice *e2new = [MocFunctions e2invoice:e3.e1card  inYearMMDD:iYearMMDD]; //変更後に属するE2
		if (e2new.e1paid) {
			NSLog(@"LOGIC ERROR: 変更先の支払日がPAIDである"); // [PAID]ならば変更禁止になっているので通らないハズ
			// [PAID]となった日だけ拒否する。　それより前日は「支払遅延」を想定して許可しておく。
			alertBox(NSLocalizedString(@"Due date PAID",nil),		// この日は、既に[PAID]です。
					 NSLocalizedString(@"Due date PAID msg",nil),	// 他の支払日を指定してください。
					 NSLocalizedString(@"Roger",nil));
			return;
		}
		//
		if (e2new != e2old)
		{	// 支払日に変化あり
			Re6edit.e2invoice = nil;	//Fix[1.1.1] E6 <<--> E2 リンク削除：切断してからE2,E7を再集計
			//Re6edit.nAmount 更新前に e2old 配下再集計
			[MocFunctions e2e7update:e2old]; //Re6edit.nAmount = OLD 減
			bDuty = YES;
		}
		//
		NSDecimalNumber *decNew = [NSDecimalNumber decimalNumberWithString:MlbAmount.text];
		//NSDecimalNumber *decNew = [[NSDecimalNumber alloc] initWithString:MlbAmount.text];
		NSLog(@"decNew=%@", decNew);
		if (decNew==[NSDecimalNumber notANumber]) {	// 万一前方に記号が入って変換できないとき、
			decNew = [NSDecimalNumber zero];
		}
		if ([Re6edit.nAmount compare:decNew] != NSOrderedSame) 
		{	// 金額に変化あり
			// 通貨型に合った丸め位置を取得
			NSUInteger iRoundingScale = 2;
			if ([[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier] isEqualToString:@"ja_JP"]) { // 言語 + 国、地域
				iRoundingScale = 0;
			}
			// 丸め（常に切り捨て）
			NSDecimalNumberHandler *behavior = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundDown	//切り捨て
																							  scale:iRoundingScale	// 丸めた後の桁数
																				   raiseOnExactness:YES				// 精度
																					raiseOnOverflow:YES				// オーバーフロー
																				   raiseOnUnderflow:YES				// アンダーフロー
																				raiseOnDivideByZero:YES ];			// アンダーフロー
			// 丸め処理
			Re6edit.nAmount = [decNew decimalNumberByRoundingAccordingToBehavior:behavior];
			[behavior release];
			NSLog(@"New Re6edit.nAmount=%@", Re6edit.nAmount);
			bDuty = YES;
		}
		//
		if (e2new != e2old)
		{	// 支払日に変化あり
			Re6edit.e2invoice = e2new;	//新しい支払日
			//Re6edit.nAmount 更新後に e2new 配下再集計
			[MocFunctions e2e7update:e2new]; // Re6edit.nAmount = NEW 増
		}
		//
		if (bDuty) 
		{	//変更あり
			AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			apd.entityModified = YES;	//変更あり
			// E6更新　　このRe6editを基準(固定)にして処理する
			if ([delegate respondsToSelector:@selector(remakeE6change:)]) {	// メソッドの存在を確認する
				if ([Re6edit.nPartNo integerValue]==1) {
					[delegate remakeE6change:5];		// (5) E6part1を固定してE6part2またはE3を調整更新する
				} else {
					[delegate remakeE6change:6];		// (6) E6part2を固定してE6part1またはE3を調整更新する
				}
			}
			// 再描画
			if ([delegate respondsToSelector:@selector(viewWillAppear:)]) {	// メソッドの存在を確認する
				[delegate viewWillAppear:YES];	
			}
		}
	}
	else {
		NSLog(@"LOGIC ERROR");
	}

	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
	
	//"DateUse Over" = "日付を確認してください";
	//"DateUse Over msg" = "日先(未来)の日付です。\n年を間違っていませんか？\n念のために確認してください";
	//"DateUse Under msg" = "日前(過去)の日付です。\n年を間違っていませんか？\n念のために確認してください";
	long	days = (long)([MdatePicker.date timeIntervalSinceNow] / (24 * 60 * 60));
	if (120 < abs(days)) {  //[0.4]日付チェック
		if (days < 0) {	// 過去すぎる
			NSString *zMsg = [NSString stringWithFormat:@"%ld%@", abs(days), NSLocalizedString(@"DateUse Under msg",nil)];
			alertBox(NSLocalizedString(@"DateUse Over",nil), zMsg, NSLocalizedString(@"Roger",nil));
		} else {	// 未来すぎる
			NSString *zMsg = [NSString stringWithFormat:@"%ld%@", days, NSLocalizedString(@"DateUse Over msg",nil)];
			alertBox(NSLocalizedString(@"DateUse Over",nil), zMsg, NSLocalizedString(@"Roger",nil));
		}
	}
}


#pragma mark - View lifecicle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithE3:(E3record*)e3 orE6:(E6part*)e6
{
	if (e3 && e6) {
		NSLog(@"LOGIC ERROR: e3 OR e6");
		return nil;
	}
	self = [super init];
	if (self) {
		// 初期化成功
		Re3edit = [e3 retain];	// どちらか必ずnil
		Re6edit = [e6 retain];	// どちらか必ずnil
#ifdef AzPAD
		self.contentSizeForViewInPopover = GD_POPOVER_SIZE;
#endif
	}
	return self;
}

/*
- (id)initWithE6row:(NSUInteger)iRow
{
	self = [super init];
	if (self) {
		// 初期化成功
		PiE6row = iRow;
		Re6edit = nil;
#ifdef AzPAD
		self.contentSizeForViewInPopover = GD_POPOVER_SIZE;
#endif
	}
	return self;
}
*/

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
//【Tips】ここでaddSubviewするオブジェクトは全てautoreleaseにすること。メモリ不足時には自動的に解放後、改めてここを通るので、初回同様に生成するだけ。
- (void)loadView
{
    [super loadView];

#ifdef AzPAD
	self.view.backgroundColor = [UIColor lightGrayColor];
#else
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	[self.navigationController setToolbarHidden:YES animated:NO]; // ツールバー消す
#endif

	// DONEボタンを右側に追加する
	// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
	// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
	// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
												   initWithBarButtonSystemItem:UIBarButtonSystemItemDone  //[DONE]
												   target:self action:@selector(done:)] autorelease];
	
	// とりあえず生成、位置はviewDesignにて決定
	if (Re3edit) {
		//------------------------------------------------------[NOW]ボタン
		MbuToday = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[MbuToday setTitle:NSLocalizedString(@"Today",nil) forState:UIControlStateNormal];
		[MbuToday addTarget:self action:@selector(buttonToday) forControlEvents:UIControlEventTouchDown];
		[self.view addSubview:MbuToday]; //[MbuToday release]; autoreleaseされるため
	}

	//------------------------------------------------------[Time]ボタン
	MbuYearTime = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	// Titleは、viewWillAppear:にてセット
	[MbuYearTime addTarget:self action:@selector(buttonYearTime) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:MbuYearTime]; //[MbuYearTime release]; autoreleaseされるため
	if (Re6edit) 
	{
		[MbuYearTime setTitle:NSLocalizedString(@"Due Amount",nil) forState:UIControlStateNormal]; // 表示は逆
		MlbAmount = [[[UILabel alloc] init] autorelease];
		MlbAmount.font = [UIFont systemFontOfSize:20];
		MlbAmount.textAlignment = UITextAlignmentCenter;
		[self.view addSubview:MlbAmount]; // autorelease
	}
	
	//------------------------------------------------------Picker
	//MdatePicker = [[[UIDatePicker alloc] init] autorelease]; iPadでは不具合発生する
	MdatePicker = [[[UIDatePicker alloc] initWithFrame:CGRectMake(0,0, 320,216)] autorelease];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"dk_DK"];  // AM/PMを消すため ＜＜実機でのみ有効らしい＞＞
	MdatePicker.locale = locale; 
	[locale release];
	//[1.1.2]システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	//NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	//[MdatePicker setCalendar:calendar];
	//[calendar release];
	//NG//UIDatePickerの言語表示を変えようと頑張ったがダメだった⇒ http://aosicode.blog94.fc2.com/blog-entry-32.html
	//NG//Pickerが和暦になっても、表示は正しく西暦になるようなので、このままにしておく。

	[self.view addSubview:MdatePicker];  //auto//[MdatePicker release];
	MintervalPrev = [MdatePicker.date timeIntervalSinceReferenceDate]; // 2001/1/1からの秒数
	//------------------------------------------------------
}
/*
- (void)datePickerDidChange:(UIDatePicker *)sender
{
}
*/

- (void)viewDesign
{
	CGRect rect = self.view.bounds;

#ifdef AzPAD
	rect.size.width = 320;
	rect.origin.x = (self.view.bounds.size.width - rect.size.width) / 2;
	rect.size.height = GD_PickerHeight;
	rect.origin.y = (self.view.bounds.size.height - rect.size.height) / 2;
	MdatePicker.frame = rect;

	if (Re3edit) {
		rect.size.height = 30;
		rect.size.width = 150;
		rect.origin.x = (self.view.bounds.size.width - rect.size.width) / 2;
		rect.origin.y = 60;
		MbuToday.frame = rect;
		
		rect.origin.y = self.view.bounds.size.height - 90;
		MbuYearTime.frame = rect;
	} else {
		rect.origin.y = 40;  //self.view.bounds.size.height - 110;
		rect.size.height = 30;
		rect.size.width = 200;
		rect.origin.x = (self.view.bounds.size.width - rect.size.width) / 2;
		MbuYearTime.frame = rect;
		rect.origin.y += 32;
		rect.size.width -= 20;
		rect.origin.x = (self.view.bounds.size.width - rect.size.width) / 2;
		MlbAmount.frame = rect;
	}

#else

	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
	{	// タテ
		if (Re3edit) {
			rect.origin.y = (self.view.bounds.size.height - GD_PickerHeight) / 2;
		} else {
			rect.origin.y = 120;
		}
		rect.size.height = GD_PickerHeight;
		MdatePicker.frame = rect;
		
		if (Re3edit) {
			rect.origin.y = 30;
			rect.size.height = 30;
			rect.size.width = 150;
			rect.origin.x = (self.view.bounds.size.width - rect.size.width) / 2;
			MbuToday.frame = rect;
			
			rect.origin.y = self.view.bounds.size.height - 60;
			MbuYearTime.frame = rect;
		} else {
			rect.origin.y = 20;
			rect.size.height = 30;
			rect.size.width = 200;
			rect.origin.x = (self.view.bounds.size.width - rect.size.width) / 2;
			MbuYearTime.frame = rect;
			rect.origin.y += 32;
			rect.size.width -= 20;
			rect.origin.x = (self.view.bounds.size.width - rect.size.width) / 2;
			MlbAmount.frame = rect;
		}
	}
	else {	// ヨコ
		rect.origin.y = self.view.bounds.size.height - GD_PickerHeight;
		rect.size.height = GD_PickerHeight;
		MdatePicker.frame = rect;
		
		rect.origin.y = 10;
		rect.size.height = 30;

		if (Re3edit) {
			rect.size.width = 150;
			rect.origin.x = 30;  //(self.view.bounds.size.width - rect.size.width) / 2;
			MbuToday.frame = rect;
			
			rect.origin.x = 250;  //self.view.bounds.size.width/2 + (self.view.bounds.size.width - rect.size.width)/2;
			MbuYearTime.frame = rect;
		} else {
			rect.origin.x = 100;  //(self.view.bounds.size.width/2) + 0;
			rect.size.width = 80;
			MbuYearTime.frame = rect;
			rect.origin.x += (rect.size.width + 2);
			rect.size.width = 200;
			MlbAmount.frame = rect;
		}
	}
#endif
}	

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　// viewDidAppear はView表示直後に呼ばれる
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];

	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	MbOptUseDateTime = [defaults boolForKey:GD_OptUseDateTime];

	if (AzMIN_YearMMDD < PiMinYearMMDD) {
		MdatePicker.minimumDate = GdateYearMMDD(PiMinYearMMDD,  0, 0, 0);
	} else {
		MdatePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:-365*24*60*60];	// 約1年前から
	}
	if (PiMaxYearMMDD < AzMAX_YearMMDD) {
		MdatePicker.maximumDate = GdateYearMMDD(PiMaxYearMMDD, 23,59,59); 
	} else {
		MdatePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:+31*6*24*60*60];	// 約6ヶ月先まで
	}

	if (Re3edit) {
		if (MbOptUseDateTime) {
			[MbuYearTime setTitle:NSLocalizedString(@"Hide Time",nil) forState:UIControlStateNormal]; // 表示は逆
			MdatePicker.datePickerMode = UIDatePickerModeDateAndTime;
		} else {
			[MbuYearTime setTitle:NSLocalizedString(@"Show Time",nil) forState:UIControlStateNormal]; // 表示は逆
			MdatePicker.datePickerMode = UIDatePickerModeDate;
		}
		MdatePicker.date =Re3edit.dateUse;
	} 
	else { // E6 常に時刻不要
		MdatePicker.datePickerMode = UIDatePickerModeDate;
		NSInteger iYearMMDD = [Re6edit.e2invoice.e7payment.nYearMMDD integerValue];
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone; //[Done]  (デフォルト[Save])
		MdatePicker.date = GdateYearMMDD(iYearMMDD, 0, 0, 0);
		// 金額表示
	/*	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // 通貨記号なし ＜＜ラベル文字⇒数値変換時にエラー発生するため
		[formatter setLocale:[NSLocale currentLocale]]; 
		MlbAmount.text = [formatter stringFromNumber:Re6edit.nAmount];
		[formatter release];*/
		// 通貨記号もコンマも無しにする。 ＜＜ラベル文字⇒Decimal数値変換時にエラー発生するため
		MlbAmount.text = [NSString stringWithFormat:@"%@", Re6edit.nAmount];
	}

	[self viewDesign];
	//ここでキーを呼び出すと画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
}

// 画面表示された直後に呼び出される
- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	
	//self.title = NSLocalizedString(@"Use date",nil);  親側でセット
	//viewWillAppearでキーを表示すると画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
}

#pragma mark  View - Rotate

// 回転の許可　ここでは許可、禁止の判定だけする
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
#ifdef AzPAD
	return NO;	// Popover内につき回転不要
#else
	// 回転禁止でも、正面は常に許可しておくこと。
	return !MbOptAntirotation OR (interfaceOrientation == UIInterfaceOrientationPortrait);
#endif
}

// 回転を始める前にこの処理が呼ばれる。
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
								duration:(NSTimeInterval)duration {	// この時点では self.View は、まだ回転前の状態
	// 電卓	アニメ効果を消さないように、回転後に破棄している
	//[McalcView viewDesign:self.view.bounds];
	if (McalcView) { // 閉じて破棄することにした。
		[McalcView cancel];
		[McalcView hide];
	}
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	//[self viewWillAppear:NO];没：これを呼ぶと、回転の都度、編集がキャンセルされてしまう。
	[self viewDesign]; // これで回転しても編集が継続されるようになった。
}

// 回転した後に呼び出される
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	// 電卓	アニメ効果を消さないように、回転後に破棄している
	if (McalcView) { // 閉じて破棄することにした。
		McalcView.delegate = nil;
		[McalcView removeFromSuperview];
		McalcView = nil;
	}
}


#pragma mark  View - Unload - dealloc

- (void)dealloc    // 最後に1回だけ呼び出される（デストラクタ）
{
	//[sourceDate release], sourceDate = nil;
	// 生成とは逆順に解放するのが好ましい
	if (McalcView) {
		[McalcView hide];
		McalcView.delegate = nil;
		[McalcView removeFromSuperview];
		McalcView = nil;
	}
	[Re3edit release];
	[Re6edit release];
	[super dealloc];
}


@end
