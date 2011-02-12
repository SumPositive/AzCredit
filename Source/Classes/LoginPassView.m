//
//  LoginPassView.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "LoginPassView.h"

@interface LoginPassView (PrivateMethods)
- (void)done:(id)sender;
@end

@implementation LoginPassView

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[super dealloc];
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
    [super loadView];
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
	MtextView = nil;	// ここで生成

	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

	// DONEボタンを右側に追加する
//	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
//											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
//											   target:self action:@selector(done:)] autorelease];

	// とりあえず生成、位置はviewDesignにて決定
	MtextView = [[UITextView alloc] init];
	MtextView.font = [UIFont systemFontOfSize:16];
	MtextView.textAlignment = UITextAlignmentLeft;
	MtextView.keyboardType = UIKeyboardTypeDefault;
	MtextView.returnKeyType = UIReturnKeyDefault; // Return
	MtextView.delegate = self;
	[self.view addSubview:MtextView]; [MtextView release]; // self.viewがOwnerになる
}

/*
- (void)viewDidUnload 
{
	[super viewDidUnload];
	AzLOG(@"MEMORY! EditTextVC: viewDidUnload");
}
*/

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　// viewDidAppear はView表示直後に呼ばれる
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];

	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];

	[self viewDesign];
	
	MtextView.text = [Rentity valueForKey:RzKey];
	
	if (0 < PiSuffixLength) {
		// 末尾改行文字("\n")を PiSuffixLength 個除く -->> doneにて追加する
		if ([MtextView.text length] <= PiSuffixLength) {
			MtextView.text = @"";  //この処理が無いと新規のときフリーズする
		} else {
			MtextView.text = [MtextView.text substringToIndex:([MtextView.text length] - PiSuffixLength)];
		}
	}
	
	//ここでキーを呼び出すと画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
}

// 画面表示された直後に呼び出される
- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	//viewWillAppearでキーを表示すると画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
	[MtextView becomeFirstResponder];  // キーボード表示
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
	float	fKeyHeight;

	if (self.interfaceOrientation == UIInterfaceOrientationPortrait OR self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		fKeyHeight = GD_KeyboardHeightPortrait;	 // タテ
	} else {
		fKeyHeight = GD_KeyboardHeightLandscape; // ヨコ
	}

	rect = self.view.bounds;  // ＜＜課題！これでは、ToolBar表示時には、高さが小さくなってしまう＞＞
	rect.origin.x += 10;
	rect.origin.y += 10;
	rect.size.width -= 20;
	rect.size.height -= (20 + fKeyHeight);
	MtextView.frame = rect;	
}	


// <UITextViewDelegete> テキストが変更される「直前」に呼び出される。これにより入力文字数制限を行っている。
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
													replacementText:(NSString *)zReplace
{
	if (PiMaxLength <= 0) return YES; // 無制限
	
	// senderは、MtextView だけ
    NSMutableString *zText = [[textView.text mutableCopy] autorelease];
    [zText replaceCharactersInRange:range withString:zReplace];
	// 置き換えた後の長さをチェックする
	return ([zText length] <= PiMaxLength); // PiMaxLength以下YES
}


// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
- (void)done:(id)sender
{
//	[PPmuString setString:MtextView.text]; // 戻り値
	if (0 < PiSuffixLength) {	// 複数行ラベルで上寄表示させるため末尾に改行を追加する
		NSMutableString *mstr = [[NSMutableString alloc] initWithString:MtextView.text];
		// 末尾改行文字("\n")を PiSuffixLength 個追加する
		for (NSInteger i=0; i<PiSuffixLength; i++) {
			[mstr appendString:@"\n"];
		}
		[Rentity setValue:mstr forKey:RzKey];
		[mstr release];
	}
	else {
		//AzLOG(@"---[%@:%@]---",MtextView.text, PzKey);
		[Rentity setValue:MtextView.text forKey:RzKey];
	}

	
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

@end
