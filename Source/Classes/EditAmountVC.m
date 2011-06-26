//
//  EditAmountVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "Entity.h"
#import "EditAmountVC.h"

@interface EditAmountVC (PrivateMethods)
- (void)viewDesign;
- (void)done:(id)sender;
@end

@implementation EditAmountVC
@synthesize Rentity;
@synthesize RzKey;


#pragma mark - Action

// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
- (void)done:(id)sender
{
	if (0 < [MtfAmount.text length]) {
		[Rentity setValue:[NSNumber numberWithInteger:[MtfAmount.text integerValue]] forKey:RzKey];
	}
	
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}


#pragma mark - View lifecicle

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
	[super loadView];
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
	MtfAmount = nil;	// ここ(loadView)で生成
	MlbAmount = nil;	// ここ(loadView)で生成

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
	MlbAmount = [[UILabel alloc] init];
	MlbAmount.text = NSLocalizedString(@"Yen (JPY)",nil);
	MlbAmount.textAlignment = UITextAlignmentCenter;
	MlbAmount.textColor = [UIColor blackColor];
	MlbAmount.backgroundColor = [UIColor clearColor];
	MlbAmount.font = [UIFont systemFontOfSize:14];
	[self.view addSubview:MlbAmount]; [MlbAmount release]; // self.viewがOwnerになる
	//------------------------------------------------------
	MtfAmount = [[UITextField alloc] init];
	MtfAmount.borderStyle = UITextBorderStyleRoundedRect;
	MtfAmount.clearButtonMode = UITextFieldViewModeAlways;
	MtfAmount.font = [UIFont fontWithName:@"Verdana-Bold" size:30];
	MtfAmount.textAlignment = UITextAlignmentRight;
	MtfAmount.keyboardType = UIKeyboardTypeNumberPad;
	MtfAmount.returnKeyType = UIReturnKeyDone;
	MtfAmount.delegate = self;  // textViewDidBeginEditingなどが呼び出されるように
	MtfAmount.tag = 99999999; // 最大値
	[self.view addSubview:MtfAmount]; [MtfAmount release];
	[MtfAmount resignFirstResponder];  // 初期キーボード表示しない　viewDidAppearにて表示
	
/*	//------------------------------------------------------Calc
	//-----------------[0]
	MbuCalcN0 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[MbuCalcN0 setTitle:NSLocalizedString(@"0",nil) forState:UIControlStateNormal];
	[MbuCalcN0 addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:MbuCalcN0]; //[bu release]; autoreleaseされるため
	//-----------------[1]
	MbuCalcN1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[MbuCalcN1 setTitle:NSLocalizedString(@"1",nil) forState:UIControlStateNormal];
	[MbuCalcN1 addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:MbuCalcN1]; //[bu release]; autoreleaseされるため
	//-----------------[2]
	MbuCalcN2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[MbuCalcN2 setTitle:NSLocalizedString(@"2",nil) forState:UIControlStateNormal];
	[MbuCalcN2 addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:MbuCalcN2]; //[bu release]; autoreleaseされるため
*/	
}

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　// viewDidAppear はView表示直後に呼ばれる
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];

	MtfAmount.text = nil;
	MtfAmount.placeholder = [NSString stringWithFormat:@"%ld", (long)[[Rentity valueForKey:RzKey] integerValue]];

	[self viewDesign];
	//ここでキーを呼び出すと画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
}

- (void)viewDesign
{
	CGRect rect;
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait 
		OR self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
	{	// タテ
		// Amount
		rect.size.width = 230; // 99999999
		rect.origin.x = self.view.bounds.size.width/2 - rect.size.width/2;
		rect.origin.y = 60;
		rect.size.height = 20;
		MlbAmount.frame = rect;
		rect.origin.y = 80;
		rect.size.height = 40;
		MtfAmount.frame = rect;	
		
		/*		rect.size.width = 30;
		 rect.size.height = 30;
		 rect.origin.y = 200;
		 rect.origin.x = 50;
		 MbuCalcN0.frame = rect;
		 rect.origin.x = 100;
		 MbuCalcN1.frame = rect;
		 rect.origin.x = 150;
		 MbuCalcN2.frame = rect;*/
	}
	else {	// ヨコ
		//NSInteger iGapX = (self.view.bounds.size.width - 120 - 120 - 160) / 4;
		// Amount
		rect.size.width = 230; // 999
		rect.origin.x = self.view.bounds.size.width/2 - rect.size.width/2;
		rect.origin.y = 20;
		rect.size.height = 20;
		MlbAmount.frame = rect;
		rect.origin.y = 40;
		rect.size.height = 40;
		MtfAmount.frame = rect;	
		
		/*		rect.size.width = 30;
		 rect.size.height = 30;
		 rect.origin.y = 200;
		 rect.origin.x = 50;
		 MbuCalcN0.frame = rect;
		 rect.origin.x = 100;
		 MbuCalcN1.frame = rect;
		 rect.origin.x = 150;
		 MbuCalcN2.frame = rect;*/
	}
	
}	


// 画面表示された直後に呼び出される
- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	
	//self.title = NSLocalizedString(@"Amount Input",nil);　親側で変えられるように
	
	//viewWillAppearでキーを表示すると画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
	[MtfAmount becomeFirstResponder];  // キーボード表示
}

#pragma mark  View - Rotate

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

#pragma mark  View - Unload - dealloc

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[RzKey release];
	[Rentity release];
	[super dealloc];
}


#pragma mark - <UITextFieldDelegate>

//テキストフィールドの文字変更のイベント処理
// UITextFieldオブジェクトから1文字入力の都度呼び出されることにより入力文字数制限を行っている。
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range 
														replacementString:(NSString *)string 
{	// textField.tag = 最大値がセットされてある
	if (![string boolValue] && ![string isEqual:@"0"]) return YES; // 数字でない [X]キーなど
	
	if ([textField.text isEqual:@"0"]) {
		textField.text = @""; // 先頭の0を取り除くため
		return NO;
	}
	
	// 範囲ペーストされることも考慮したチェック方法
	NSMutableString *text = [[textField.text mutableCopy] autorelease];
    [text replaceCharactersInRange:range withString:string];
	[text replaceOccurrencesOfString:@"," withString:@"" 
					 options:NSLiteralSearch range:NSMakeRange(0,[text length])]; // コンマを取り除く
	NSInteger iNum = [text integerValue]; // 入力を受け入れた後の値
	if (iNum < 0 OR textField.tag < iNum) return NO; // OVER

	return YES; // この後、stringが追加される。
}

//テキストフィールドリターン時のイベント処理
- (BOOL)textFieldShouldReturn:(UITextField *)sender 
{
	[self done:sender];
    return YES;
}


/*
- (void)buttonCalc:(id)sender
{
	if (sender == MbuCalcN0) {
		AzLOG(@"[0]");
	}
	else if (sender == MbuCalcN1) {
		AzLOG(@"[1]");
	}
	else if (sender == MbuCalcN2) {
		AzLOG(@"[2]");
	}
}
*/

@end
