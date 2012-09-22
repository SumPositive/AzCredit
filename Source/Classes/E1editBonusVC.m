//
//  E1editBonusVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "Entity.h"
#import "E1editBonusVC.h"

@interface E1editBonusVC (PrivateMethods)
- (void)viewDesign;
- (void)done:(id)sender;
@end

@implementation E1editBonusVC
@synthesize Re1edit;


#pragma mark - Action

// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
- (void)done:(id)sender
{
	// 結果更新
	Re1edit.nBonus1 = [NSNumber numberWithInteger:[Mpicker selectedRowInComponent:0]];
	Re1edit.nBonus2 = [NSNumber numberWithInteger:[Mpicker selectedRowInComponent:1]];
	
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
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
	
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

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
	MlbBonus1 = [[[UILabel alloc] init] autorelease];
	MlbBonus1.text = NSLocalizedString(@"Bonus1",nil);
	//MlbBonus1.numberOfLines = 2;
	MlbBonus1.textAlignment = UITextAlignmentCenter;
	MlbBonus1.font = [UIFont systemFontOfSize:14];
	MlbBonus1.backgroundColor = [UIColor clearColor];
	[self.view addSubview:MlbBonus1]; //[MlbBonus1 release];
	//------------------------------------------------------
	MlbBonus2 = [[[UILabel alloc] init] autorelease];
	MlbBonus2.text = NSLocalizedString(@"Bonus2",nil);
	//MlbBonus2.numberOfLines = 2;
	MlbBonus2.font = [UIFont systemFontOfSize:14];
	MlbBonus2.textAlignment = UITextAlignmentCenter;
	MlbBonus2.backgroundColor = [UIColor clearColor];
	[self.view addSubview:MlbBonus2]; //[MlbBonus2 release];
	//------------------------------------------------------
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
	
	rect.size.width = 150;
	rect.size.height = 20;
	rect.origin.y -= rect.size.height;
	float fcx = self.view.bounds.size.width / 2;
	// 左
	rect.origin.x = fcx - rect.size.width;
	MlbBonus1.frame = rect;
	// 右
	rect.origin.x = fcx;
	MlbBonus2.frame = rect;
	
}	

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　// viewDidAppear はView表示直後に呼ばれる
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];

	// PICKER 指定されたコンポーネンツの行を選択する。
	NSInteger iMon = [Re1edit.nBonus1 integerValue];
	if (iMon < 0 OR 12 < iMon) iMon = 1;
	[Mpicker selectRow:iMon inComponent:0 animated:NO];

	iMon = [Re1edit.nBonus2 integerValue];
	if (iMon < 0 OR 12 < iMon) iMon = 8;
	[Mpicker selectRow:iMon inComponent:1 animated:NO];

	
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
{	//iPad//Popover内につき回転不要
	// 回転禁止でも、正面は常に許可しておくこと。
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
	//--------------------------------Private Alloc
	//--------------------------------@property (retain)
	[Re1edit release];
	[super dealloc];
}


#pragma mark - UIPickerView

//-----------------------------------------------------------Picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	switch (component) {
		case 0: return 13;
			break;
		case 1: return 13;
			break;
	}
	return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return 150;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (1 <= row && row <= 12) {
		return GstringMonth( row );
	}
	return NSLocalizedString(@"Unused", nil);
}

// 変更時に呼び出される
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if ([pickerView selectedRowInComponent:0] <= 0) {
		[pickerView selectRow:0 inComponent:1 animated:YES];
	}
	else if (0 < [pickerView selectedRowInComponent:1] 
		 && [pickerView selectedRowInComponent:1] < [pickerView selectedRowInComponent:0]  ) {
		// Bonus1 <= Bonus2 になるように交換する
		NSInteger iRow = [pickerView selectedRowInComponent:0];
		[pickerView selectRow:[pickerView selectedRowInComponent:1] inComponent:0 animated:YES];
		[pickerView selectRow:iRow inComponent:1 animated:YES];
	}
}


@end
