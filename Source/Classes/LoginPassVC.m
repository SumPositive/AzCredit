//
//  LoginPassVC.m
//  AzCredit
//
//  Created by Sum Positive on 11/06/26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SFHFKeychainUtils.h"
#import "Global.h"
#import "AppDelegate.h"
#import "LoginPassVC.h"


#define TAG_ICON						109
#define TAG_LOGINPASS			118
#define TAG_MSG1						127
#define TAG_MSG2						136


@implementation LoginPassVC

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
	
	self.view.backgroundColor = [UIColor colorWithRed:151.0/255.0 
												 green:80.0/255.0 
												  blue:77.0/255.0 
												 alpha:1.0]; // Azukid Color

	//------------------------------------------アイコン
	UIImageView *iv = [[UIImageView alloc] init];
	iv.tag = TAG_ICON;
#ifdef AzPAD
#ifdef AzSTABLE
	[iv setImage:[UIImage imageNamed:@"Icon72s1.png"]];
#else
	[iv setImage:[UIImage imageNamed:@"Icon72Free.png"]];
#endif
#else	
#ifdef AzSTABLE
	[iv setImage:[UIImage imageNamed:@"Icon57s1.png"]];
#else
	[iv setImage:[UIImage imageNamed:@"Icon57.png"]];
#endif
#endif
	[self.view addSubview:iv]; [iv release];
	//------------------------------------------ログイン
	UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(83,120, 154,28)];
	tf.tag = TAG_LOGINPASS;
	tf.borderStyle = UITextBorderStyleRoundedRect;
	tf.placeholder = NSLocalizedString(@"OptLoginPass1 place",nil);
	tf.keyboardType = UIKeyboardTypeASCIICapable;
	tf.secureTextEntry = YES;
	tf.returnKeyType = UIReturnKeyDone;
	tf.delegate = self;			//<UITextFieldDelegate>
	[self.view addSubview:tf]; [tf release];
	//------------------------------------------■注意■
	UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(34, 170, 266, 80)];
	lb.tag = TAG_MSG1;
	lb.text = NSLocalizedString(@"LoginPass Attention",nil);
	lb.numberOfLines = 4;
	lb.textAlignment = UITextAlignmentLeft;
	lb.textColor = [UIColor whiteColor];
	lb.backgroundColor = [UIColor clearColor]; //背景透明
#ifdef AzPAD
	lb.font = [UIFont systemFontOfSize:18];
#else
	lb.font = [UIFont systemFontOfSize:12];
#endif
	[self.view addSubview:lb]; [lb release];	
	//------------------------------------------パスワードを忘れた場合
	lb = [[UILabel alloc] initWithFrame:CGRectMake(34, 270, 266, 120)];
	lb.tag = TAG_MSG2;
	lb.text = NSLocalizedString(@"LoginPass Lost",nil);
	lb.numberOfLines = 7;
	lb.textAlignment = UITextAlignmentLeft;
	lb.textColor = [UIColor whiteColor];
	lb.backgroundColor = [UIColor clearColor]; //背景透明
#ifdef AzPAD
	lb.font = [UIFont systemFontOfSize:18];
#else
	lb.font = [UIFont systemFontOfSize:12];
#endif
	[self.view addSubview:lb]; [lb release];	

}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// 画面表示された直後に呼び出される
- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	//viewWillAppearでキーを表示すると画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
	[[self.view viewWithTag:TAG_LOGINPASS] becomeFirstResponder];  //フォーカス＆キーボード表示
}

#pragma mark  View - Rotate

- (void)viewDesign:(UIInterfaceOrientation)toInterfaceOrientation 
{
	float fx, fy, fwid,fhi;

#ifdef AzPAD
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
		fx = 768.0 / 2.0;
	} else {
		fx = 1024.0 / 2.0;
	}
	fy = 140;
#else
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
		fx = 320 / 2.0;
		fy = 40; // タテ	
	} else {
		fx = 480 / 2.0;
		fy = 10;	// ヨコ	
	}
#endif

	id obj = [self.view viewWithTag:TAG_ICON];
#ifdef AzPAD
	fwid = 72;
#else
	fwid = 57;
#endif
	[obj setFrame:CGRectMake(fx-fwid/2.0, fy, fwid,fwid)];

	fy += (fwid + 20);

	obj = [self.view viewWithTag:TAG_LOGINPASS];
	fwid = 154;
	[obj setFrame:CGRectMake(fx-fwid/2.0, fy, fwid,28)];

	fy += 50;

#ifdef AzPAD
	fwid = 500;
	fhi = 100;
#else
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
	{	// タテ
		fwid = 266;
		fhi = 60;
	} else {		// ヨコ
		fwid = 400;
		fhi = 50;
	}
#endif
	obj = [self.view viewWithTag:TAG_MSG1];
	[obj setFrame:CGRectMake(fx-fwid/2.0, fy, fwid,fhi)];
	fy += (fhi + 20);
	obj = [self.view viewWithTag:TAG_MSG2];
	[obj setFrame:CGRectMake(fx-fwid/2.0, fy, fwid,fhi*2)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self viewDesign:toInterfaceOrientation]; // cell生成の後
}


//--------------------------------------<UITextFieldDelegate>
// キーボードのリターンキーを押したときに呼ばれる
- (BOOL)textFieldShouldReturn:(UITextField *)sender 
{
	if (sender.tag==TAG_LOGINPASS) 
	{
		// KeyChainから保存しているパスワードを取得する
		NSError *error; // nilを渡すと異常終了するので注意
		NSString *pass = [SFHFKeychainUtils getPasswordForUsername:GD_KEY_LOGINPASS
													andServiceName:GD_PRODUCTNAME error:&error];
		if (error) {
			alertBox(NSLocalizedString(@"OptLoginPass Error",nil), 
					 [error localizedDescription],
					 NSLocalizedString(@"Roger",nil));
			return YES;
		}
		[sender resignFirstResponder];
		if ([pass isEqualToString:sender.text]) {
			// OK
			[self dismissModalViewControllerAnimated:YES];
//			MbLoginShow = NO;
			//[MviewLogin removeFromSuperview];  	self.windowへaddSubviewしてrelease済みである
			//MviewLogin = nil;　　　バックグランド中も有効、self.windowが破棄されるまで有効のまま残す
		}
		else {
			// NG
		}
		sender.text = @""; // 次回のためクリアしておく
	}
	return YES;
}

@end
