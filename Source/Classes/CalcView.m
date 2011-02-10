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
- (NSString *)zRpnCalc:(NSString *)zCalcString;	// 計算式 ⇒ 逆ポーランド記法(Reverse Polish Notation) ⇒ 答え
@end

@implementation CalcView
@synthesize Rlabel;
@synthesize Rentity;
@synthesize RzKey;
@synthesize AparentTableView;

- (void)dealloc {
	[MzCalc release];
	
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

	self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0]; // 背景透明
	
	self.userInteractionEnabled = YES; //タッチの可否  どこでもDone
	
	//------------------------------------------電卓背景画像
	UIImageView *iv = [[UIImageView alloc] init];
	[iv setImage:[UIImage imageNamed:@"Calc-Back.png"]];
	iv.tag = 91;
	[self addSubview:iv]; [iv release];
	//------------------------------------------
	MlbCalc = [[UILabel alloc] init];
	//lb.tag = 92;
	MlbCalc.textAlignment = UITextAlignmentCenter;
	MlbCalc.backgroundColor = [UIColor clearColor];
	MlbCalc.textColor = [UIColor whiteColor];
	MlbCalc.font = [UIFont systemFontOfSize:26];
	MlbCalc.text = @"";  //@"123456.001÷5×2+3.200001";
	MlbCalc.adjustsFontSizeToFitWidth = YES;
	MlbCalc.minimumFontSize = 8;
	MlbCalc.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	[self addSubview:MlbCalc]; [MlbCalc release];
	

	//------------------------------------------
	UIButton *bu;

	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag =  1;	[bu setTitle:@"1" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	[bu becomeFirstResponder];
	
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
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:24];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = 12;	[bu setTitle:@"000" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:20];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = 13;	[bu setTitle:@"." forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	//----------------------------------------------------------------------[0.3]演算子
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = 30;	[bu setTitle:@"+" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:30];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = 31;	[bu setTitle:@"-" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = 32;	[bu setTitle:@"×" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:30];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = 33;	[bu setTitle:@"÷" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:30];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = 34;	[bu setTitle:@"(" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:26];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = 35;	[bu setTitle:@")" forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:26];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	//--------------------------------------------------------------------------------Function
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = -1;	[bu setTitle:@"AC" forState:UIControlStateNormal]; //NSLocalizedString(@"Clear",nil)
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:14];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = -2;	[bu setTitle:@"BS" forState:UIControlStateNormal];	//NSLocalizedString(@"Back",nil)
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:14];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = -3;	[bu setTitle:NSLocalizedString(@"Including tax",nil) forState:UIControlStateNormal]; // T(税込)
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため

	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = -4;	[bu setTitle:NSLocalizedString(@"Net of tax",nil) forState:UIControlStateNormal]; // N(税抜)
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため

	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = -5;	[bu setTitle:NSLocalizedString(@"Rounding",nil) forState:UIControlStateNormal]; // R(四捨五入)
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	
	
	bu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bu.tag = -9;	[bu setTitle:NSLocalizedString(@"Calc Done",nil) forState:UIControlStateNormal];
	bu.titleLabel.font = [UIFont boldSystemFontOfSize:14];
	[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:bu]; //[bu release]; autoreleaseされるため
	// 演算ボタンを押せば -8 [=] に変化する
	
	[self viewDesign:self.frame];  //.bounds]; // コントロール配置

	// Calc 初期化
	MzCalc = [[NSMutableString alloc] init];
	MdRegister = 0.0;
	MiFunc = 0;
	
    return self;
}

- (void)buttonCalc:(UIButton *)button
{
	AzLOG(@"[%@](%d)", button.titleLabel.text, (int)button.tag);

	if (0 <= button.tag && [MzCalc length] < 50) { // 99999999, -9999999 Over
		//if (button.tag == 12) {	//[.]
		//	NSRange rg = [MzCalc rangeOfString:@"."];
		//	if (rg.location != NSNotFound) return; // 既に[.]が含まれているからパスする
		//}
		[MzCalc appendString:button.titleLabel.text];
		
		if (30 <= button.tag) {	//演算子ボタンが押された
			// [Done] ⇒ [=]
			UIButton *bu = (UIButton *)[self viewWithTag:-9]; //[Done]
			if (bu) {
				[bu setTitle:@"=" forState:UIControlStateNormal];
				bu.titleLabel.font = [UIFont boldSystemFontOfSize:26];
				bu.tag = -8; //[=]
			}
		}
	}
	else {
		// Functions
		switch (button.tag) {
			case -1: { // [Clear]
				[MzCalc setString:@""]; // All Clear
				// [=] ⇒ [Done]
				UIButton *bu = (UIButton *)[self viewWithTag:-8]; //[=]
				if (bu) {
					[bu setTitle:NSLocalizedString(@"Calc Done",nil) forState:UIControlStateNormal];
					bu.titleLabel.font = [UIFont boldSystemFontOfSize:14];
					bu.tag = -9; //[Done]
				}
			} break;
			case -2: { // [Back]
				int iLen = [MzCalc length];
				if (0 < iLen) {
					[MzCalc deleteCharactersInRange:NSMakeRange(iLen-1, 1)]; 
				}
				if (iLen <= 1) {
					// [=] ⇒ [Done]
					UIButton *bu = (UIButton *)[self viewWithTag:-8]; //[=]
					if (bu) {
						[bu setTitle:NSLocalizedString(@"Calc Done",nil) forState:UIControlStateNormal];
						bu.titleLabel.font = [UIFont boldSystemFontOfSize:14];
						bu.tag = -9; //[Done]
					}
				}
			} break;
			case -3: { // [税込み]
				if ([self viewWithTag:-9]) {
					// [Done] 即計算
					[MzCalc setString:[NSString stringWithFormat:@"%.3f", [MzCalc doubleValue] * 1.05]];
				} else {
					// [=] 計算式に関数挿入
					[MzCalc setString:[NSString stringWithFormat:@"T(%@)", MzCalc]];
				}
			} break;
			case -4: { // [税抜き]
				if ([self viewWithTag:-9]) {
					// [Done] 即計算
					[MzCalc setString:[NSString stringWithFormat:@"%.3f", [MzCalc doubleValue] / 1.05]];
				} else {
					// [=] 計算式に関数挿入
					[MzCalc setString:[NSString stringWithFormat:@"N(%@)", MzCalc]];
				}
			} break;
			case -5: { // [四捨五入]
				if ([self viewWithTag:-9]) {
					// [Done] 即計算
					[MzCalc setString:[NSString stringWithFormat:@"%.0f", round([MzCalc doubleValue])]];
				} else {
					// [=] 計算式に関数挿入
					[MzCalc setString:[NSString stringWithFormat:@"R(%@)", MzCalc]];
				}
			} break;
			case -8: { // [=]
				// MzCalc 計算式を処理して答えを改めて MzCalc にセットする
				NSString *zAns = [[NSString alloc] initWithString:[self zRpnCalc:MzCalc]];
				if (0 < [zAns length]) {
					[MzCalc setString:zAns];
					// 
					if (AzMAX_AMOUNT < fabs([MzCalc doubleValue])) {
						Rlabel.text = @"Over";
					} else {
						NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
						[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
						Rlabel.text = [formatter stringFromNumber:[NSNumber numberWithDouble:[MzCalc integerValue]]];
						[formatter release];
					}
					// [=] ⇒ [Done]
					UIButton *bu = (UIButton *)[self viewWithTag:-8]; //[=]
					if (bu) {
						[bu setTitle:NSLocalizedString(@"Calc Done",nil) forState:UIControlStateNormal];
						bu.titleLabel.font = [UIFont boldSystemFontOfSize:14];
						bu.tag = -9; //[Done]
					}
				}
				[zAns release];
			} break;
			case -9: { // [Dome]
				if ([MzCalc length] <= 0) {
					// Rlabel.text 変更なし
				} 
				else if (AzMAX_AMOUNT < fabs([MzCalc doubleValue])) {
					Rlabel.text = @"Over";
				} 
				else {
					NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
					[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
					Rlabel.text = [formatter stringFromNumber:[NSNumber numberWithDouble:[MzCalc integerValue]]];
					[formatter release];
				}
				[self save];
				[self hide];
			} break;
		}
	}


	//Rlabel.tag = [MzCalc integerValue]; // Rlabel.tag にはCalc入力された数値(long)を記録する
	//if (Rlabel.tag <= 0) {
/*	if ([MzCalc doubleValue] <= 0.0) {
		Rlabel.textColor = [UIColor blueColor];
	} else {
		Rlabel.textColor = [UIColor blackColor];
	}*/
/*	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	//Rlabel.text = [formatter stringFromNumber:[NSNumber numberWithInteger:Rlabel.tag]];
	Rlabel.text = [formatter stringFromNumber:[NSNumber numberWithDouble:[MzCalc doubleValue]]];
	[formatter release];*/

//	Rlabel.text = MzCalc;

	MlbCalc.text = MzCalc;
}


/***** UIView には回転は無い！！！
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

	AzLOG(@"viewDesign:rect (x,y)=(%f,%f) (w,h)=(%f,%f)", rect.origin.x,rect.origin.y, rect.size.width,rect.size.height);

	if (rect.size.width < rect.size.height)
	{	// タテ
		float fLabelHeight = 30; // 上下の余白を含む高さ
		float fWidth = 310;
		float fLeft = (rect.size.width - fWidth) / 2;
		float fTop = 40;
		float fHeight = rect.size.height - fTop - 64;
		float fWaku = 12;		// 枠の幅
		float fGap = 2;		// ボタン間隔
		float fxButtons = 5;
		float fyButtons = 5;
		float fBuWidth = (fWidth - fWaku*2 - fGap *(fxButtons-1)) / fxButtons;
		float fBuHeight = (fHeight - fWaku*2 - fLabelHeight - fGap *(fyButtons-1)) / fyButtons;
		
		// 回転によるリサイズ
		UIImageView *iv = (UIImageView *)[self viewWithTag:91];
		iv.frame = CGRectMake(fLeft, fTop, fWidth, fHeight);

		//UILabel *lb = (UILabel *)[self viewWithTag:92];
		MlbCalc.frame = CGRectMake(fLeft+fWaku*2, fTop+fWaku-2, fWidth-fWaku*4, fLabelHeight-fGap);

		//------------------------------------------------------------------------Line 1
		float fy = fTop + fWaku + fLabelHeight;
		float fx = fLeft + fWaku;
		UIButton *bu;
		bu = (UIButton *)[self viewWithTag:-1]; // Clear
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:-2]; // Back
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:-3]; // [税込]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:-4]; // [税抜]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:-5]; // [四捨五入]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		
		//------------------------------------------------------------------------Line 2
		fy += (fBuHeight + fGap);
		fx = fLeft + fWaku;
		bu = (UIButton *)[self viewWithTag:7];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:8];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:9];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:34]; // [(]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:35]; // [)]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		
		//------------------------------------------------------------------------Line 3
		fy += (fBuHeight + fGap);
		fx = fLeft + fWaku;
		bu = (UIButton *)[self viewWithTag:4];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:5];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:6];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:31]; // [-]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:33]; // [÷]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		
		//------------------------------------------------------------------------Line 4
		fy += (fBuHeight + fGap);
		fx = fLeft + fWaku;
		bu = (UIButton *)[self viewWithTag:1];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:2];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:3];
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:30]; // [+]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:32]; // [×]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		
		//------------------------------------------------------------------------Line 5
		fy += (fBuHeight + fGap);
		fx = fLeft + fWaku;
		bu = (UIButton *)[self viewWithTag:10]; // [0]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:11]; // [00]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:12]; // [000]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:13]; // [.]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:-8]; // [=]
		if (!bu) bu = (UIButton *)[self viewWithTag:-9]; // [Done]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
	}
	else {	// ヨコ
		float fLabelHeight = 25; // 上下の余白を含む高さ
		float fWidth = 470;
		float fLeft = (rect.size.width - fWidth) / 2;
		float fTop = 44;
		float fHeight = rect.size.height - fTop;
		float fWaku = 12;		// 枠の幅
		float fGap = 2;		// ボタン間隔
		float fxButtons = 7;
		float fyButtons = 4;
		float fBuWidth = (fWidth - fWaku*2 - fGap *(fxButtons-1)) / fxButtons;
		float fBuHeight = (fHeight - fWaku*2 - fLabelHeight - fGap *(fyButtons-1)) / fyButtons;
		
		// 回転によるリサイズ
		UIImageView *iv = (UIImageView *)[self viewWithTag:91];
		iv.frame = CGRectMake(fLeft, fTop, fWidth, fHeight);
		
		MlbCalc.frame = CGRectMake(fLeft+fWaku*2, fTop+fWaku-2, fWidth-fWaku*4, fLabelHeight-fGap);

		//------------------------------------------------------------------------Line 1
		float fy = fTop + fWaku + fLabelHeight;
		float fx = fLeft + fWaku;
		UIButton *bu;
		bu = (UIButton *)[self viewWithTag:-1]; // Clear
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:-2]; // Back
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
		bu = (UIButton *)[self viewWithTag:34]; // [(]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:35]; // [)]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		
		//------------------------------------------------------------------------Line 2
		fy += (fBuHeight + fGap);
		fx = fLeft + fWaku;
		bu = (UIButton *)[self viewWithTag:-3]; // [税込]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:-4]; // [税抜]
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
		bu = (UIButton *)[self viewWithTag:31]; // [-]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:33]; // [÷]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		
		//------------------------------------------------------------------------Line 3
		fy += (fBuHeight + fGap);
		fx = fLeft + fWaku;
		bu = (UIButton *)[self viewWithTag:-5]; // [四捨五入]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		//bu = (UIButton *)[self viewWithTag:1];
		//bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
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
		bu = (UIButton *)[self viewWithTag:30]; // [+]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:32]; // [×]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);

		//------------------------------------------------------------------------Line 4
		fy += (fBuHeight + fGap);
		fx = fLeft + fWaku;
		//bu = (UIButton *)[self viewWithTag:-5]; // [四捨五入]
		//bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		//bu = (UIButton *)[self viewWithTag:1];
		//bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:10]; // [0]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:11]; // [00]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:12]; // [000]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:13]; // [.]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
		fx += (fBuWidth + fGap);
		bu = (UIButton *)[self viewWithTag:-8]; // [=]
		if (!bu) bu = (UIButton *)[self viewWithTag:-9]; // [Done]
		bu.frame = CGRectMake(fx, fy, fBuWidth, fBuHeight);
	}
}


- (void)save
{
	if (Rentity && RzKey && 0 < [MzCalc length]) {
		[Rentity setValue:[NSNumber numberWithInteger:[MzCalc integerValue]]  forKey:RzKey];
	}
}

- (void)hide
{
	if (AparentTableView) {
		[AparentTableView setScrollEnabled:YES]; //[0.3]元画面のスクロール許可
//		AparentTableView.userInteractionEnabled = YES; //[0.3]タッチイベントやキーイベントを有効
	}

	// Scroll away the overlay
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationDuration:0.8];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	CGRect rect = [self frame];
	rect.origin.y = 700;  // rect.size.height; 横向きからタテにしても完全に隠れるようにするため。

	[self setFrame:rect];
	
	// Complete the animation
	[UIView commitAnimations];
	MbShow = NO;

	//if ([Rlabel.text integerValue] <= 0) {
	//if (Rlabel.tag <= 0) {
	if ([MzCalc doubleValue] <= 0.0) {
		Rlabel.textColor = [UIColor blueColor];
	} else {
		Rlabel.textColor = [UIColor blackColor];
	}
	[self.AparentTableView reloadData]; // Footer表示を消すため
}

- (void)show
{
	if (AparentTableView) {
		[AparentTableView setScrollEnabled:NO]; //[0.3]元画面のスクロール禁止 ⇒ hideにて許可
	}
	
	// Scroll in the overlay
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.15]; //　出は早く

	CGRect rect = [self frame];
	rect.origin.y = 64; //＝ アプリケーションエリア上端 ＝ ステータスバー(20) ＋ ナビゲーションバー(44)

	[self setFrame:rect];
	
	// Complete the animation
	[UIView commitAnimations];
	MbShow = YES;
	Rlabel.textColor = [UIColor grayColor];
}

- (BOOL)isShow {
	return MbShow;
}

/*
// タッチイベント
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	//[self save];
	//[self hide];
}
*/

/*
	計算式		⇒　逆ポーランド記法
	"5 + 4 - 3"	⇒ "5 4 3 - +"
	"5 + 4 * 3 + 2 / 6" ⇒ "5 4 3 * 2 6 / + +"
	"(1 + 4) * (3 + 7) / 5" ⇒ "1 4 + 3 7 + 5 * /" OR "1 4 + 3 7 + * 5 /"
 
	"T ( 5 + 2 )" ⇒ "5 2 + T"
 */
- (NSString *)zRpnCalc:(NSString *)zCalcString	// 計算式 ⇒ 逆ポーランド記法(Reverse Polish Notation) ⇒ 答え
{
	NSString *zAnswer = @""; // 戻り値になるため、localPoolの前（親のlocalPool内）で確保すること
	
	// これ以降、localPool管理エリア
	NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];	// [0.3]autorelease独自解放のため

	// [-]を数値符号とするための処理　[+]演算子に置き換える
	NSString *zTemp = [zCalcString stringByReplacingOccurrencesOfString:@"-" withString:@"+(-1)×"];
	// [+]を挿入した結果、おかしくなる組み合わせを補正する
	zTemp = [zTemp stringByReplacingOccurrencesOfString:@"×+" withString:@"×"];
	zTemp = [zTemp stringByReplacingOccurrencesOfString:@"÷+" withString:@"÷"];
	zTemp = [zTemp stringByReplacingOccurrencesOfString:@"++" withString:@"+"];
	// 演算子の両側にスペース挿入
	zTemp = [zTemp stringByReplacingOccurrencesOfString:@"×" withString:@" * "]; // 半角文字化
	zTemp = [zTemp stringByReplacingOccurrencesOfString:@"÷" withString:@" / "]; // 半角文字化
	zTemp = [zTemp stringByReplacingOccurrencesOfString:@"+" withString:@" + "]; // [-]は演算子ではない
	zTemp = [zTemp stringByReplacingOccurrencesOfString:@"(" withString:@" ( "];
	zTemp = [zTemp stringByReplacingOccurrencesOfString:@")" withString:@" ) "];
	zTemp = [zTemp stringByReplacingOccurrencesOfString:@"T" withString:@" T "];
	zTemp = [zTemp stringByReplacingOccurrencesOfString:@"N" withString:@" N "];
	zTemp = [zTemp stringByReplacingOccurrencesOfString:@"R" withString:@" R "];

	// スペースで区切られたコンポーネント(部分文字列)を切り出す
	NSArray *arComp = [zTemp componentsSeparatedByString:@" "];

	NSInteger iCapLeft = 0;
	NSInteger iCapRight = 0;
	NSInteger iCntOperator = 0;	// 演算子の数　（関数は除外）
	NSInteger iCntNumber = 0;	// 数値の数
	
	NSMutableArray *maStack = [NSMutableArray new];
	NSInteger iStackIdx = 0;
	NSMutableArray *maRpn = [NSMutableArray new]; // 逆ポーランド記法結果
	
	for (int index = 0; index < [arComp count]; index++) 
	{
		NSString *zTokn = [arComp objectAtIndex:index];
		AzLOG(@"arComp[%d]='%@'", index, zTokn);
		
		if ([zTokn isEqualToString:@""] OR [zTokn isEqualToString:@" "]) {
			// スペースならばパス
		}
		else if ([zTokn isEqualToString:@"T"] OR [zTokn isEqualToString:@"N"] OR [zTokn isEqualToString:@"R"]) {
			[maStack addObject:zTokn];  iStackIdx++; // スタックPUSH
		}
		else if ([zTokn isEqualToString:@"*"] OR [zTokn isEqualToString:@"/"]) {
			iCntOperator++;
			[maStack addObject:zTokn];  iStackIdx++; // スタックPUSH
		}
		else if ([zTokn isEqualToString:@"+"]) { // [-]は演算子ではない
			iCntOperator++;
			while (0 < iStackIdx) {
				NSString *zz = [maStack objectAtIndex:iStackIdx-1]; // スタック最上位のトークン
				if ([zz isEqualToString:@"*"] OR [zz isEqualToString:@"/"]) {
					[maRpn addObject:zz]; // 逆ポーランドへPUSH
					[maStack removeLastObject]; iStackIdx--; // スタックからPOP
				} else {
					break;
				}
			}
			[maStack addObject:zTokn];  iStackIdx++; // スタックへPUSH
		}
		else if ([zTokn isEqualToString:@"("]) {
			iCapLeft++;
			[maStack addObject:zTokn];  iStackIdx++; // スタックへPUSH
		}
		else if ([zTokn isEqualToString:@")"]) {
			iCapRight++;
			while (0 < iStackIdx) {
				NSString *zz = [maStack objectAtIndex:iStackIdx-1]; // スタックからPOP
				[maStack removeLastObject]; iStackIdx--; // スタックPOP
				if ([zz isEqualToString:@"("]) break; // 両カッコは、maRpnには不要
				[maRpn addObject:zz]; // 逆ポーランドPUSH
			}
		}
		else { // 数字　先頭が[-]の場合あり
			iCntNumber++;
			[maRpn addObject:zTokn]; // 逆ポーランドPUSH
		}
	}
	
	// 数値と演算子の数チェック
	if (iCntNumber < iCntOperator + 1) {
		zAnswer = NSLocalizedString(@"Too many operators", nil); // 演算子が多すぎる
	} else if (iCntNumber > iCntOperator + 1) {
		zAnswer = NSLocalizedString(@"Insufficient operator", nil); // 演算子が足らない
	}
	// 括弧チェック
	if (iCapLeft < iCapRight) {
		zAnswer = NSLocalizedString(@"Closing parenthesis is excessive", nil); // 括弧が閉じ過ぎ
	} else if (iCapLeft > iCapRight) {
		zAnswer = NSLocalizedString(@"Unclosed parenthesis", nil); // 括弧が閉じていない
	}
	if (0 < [zAnswer length]) {
		[maRpn release];
		[localPool release]; // localPool解放　　zAnswerが解放されないように注意すること
		[maStack release];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to compute", nil)
														message:zAnswer
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		return @""; // ERROR
	}
	
	// スタックに残っているトークンを全て逆ポーランドPUSH
	while (0 < iStackIdx) {
		NSString *zz = [maStack objectAtIndex:--iStackIdx]; // スタックからPOP  この後、PUSHすること無いので削除処理をしていない
		[maRpn addObject:zz]; // 逆ポーランドへPUSH
	}
#ifdef AzDEBUG
	for (int index = 0; index < [maRpn count]; index++) 
	{
		AzLOG(@"maRpn[%d]='%@'", index, [maRpn objectAtIndex:index]);
	}
#endif
	
	// スタック クリア
	[maStack removeAllObjects]; iStackIdx = 0;
	//-------------------------------------------------------------------------------------
	// maRpn 逆ポーランド記法を計算する
	double	d1, d2;
	
	for (int index = 0; index < [maRpn count]; index++) 
	{
		NSString *zTokn = [maRpn objectAtIndex:index];
		
		if ([zTokn isEqualToString:@"T"]) {
			if (1 <= iStackIdx) {
				d1 = [[maStack objectAtIndex:iStackIdx-1] doubleValue]; [maStack removeLastObject]; iStackIdx--; // スタックからPOP
				[maStack addObject:[NSString stringWithFormat:@"%f", d1*1.05]];  iStackIdx++; // スタックPUSH
			}
		}
		else if ([zTokn isEqualToString:@"N"]) {
			if (1 <= iStackIdx) {
				d1 = [[maStack objectAtIndex:iStackIdx-1] doubleValue]; [maStack removeLastObject]; iStackIdx--; // スタックからPOP
				[maStack addObject:[NSString stringWithFormat:@"%f", d1/1.05]];  iStackIdx++; // スタックPUSH
			}
		}
		else if ([zTokn isEqualToString:@"R"]) {
			if (1 <= iStackIdx) {
				d1 = [[maStack objectAtIndex:iStackIdx-1] doubleValue]; [maStack removeLastObject]; iStackIdx--; // スタックからPOP
				[maStack addObject:[NSString stringWithFormat:@"%f", round(d1)]];  iStackIdx++; // スタックPUSH
			}
		}
		else if ([zTokn isEqualToString:@"*"]) {
			if (2 <= iStackIdx) {
				d2 = [[maStack objectAtIndex:iStackIdx-1] doubleValue]; [maStack removeLastObject]; iStackIdx--; // スタックからPOP
				d1 = [[maStack objectAtIndex:iStackIdx-1] doubleValue]; [maStack removeLastObject]; iStackIdx--; // スタックからPOP
				[maStack addObject:[NSString stringWithFormat:@"%f", d1*d2]];  iStackIdx++; // スタックPUSH
			}
		}
		else if ([zTokn isEqualToString:@"/"]) {
			if (2 <= iStackIdx) {
				d2 = [[maStack objectAtIndex:iStackIdx-1] doubleValue]; [maStack removeLastObject]; iStackIdx--; // スタックからPOP
				d1 = [[maStack objectAtIndex:iStackIdx-1] doubleValue]; [maStack removeLastObject]; iStackIdx--; // スタックからPOP
				if (d1==0) { // 0割
					[maRpn release];
					[localPool release]; // localPool解放　　zAnswerが解放されないように注意すること
					[maStack release];
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to compute", nil)
																	message:NSLocalizedString(@"How do you divide by zero", nil)
																   delegate:nil
														  cancelButtonTitle:nil
														  otherButtonTitles:@"OK", nil];
					[alert show];
					[alert release];
					return @""; // ERROR
					break;
				}
				[maStack addObject:[NSString stringWithFormat:@"%f", d1/d2]];  iStackIdx++; // スタックPUSH
			}
		}
		else if ([zTokn isEqualToString:@"-"]) {
			if (1 <= iStackIdx) {
				d2 = [[maStack objectAtIndex:iStackIdx-1] doubleValue]; [maStack removeLastObject]; iStackIdx--; // スタックからPOP
				if (1 <= iStackIdx) {
					d1 = [[maStack objectAtIndex:iStackIdx-1] doubleValue]; [maStack removeLastObject]; iStackIdx--; // スタックからPOP
				} else {
					d1 = 0.0;
				}
				[maStack addObject:[NSString stringWithFormat:@"%f", d1-d2]];  iStackIdx++; // スタックPUSH
			}
		}
		else if ([zTokn isEqualToString:@"+"]) {
			if (1 <= iStackIdx) {
				d2 = [[maStack objectAtIndex:iStackIdx-1] doubleValue]; [maStack removeLastObject]; iStackIdx--; // スタックからPOP
				if (1 <= iStackIdx) {
					d1 = [[maStack objectAtIndex:iStackIdx-1] doubleValue]; [maStack removeLastObject]; iStackIdx--; // スタックからPOP
				} else {
					d1 = 0.0;
				}
				[maStack addObject:[NSString stringWithFormat:@"%f", d1+d2]];  iStackIdx++; // スタックPUSH
			}
		}
		else {
			[maStack addObject:zTokn];  iStackIdx++; // スタックPUSH
		}
	}
	
	[maRpn release];
	[localPool release];
	// ここまでが、localPool管理エリア　　zAnswerが解放されないように注意すること

	// スタックに残った最後が答え
	if (iStackIdx == 1) {
		//zAnswer = [NSString stringWithString:[maStack objectAtIndex:iStackIdx-1]];
		//計算途中精度を小数以下3桁にする
		zAnswer = [NSString stringWithFormat:@"%.3f", [[maStack objectAtIndex:iStackIdx-1] doubleValue]];
		if ([zAnswer hasSuffix:@".000"]) {
			zAnswer = [zAnswer stringByReplacingOccurrencesOfString:@".000" withString:@""];
		}
	} else {
		AzLOG(@"zRpnCalc:ERROR: iStackIdx != 1");
	}
	[maStack release];
	return zAnswer; // これは、localPool解放対象外である
}


@end

