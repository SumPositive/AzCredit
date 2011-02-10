//
//  CalcView.m
//
//  Created by 松山 和正 on 10/01/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "CalcView.h"

@interface CalcView (PrivateMethods)
@end

@implementation CalcView
@synthesize Rlabel;
@synthesize Rentity;
@synthesize RzKey;

- (void)dealloc {
	[RzKey release];
	[Rentity release];
	[Rlabel release];
    [super dealloc];
}

/*
static UIColor *MpColorBlue(float percent) {
	float red = percent * 255.0f;
	float green = (red + 20.0f) / 255.0f;
	float blue = (red + 45.0f) / 255.0f;
	if (green > 1.0) green = 1.0f;
	if (blue > 1.0f) blue = 1.0f;
	
	return [UIColor colorWithRed:percent green:green blue:blue alpha:0.5f]; // 背景
}*/

- (void)drawRect:(CGRect)rect {
    // Drawing code
	//self.userInteractionEnabled = YES; //タッチの可否  どこでもDone
}

- (id)initWithFrame:(CGRect)rect 
{
	MbShow = NO;

	// アニメションの開始位置
	
	//rect.origin.y = 20.0f - rect.size.height;
	rect.origin.y = rect.size.height; // 最初、下部に隠れている状態
									// ↓
	if (!(self = [super initWithFrame:rect])) return self;

	//float f = self.frame.size.width;
	
	// [self setAlpha:0.5f]; 前景は1.0
	//[self setBackgroundColor: MpColorBlue(0.3f)];
	self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0]; // 背景透明
	
	self.userInteractionEnabled = YES; //タッチの可否  どこでもDone
	
	//------------------------------------------電卓背景画像
	UIImageView *iv = [[UIImageView alloc] init];
	[iv setImage:[UIImage imageNamed:@"Calc-Back.png"]];
	iv.tag = 91;
	[self addSubview:iv]; [iv release];
	//------------------------------------------
	UIButton *bu;

	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag =  1;	[bu setTitle:@"1" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag =  2;	[bu setTitle:@"2" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag =  3;	[bu setTitle:@"3" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag =  4;	[bu setTitle:@"4" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag =  5;	[bu setTitle:@"5" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag =  6;	[bu setTitle:@"6" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag =  7;	[bu setTitle:@"7" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag =  8;	[bu setTitle:@"8" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag =  9;	[bu setTitle:@"9" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = 10;	[bu setTitle:@"0" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = 11;	[bu setTitle:@"00" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = -1;	[bu setTitle:NSLocalizedString(@"Clear",nil) forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:14];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = -2;	[bu setTitle:NSLocalizedString(@"Back",nil) forState:UIControlStateNormal];	
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:14];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = -3;	[bu setTitle:@"＋／−" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:14];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	UILabel *lb = [[UILabel alloc] init];
	lb.text = NSLocalizedString(@"Calc Done",nil);
	lb.textAlignment = UITextAlignmentCenter;
	lb.backgroundColor = [UIColor clearColor];
	lb.textColor = [UIColor blueColor];
	lb.font = [UIFont systemFontOfSize:16];
	lb.tag = 92;
	[self addSubview:lb]; [lb release];

	
	[self viewDesign:self.bounds]; // コントロール配置

	// Calc 初期化
	MzCalc = [[NSMutableString alloc] init];

    return self;
}

- (void)buttonCalc:(UIButton *)button
{
	AzLOG(@"[%@](%d)", button.titleLabel.text, (int)button.tag);

	if (0 <= button.tag && button.tag <= 11 && [MzCalc length] < 8) { // 99999999, -9999999 Over
		[MzCalc appendString:button.titleLabel.text];
	}
	else {
		// Functions
		switch (button.tag) {
			case -1: { // AC
				[MzCalc setString:@""]; // All Clear
			} break;
			case -2: { // BS
				int iLen = [MzCalc length];
				if (0 < iLen) {
					[MzCalc deleteCharactersInRange:NSMakeRange(iLen-1, 1)]; 
				}
			} break;
			case -3: { // +/-
				if ([MzCalc hasPrefix:@"-"]) {  // 半角[-]であることに注意！
					[MzCalc deleteCharactersInRange:NSMakeRange(0, 1)]; // 先頭の[-]をトル
				} else {
					[MzCalc insertString:@"-" atIndex:0]; // 先頭に[-]を挿入する
				}
			} break;
			case -9: { // Done
				[self save];
				[self hide];
				return;
			} break;
		}
	}

	Rlabel.tag = [MzCalc integerValue]; // Rlabel.tag にはCalc入力された数値(long)を記録する
	if (Rlabel.tag <= 0) {
		Rlabel.textColor = [UIColor blueColor];
	} else {
		Rlabel.textColor = [UIColor blackColor];
	}
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	Rlabel.text = [formatter stringFromNumber:[NSNumber numberWithInteger:Rlabel.tag]];
	[formatter release];
}


/***** UIView には回転サピートは無い！！！
// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES; // この方向だけは常に許可する
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	[self viewDesign:self.bounds]; // コントロール配置
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	CGRect rect;
	rect.origin = CGPointMake(0,0);
	
	if (orientation == UIInterfaceOrientationLandscapeLeft OR orientation == UIInterfaceOrientationLandscapeRight) {
		// ヨコ
		rect.size = CGSizeMake(480, 300);
	} else {
		// タテ
		rect.size = CGSizeMake(320, 460);
	}
	[self viewDesign:rect]; // コントロール配置
}
*/


- (void)viewDesign:(CGRect)rect 
{
	//CGRect rect = self.bounds;
//	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//	CGRect rect = appDelegate.window.bounds;

	if (rect.size.width < rect.size.height)
	{	// タテ
		float fWidth = 280;
		float fHeight = GD_KeyboardHeightPortrait + 44;
		float fLeft = (rect.size.width - fWidth) / 2;
		float fTop = rect.size.height - 5 - fHeight;
		float fWaku = 12;		// 枠の幅
		float fGap = 3;		// ボタン間隔
		float fxButtons = 3;
		float fyButtons = 5;
		float fBuWidth = (fWidth - fWaku*2 - fGap *(fxButtons-1)) / fxButtons;
		float fBuHeight = (fHeight - fWaku*2 - fGap *(fyButtons-1)) / fyButtons;
		
		// 回転によるリサイズ
		UIImageView *iv = (UIImageView *)[self viewWithTag:91];
		iv.frame = CGRectMake(fLeft, fTop, fWidth, fHeight);
		//------------------------------------------------------------------------Line 1
		float fx = fLeft + fWaku;
		float fy = fTop + fWaku;
		UIButton *bu;
		bu = (UIButton *)[self viewWithTag:-1]; // Clear
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:-2]; // Back
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:-3]; // +/-
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		
		//------------------------------------------------------------------------Line 2
		fx = fLeft + fWaku;
		fy += (fBuHeight + fGap);
		bu = (UIButton *)[self viewWithTag:7];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:8];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:9];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		
		//------------------------------------------------------------------------Line 3
		fx = fLeft + fWaku;
		fy += (fBuHeight + fGap);
		bu = (UIButton *)[self viewWithTag:4];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:5];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:6];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		
		//------------------------------------------------------------------------Line 4
		fx = fLeft + fWaku;
		fy += (fBuHeight + fGap);
		bu = (UIButton *)[self viewWithTag:1];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:2];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:3];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		
		//------------------------------------------------------------------------Line 5
		fx = fLeft + fWaku;
		fy += (fBuHeight + fGap);
		bu = (UIButton *)[self viewWithTag:10]; // [0]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:11]; // [00]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		UILabel *lb = (UILabel *)[self viewWithTag:92]; // [Done]
		lb.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
	}
	else {	// ヨコ
		float fWidth = 440;
		float fHeight = GD_KeyboardHeightLandscape;
		float fLeft = (rect.size.width - fWidth) / 2;
		float fTop = rect.size.height - 5 - fHeight;
		float fWaku = 12;		// 枠の幅
		float fGap = 3;		// ボタン間隔
		float fxButtons = 5;
		float fyButtons = 3;
		float fBuWidth = (fWidth - fWaku*2 - fGap *(fxButtons-1)) / fxButtons;
		float fBuHeight = (fHeight - fWaku*2 - fGap *(fyButtons-1)) / fyButtons;
		
		// 回転によるリサイズ
		UIImageView *iv = (UIImageView *)[self viewWithTag:91];
		iv.frame = CGRectMake(fLeft, fTop, fWidth, fHeight);
		//------------------------------------------------------------------------Line 1
		float fx = fLeft + fWaku;
		float fy = fTop + fWaku;
		UIButton *bu;
		bu = (UIButton *)[self viewWithTag:-3]; // +/-
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:7];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:8];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:9];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:-1]; // Clear
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		
		//------------------------------------------------------------------------Line 2
		fx = fLeft + fWaku;
		fy += (fBuHeight + fGap);
		bu = (UIButton *)[self viewWithTag:11]; // [00]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:4];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:5];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:6];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:-2]; // Back
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		
		//------------------------------------------------------------------------Line 3
		fx = fLeft + fWaku;
		fy += (fBuHeight + fGap);
		bu = (UIButton *)[self viewWithTag:10]; // [0]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:1];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:2];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:3];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		UILabel *lb = (UILabel *)[self viewWithTag:92]; // [Done]
		lb.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
	}
}


- (void)save
{
	if (Rentity && RzKey) {
		[Rentity setValue:[NSNumber numberWithInteger:[MzCalc integerValue]]  forKey:RzKey];
	}
}

- (void)hide
{
	// Scroll away the overlay
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationDuration:0.6];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	CGRect rect = [self frame];
	rect.origin.y = 480;  // rect.size.height; 横向きからタテにしても完全に隠れるようにするため。

	[self setFrame:rect];
	
	// Complete the animation
	[UIView commitAnimations];
	MbShow = NO;

	//if ([Rlabel.text integerValue] <= 0) {
	if (Rlabel.tag <= 0) {
		Rlabel.textColor = [UIColor blueColor];
	} else {
		Rlabel.textColor = [UIColor blackColor];
	}
}

- (void)show
{
	// Scroll in the overlay
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.15]; //　出は早く

	CGRect rect = [self frame];
	rect.origin.y = 0;  //rect.size.height - 300;

	[self setFrame:rect];
	
	// Complete the animation
	[UIView commitAnimations];
	MbShow = YES;
	Rlabel.textColor = [UIColor grayColor];
}

- (BOOL)isShow {
	return MbShow;
}


// タッチイベント　　　どこでもDone
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self save];
	[self hide];
}

@end

