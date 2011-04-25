//
//  EditDateVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "EditDateVC.h"

@interface NSObject (E3recordDetailTVC_delagate_Methods)
- (void)editDateE6change;
@end

@interface EditDateVC (PrivateMethods)
- (void)viewDesign;
- (void)buttonToday;
- (void)buttonYearTime;
- (void)done:(id)sender;
@end

@implementation EditDateVC
@synthesize Rentity;
@synthesize RzKey;
@synthesize PiMinYearMMDD;
@synthesize PiMaxYearMMDD;
//@synthesize PiE6row;				//[1.0.0]E6date変更モード
@synthesize delegate;


- (void)dealloc    // 最後に1回だけ呼び出される（デストラクタ）
{
	[Re6edit release], Re6edit = nil;
	// 生成とは逆順に解放するのが好ましい
	[RzKey release], RzKey = nil;
	[Rentity release], Rentity = nil;
	[super dealloc];
}

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)init
{
	self = [super init];
	if (self) {
		// 初期化成功
		PiE6row = (-1);  //E6dateモードでないことを示す
		Re6edit = nil;
	}
	return self;
}

- (id)initWithE6row:(NSUInteger)iRow
{
	self = [super init];
	if (self) {
		// 初期化成功
		PiE6row = iRow;
		Re6edit = nil;
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
    [super loadView];
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
	MdatePicker = nil;	// ここ(loadView)で生成
	MbuToday = nil;		// ここ(loadView)で生成
	MbuYearTime = nil;	// ここ(loadView)で生成

	
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

	// DONEボタンを右側に追加する
	// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
	// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
	// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
												   initWithBarButtonSystemItem:UIBarButtonSystemItemDone  //[DONE]
												   target:self action:@selector(done:)] autorelease];
	
	// とりあえず生成、位置はviewDesignにて決定
	//------------------------------------------------------
	MbuToday = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[MbuToday setTitle:NSLocalizedString(@"Today",nil) forState:UIControlStateNormal];
	[MbuToday addTarget:self action:@selector(buttonToday) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:MbuToday]; //[MbuToday release]; autoreleaseされるため
	//------------------------------------------------------
	MbuYearTime = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	//MbuMode.titleLabel.text = NSLocalizedString(@"Year/Month/Day",nil); viewWillAppear にてセット
	[MbuYearTime addTarget:self action:@selector(buttonYearTime) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:MbuYearTime]; //[MbuYearTime release]; autoreleaseされるため
	//------------------------------------------------------
	MdatePicker = [[[UIDatePicker alloc] init] autorelease];
	//[MdatePicker addTarget:self action:@selector(datePickerDidChange:) forControlEvents:UIControlEventValueChanged]; //[0.4]
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
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"dk_DK"];  // AM/PMを消すため ＜＜実機でのみ有効らしい＞＞
	MdatePicker.locale = locale; [locale release];
	[self.view addSubview:MdatePicker];  //auto//[MdatePicker release];
	MintervalPrev = [MdatePicker.date timeIntervalSinceReferenceDate]; // 2001/1/1からの秒数
	//------------------------------------------------------
}
/*
- (void)datePickerDidChange:(UIDatePicker *)sender
{
}
*/

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　// viewDidAppear はView表示直後に呼ばれる
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	MbOptUseDateTime = [defaults boolForKey:GD_OptUseDateTime];

	if (MbOptUseDateTime) {
		[MbuYearTime setTitle:NSLocalizedString(@"Hide Time",nil) forState:UIControlStateNormal]; // 表示は逆
		MdatePicker.datePickerMode = UIDatePickerModeDateAndTime;
	} else {
		[MbuYearTime setTitle:NSLocalizedString(@"Show Time",nil) forState:UIControlStateNormal]; // 表示は逆
		MdatePicker.datePickerMode = UIDatePickerModeDate;
	}
	
	if (0<=PiE6row) {	//[1.0.0]E6date変更モード
		E3record *e3 = Rentity;
		if (0 <= PiE6row && PiE6row < [e3.e6parts count]) {
			NSArray* e6parts = nil;
			if ([e3.e6parts count]==1) {
				assert(PiE6row==0);
				e6parts = [e3.e6parts allObjects];
				// 要素が1個だけなのでSorting不要
			} else {
				// Index指定するためにSortingが必要
				NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"nPartNo" ascending:YES];
				NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
				[sort1 release];
				e6parts = [[e3.e6parts allObjects] sortedArrayUsingDescriptors:sortArray];
				[sortArray release];
				// 分割払いの場合、前回や次回の支払があればその日までに制限する
				if (0 < PiE6row) {
					//前回支払あり
					E6part *e6 = [e6parts objectAtIndex:PiE6row-1];  //前回
					NSInteger iYearMMDD = [e6.e2invoice.e7payment.nYearMMDD integerValue];
					//最小日付制限
					PiMinYearMMDD = GiAddYearMMDD( iYearMMDD, 0,0,+1); // +1日＝翌日
				}
				else if (PiE6row < [e3.e6parts count]-1) {
					//次回支払あり
					E6part *e6 = [e6parts objectAtIndex:PiE6row+1];  //次回
					NSInteger iYearMMDD = [e6.e2invoice.e7payment.nYearMMDD integerValue];
					//最大日付制限
					PiMaxYearMMDD = GiAddYearMMDD( iYearMMDD, 0,0,-1); // -1日＝前日
				}
			}
			// Re6edit : 支払日変更対象となるE6
			if (Re6edit) {
				[Re6edit release], Re6edit = nil;
			}
			Re6edit = [[e6parts objectAtIndex:PiE6row] retain];  //SortしたのでIndex指定できる		//このモジュールで確保するためｒｅｔａｉｎしている
			NSInteger iYearMMDD = [Re6edit.e2invoice.e7payment.nYearMMDD integerValue];
			MdatePicker.date = GdateYearMMDD(iYearMMDD, 0, 0, 0);
		}
		else if ([Rentity valueForKey:RzKey]) {
			self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone; //[Done]  デフォルト[Save]
				MdatePicker.date = [Rentity valueForKey:RzKey];
		}
		else {
			self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone; //[Done]  デフォルト[Save]
			MdatePicker.date = [NSDate date]; // Now
		}
	}
	else {
		MdatePicker.date = [NSDate date]; // Now
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

// 回転の許可　ここでは許可、禁止の判定だけする
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	// 回転禁止でも、正面は常に許可しておくこと。
	return !MbOptAntirotation OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	//[self viewWillAppear:NO];没：これを呼ぶと、回転の都度、編集がキャンセルされてしまう。
	[self viewDesign]; // これで回転しても編集が継続されるようになった。
}

- (void)viewDesign
{
	CGRect rect = self.view.bounds;
	

	if (self.interfaceOrientation == UIInterfaceOrientationPortrait 
	 OR self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
	{	// タテ
		rect.origin.y = (self.view.bounds.size.height - GD_PickerHeight) / 2;
		rect.size.height = GD_PickerHeight;
		MdatePicker.frame = rect;
		
		rect.size.width = 150;
		rect.size.height = 30;
		rect.origin.x = self.view.bounds.size.width/2 - rect.size.width / 2;
		rect.origin.y = 30;
		MbuToday.frame = rect;

		rect.origin.y = self.view.bounds.size.height - 60;
		MbuYearTime.frame = rect;
	}
	else {	// ヨコ
		rect.origin.y = self.view.bounds.size.height - GD_PickerHeight;
		rect.size.height = GD_PickerHeight;
		MdatePicker.frame = rect;

		rect.size.width = 150;
		rect.size.height = 30;
		rect.origin.y = 10;
		rect.origin.x = (self.view.bounds.size.width/2) - rect.size.width - 50;
		MbuToday.frame = rect;
		
		rect.origin.x = (self.view.bounds.size.width/2) + 50;
		MbuYearTime.frame = rect;
	}
}	

- (void)buttonToday
{
	//MdatePicker.date = [NSDate date]; // Now
	[MdatePicker setDate:[NSDate date] animated:YES];
}

- (void)buttonYearTime
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


// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
- (void)done:(id)sender
{
	if (0<=PiE6row) {	//[1.0.0]E6date変更モード：変更有れば即保存
		if (Re6edit) {
			E2invoice *e2old = Re6edit.e2invoice;  //変更前に属しているE2
			E3record *e3 = Rentity;
			NSInteger iYearMMDD = GiYearMMDD(MdatePicker.date);
			E2invoice *e2new = [MocFunctions e2invoice:e3.e1card  inYearMMDD:iYearMMDD]; //変更後に属するE2
			if (e2new != e2old) { 
				//属するE2に変化あり
				Re6edit.e2invoice = e2new;
				//e2new 配下再集計
				[MocFunctions e2e7update:e2new]; //E6増
				//e2old 配下再集計
				[MocFunctions e2e7update:e2old]; //E6減
				//
				if ([delegate respondsToSelector:@selector(editDateE6change)]) {
					[delegate editDateE6change];
				}
			}
		}
	} 
	else {
		[Rentity setValue:MdatePicker.date forKey:RzKey];
	}

	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る

	if (120 * 24 * 60 * 60 < fabs([MdatePicker.date timeIntervalSinceNow])) {  //[0.4]日付チェック
		alertBox(NSLocalizedString(@"DateUse Over",nil),
				 NSLocalizedString(@"DateUse Over msg",nil),
				 NSLocalizedString(@"Roger",nil));
	}
}


@end
