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
//#import "UIDevice-Hardware.h"


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

//#ifdef AzSTABLE	//2.0移行のため、招待パスコードをコピーする機能を実装
//- (BOOL)canBecomeFirstResponder 
//{	// 編集メニュー[Copy]を表示するため、ファーストレスポンダになる
//	return YES;
//}
//
//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{	// [Copy]利用可能にする
//	if (@selector(copy:)==action) return YES;
//	return [super canPerformAction:action withSender:sender];
//}
//
//- (void)buPassCodeCopy
//{	// [Copy]メニュー表示
//	if ([self becomeFirstResponder]) {
//		UIMenuController *menu = [UIMenuController sharedMenuController];
//		//label = [[UILabel alloc] initWithFrame:CGRectMake(150, 240, 150, 40)];
//		[menu setTargetRect:CGRectMake(225, 265, 1, 1) inView:self.view];
//		[menu setMenuVisible:YES animated:YES];
//	}
//}
//
//- (void)copy:(id)sender
//{	// [Copy]タッチしたときに呼ばれる
//	[UIPasteboard generalPasteboard].string = zPassCode_;
//}
//#endif


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
	
//	UIAlertController *alert = nil;
//	alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"GoAppStore Paid",nil)
//												message:NSLocalizedString(@"GoAppStore Paid msg",nil)
//										 preferredStyle:UIAlertControllerStyleAlert];
//	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
//											  style:UIAlertActionStyleCancel
//											handler:nil]];
//	[alert addAction:[UIAlertAction actionWithTitle:@"OK"
//											  style:UIAlertActionStyleDefault
//											handler:^(UIAlertAction *action){
//                                                NSURL *url;
//                                                if (IS_PAD) {
//                                                    //iPad//								クレメモ	 for iPad	457542400
//                                                    url = [NSURL URLWithString:
//                                                                  @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=457542400&mt=8"];
//                                                }else{
//                                                    //iPhone//									クレメモ	432458298
//                                                    url = [NSURL URLWithString:
//                                                                  @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=432458298&mt=8"];
//                                                }
//												[[UIApplication sharedApplication] openURL:url
//																				   options:@{}
//																		 completionHandler:nil];
//											}]];
//	[self presentViewController:alert animated:YES completion:nil];
    
    NSString* zTitle;
    if (button.tag==2) {
        zTitle = NSLocalizedString(@"GoAppStore Stable",nil);
    } else {
        zTitle = NSLocalizedString(@"GoAppStore Beta",nil);
    }

    [AZAlert target:self
         actionRect:button.frame
              title:zTitle
            message:NSLocalizedString(@"GoAppStore msg",nil)
            b1title:@"OK"
            b1style:UIAlertActionStyleDefault
           b1action:^(UIAlertAction * _Nullable action) {
               NSURL *url;
               if (button.tag==2) {
                   url = [NSURL URLWithString:               // クレメモβ  1262724086
                          @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1262724086&mt=8"];
               } else {
                   url = [NSURL URLWithString:               // クレメモ  432458298
                          @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=432458298&mt=8"];
               }

               [[UIApplication sharedApplication] openURL:url
                                                  options:@{}
                                        completionHandler:nil];
           }
            b2title:@"Cancel"
            b2style:UIAlertActionStyleCancel
           b2action:nil
     ];

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

//	UIAlertController *alert = nil;
//	alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"GoSupportSite",nil)
//												message:NSLocalizedString(@"GoSupportSite msg",nil)
//										 preferredStyle:UIAlertControllerStyleActionSheet];
//	[alert addAction:[UIAlertAction actionWithTitle:@"OK"
//											  style:UIAlertActionStyleDefault
//											handler:^(UIAlertAction *action){
//												// サポートサイトへ
//												NSURL *url = [NSURL URLWithString:@"http://paynote.azukid.com/"];
//												[[UIApplication sharedApplication] openURL:url
//																				   options:@{}
//																		 completionHandler:nil];
//											}]];
//    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
//                                              style:UIAlertActionStyleCancel
//                                            handler:nil]];
//	[self presentViewController:alert animated:YES completion:nil];

//    [UICommon alertTitle: NSLocalizedString(@"GoSupportSite",nil)
//              message: NSLocalizedString(@"GoSupportSite msg",nil)
//              b1title: @"OK"
//              b1style: UIAlertActionStyleDefault
//             b1action: ^(UIAlertAction * action){
//                 // サポートサイトへ
//                 NSURL *url = [NSURL URLWithString:@"http://paynote.azukid.com/"];
//                 [[UIApplication sharedApplication] openURL:url
//                                                    options:@{}
//                                          completionHandler:nil];
//             }
//              b2title: @"Cancel"
//              b2style: UIAlertActionStyleCancel
//             b2action: ^(UIAlertAction * action){
//             }
//     ];
    
//    [UICommon alertTitle:NSLocalizedString(@"GoSupportSite",nil)
//                 message:NSLocalizedString(@"GoSupportSite msg",nil)
//                 b1title:@"OK"
//                 b1style:UIAlertActionStyleDefault
//                b1action:^(UIAlertAction * _Nullable action) {
//                    // サポートサイトへ
//                    NSURL *url = [NSURL URLWithString:@"http://paynote.azukid.com/"];
//                    [[UIApplication sharedApplication] openURL:url
//                                                       options:@{}
//                                             completionHandler:nil];
//                }
//                 b2title:@"Cancel"
//                 b2style:UIAlertActionStyleCancel
//                b2action:^(UIAlertAction * _Nullable action) {
//                    
//                }];
    
    [AZAlert target:self
         actionRect:button.frame
              title:NSLocalizedString(@"GoSupportSite",nil)
            message:NSLocalizedString(@"GoSupportSite msg",nil)
            b1title:@"OK"
            b1style:UIAlertActionStyleDefault
           b1action:^(UIAlertAction * _Nullable action) {
               // サポートサイトへ
               NSURL *url = [NSURL URLWithString:@"http://paynote.azukid.com/"];
               [[UIApplication sharedApplication] openURL:url
                                                  options:@{}
                                        completionHandler:nil];
           }
            b2title:@"Cancel"
            b2style:UIAlertActionStyleCancel
           b2action:^(UIAlertAction * _Nullable action) {
               
           }];
    

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

    [AZAlert target:self
         actionRect:sender.frame
              title:NSLocalizedString(@"Contact mail",nil)
            message:NSLocalizedString(@"Contact mail msg",nil)
            b1title:@"OK"
            b1style:UIAlertActionStyleDefault
           b1action:^(UIAlertAction * _Nullable action) {
                 // Post commens
                 MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                 picker.mailComposeDelegate = self;
                 // To: 宛先
                 NSArray *toRecipients = @[@"post@azukid.com"];
                 [picker setToRecipients:toRecipients];
                 
                 // Subject: 件名
                 NSString* zSubj = NSLocalizedString(@"Product Title",nil);
#ifdef AZ_LEGACY
               zSubj = [zSubj stringByAppendingString:@" Legacy"];
#endif
#ifdef AZ_BETA
               zSubj = [zSubj stringByAppendingString:@" Beta"];
#endif
#ifdef AZ_STABLE
               zSubj = [zSubj stringByAppendingString:@" Stable"];
#endif
               [picker setSubject:zSubj];

               
               // Body: 本文
               if (IS_PAD) {
                   zSubj = [zSubj stringByAppendingString:@" (Pad)"];
               }else{
                   zSubj = [zSubj stringByAppendingString:@" (Tel)"];
               }
               NSString* zBody = [NSString stringWithFormat:@"Product: %@\n",  zSubj];

               //（リリース バージョン）は、ユーザーに公開した時のレベルを表現したバージョン表記
               NSString *zVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
               //(ビルド回数 バージョン）は、ユーザーに非公開のレベルも含めたバージョン表記
               NSString *zBuild = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
               zBody = [zBody stringByAppendingFormat:@"Version: %@ (%@)\n",  zVersion, zBuild];

               UIDevice *device = [UIDevice currentDevice];
                 zBody = [zBody stringByAppendingFormat:@"Device: %@  (iOS %@)\n",
                          [self getDeviceType],
                          device.systemVersion]; // OSの現在のバージョン
                 
                 NSArray *languages = [NSLocale preferredLanguages];
                 zBody = [zBody stringByAppendingFormat:@"Locale: %@ (%@)\n\n",
                          [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier],
                          languages[0]];
                 
                 zBody = [zBody stringByAppendingString:NSLocalizedString(@"Contact message",nil)];
                 [picker setMessageBody:zBody isHTML:NO];
                 
                 //Bug//[self hide]; 上のアニメと競合してメール画面が表示されない。これより先にhideするように改めた。
                 AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                 //[app.mainController presentModalViewController:picker animated:YES];
                 if (IS_PAD) {
                     [app.mainSplit presentViewController:picker animated:YES completion:nil];
                 }else{
                     [app.mainNavi presentViewController:picker animated:YES completion:nil];
                 }
             }
              b2title:@"Cancel"
              b2style:UIAlertActionStyleCancel
             b2action:nil
     ];
}

- (NSString *)getDeviceType
{
    char* type = "hw.machine";
    size_t size;
    sysctlbyname(type, NULL, &size, NULL, 0);
    char *answer = malloc(size);
    sysctlbyname(type, answer, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    free(answer);
    return results;
}


#pragma mark - Touch

// タッチイベント
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//#ifdef AzSTABLE
//	UITouch *tc = [touches anyObject];
//	CGPoint tp = [tc locationInView:self.view];
//	if (200<tp.y && tp.y<300) return;	// 招待コード [Copy] の範囲を除くため
//#endif
	[self hide];
}


#pragma mark - View

//- (id)initWithFrame:(CGRect)rect 
//- (instancetype)init
//{
//	// アニメションの開始位置
//	//rect.origin.y = 20.0f - rect.size.height;
//									// ↓
//	//if (!(self = [super initWithFrame:rect])) return self;
//	self = [super init];
//	if (!self) return nil;
//}

- (void)loadView
{
    [super loadView];
    if (IS_PAD) {
        self.navigationItem.hidesBackButton = YES;
    }
    self.title = NSLocalizedString(@"Information", nil);

	float fX = 0, fY = 0;
	if (320.0 < self.view.frame.size.width) {  //iPhone6以降対応
		fX += (self.view.frame.size.width - 320.0) / 2.0;
	}
    if (IS_PAD) {
        //self.preferredContentSize = CGSizeMake(320, 510);
        self.navigationItem.hidesBackButton = YES;
        fX = 70;  //(768 - 320) / 2.0;
        fY = 100;
    }
	
	// 小豆色 RGB(152,81,75) #98514B
	self.view.backgroundColor = [UIColor colorWithRed:152/255.0f 
												green:81/255.0f 
												 blue:75/255.0f
												alpha:1.0f];
    if (IS_PAD) {
        // Popover
    }else{
        self.view.userInteractionEnabled = YES; //タッチの可否
    }
	
	//------------------------------------------アイコン
    UIImageView *iv;
    if (IS_PAD) {
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(fX+20, fY+35, 72, 72)];
    }else{
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(fX+20, fY+50, 57, 57)];
    }
    //iv.image = [UIImage imageNamed:@"Icon57s1"];
    
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    iv.image = [UIImage imageNamed:icon];
    
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
    
    NSString *zDetail;
#ifdef AZ_LEGACY
    NSString *zTitle = @"PayNoteLegacy";
    zDetail = NSLocalizedString(@"Legacy version",nil);
#endif
#ifdef AZ_BETA
    NSString *zTitle = @"PayNoteβ";
    zDetail = NSLocalizedString(@"Beta version",nil);
#endif
#ifdef AZ_STABLE
    NSString *zTitle = @"PayNote";
    zDetail = NSLocalizedString(@"Stable version",nil);
#endif

    //（リリース バージョン）は、ユーザーに公開した時のレベルを表現したバージョン表記
    NSString *zVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];

    label.text = [NSString stringWithFormat:@"%@\nVersion %@\n%@", zTitle, zVersion, zDetail];  // Build表示しない
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
	label.text = @"Copyright 2010\n"
                @"Masakazu.Matsuyama\n"
				@"All Rights Reserved.";
	label.numberOfLines = 3;
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont systemFontOfSize:12];
	[self.view addSubview:label]; 	
	
    UIButton *bu;
    //------------------------------------------Go to Support blog.
    bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bu.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    bu.tintColor = [UIColor lightGrayColor];
    bu.frame = CGRectMake(fX+100, fY+200, 200,25);
    [bu setTitle:NSLocalizedString(@"GoSupportSite",nil) forState:UIControlStateNormal];
    [bu addTarget:self action:@selector(buGoSupportSite:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bu];  //autorelease
    
	//------------------------------------------Post Comment
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    bu.tintColor = [UIColor lightGrayColor];
	bu.frame = CGRectMake(fX+100, fY+230, 200,25);
	[bu setTitle:NSLocalizedString(@"Contact mail",nil) forState:UIControlStateNormal];
	[bu addTarget:self action:@selector(buPostComment:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:bu];  //autorelease
	
	//------------------------------------------Go to App Store: Beta
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    bu.tintColor = [UIColor lightGrayColor];
	bu.frame = CGRectMake(fX+50, fY+260, 250,25);
	[bu setTitle:NSLocalizedString(@"GoAppStore Beta",nil) forState:UIControlStateNormal];
    bu.tag = 1;
	[bu addTarget:self action:@selector(buGoAppStore:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:bu];  //autorelease

    //------------------------------------------Go to App Store: Stable
    bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bu.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    bu.tintColor = [UIColor lightGrayColor];
    bu.frame = CGRectMake(fX+50, fY+290, 250,25);
    [bu setTitle:NSLocalizedString(@"GoAppStore Stable",nil) forState:UIControlStateNormal];
    bu.tag = 2;
    [bu addTarget:self action:@selector(buGoAppStore:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bu];  //autorelease
	
    //------------------------------------------CLOSE
    if (IS_PAD) {
        //label.text = NSLocalizedString(@"Information Open Pad",nil);
    }else{
        label = [[UILabel alloc] initWithFrame:CGRectMake(fX+20, fY+320, 280, 25)];
        label.text = NSLocalizedString(@"Information Open",nil);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor]; //背景透明
        label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        [self.view addSubview:label];
    }

//#ifdef AzSTABLExxxxxxxxxxxxxx
//	zPassCode_ = [passCode() retain];  // dealloc:にてrelease
//	label = [[UILabel alloc] initWithFrame:CGRectMake(150, 236, 150, 60)];
//	label.text = [NSString stringWithFormat:@"%@\n%@\n%@", NSLocalizedString(@"Invitation pass",nil), 
//				  zPassCode_, @"< Tap Copy >"];
//	label.numberOfLines = 3;
//	label.textAlignment = NSTextAlignmentCenter;
//	label.textColor = [UIColor blackColor];
//	label.backgroundColor = [UIColor redColor]; //背景
//	label.font = [UIFont boldSystemFontOfSize:14];
//	label.userInteractionEnabled = YES;
//	[label addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buPassCodeCopy)]];
//	[self.view addSubview:label]; [label release];
//#endif

	//------------------------------------------
    CGRect rc = self.view.bounds;
    rc.origin.x = fX + 20;
    rc.origin.y = fY + 360;
    rc.size.width = 320 - (20 * 2);
    rc.size.height -= (rc.origin.y + 20);
    UITextView* tv = [[UITextView alloc] initWithFrame:rc];
    tv.font = [UIFont fontWithName:@"Courier" size:12];
    tv.backgroundColor = [UIColor clearColor];
    tv.textColor = [UIColor whiteColor];
    tv.selectable = NO;
    [self.view addSubview:tv];
    
//	label = [[UILabel alloc] initWithFrame:rc];
//    label.textAlignment = NSTextAlignmentLeft;
//    label.numberOfLines = 0;
//    label.textColor = [UIColor whiteColor];
//    label.backgroundColor = [UIColor clearColor]; //背景透明
//    label.font = [UIFont fontWithName:@"Courier" size:12];
//    [self.view addSubview:label];
    //------------------------------------------免責
	tv.text = NSLocalizedString(@"Disclaimer",nil);
#ifdef AZ_BETA
    tv.text = [tv.text stringByAppendingString:NSLocalizedString(@"\n\n",nil)];
    tv.text = [tv.text stringByAppendingString:NSLocalizedString(@"DisclaimerBeta",nil)];
#endif
	//------------------------------------------注意
    tv.text = [tv.text stringByAppendingString:NSLocalizedString(@"\n\n",nil)];
    tv.text = [tv.text stringByAppendingString:NSLocalizedString(@"Security Alert",nil)];

	
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    if (IS_PAD) {
        //Popover [Menu] button
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (app.barMenu) {
            UIBarButtonItem* buFlexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem* buFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            UIBarButtonItem* buTitle = [[UIBarButtonItem alloc] initWithTitle: self.title  style:UIBarButtonItemStylePlain target:nil action:nil];
            NSMutableArray* items = [[NSMutableArray alloc] initWithObjects: buFixed, app.barMenu, buFlexible, buTitle, buFlexible, nil];
            UIToolbar* toolBar = [[UIToolbar alloc] init];
            toolBar.barStyle = UIBarStyleDefault;
            [toolBar setItems:items animated:NO];
            [toolBar sizeToFit];
            self.navigationItem.titleView = toolBar;
        }
        [self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示
    }else{
        [self.navigationController setToolbarHidden:YES animated:animated]; // ツールバー消す
    }
	
//	self.title = NSLocalizedString(@"Setting", nil);
}

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (IS_PAD) {
        return YES;
    }else{
        return (interfaceOrientation == UIInterfaceOrientationPortrait); // 正面のみ許可
    }
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
    if (IS_PAD) {
        [app.mainSplit dismissViewControllerAnimated:YES completion:nil];
    }else{
        [app.mainNavi dismissViewControllerAnimated:YES completion:nil];
    }
}

@end

