//
//  E1edit.m
//  iPack
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
// InterfaceBuilderを使わずに作ったViewController

#import "Global.h"
#import "AppDelegate.h"
#import "Elements.h"
#import "E1viewController.h"
#import "E1edit.h"
#import "E2viewController.h"
#import "GooDocsTVC.h"

@interface E1edit (PrivateMethods)
	- (void)cancel:(id)sender;
	- (void)save:(id)sender;
	- (void)viewDesign;
	- (void)tvNoteNarrow; // Noteフィールドをキーボードに隠れなくする
//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
//----------------------------------------------------------------Owner移管につきdealloc時のrelese不要
	UITextField		*MtfName;  // self.viewがOwner
	UITextView		*MtvNote;  // self.viewがOwner
//----------------------------------------------------------------assign
	BOOL MbOptShouldAutorotate;
@end
@implementation E1edit   // ViewController
@synthesize Pe1target;
@synthesize PiAddRow;

- (void)dealloc 
{
	AzRETAIN_CHECK(@"E1e MtfName", MtfName, 1)
	//[MtfName release]; addSub直後のreleaseにより、self.viewがOwnerになったので不要
	AzRETAIN_CHECK(@"E1e MtvNote", MtvNote, 1)
	//[MtvNote release];
	
	// @property (retain)
	AzRETAIN_CHECK(@"E1e Pe1target", Pe1target, 1)
	[Pe1target release];

    [super dealloc];
}

- (void)viewDidUnload 
{
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。

	// @property (retain) は解放しない。
}

//- (id)init {
//	if ( !(self = [super init]) ) return self;
//}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	MtfName = nil;
	MtvNote = nil;
	
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

	// E1.name
	MtfName = [[UITextField alloc] init]; // 位置はviewDesignで決定
	MtfName.font = [UIFont systemFontOfSize:16];
	MtfName.borderStyle = UITextBorderStyleRoundedRect;
	MtfName.placeholder = NSLocalizedString(@"Plan name", @"AzPack名称");
	MtfName.keyboardType = UIKeyboardTypeDefault;
	MtfName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter; // 縦中央
	MtfName.delegate = self;
	[self.view addSubview:MtfName]; [MtfName release]; // self.viewがOwnerになる

	// E1.note
	MtvNote = [[UITextView alloc] init];
	MtvNote.font = [UIFont systemFontOfSize:14];
	MtvNote.keyboardType = UIKeyboardTypeDefault;
	MtvNote.delegate = self;
	[self.view addSubview:MtvNote]; [MtvNote release]; // self.viewがOwnerになる
	
	// CANCELボタンを左側に追加する  Navi標準の戻るボタンでは cancel:処理ができないため
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
											  target:self action:@selector(cancel:)] autorelease];
	// SAVEボタンを右側に追加する
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
											   target:self action:@selector(save:)] autorelease];
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptShouldAutorotate = [defaults boolForKey:GD_OptShouldAutorotate];
	
	[self viewDesign];
	
	MtfName.text = [Pe1target valueForKey:@"name"];
	MtvNote.text = [Pe1target valueForKey:@"note"];
}

// 画面表示された直後に呼び出される
- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	//viewWillAppearでキーを表示すると画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
	[MtfName becomeFirstResponder];  // キーボード表示
}

// ビューが非表示にされる前や解放される前ににこの処理が呼ばれる
- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	// 戻る前にキーボードを消さないと、次に最初から現れた状態になり、表示されるまでが遅くなってしまう。
	// キーボードを消すために全てのコントロールへresignFirstResponderを送る ＜表示中にしか効かない＞
	[MtfName resignFirstResponder];
	[MtvNote resignFirstResponder];
}

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// 回転禁止でも万一ヨコからはじまった場合、タテにはなるようにしてある。
	return MbOptShouldAutorotate OR (interfaceOrientation == UIInterfaceOrientationPortrait);
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
	float fKeyHeight;
	float fHeightOfsset;
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait 
		OR self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		fKeyHeight = GD_KeyboardHeightPortrait;	 // タテ
		fHeightOfsset = 15; // タテ： MtfNameの高さを少しでも高くして操作しやすくする
	} else {
		fKeyHeight = GD_KeyboardHeightLandscape; // ヨコ
		fHeightOfsset = 0; // ヨコ： MtvNoteの高さをできるだけ確保しなければ入力しにくくなる
	}

	CGRect rect;
	rect.origin.x = 10;
	rect.origin.y = 5;
	rect.size.width = self.view.frame.size.width - rect.origin.x * 2;
	rect.size.height = 25 + fHeightOfsset;
	MtfName.frame = rect;
	
	rect.origin.x = 15;
	rect.origin.y = 33 + fHeightOfsset;
	rect.size.width = self.view.frame.size.width - rect.origin.x * 2;
	rect.size.height = self.view.frame.size.height - rect.origin.y - 5 - fKeyHeight;
	MtvNote.frame = rect;
}


- (void)cancel:(id)sender {
	if (0 <= PiAddRow) {
		// 新オブジェクトのキャンセルなので、呼び出し元で挿入したオブジェクトを削除する
		NSManagedObjectContext *ct = Pe1target.managedObjectContext;
		[ct deleteObject:Pe1target];
		NSError *err = nil;
		if (![ct save:&err]) {
			NSLog(@"Unresolved error %@, %@", err, [err userInfo]);
			abort();
		}
	}
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}


// <UITextFieldDelegate> テキストが変更される「直前」に呼び出される。これにより入力文字数制限を行っている。
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range 
												replacementString:(NSString *)string 
{
	// senderは、MtfName だけ
    NSMutableString *text = [[textField.text mutableCopy] autorelease];
    [text replaceCharactersInRange:range withString:string];
	// 置き換えた後の長さをチェックする
	return [text length] <= AzMAX_NAME_LENGTH; // 最大文字数
}

// UITextView テキストが変更される「直前」に呼び出される。これにより入力文字数制限を行っている。
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
											replacementText:(NSString *)zReplace
{
	// senderは、MtvNote だけ
    NSMutableString *zText = [[textView.text mutableCopy] autorelease];
    [zText replaceCharactersInRange:range withString:zReplace];
	// 置き換えた後の長さをチェックする
	return ([zText length] <= AzMAX_NOTE_LENGTH);
}


- (void)save:(id)sender 
{
//	// .name はブランクにならないようにする
//	if([MtfName.text length] <= 0)	MtfName.text = NSLocalizedString(@"Untitled", nil);
//代入せずにcell表示だけするように改良
	
	// 編集フィールドの値を editObj にセットする
	[Pe1target setValue:MtfName.text forKey:@"name"];
	[Pe1target setValue:MtvNote.text forKey:@"note"];

	if (0 <= PiAddRow) {
		// 新規のとき、末尾になるように行番号を付与する
		[Pe1target setValue:[NSNumber numberWithInteger:PiAddRow] forKey:@"row"];
	}
	
	NSManagedObjectContext *ct = Pe1target.managedObjectContext;
	NSError *err = nil;
	if (![ct save:&err]) {
		NSLog(@"Unresolved error %@, %@", err, [err userInfo]);
		abort();
	}
	//[self.navigationController dismissModalViewControllerAnimated:MbAnimation];
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"didReceiveMemoryWarning" 
													 message:@"E1edit" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif
    [super didReceiveMemoryWarning];
}

@end
