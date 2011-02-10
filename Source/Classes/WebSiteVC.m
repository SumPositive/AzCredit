//
//  WebSiteVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/02/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "WebSiteVC.h"


@interface WebSiteVC (PrivateMethods)
- (void)close:(id)sender;
- (void)updateToolBar;
- (void)toolReload;
- (void)toolBack;
- (void)toolForward;
@end

@implementation WebSiteVC

- (void)dealloc 
{
	if (MwebView.loading) [MwebView stopLoading];
	MwebView.delegate = nil;
	//[MwebView release];
	
	// @property (retain)
	
    [super dealloc];
}

- (void)viewDidUnload 
{
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。
	if (MwebView.loading) [MwebView stopLoading];
	MwebView.delegate = nil;
	//[MwebView release];		MwebView = nil;
	// @property (retain) は解放しない。
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
	alert.title = @"didReceiveMemoryWarning" ;
	alert.message = @"WebSiteVC" ;
	[alert addButtonWithTitle:@"OK"];
	[alert show];
	// autorelease
#endif
    [super didReceiveMemoryWarning];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	MwebView = nil;
	
	// Closeボタンを左側に追加する：Web入力中に間違って押したとき確認Alartを出すため。
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithTitle:NSLocalizedString(@"Close",nil)
											  style:UIBarButtonItemStylePlain
											  target:self action:@selector(close:)] autorelease];
	
	MwebView = [[UIWebView alloc] init];
	MwebView.delegate = self;
	MwebView.frame = self.view.bounds;
	//MwebView.autoresizingMask = UIViewAutoresizingFlexibleWidth OR UIViewAutoresizingFlexibleHeight;
	MwebView.autoresizingMask = UIViewAutoresizingNone;
	MwebView.scalesPageToFit = YES;
	//MwebView.clipsToBounds = YES;
	[self.view addSubview:MwebView]; [MwebView release];


	// Tool Bar Button
	UIBarButtonItem *buFlex = [[[UIBarButtonItem alloc] 
								initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
								target:nil action:nil] autorelease];
	MbuBack = [[[UIBarButtonItem alloc] 
								   initWithImage:[UIImage imageNamed:@"WebSite-Back16.png"]
								   style:UIBarButtonItemStylePlain
								   target:self action:@selector(toolBack)] autorelease];
	MbuForward = [[[UIBarButtonItem alloc] 
								initWithImage:[UIImage imageNamed:@"WebSite-Forward16.png"]
								style:UIBarButtonItemStylePlain
								target:self action:@selector(toolForward)] autorelease];
	MbuReload = [[[UIBarButtonItem alloc] 
								initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
								target:self action:@selector(toolReload)] autorelease];
	
	NSArray *aArray = [NSArray arrayWithObjects:  MbuBack, buFlex, MbuReload, buFlex, MbuForward, nil];
	self.navigationController.toolbarHidden = NO;
	[self setToolbarItems:aArray animated:YES];
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
	MwebView.frame = self.view.bounds;
	MwebView.contentMode = UIViewContentModeCenter;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];

	MwebView.frame = self.view.bounds;
	MwebView.contentMode = UIViewContentModeCenter;
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];

	NSURLRequest *request = [NSURLRequest requestWithURL:
							 [NSURL URLWithString:@"http://azpacking.azukid.com/"]];
	[MwebView loadRequest:request];
	[self updateToolBar];
}

// ビューが非表示にされる前や解放される前ににこの処理が呼ばれる
- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	// 画面表示から消す
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF
	
	// ToolBarを消すような操作は不要　（POPで戻るときに消される）
	// ただし、呼び出し側で .hidesBottomBarWhenPushed = YES としていると逆に残ってしまうようだ。
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		// OK
		[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
	}
}

- (void)close:(id)sender 
{
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WebSite Close",nil)
													 message:NSLocalizedString(@"WebSite Close message",nil)
													delegate:self 
										   cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
}

- (void)updateToolBar {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = MwebView.loading;
	MbuBack.enabled = MwebView.canGoBack;
	MbuForward.enabled = MwebView.canGoForward;
}

- (void)webViewDidStartLoad:(UIWebView *)webView 
{
	[self updateToolBar];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self updateToolBar];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self updateToolBar];
}

// URL制限する：無制限ならばレーティング"17+"になってしまう！
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
										navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeOther) 
	{
		NSString *zUrl = [[request URL] absoluteString];
		NSRange range = [zUrl rangeOfString:@"azukid.com" options:NSCaseInsensitiveSearch];
		if (range.location != NSNotFound) return YES;

		range = [zUrl rangeOfString:@"spreadsheets.google.com/embeddedform" options:NSCaseInsensitiveSearch];
		if (range.location != NSNotFound) return YES; // 「ご記帳」埋め込みを通すため
		
		//AzLOG(@"Alert URL=%@", zUrl);

		// 範囲外へのアクセス禁止
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WebSite CAUTION", nil)
														message:NSLocalizedString(@"WebSite CAUTION message", nil)
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		return NO;
	}
	return YES;
}


- (void)toolReload {
	[MwebView reload];
}

- (void)toolBack {
	if (MwebView.canGoBack) [MwebView goBack];
}

- (void)toolForward {
	if (MwebView.canGoForward) [MwebView goForward];
}

@end
