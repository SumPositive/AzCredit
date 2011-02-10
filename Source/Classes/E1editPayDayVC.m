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
- (void)done:(id)sender;
@end

@implementation E1editPayDayVC
@synthesize Re1edit;

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	//--------------------------------Private Alloc
	//--------------------------------@property (retain)
	[Re1edit release];
	[super dealloc];
}

- (void)viewDidUnload 
{
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。

	// @property (retain) は解放しない。
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"viewDidUnload" 
													 message:@"E1editPayDayVC" 
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
	Mpicker = nil;	
//	MlbClosing = nil;
//	MlbPayMonth = nil;
//	MlbPayDay = nil;

	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

	// DONEボタンを右側に追加する
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self action:@selector(done:)] autorelease];
	
	// とりあえず生成、位置はviewDesignにて決定
	//------------------------------------------------------
	Mpicker = [[UIPickerView alloc] init];
	Mpicker.delegate = self;
	Mpicker.dataSource = self;
	Mpicker.showsSelectionIndicator = YES;
	[self.view addSubview:Mpicker]; [Mpicker release];
	//------------------------------------------------------
	MlbClosing = [[UILabel alloc] init];
	MlbClosing.font = [UIFont systemFontOfSize:14];
	MlbClosing.textAlignment = UITextAlignmentCenter;
	MlbClosing.text = NSLocalizedString(@"Closing day",nil);
	MlbPayDay.numberOfLines = 2;
	MlbClosing.backgroundColor = [UIColor clearColor];
	[self.view addSubview:MlbClosing]; [MlbClosing release];
	//------------------------------------------------------
	MlbPayMonth = [[UILabel alloc] init];
	MlbPayMonth.font = [UIFont systemFontOfSize:14];
	MlbPayMonth.textAlignment = UITextAlignmentCenter;
	MlbPayMonth.text = NSLocalizedString(@"Payment month",nil);
	MlbPayDay.numberOfLines = 2;
	MlbPayMonth.backgroundColor = [UIColor clearColor];
	[self.view addSubview:MlbPayMonth]; [MlbPayMonth release];
	//------------------------------------------------------
	MlbPayDay = [[UILabel alloc] init];
	MlbPayDay.font = [UIFont systemFontOfSize:14];
	MlbPayDay.textAlignment = UITextAlignmentCenter;
	MlbPayDay.text = NSLocalizedString(@"Payment day",nil);
	MlbPayDay.numberOfLines = 2;
	MlbPayDay.backgroundColor = [UIColor clearColor];
	[self.view addSubview:MlbPayDay]; [MlbPayDay release];
	//------------------------------------------------------
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
	if (iDay < 1 OR 29 < iDay) iDay = 20;
	[Mpicker selectRow:iDay-1 inComponent:0 animated:NO];	

	iDay = [Re1edit.nPayMonth integerValue];
	if (iDay < 0 OR 3 < iDay) iDay = 1;
	[Mpicker selectRow:iDay inComponent:1 animated:NO];	
	
	iDay = [Re1edit.nPayDay integerValue];
	if (iDay < 1 OR 29 < iDay) iDay = 20;
	[Mpicker selectRow:iDay-1 inComponent:2 animated:NO];	

	
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
		rect.origin.y = self.view.bounds.size.height/2 - GD_PickerHeight/2;
	}
	else {	// ヨコ
		rect.origin.y = self.view.bounds.size.height - GD_PickerHeight;
	}
	rect.size.height = GD_PickerHeight;
	Mpicker.frame = rect;

	rect.size.width = 80;
	rect.size.height = 40;
	rect.origin.y -= rect.size.height;
	float fcx = self.view.bounds.size.width / 2;
	// 中央
	rect.origin.x = fcx - (rect.size.width / 2);
	MlbPayMonth.frame = rect;
	// 左
	rect.origin.x = fcx - (rect.size.width * 1.5) - 20;
	MlbClosing.frame = rect;
	// 右
	rect.origin.x = fcx + (rect.size.width / 2) + 20;
	MlbPayDay.frame = rect;
	
}	


//-----------------------------------------------------------Picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	switch (component) {
		case 0: return 28;
			break;
		case 1: return 3;
			break;
		case 2: return 28;
			break;
	}
	return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	switch (component) {
		case 0: return 80;
			break;
		case 1: return 110;
			break;
		case 2: return 80;
			break;
	}
	return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	switch (component) {
		case 0:
			//return GstringDay( 1 + row );
			return [NSString stringWithFormat:@"%@%@", 
					GstringDay( 1 + row ), 
					NSLocalizedString(@"Closing", nil)];
			break;
		case 1:
			switch (row) {
				case 0:
					return NSLocalizedString(@"This month",nil);
					break;
				case 1:
					return NSLocalizedString(@"Next month",nil);
					break;
				case 2:
					return NSLocalizedString(@"Twice months",nil);
					break;
			}
			break;
		case 2:
			//return GstringDay( 1 + row );
			return [NSString stringWithFormat:@"%@%@", 
					GstringDay( 1 + row ), 
					NSLocalizedString(@"Due", nil)];
			break;
	}
	return 0;
}





// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
- (void)done:(id)sender
{
	// 結果更新
	Re1edit.nClosingDay = [NSNumber numberWithInteger:1+[Mpicker selectedRowInComponent:0]];
	Re1edit.nPayMonth = [NSNumber numberWithInteger:[Mpicker selectedRowInComponent:1]];
	Re1edit.nPayDay = [NSNumber numberWithInteger:1+[Mpicker selectedRowInComponent:2]];

//	(*PPiClosingDay) = (NSInteger)(1 + [Mpicker selectedRowInComponent:0]);
//	(*PPiPayMonth) = (NSInteger)([Mpicker selectedRowInComponent:1]);
//	(*PPiPayDay) = (NSInteger)(1 + [Mpicker selectedRowInComponent:2]);
	
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

@end
