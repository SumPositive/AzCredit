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

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
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
													 message:@"EditAmountVC" 
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
	MtfAmount = nil;	
	MlbAmount = nil;

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

// 画面表示された直後に呼び出される
- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	
	//self.title = NSLocalizedString(@"Amount Input",nil);　親側で変えられるように
	
	//viewWillAppearでキーを表示すると画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
	[MtfAmount becomeFirstResponder];  // キーボード表示
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
	}

}	

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


@end
