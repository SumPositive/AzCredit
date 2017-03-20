//
//  InformationView.m
//  iPack
//
//  Created by 松山 和正 on 10/01/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "InformationView.h"
#import "UIDevice-Hardware.h"


#ifdef AzDEBUG
#import <mach/mach.h> // これを import するのを忘れずに
@interface MemoryInfo : NSObject {
}
+ (struct task_basic_info)used;
@end

@implementation MemoryInfo 
+ (struct task_basic_info)used {
	struct task_basic_info basicInfo;
	mach_msg_type_number_t basicInfoCount = TASK_BASIC_INFO_COUNT;
	
	if (task_info(current_task(), TASK_BASIC_INFO, (task_info_t)&basicInfo, &basicInfoCount) != KERN_SUCCESS) {
		NSLog(@"%s", strerror(errno));
	}
	
    return basicInfo;
}
//return info;
@end
#endif


@interface InformationView (PrivateMethods)
@end

@implementation InformationView

//static UIColor *MpColorBlue(float percent) {
//	float red = percent * 255.0f;
//	float green = (red + 20.0f) / 255.0f;
//	float blue = (red + 45.0f) / 255.0f;
//	if (green > 1.0) green = 1.0f;
//	if (blue > 1.0f) blue = 1.0f;
//	
//	return [UIColor colorWithRed:percent green:green blue:blue alpha:1.0f];
//}



#pragma mark - UUID　-　passCode生成
#import <CommonCrypto/CommonDigest.h>  // MD5
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
NSString *getMacAddress()
{	// cf. http://iphonedevelopertips.com/device/determine-mac-address.html
	int                 mgmtInfoBase[6];
	char                *msgBuffer = NULL;
	size_t              length;
	unsigned char       macAddress[6];
	struct if_msghdr    *interfaceMsgStruct;
	struct sockaddr_dl  *socketStruct;
	NSString            *errorFlag = NULL;
	
	// Setup the management Information Base (mib)
	mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
	mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
	mgmtInfoBase[2] = 0;              
	mgmtInfoBase[3] = AF_LINK;        // Request link layer information
	mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
	
	// With all configured interfaces requested, get handle index
	if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0) 
		errorFlag = @"if_nametoindex failure";
	else
	{
		// Get the size of the data available (store in len)
		if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0) 
			errorFlag = @"sysctl mgmtInfoBase failure";
		else
		{
			// Alloc memory based on above call
			if ((msgBuffer = malloc(length)) == NULL)
				errorFlag = @"buffer allocation failure";
			else
			{
				// Get system information, store in buffer
				if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
					errorFlag = @"sysctl msgBuffer failure";
			}
		}
	}
	
	// Befor going any further...
	if (errorFlag != NULL)
	{
		NSLog(@"Error: %@", errorFlag);
		return errorFlag;
	}
	
	// Map msgbuffer to interface message structure
	interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
	
	// Map to link-level socket structure
	socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
	
	// Copy link layer address data in socket structure to an array
	memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
	
	// Read from char array into a string object, into traditional Mac address format
	//NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
	NSString *macAddressString = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X",
								  macAddress[0], macAddress[1], macAddress[2], 
								  macAddress[3], macAddress[4], macAddress[5]];
	NSLog(@"Mac Address: %@", macAddressString);
	
	// Release the buffer memory
	free(msgBuffer);
	
	return macAddressString;
}

// 「招待パス」生成　　＜＜固有セット＞＞を Version 2.0 にも実装して認証する
#define PASS_SECRET		@"1618AzPayNote1" //＜＜固有セット＞＞
NSString *passCode()
{	// userPass : デバイスID（UDID） & MD5   （UDIDをそのまま利用するのはセキュリティ上好ましくないため）
	//NSString *code = [UIDevice currentDevice].uniqueIdentifier;		// デバイスID文字列 ＜＜iOS5.1以降廃止のため
	// MACアドレスにAzPackList固有文字を絡めて種コード生成
	NSString *code = [NSString stringWithFormat:@"Syukugawa%@%@", getMacAddress(), PASS_SECRET];
	NSLog(@"MAC address: code=%@", code);
	// code を MD5ハッシュ化
	const char *cstr = code.UTF8String;	// C文字列化
	unsigned char ucMd5[CC_MD5_DIGEST_LENGTH];	// MD5結果領域 [16]bytes
	CC_MD5(cstr, (CC_LONG)strlen(cstr), ucMd5);			// MD5生成
	// 16進文字列化 ＜＜ucMd5[0]〜[15]のうち10文字分だけ使用する＞＞
	code = [NSString stringWithFormat: @"%02X%02X%02X%02X%02X",  
			ucMd5[1], ucMd5[5], ucMd5[7], ucMd5[11], ucMd5[13]];	
	AzLOG(@"passCode: code=%@", code);
	return code;
}



#pragma mark - dealloc


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


#pragma mark - Button functions

#ifdef AzSTABLE	//2.0移行のため、招待パスコードをコピーする機能を実装
- (BOOL)canBecomeFirstResponder 
{	// 編集メニュー[Copy]を表示するため、ファーストレスポンダになる
	return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{	// [Copy]利用可能にする
	if (@selector(copy:)==action) return YES;
	return [super canPerformAction:action withSender:sender];
}

- (void)buPassCodeCopy
{	// [Copy]メニュー表示
	if ([self becomeFirstResponder]) {
		UIMenuController *menu = [UIMenuController sharedMenuController];
		//label = [[UILabel alloc] initWithFrame:CGRectMake(150, 240, 150, 40)];
		[menu setTargetRect:CGRectMake(225, 265, 1, 1) inView:self.view];
		[menu setMenuVisible:YES animated:YES];
	}
}

- (void)copy:(id)sender
{	// [Copy]タッチしたときに呼ばれる
	[UIPasteboard generalPasteboard].string = zPassCode_;
}
#endif


- (void)buGoAppStore:(UIButton *)button
{
	//alertBox( NSLocalizedString(@"Contact mail",nil), NSLocalizedString(@"Contact mail msg",nil), @"OK" );
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GoAppStore Paid",nil)
//													message:NSLocalizedString(@"GoAppStore Paid msg",nil)
//												   delegate:self		// clickedButtonAtIndexが呼び出される
//										  cancelButtonTitle:@"Cancel"
//										  otherButtonTitles:@"OK", nil];
//	alert.tag = ALERT_TAG_GoAppStore;
//	[alert show];
	
	UIAlertController *alert = nil;
	alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"GoAppStore Paid",nil)
												message:NSLocalizedString(@"GoAppStore Paid msg",nil)
										 preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
											  style:UIAlertActionStyleCancel
											handler:nil]];
	[alert addAction:[UIAlertAction actionWithTitle:@"OK"
											  style:UIAlertActionStyleDefault
											handler:^(UIAlertAction *action){
#ifdef AzPAD
												//iPad//								クレメモ	 for iPad	457542400
												NSURL *url = [NSURL URLWithString:
															  @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=457542400&mt=8"];
#else
												//iPhone//									クレメモ	432458298
												NSURL *url = [NSURL URLWithString:
															  @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=432458298&mt=8"];
#endif
												[[UIApplication sharedApplication] openURL:url
																				   options:@{}
																		 completionHandler:nil];
											}]];
	[self presentViewController:alert animated:YES completion:nil];
}


- (void)buGoSupportSite:(UIButton *)button
{
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GoSupportSite",nil)
//													message:NSLocalizedString(@"GoSupportSite msg",nil)
//												   delegate:self		// clickedButtonAtIndexが呼び出される
//										  cancelButtonTitle:@"Cancel"
//										  otherButtonTitles:@"OK", nil];
//	alert.tag = ALERT_TAG_GoSupportSite;
//	[alert show];

	UIAlertController *alert = nil;
	alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"GoSupportSite",nil)
												message:NSLocalizedString(@"GoSupportSite msg",nil)
										 preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
											  style:UIAlertActionStyleDefault
											handler:nil]];
	[alert addAction:[UIAlertAction actionWithTitle:@"OK"
											  style:UIAlertActionStyleDefault
											handler:^(UIAlertAction *action){
												// サポートサイトへ
												NSURL *url = [NSURL URLWithString:@"http://paynote.azukid.com/"];
												[[UIApplication sharedApplication] openURL:url
																				   options:@{}
																		 completionHandler:nil];
											}]];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void)buPostComment:(UIButton*)sender
{
	//メール送信可能かどうかのチェック　　＜＜＜MessageUI.framework が必要＞＞＞
    if (![MFMailComposeViewController canSendMail]) {
		//[self setAlert:@"メールが起動出来ません！":@"メールの設定をしてからこの機能は使用下さい。"];
		alertBox( NSLocalizedString(@"Contact NoMail",nil), NSLocalizedString(@"Contact NoMail msg",nil), @"OK" );
        return;
    }
	
	[self hide]; //アニメ競合しないように、先にhideしている。

//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Contact mail",nil)
//													message:NSLocalizedString(@"Contact mail msg",nil)
//												   delegate:self		// clickedButtonAtIndexが呼び出される
//										  cancelButtonTitle:@"Cancel"
//										  otherButtonTitles:@"OK", nil];
//	alert.tag = ALERT_TAG_PostComment;
//	[alert show];

	UIAlertController *alert = nil;
	
	alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Contact mail",nil)
												message:NSLocalizedString(@"Contact mail msg",nil)
										 preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
											  style:UIAlertActionStyleDefault
											handler:nil]];
	[alert addAction:[UIAlertAction actionWithTitle:@"OK"
											  style:UIAlertActionStyleDefault
											handler:^(UIAlertAction *action){
												// Post commens
												MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
												picker.mailComposeDelegate = self;
												// To: 宛先
												NSArray *toRecipients = @[@"post@azukid.com"];
												[picker setToRecipients:toRecipients];
												
												// Subject: 件名
												NSString* zSubj = NSLocalizedString(@"Product Title",nil);
#ifdef AzSTABLE
												//zSubj = [zSubj stringByAppendingString:@" Stable"];
#else
												zSubj = [zSubj stringByAppendingString:@" Free"];
#endif
#ifdef AzPAD
												zSubj = [zSubj stringByAppendingString:@" for iPad"];
#else
												zSubj = [zSubj stringByAppendingString:@" for iPhone"];
#endif
												[picker setSubject:zSubj];
												
												// Body: 本文
												NSString *zVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]; //（リリース バージョン）は、ユーザーに公開した時のレベルを表現したバージョン表記
												NSString *zBuild = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]; //(ビルド回数 バージョン）は、ユーザーに非公開のレベルも含めたバージョン表記
												NSString* zBody = [NSString stringWithFormat:@"Product: %@\n",  zSubj];
#ifdef AzSTABLE
												zBody = [zBody stringByAppendingFormat:@"Version: %@ (%@) Stable\n",  zVersion, zBuild];
#else
												zBody = [zBody stringByAppendingFormat:@"Version: %@ (%@)\n",  zVersion, zBuild];
#endif
												UIDevice *device = [UIDevice currentDevice];
												NSString* deviceID = [device platformString];
												zBody = [zBody stringByAppendingFormat:@"Device: %@   iOS: %@\n",
														 deviceID,
														 [UIDevice currentDevice].systemVersion]; // OSの現在のバージョン
												
												NSArray *languages = [NSLocale preferredLanguages];
												zBody = [zBody stringByAppendingFormat:@"Locale: %@ (%@)\n\n",
														 [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier],
														 languages[0]];
												
												zBody = [zBody stringByAppendingString:NSLocalizedString(@"Contact message",nil)];
												[picker setMessageBody:zBody isHTML:NO];
												
												//Bug//[self hide]; 上のアニメと競合してメール画面が表示されない。これより先にhideするように改めた。
												AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
												//[app.mainController presentModalViewController:picker animated:YES];
												[app.mainController presentViewController:picker animated:YES completion:nil];
											}]];
	[self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Touch

// タッチイベント
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
#ifdef AzSTABLE
	UITouch *tc = [touches anyObject];
	CGPoint tp = [tc locationInView:self.view];
	if (200<tp.y && tp.y<300) return;	// 招待コード [Copy] の範囲を除くため
#endif
	[self hide];
}


#pragma mark - View

//- (id)initWithFrame:(CGRect)rect 
- (instancetype)init
{
	// アニメションの開始位置
	//rect.origin.y = 20.0f - rect.size.height;
									// ↓
	//if (!(self = [super initWithFrame:rect])) return self;
	self = [super init];
	if (!self) return nil;

	float fX = 0, fY = 0;
#ifdef AzPAD
	//self.preferredContentSize = CGSizeMake(320, 510);
	self.navigationItem.hidesBackButton = YES;
	fX = (768 - 320) / 2.0;
	fY = 100;
#endif
	
	// 小豆色 RGB(152,81,75) #98514B
	self.view.backgroundColor = [UIColor colorWithRed:152/255.0f 
												green:81/255.0f 
												 blue:75/255.0f
												alpha:1.0f];
#ifdef AzPAD
	// Popover
#else	
	self.view.userInteractionEnabled = YES; //タッチの可否
#endif

	
	//------------------------------------------アイコン
#ifdef AzPAD
	UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(fX+20, fY+35, 72, 72)];
#ifdef AzSTABLE
	[iv setImage:[UIImage imageNamed:@"Icon72S1.png"]];
#else
	[iv setImage:[UIImage imageNamed:@"Icon72Free.png"]];
#endif
#else	
	UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(fX+20, fY+50, 57, 57)];
#ifdef AzSTABLE
	iv.image = [UIImage imageNamed:@"Icon57s1.png"];
#else
	[iv setImage:[UIImage imageNamed:@"Icon57.png"]];
#endif
#endif
	[self.view addSubview:iv]; 
	
	UILabel *label;
	//------------------------------------------Lable:タイトル
	label = [[UILabel alloc] initWithFrame:CGRectMake(fX+100, fY+40, 200, 40)];
	label.text = NSLocalizedString(@"Product Title",nil);
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:35];
	label.adjustsFontSizeToFitWidth = YES;
	//iOS6//label.minimumFontSize = 16;
	[label setMinimumScaleFactor:16.0/[UIFont labelFontSize]];
	label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
	[self.view addSubview:label]; 
	
	//------------------------------------------Lable:Version
	label = [[UILabel alloc] initWithFrame:CGRectMake(fX+100, fY+80, 200, 45)];
#ifdef AzSTABLE
	NSString *zFree = @"PayNote";
#else	
	NSString *zFree = @"PayNote Free";
#endif
#ifdef AzPAD
	NSString *zDevice = @"for iPad";
#else	
	NSString *zDevice = @"for iPhone";
#endif
	NSString *zVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]; //（リリース バージョン）は、ユーザーに公開した時のレベルを表現したバージョン表記
	label.text = [NSString stringWithFormat:@"%@\n%@\nVersion %@", zFree, zDevice, zVersion];  // Build表示しない
	label.numberOfLines = 3;
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont boldSystemFontOfSize:12];
	[self.view addSubview:label]; 

	//------------------------------------------Lable:Azuki Color
	label = [[UILabel alloc] initWithFrame:CGRectMake(fX+20, fY+110, 100, 77)];
	label.text = @"Azukid Color\n"
				 @"RGB(151,80,77)\n"
				 @"Code#97504D\n"
				 @"Japanese\n"
				 @"tradition\n"
				 @"color.";
	label.numberOfLines = 6;
	label.textAlignment = NSTextAlignmentLeft;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont boldSystemFontOfSize:10];
	[self.view addSubview:label]; 
	
	//------------------------------------------Lable:著作権表示
	label = [[UILabel alloc] initWithFrame:CGRectMake(fX+100, fY+130, 200, 60)];
	label.text =	@"Born on March 26\n"
						@"© 2000-2012  Azukid\n"
						@"Creator Sum Positive\n"
						@"All Rights Reserved.";
	label.numberOfLines = 4;
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont systemFontOfSize:12];
	[self.view addSubview:label]; 	
	
	//------------------------------------------Post Comment
	UIButton *bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:14];
	bu.frame = CGRectMake(fX+20, fY+200, 280,30);
	[bu setTitle:NSLocalizedString(@"Contact mail",nil) forState:UIControlStateNormal];
	[bu addTarget:self action:@selector(buPostComment:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:bu];  //autorelease
	
	//------------------------------------------Go to Support blog.
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	bu.frame = CGRectMake(fX+20, fY+245, 120,26);
	[bu setTitle:NSLocalizedString(@"GoSupportSite",nil) forState:UIControlStateNormal];
	[bu addTarget:self action:@selector(buGoSupportSite:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:bu];  //autorelease
	
#if defined(AzFREE)
	//------------------------------------------Go to App Store
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:10];
	bu.frame = CGRectMake(fX+150, fY+245, 150,26);
	[bu setTitle:NSLocalizedString(@"GoAppStore Paid",nil) forState:UIControlStateNormal];
	[bu addTarget:self action:@selector(buGoAppStore:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:bu];  //autorelease
#endif
	
#ifdef AzSTABLExxxxxxxxxxxxxx
	zPassCode_ = [passCode() retain];  // dealloc:にてrelease
	label = [[UILabel alloc] initWithFrame:CGRectMake(150, 236, 150, 60)];
	label.text = [NSString stringWithFormat:@"%@\n%@\n%@", NSLocalizedString(@"Invitation pass",nil), 
				  zPassCode_, @"< Tap Copy >"];
	label.numberOfLines = 3;
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor blackColor];
	label.backgroundColor = [UIColor redColor]; //背景
	label.font = [UIFont boldSystemFontOfSize:14];
	label.userInteractionEnabled = YES;
	[label addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buPassCodeCopy)]];
	[self.view addSubview:label]; [label release];
#endif

	//------------------------------------------免責
	label = [[UILabel alloc] initWithFrame:CGRectMake(fX+20, fY+300, 300, 50)];
	label.text = NSLocalizedString(@"Disclaimer",nil);
	label.textAlignment = NSTextAlignmentLeft;
	label.numberOfLines = 4;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont fontWithName:@"Courier" size:10];
	[self.view addSubview:label]; 	
	
	//------------------------------------------注意
	label = [[UILabel alloc] initWithFrame:CGRectMake(fX+20, fY+360, 300, 65)];
	label.text = NSLocalizedString(@"Security Alert",nil);
	label.textAlignment = NSTextAlignmentLeft;
	label.numberOfLines = 5;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont fontWithName:@"Courier" size:10];
	[self.view addSubview:label]; 	

	
	//------------------------------------------CLOSE
#ifdef AzPAD
	//label.text = NSLocalizedString(@"Information Open Pad",nil);
#else
	label = [[UILabel alloc] initWithFrame:CGRectMake(fX+20, fY+440, 280, 25)];
	label.text = NSLocalizedString(@"Information Open",nil);
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	[self.view addSubview:label]; 	
#endif

    return self;
}

- (void)loadView
{
    [super loadView];
#ifdef AzPAD
	self.navigationItem.hidesBackButton = YES;
#endif
	self.title = NSLocalizedString(@"Information", nil);
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
#ifdef AzPAD
	//Popover [Menu] button
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (app.barMenu) {
		UIBarButtonItem* buFlexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem* buFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		UIBarButtonItem* buTitle = [[UIBarButtonItem alloc] initWithTitle: self.title  style:UIBarButtonItemStylePlain target:nil action:nil];
		NSMutableArray* items = [[NSMutableArray alloc] initWithObjects: buFixed, app.barMenu, buFlexible, buTitle, buFlexible, nil];
		[buTitle release], buTitle = nil;
		[buFixed release], buFixed = nil;
		[buFlexible release], buFlexible = nil;
		UIToolbar* toolBar = [[UIToolbar alloc] init];
		toolBar.barStyle = UIBarStyleDefault;
		[toolBar setItems:items animated:NO];
		[toolBar sizeToFit];
		self.navigationItem.titleView = toolBar;
		[toolBar release];
		[items release];
	}
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示
#else
	[self.navigationController setToolbarHidden:YES animated:animated]; // ツールバー消す
#endif
	
//	self.title = NSLocalizedString(@"Setting", nil);
}

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifdef AzPAD
	return YES;
#else
	return (interfaceOrientation == UIInterfaceOrientationPortrait); // 正面のみ許可
#endif
}


- (void)hide
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)show
{
	return;
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
    switch (result){
        case MFMailComposeResultCancelled:
            //キャンセルした場合
            break;
        case MFMailComposeResultSaved:
            //保存した場合
            break;
        case MFMailComposeResultSent:
            //送信した場合
			alertBox( NSLocalizedString(@"Contact Sent",nil), NSLocalizedString(@"Contact Sent msg",nil), @"OK" );
            break;
        case MFMailComposeResultFailed:
            //[self setAlert:@"メール送信失敗！":@"メールの送信に失敗しました。ネットワークの設定などを確認して下さい"];
			alertBox( NSLocalizedString(@"Contact Failed",nil), NSLocalizedString(@"Contact Failed msg",nil), @"OK" );
            break;
        default:
            break;
    }
	// [self dismissModalViewControllerAnimated:YES];
	AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
	[app.mainController dismissViewControllerAnimated:YES completion:nil];
}

@end

