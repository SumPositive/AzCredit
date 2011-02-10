//
//  EditDateVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "Entity.h"
#import "EditDateVC.h"

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

- (void)dealloc    // 最後に1回だけ呼び出される（デストラクタ）
{
	// 生成とは逆順に解放するのが好ましい
	[RzKey release];
	[Rentity release];
	[super dealloc];
}

- (void)viewDidUnload 
{
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。

	// @property (retain) は解放しない。
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"viewDidUnload" 
													 message:@"EditDateVC" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
}


// viewDidLoadメソッドは，TableViewContorllerオブジェクトが生成された後，実際に表示される際に呼び出されるメソッド
- (void)viewDidLoad 
{
    [super viewDidLoad];
	MdatePicker = nil;	
	MbuToday = nil;
	MbuYearTime = nil;
	
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

	// DONEボタンを右側に追加する
	// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
	// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
	// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
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
	MdatePicker = [[UIDatePicker alloc] init];
	//MdatePicker.datePickerMode = UIDatePickerModeDateAndTime;  viewWillAppear にてセット
	if (AzMIN_YearMMDD < PiMinYearMMDD) {
		MdatePicker.minimumDate = GdateYearMMDD(PiMinYearMMDD,  0, 0, 0);
	} else {
		MdatePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:-60*60*24*360];	// 約1年前から
	}
	if (PiMaxYearMMDD < AzMAX_YearMMDD) {
		MdatePicker.maximumDate = GdateYearMMDD(PiMaxYearMMDD, 23,59,59); 
	} else {
		MdatePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*120];	// 約3ヶ月先まで
	}
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"dk_DK"];  // AM/PMを消すため ＜＜実機でのみ有効らしい＞＞
	MdatePicker.locale = locale; [locale release];
	[self.view addSubview:MdatePicker]; [MdatePicker release];
	//------------------------------------------------------
}

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
	
	if ([Rentity valueForKey:RzKey] == nil) {
		MdatePicker.date = [NSDate date]; // Now
	} else {
		MdatePicker.date = [Rentity valueForKey:RzKey];
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

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// 回転禁止でも万一ヨコからはじまった場合、タテにはなるようにしてある。
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
	[Rentity setValue:MdatePicker.date forKey:RzKey];
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}


@end
