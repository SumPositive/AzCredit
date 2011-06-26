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

#define TAG_TF_LOGINPASS			901


@implementation LoginPassVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
	//------------------------------------------アイコン
#ifdef AzPAD
	UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-72)/2.0, 35, 72, 72)];
#ifdef AzSTABLE
	[iv setImage:[UIImage imageNamed:@"Icon72s1.png"]];
#else
	[iv setImage:[UIImage imageNamed:@"Icon72Free.png"]];
#endif
#else	
	UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(130, 50, 57, 57)];
#ifdef AzSTABLE
	[iv setImage:[UIImage imageNamed:@"Icon57s1.png"]];
#else
	[iv setImage:[UIImage imageNamed:@"Icon57.png"]];
#endif
#endif
	[self.view addSubview:iv]; [iv release];
	//------------------------------------------ログイン
	UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(83,120, 154,28)];
	tf.borderStyle = UITextBorderStyleRoundedRect;
	tf.placeholder = NSLocalizedString(@"OptLoginPass1 place",nil);
	tf.keyboardType = UIKeyboardTypeASCIICapable;
	tf.secureTextEntry = YES;
	tf.returnKeyType = UIReturnKeyDone;
	tf.delegate = self;			//<UITextFieldDelegate>
	tf.tag = TAG_TF_LOGINPASS;
	[self.view addSubview:tf]; [tf release];
	//------------------------------------------■注意■
	UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(34, 170, 266, 80)];
	lb.text = NSLocalizedString(@"LoginPass Attention",nil);
	lb.numberOfLines = 4;
	lb.textAlignment = UITextAlignmentLeft;
	lb.textColor = [UIColor whiteColor];
	lb.backgroundColor = [UIColor clearColor]; //背景透明
	lb.font = [UIFont systemFontOfSize:12];
	[self.view addSubview:lb]; [lb release];	
	//------------------------------------------パスワードを忘れた場合
	lb = [[UILabel alloc] initWithFrame:CGRectMake(34, 270, 266, 120)];
	lb.text = NSLocalizedString(@"LoginPass Lost",nil);
	lb.numberOfLines = 7;
	lb.textAlignment = UITextAlignmentLeft;
	lb.textColor = [UIColor whiteColor];
	lb.backgroundColor = [UIColor clearColor]; //背景透明
	lb.font = [UIFont systemFontOfSize:12];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


//--------------------------------------<UITextFieldDelegate>
// キーボードのリターンキーを押したときに呼ばれる
- (BOOL)textFieldShouldReturn:(UITextField *)sender 
{
	if (sender.tag==TAG_TF_LOGINPASS) 
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
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
			CGRect rc = MviewLogin.frame;
			rc.origin.y = 500;
			MviewLogin.frame = rc;
			MviewLogin.alpha = 0.3;
			[UIView commitAnimations];
			MbLoginShow = NO;
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
