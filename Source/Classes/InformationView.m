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

#define ALERT_TAG_GoAppStore			28
#define ALERT_TAG_PostComment		37
#define ALERT_TAG_GoSupportSite		46


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

static UIColor *MpColorBlue(float percent) {
	float red = percent * 255.0f;
	float green = (red + 20.0f) / 255.0f;
	float blue = (red + 45.0f) / 255.0f;
	if (green > 1.0) green = 1.0f;
	if (blue > 1.0f) blue = 1.0f;
	
	return [UIColor colorWithRed:percent green:green blue:blue alpha:1.0f];
}


#pragma mark - dealloc

- (void)dealloc {
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


#pragma mark - Button functions

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != 1) return; // Cancel
	// OK
	switch (alertView.tag) 
	{
		case ALERT_TAG_GoAppStore: { // Paid App Store																							 クレメモ	432458298
			NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=432458298&mt=8"];
			[[UIApplication sharedApplication] openURL:url];
		}	break;
		
		case ALERT_TAG_GoSupportSite: {
			NSURL *url = [NSURL URLWithString:@"http://paynote.tumblr.com/"];
			[[UIApplication sharedApplication] openURL:url];
		}	break;
			
		case ALERT_TAG_PostComment: { // Post commens
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			// To: 宛先
			NSArray *toRecipients = [NSArray arrayWithObject:@"PayNote@azukid.com"];
			[picker setToRecipients:toRecipients];
			// Subject: 件名
			NSString* zSubj = [NSString stringWithFormat:@"%@ %@ ", 
							   NSLocalizedString(@"Product Title",nil), 
							   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
#ifdef AzSTABLE
			zSubj = [zSubj stringByAppendingString:@"Stable"];
#else
			zSubj = [zSubj stringByAppendingString:@"Free"];
#endif
			UIDevice *device = [UIDevice currentDevice];
			NSString* deviceID = [device platformString];	
			zSubj = [zSubj stringByAppendingFormat:@" [%@-%@]", 
					 deviceID, 
					 [[ UIDevice currentDevice ] systemVersion]]; // OSの現在のバージョン
			
			[picker setSubject:zSubj];  
			// Body: 本文
			[picker setMessageBody:NSLocalizedString(@"Contact message",nil) isHTML:NO];
			[self hide];
			AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			[app.navigationController presentModalViewController:picker animated:YES];
			[picker release];
		}	break;
	}
}

- (void)buGoAppStore:(UIButton *)button
{
	//alertBox( NSLocalizedString(@"Contact mail",nil), NSLocalizedString(@"Contact mail msg",nil), @"OK" );
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GoAppStore Paid",nil)
													message:NSLocalizedString(@"GoAppStore Paid msg",nil)
												   delegate:self		// clickedButtonAtIndexが呼び出される
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"OK", nil];
	alert.tag = ALERT_TAG_GoAppStore;
	[alert show];
	[alert autorelease];
}

- (void)buGoSupportSite:(UIButton *)button
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GoSupportSite",nil)
													message:NSLocalizedString(@"GoSupportSite msg",nil)
												   delegate:self		// clickedButtonAtIndexが呼び出される
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"OK", nil];
	alert.tag = ALERT_TAG_GoSupportSite;
	[alert show];
	[alert autorelease];
}

-(void)buPostComment:(UIButton*)sender 
{
	//メール送信可能かどうかのチェック　　＜＜＜MessageUI.framework が必要＞＞＞
    if (![MFMailComposeViewController canSendMail]) {
		//[self setAlert:@"メールが起動出来ません！":@"メールの設定をしてからこの機能は使用下さい。"];
		alertBox( NSLocalizedString(@"Contact NoMail",nil), NSLocalizedString(@"Contact NoMail msg",nil), @"OK" );
        return;
    }
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Contact mail",nil)
													message:NSLocalizedString(@"Contact mail msg",nil)
												   delegate:self		// clickedButtonAtIndexが呼び出される
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"OK", nil];
	alert.tag = ALERT_TAG_PostComment;
	[alert show];
	[alert autorelease];
}

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
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[app.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark - Touch

// タッチイベント
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self hide];
}


#pragma mark - View

- (id)initWithFrame:(CGRect)rect 
{
	// アニメションの開始位置
	rect.origin.y = 20.0f - rect.size.height;
									// ↓
	if (!(self = [super initWithFrame:rect])) return self;

	[self setAlpha:0.85f]; // Information時
	[self setBackgroundColor: MpColorBlue(0.15f)];
	
	// 小豆色 RGB(152,81,75) #98514B  ＜＜しかし全面には不適切だ＞＞
	//self.backgroundColor = [UIColor colorWithRed:152/255.0f green:81/255.0f blue:75/255.0f alpha:1.0f];

	self.userInteractionEnabled = YES; //タッチの可否
	
	//------------------------------------------アイコン
	UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 50, 57, 57)];
#ifdef AzSTABLE
	[iv setImage:[UIImage imageNamed:@"Icon57s1.png"]];
#else
	[iv setImage:[UIImage imageNamed:@"Icon57.png"]];
#endif
	[self addSubview:iv]; [iv release];
	
	UILabel *label;
	//------------------------------------------Lable:タイトル
	label = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 200, 30)];
	label.text = NSLocalizedString(@"Product Title",nil);
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	//label.font = [UIFont boldSystemFontOfSize:25];
	label.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:25];
	[self addSubview:label]; [label release];
	
	//------------------------------------------Lable:Version
	NSString *zVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]; // "Bundle version"
	label = [[UILabel alloc] initWithFrame:CGRectMake(100, 80, 200, 30)];
#ifdef AzSTABLE
	label.text = [NSString stringWithFormat:@"Version %@\nStable", zVersion];
#else
	label.text = [NSString stringWithFormat:@"Version %@\nFree", zVersion];
#endif
	label.numberOfLines = 2;
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont boldSystemFontOfSize:12];
	[self addSubview:label]; [label release];

	//------------------------------------------Lable:Azuki Color
	label = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 100, 77)];
	label.text = @"Azukid Color\n"
				 @"RGB(151,80,77)\n"
				 @"Code#97504D\n"
				 @"Japanese\n"
				 @"tradition\n"
				 @"color.";
	label.numberOfLines = 6;
	label.textAlignment = UITextAlignmentLeft;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont boldSystemFontOfSize:10];
	[self addSubview:label]; [label release];
	
	//------------------------------------------Lable:著作権表示
	label = [[UILabel alloc] initWithFrame:CGRectMake(100, 120, 200, 80)];
	label.text =	@"PayNote\n"
						@"Born on March 26\n"
						@"© 2000-2011  Azukid\n"
						@"Creator Sum Positive\n"
						@"All Rights Reserved.";
	label.numberOfLines = 5;
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont systemFontOfSize:12];
	[self addSubview:label]; [label release];	
	
	//------------------------------------------Go to Support blog.
	UIButton *bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	bu.frame = CGRectMake(20, 210, 120,26);
	[bu setTitle:NSLocalizedString(@"GoSupportSite",nil) forState:UIControlStateNormal];
	[bu addTarget:self action:@selector(buGoSupportSite:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:bu];  //autorelease
	
#if defined(AzFREE) && !defined(AzPAD)
	//------------------------------------------Go to App Store
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:10];
	bu.frame = CGRectMake(150, 210, 150,26);
	[bu setTitle:NSLocalizedString(@"GoAppStore Paid",nil) forState:UIControlStateNormal];
	[bu addTarget:self action:@selector(buGoAppStore:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:bu];  //autorelease
#endif
	
	//------------------------------------------Post Comment
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:14];
	bu.frame = CGRectMake(20, 255, 280,30);
	[bu setTitle:NSLocalizedString(@"Contact mail",nil) forState:UIControlStateNormal];
	[bu addTarget:self action:@selector(buPostComment:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:bu];  //autorelease
	
	//------------------------------------------免責
	label = [[UILabel alloc] initWithFrame:CGRectMake(20, 300, 300, 50)];
	label.text = NSLocalizedString(@"Disclaimer",nil);
	label.textAlignment = UITextAlignmentLeft;
	label.numberOfLines = 4;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont fontWithName:@"Courier" size:10];
	[self addSubview:label]; [label release];	
	
	//------------------------------------------注意
	label = [[UILabel alloc] initWithFrame:CGRectMake(20, 360, 300, 65)];
	label.text = NSLocalizedString(@"Security Alert",nil);
	label.textAlignment = UITextAlignmentLeft;
	label.numberOfLines = 5;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont fontWithName:@"Courier" size:10];
	[self addSubview:label]; [label release];	

	
	//------------------------------------------CLOSE
	label = [[UILabel alloc] initWithFrame:CGRectMake(20, 440, 280, 25)];
#ifdef AzPAD
	label.text = NSLocalizedString(@"Infomation Open Pad",nil);
#else
	label.text = NSLocalizedString(@"Infomation Open",nil);
#endif
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	[self addSubview:label]; [label release];	

    return self;
}

/*　UIViewでは無効　なので、親側から回転したらhideが送られるようにした。
// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait; // 正面のみ許可
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	[self hide]; // 回転が始まるとhideする
}
*/

/*
- (void)openWebSite
{
	UIWebView *web = [[UIWebView alloc] init];
	web.frame = self.bounds;
	web.autoresizingMask = UIViewAutoresizingFlexibleWidth OR UIViewAutoresizingFlexibleHeight;
	web.scalesPageToFit = YES;
	[self addSubview:web]; [web release];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://azpacking.azukid.com/"]];
	[web loadRequest:request];
}
*/

- (void)hide
{
	// Scroll away the overlay
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	
	CGRect rect = [self frame];
	rect.origin.y = -10.0f - rect.size.height;
	[self setFrame:rect];
	
	// Complete the animation
	[UIView commitAnimations];
}

- (void)show
{
	// Scroll in the overlay
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	
	CGRect rect = [self frame];
	rect.origin.y = 0.0f;
	[self setFrame:rect];
	
	// Complete the animation
	[UIView commitAnimations];
}


@end

