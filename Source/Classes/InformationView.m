//
//  InformationView.m
//  iPack
//
//  Created by 松山 和正 on 10/01/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "InformationView.h"

@interface InformationView (PrivateMethods)
@end

@implementation InformationView

- (void)dealloc {
    [super dealloc];
}

static UIColor *MpColorBlue(float percent) {
	float red = percent * 255.0f;
	float green = (red + 20.0f) / 255.0f;
	float blue = (red + 45.0f) / 255.0f;
	if (green > 1.0) green = 1.0f;
	if (blue > 1.0f) blue = 1.0f;
	
	return [UIColor colorWithRed:percent green:green blue:blue alpha:1.0f];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

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
	UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 57, 57)];
#ifdef AzFREE
	[iv setImage:[UIImage imageNamed:@"Icon57Free.png"]];
#else
	[iv setImage:[UIImage imageNamed:@"Icon57.png"]];
#endif
	[self addSubview:iv]; [iv release];
	
	UILabel *label;
	//------------------------------------------Lable:タイトル
	label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 30)];
	label.text = NSLocalizedString(@"Product Title",nil);
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont boldSystemFontOfSize:25];
	[self addSubview:label]; [label release];
	
	//------------------------------------------Lable:Version
	NSString *zVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]; // "Bundle version"
	label = [[UILabel alloc] initWithFrame:CGRectMake(100, 130, 200, 30)];
#ifdef AzFREE
	label.text = [NSString stringWithFormat:@"Version %@\n%@", zVersion, NSLocalizedString(@"VER FREE",nil)];
#else
	label.text = [NSString stringWithFormat:@"Version %@\n%@", zVersion, NSLocalizedString(@"VER STABLE",nil)];
#endif
	label.numberOfLines = 2;
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont boldSystemFontOfSize:12];
	[self addSubview:label]; [label release];

	//------------------------------------------Lable:Azuki Color
	label = [[UILabel alloc] initWithFrame:CGRectMake(20, 158, 100, 77)];
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
	label = [[UILabel alloc] initWithFrame:CGRectMake(100, 168, 200, 100)];
	label.text =	@"AzukiSoft Project\n"
					@"AzCredit\n"
					@"Born on March 26\n"
					@"© 2000-2011  Azukid\n"
					@"Creator Sum Positive\n"
					@"All Rights Reserved.";
	label.numberOfLines = 6;
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor]; //背景透明
	label.font = [UIFont systemFontOfSize:12];
	[self addSubview:label]; [label release];	
	
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
	label = [[UILabel alloc] initWithFrame:CGRectMake(20, 450, 280, 25)];
	label.text = NSLocalizedString(@"Infomation Open",nil);
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

// タッチイベント
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self hide];
}


@end

