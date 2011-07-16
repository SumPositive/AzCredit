//
//  E1editPayDayVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "Entity.h"
#import "E1editPayDayVC.h"


@interface E1editPayDayVC (PrivateMethods)
- (void)viewDesign;
- (void)buttonDebit;
- (void)done:(id)sender;
@end

@implementation E1editPayDayVC
@synthesize Re1edit;
#ifdef xxxxxxAzPAD
@synthesize delegate;
@synthesize selfPopover;
#endif


#pragma mark - Action

- (void)buttonDebit		// [Debit]ボタンが押されたとき
{
	[Mpicker selectRow:0 inComponent:0 animated:YES];	//「当日締」
	[Mpicker reloadAllComponents];						// 再描画
	[Mpicker selectRow:0 inComponent:0 animated:YES];	// 2回目だが、こうしないと再描画されない
	[Mpicker selectRow:0 inComponent:1 animated:YES];	//「⇒⇒⇒」
	[Mpicker selectRow:0 inComponent:2 animated:YES];	//「当日払」
}

// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
- (void)done:(id)sender
{
	// 結果更新
	if ([Mpicker selectedRowInComponent:0] <= 0 
		OR [Mpicker selectedRowInComponent:1] <= 0) {
		// 0=Debit(自動引落し)
		Re1edit.nClosingDay = [NSNumber numberWithInteger:0];
		Re1edit.nPayMonth = [NSNumber numberWithInteger:-1];
		Re1edit.nPayDay = [NSNumber numberWithInteger:[Mpicker selectedRowInComponent:2]]; // 日後払い
	} else {
		// 締め支払
		Re1edit.nClosingDay = [NSNumber numberWithInteger:[Mpicker selectedRowInComponent:0]];
		Re1edit.nPayMonth = [NSNumber numberWithInteger:[Mpicker selectedRowInComponent:1]-1];
		Re1edit.nPayDay = [NSNumber numberWithInteger:[Mpicker selectedRowInComponent:2]];
	}
	
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


#pragma mark - UIViewController

- (id)init
{
	self = [super init];
	if (self) {
		// 初期化成功
#ifdef AzPAD
		self.contentSizeForViewInPopover = GD_POPOVER_SIZE;
#endif
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
//【Tips】ここでaddSubviewするオブジェクトは全てautoreleaseにすること。メモリ不足時には自動的に解放後、改めてここを通るので、初回同様に生成するだけ。
- (void)loadView
{
    [super loadView];
	
#ifdef AzPAD
	self.view.backgroundColor = [UIColor lightGrayColor];
#else
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
#endif
	
	// DONEボタンを右側に追加する
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self action:@selector(done:)] autorelease];
	
	// とりあえず生成、位置はviewDesignにて決定
	//------------------------------------------------------
	Mpicker = [[[UIPickerView alloc] init] autorelease];
	Mpicker.delegate = self;
	Mpicker.dataSource = self;
	Mpicker.showsSelectionIndicator = YES;
	[self.view addSubview:Mpicker]; //[Mpicker release];
	//------------------------------------------------------
	MlbClosing = [[[UILabel alloc] init] autorelease];
	MlbClosing.text = NSLocalizedString(@"Closing day",nil);
	//MlbClosing.numberOfLines = 2;
	MlbClosing.textAlignment = UITextAlignmentCenter;
	MlbClosing.font = [UIFont systemFontOfSize:14];
	MlbClosing.backgroundColor = [UIColor clearColor];
	[self.view addSubview:MlbClosing]; //[MlbClosing release];
	//------------------------------------------------------
	MlbPayMonth = [[[UILabel alloc] init] autorelease];
	MlbPayMonth.text = NSLocalizedString(@"Payment month",nil);
	//MlbPayMonth.numberOfLines = 2;
	MlbPayMonth.font = [UIFont systemFontOfSize:14];
	MlbPayMonth.textAlignment = UITextAlignmentCenter;
	MlbPayMonth.backgroundColor = [UIColor clearColor];
	[self.view addSubview:MlbPayMonth]; //[MlbPayMonth release];
	//------------------------------------------------------
	MlbPayDay = [[[UILabel alloc] init] autorelease];
	MlbPayDay.text = NSLocalizedString(@"Payment day",nil);
	//MlbPayDay.numberOfLines = 2;
	MlbPayDay.font = [UIFont systemFontOfSize:14];
	MlbPayDay.textAlignment = UITextAlignmentCenter;
	MlbPayDay.backgroundColor = [UIColor clearColor];
	[self.view addSubview:MlbPayDay]; //[MlbPayDay release];
	//------------------------------------------------------
	MbuDebit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[MbuDebit setTitle:NSLocalizedString(@"PayDay Debit",nil) forState:UIControlStateNormal];
	[MbuDebit addTarget:self action:@selector(buttonDebit) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:MbuDebit]; //[MbuDebit release]; autoreleaseされるため
	//------------------------------------------------------
	MlbDebit = [[[UILabel alloc] init] autorelease];
	MlbDebit.text = NSLocalizedString(@"PayDay Debit msg",nil);
#ifdef AzPAD
	MlbDebit.font = [UIFont systemFontOfSize:14];
#else
	MlbDebit.font = [UIFont systemFontOfSize:12];
#endif
	MlbDebit.backgroundColor = [UIColor clearColor];
	[self.view addSubview:MlbDebit]; //[MlbDebit release];
	//------------------------------------------------------
}

- (void)viewDesign
{
	CGRect rect = self.view.bounds;

#ifdef AzPAD
	float fXofs = (rect.size.width - 320) / 2.0;
	float fYofs = 60;
#else
	float fXofs = 0;
	float fYofs = 0;
#endif

	rect.origin.x = fXofs;
	//---------------------------- Picker
	rect.origin.y = fYofs + 25;
	rect.size.height = GD_PickerHeight;
	rect.size.width = 320;
	Mpicker.frame = rect;
	
	//---------------------------- Picker見出しラベル
	rect.origin.y = fYofs + 5;
	rect.size.width = 80;
	rect.size.height = 20;
	//float fcx = 320 / 2;
	// 左
	rect.origin.x = fXofs + 10; //fcx - (rect.size.width * 1.5) - 20;
	MlbClosing.frame = rect;
	// 中央
	rect.origin.x = fXofs + 100; //fcx - (rect.size.width / 2);
	MlbPayMonth.frame = rect;
	// 右
	rect.origin.x = fXofs + 200; //fcx + (rect.size.width / 2) + 20;
	MlbPayDay.frame = rect;
	
	//---------------------------- Debit
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
	{	// タテ
		// 中央
		rect.origin.y += (GD_PickerHeight + 80);
		rect.size.width = 80;
		rect.origin.x = fXofs + 160 - (rect.size.width / 2);
		rect.size.height = 30;
		MbuDebit.frame = rect;
		// 中央
		rect.origin.y += (rect.size.height + 5);
		rect.size.width = 360;
		rect.origin.x = fXofs + 160 - (rect.size.width / 2);
		rect.size.height = 50;
		MlbDebit.frame = rect;
		MlbDebit.textAlignment = UITextAlignmentCenter;
		MlbDebit.numberOfLines = 3;
	}
	else {	// ヨコ
		// Pickerの右
		rect.origin.x = 320 + 40;
		rect.size.width = 80;
		rect.origin.y = fYofs + 80;
		rect.size.height = 30;
		MbuDebit.frame = rect;
		// 下
		rect.origin.x = 320 + 10;
		rect.size.width = 150;
		rect.origin.y = 110;
		rect.size.height = 100;
		MlbDebit.frame = rect;
		MlbDebit.textAlignment = UITextAlignmentLeft;
		MlbDebit.numberOfLines = 6;
	}
}	

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　// viewDidAppear はView表示直後に呼ばれる
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];

	// PICKER 指定されたコンポーネンツの行を選択する。
	NSInteger iDay = [Re1edit.nClosingDay integerValue]; // (*PPiClosingDay); //[Pe1.nClosingDay integerValue];
	if (iDay < 0 OR 29 < iDay) iDay = 20;
	[Mpicker selectRow:iDay inComponent:0 animated:NO]; // 0=Debit

	iDay = [Re1edit.nPayMonth integerValue];
	if (iDay < -1 OR 2 < iDay) iDay = 1;
	[Mpicker selectRow:1+iDay inComponent:1 animated:NO]; // 0=Debit
	
	iDay = [Re1edit.nPayDay integerValue];
	if (iDay < 0 OR 29 < iDay) iDay = 20;
	[Mpicker selectRow:iDay inComponent:2 animated:NO];  // 0=Debit

	
	[self viewDesign];
	//ここでキーを呼び出すと画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
}

// 画面表示された直後に呼び出される
- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	
	//viewWillAppearでキーを表示すると画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
//	[MtfAmount becomeFirstResponder];  // キーボード表示
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

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	//[self viewWillAppear:NO];没：これを呼ぶと、回転の都度、編集がキャンセルされてしまう。
	[self viewDesign]; // これで回転しても編集が継続されるようになった。
}


#pragma mark  View - Unload - dealloc

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
#ifdef xxxAzPAD
	[selfPopover release], selfPopover = nil;
#endif
	[Re1edit release];
	[super dealloc];
}

#pragma mark  - UIPickerView

//-----------------------------------------------------------Picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	switch (component) {
		case 0: return 30;
			break;
		case 1: return 4;
			break;
		case 2: return 30;
			break;
	}
	return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	switch (component) {
		case 0: return 80;
			break;
		case 1: return 100;
			break;
		case 2: return 120;
			break;
	}
	return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	switch (component) {
		case 0:
			if (row <= 0) {
				return NSLocalizedString(@"Debit", nil); // 0=Debit(利用日⇒支払日)	
			} else {
				return [NSString stringWithFormat:@"%@%@", 
						GstringDay( row ), 
						NSLocalizedString(@"Closing", nil)];
			}
			break;
		case 1:
			if ([Mpicker selectedRowInComponent:0] <= 0) { // 当日締
				if (row==0) {
					return @"⇒ ⇒ ⇒";
				}
			}
			else {
				switch (row) {
					case 0:
						//return @"";
						break;
					case 1:
						return NSLocalizedString(@"This month",nil);
						break;
					case 2:
						return NSLocalizedString(@"Next month",nil);
						break;
					case 3:
						return NSLocalizedString(@"Twice months",nil);
						break;
				}
			}
			break;
		case 2:
			if ([Mpicker selectedRowInComponent:0] <= 0) { 
				if (row <= 0) {
					return NSLocalizedString(@"Debit day", nil); // 当日払
				} else if (row <= 28) {
					return [NSString stringWithFormat:@"%@%@", 
							GstringDay( row ), 
							NSLocalizedString(@"Debit After", nil)];
				}
			} else {
				if (0 < row && row <= 29) {
					return [NSString stringWithFormat:@"%@%@", 
							GstringDay( row ), 
							NSLocalizedString(@"Due", nil)];
				}
			}
			break;
	}
	return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[Mpicker reloadAllComponents];
	
	if ([Mpicker selectedRowInComponent:0] <= 0) {
		// 0=Debit(自動引落し)
		[Mpicker selectRow:0 inComponent:1 animated:YES];
		if (28<[Mpicker selectedRowInComponent:2]) {
			[Mpicker selectRow:28 inComponent:2 animated:YES];
		}
	} 
	else {
		if ([Mpicker selectedRowInComponent:1]<=0) {
			[Mpicker selectRow:1 inComponent:1 animated:YES];
		}
		if ([Mpicker selectedRowInComponent:2]<=0) {
			[Mpicker selectRow:1 inComponent:2 animated:YES];
		}
	}
}

@end
