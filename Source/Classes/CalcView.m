//
//  CalcView.m
//
//  Created by 松山 和正 on 10/01/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "CalcView.h"
#import "E3recordDetailTVC.h"		// delegate


//----------------------------------------------------------NSMutableArray Stack Method
@interface NSMutableArray (StackAdditions)
- (void)push:(id)obj;
- (id)pop;
@end

@implementation NSMutableArray (StackAdditions)
- (void)push:(id)obj
{
	[self addObject: obj];
}

- (id)pop
{
    // nil if [self count] == 0
    id lastObject = [[[self lastObject] retain] autorelease];
    if (lastObject)
        [self removeLastObject];
    return lastObject;
}
@end
//----------------------------------------------------------NSMutableArray Stack Method


@interface CalcView (PrivateMethods)
//- (void)MtextFieldDidChange:(UITextField *)textField;
- (NSDecimalNumber *)decimalAnswerFomula:(NSString *)strFomula;	// autorelease
- (void)textFieldDidChange:(UITextField *)textField;
@end

@implementation CalcView
@synthesize Rlabel;
//@synthesize Rentity;
//@synthesize RzKey;
@synthesize PoParentTableView;
@synthesize delegate;


#pragma mark - Action

// zFomula を計算し、答えを MdecAnswer に保持しながら Rlabel.text に表示する
- (void)finalAnswer:(NSString *)zFomula
{
//	AzRETAIN_CHECK(@"finalAnswer: MdecAnswer1", MdecAnswer, 9);
	MdecAnswer = [self decimalAnswerFomula:zFomula]; // retain
//	AzRETAIN_CHECK(@"finalAnswer: MdecAnswer2", MdecAnswer, 9);
	//NSLog(@"**********1 MdecAnswer=%@", MdecAnswer);
	if (MdecAnswer) {
		if (ANSWER_MAX < fabs([MdecAnswer doubleValue])) {
			Rlabel.text = @"Game Over";
			[MdecAnswer release], MdecAnswer = [[NSDecimalNumber alloc] initWithString:@"0.0"];
			// textField.text は、そのままなので計算続行可能。
			return;
		}
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // ＜＜計算途中、通貨小数＋2桁表示するため
		//[formatter setLocale:[NSLocale currentLocale]]; 
		[formatter setPositiveFormat:@"#,##0.####"];
		[formatter setNegativeFormat:@"-#,##0.####"];
		// 表示のみ　Rentity更新はしない
		Rlabel.text = [formatter stringFromNumber:MdecAnswer];
		[formatter release];
	}
	else {
		Rlabel.text = @"?";
	}
}

- (void)buttonCalc:(UIButton *)button
{
	AzLOG(@"buttonCalc: text[%@] tag(%d)", button.titleLabel.text, (int)button.tag);
	
	//クリック音を入れてみたが、無い方が良さそう。
	//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate audioPlayer:@"Tock.caf"];  // キークリック音

	switch (button.tag) 
	{
		case 1: // 数値
			MtextField.text = [MtextField.text stringByAppendingString:button.titleLabel.text];
			break;
			
		case 2: { // 演算子
			//[RzCalc appendString:button.titleLabel.text];
			MtextField.text = [MtextField.text stringByAppendingString:button.titleLabel.text];
			MtextField.hidden = NO;
		} break;
			
		case 4: { // AC
			if (MdecAnswer) {
				[MdecAnswer release], MdecAnswer = nil;
			}
			MtextField.text = @"";
			Rlabel.text = @"";
			MtextField.hidden = YES;
		} break;
			
		case 5: { // BS
			int iLen = [MtextField.text length];
			if (1 <= iLen) {
				//[RzCalc deleteCharactersInRange:NSMakeRange(iLen-1, 1)]; 
				MtextField.text = [MtextField.text substringToIndex:iLen-1];
			}
			else { // [AC]状態
				if (MdecAnswer) {
					[MdecAnswer release], MdecAnswer = nil;
				}
				MtextField.text = @"";
				Rlabel.text = @"";
				MtextField.hidden = YES;
			}
		} break;
			
		case 6: // +/-
			if (MtextField.hidden) {
				if ([MtextField.text hasPrefix:@"-"]) {
					MtextField.text = [MtextField.text substringFromIndex:1];
				} else {
					MtextField.text = [NSString stringWithFormat:@"-%@", MtextField.text];
				}
			} else {
				// 計算式
				if ([MtextField.text hasPrefix:@"-"]) {
					MtextField.text = [MtextField.text substringFromIndex:1];
				} else {
					MtextField.text = [NSString stringWithFormat:@"-(%@)", MtextField.text];
				}
			}
			break;
			
		case 7: { // [NoTax]
			float fRate = [[NSUserDefaults standardUserDefaults] floatForKey:GD_OptTaxRate]; // 税率(%)
			if (0.0 < fRate && fRate < 100.0) {
				fRate = (100.0 + fRate) / 100.0;
				MtextField.text = [NSString stringWithFormat:@"(%@)÷%.2f", MtextField.text, fRate];
				MtextField.hidden = NO;
			}
		} break;
			
		case 8: { // [InTax]
			float fRate = [[NSUserDefaults standardUserDefaults] floatForKey:GD_OptTaxRate]; // 税率(%)
			if (0.0 < fRate && fRate < 100.0) {
				fRate = (100.0 + fRate) / 100.0;
				MtextField.text = [NSString stringWithFormat:@"(%@)×%.2f", MtextField.text, fRate];
				MtextField.hidden = NO;
			}
		} break;
			
		case 9: // [Done]
//			AzRETAIN_CHECK(@"[Done]: MdecAnswer", MdecAnswer, 0);
			NSLog(@"[Done] MdecAnswer=%@", MdecAnswer);
			if (MdecAnswer) [self save]; // MdecAnswer を Rentity へ保存する
			[self hide];
			break;
			
		default:
			NSLog(@"ERROR");
//			GA_TRACK_EVENT_ERROR(@"No Button",0)
			break;
	}
	
//	AzRETAIN_CHECK(@"buttonCalc: MdecAnswer", MdecAnswer, 0);
	//MtextView.text = RzCalc;
	[self textFieldDidChange:MtextField];
}

- (void)save	// E3recordDetailTVCの中から呼び出されることがある
{
	if (MdecAnswer)
	{
//		AzRETAIN_CHECK(@"save: MdecAnswer", MdecAnswer, 0);

		if (Re3edit) {
			NSDecimalNumber *decSource = Re3edit.nAmount;
			NSLog(@"Calc: MdecAnswer=%@ != %@", MdecAnswer, decSource);
			if ([MdecAnswer compare:decSource] != NSOrderedSame) 
			{	// 変化あり
				// デフォルト丸め処理
				Re3edit.nAmount = [MdecAnswer decimalNumberByRoundingAccordingToBehavior:MbehaviorDefault];
				
				AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
				apd.entityModified = YES;	//変更あり
				// E6更新
				if ([delegate respondsToSelector:@selector(remakeE6change:)]) {	// メソッドの存在を確認する
					[delegate remakeE6change:2];		// (2) nAmount	金額
				}
				// 再描画
				if ([delegate respondsToSelector:@selector(viewWillAppear:)]) {	// メソッドの存在を確認する
					[delegate viewWillAppear:YES];	
				}
			}
		}
		else {
			// Entity更新なし。　ラベルだけ更新
			// Rlabel.text により値を返す　＜＜＜この後、デフォルト丸め処理すること。
		}
	}
}


- (void)cancel
{
	Rlabel.text = RzLabelText;  // ラベルを元に戻す
}

- (void)hide
{
	if (!MbShow) return;
	MbShow = NO;
	
	if (MdecAnswer) {
		[MdecAnswer release], MdecAnswer = nil;
	}
	if (self.PoParentTableView) {
		[self.PoParentTableView setScrollEnabled:YES]; //[0.3]元画面のスクロール許可
		//		AparentTableView.userInteractionEnabled = YES; //[0.3]タッチイベントやキーイベントを有効
	}
	
	// アニメ準備
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationDuration:0.8];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	// アニメ終了位置
	CGRect rect = MrectInit;
	rect.origin.y += 600;  // rect.size.height; 横向きからタテにしても完全に隠れるようにするため。
	[self setFrame:rect];
	// 丸め設定
	[NSDecimalNumber setDefaultBehavior:MbehaviorDefault];
	
	if ([Rlabel.text length]<=0) {
		Rlabel.text = RzLabelText; // 初期値復元
	}

	// アニメ実行
	[UIView commitAnimations];
	[self.PoParentTableView reloadData]; // Footer表示を消すため
}

- (void)show
{
	if (MbShow) return;
	MbShow = YES;
	
	if (RzLabelText) {
		[RzLabelText release];
	}
	RzLabelText = [Rlabel.text copy];	//表示文字列をそのまま戻すために記録  deallocにてrelease

	//sourceDecimal = [NSDecimalNumber decimalNumberWithDecimal:[[Rentity valueForKey:RzKey] decimalValue]];	//初期値
	//NSLog(@"sourceDecimal=%@", sourceDecimal);
	
	if (MdecAnswer) {
		[MdecAnswer release], MdecAnswer = nil;
	}
	if (self.PoParentTableView) {
		[self.PoParentTableView setScrollEnabled:NO]; //[0.3]元画面のスクロール禁止 ⇒ hideにて許可
	}
	
	// アニメ準備
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2]; // 出は早く
	
	[self setFrame:MrectInit]; // viewDesign:で決められた位置へ
	
	// Complete the animation
	[UIView commitAnimations];
	Rlabel.textColor = [UIColor brownColor];	// 電卓中は、ずっと茶色！ 文字色指定は、ここだけ。

	// 丸め設定
	[NSDecimalNumber setDefaultBehavior:MbehaviorCalc];	// 計算途中の丸め
}

- (BOOL)isShow {
	return MbShow;
}


/*
 計算式		⇒　逆ポーランド記法
 "5 + 4 - 3"	⇒ "5 4 3 - +"
 "5 + 4 * 3 + 2 / 6" ⇒ "5 4 3 * 2 6 / + +"
 "(1 + 4) * (3 + 7) / 5" ⇒ "1 4 + 3 7 + 5 * /" OR "1 4 + 3 7 + * 5 /"
 
 "T ( 5 + 2 )" ⇒ "5 2 + T"
 */
int levelOperator( NSString *zOpe )  // 演算子の優先順位
{
	if ([zOpe isEqualToString:@"*"] || [zOpe isEqualToString:@"/"]) {
		return 1;
	}
	else if ([zOpe isEqualToString:@"+"] || [zOpe isEqualToString:@"-"]) {
		return 2;
	}
	return 99;
}

- (NSDecimalNumber *)decimalAnswerFomula:(NSString *)strFomula	// 計算式 ⇒ 逆ポーランド記法(Reverse Polish Notation) ⇒ 答え
{
	if ([strFomula length] <= 0) return nil;
	
	NSMutableArray *maStack = [NSMutableArray new];	// - Stack Method
	NSMutableArray *maRpn = [NSMutableArray new]; // 逆ポーランド記法結果
	NSDecimalNumber *decAns = nil;
	
	//-------------------------------------------------localPool BEGIN >>> @finaly release
//	NSAutoreleasePool *autoPool = [[NSAutoreleasePool alloc] init]; //イベント（タッチ）毎の解放では不足(落ちる)なので独自に解放する
	@try {
		NSString *zTokn;
		NSString *zz;
		
		NSString *zTemp = [strFomula stringByReplacingOccurrencesOfString:@" " withString:@""]; // [ ]スペース除去
		NSString *zFlag = nil;
		if ([zTemp hasPrefix:@"-"] || [zTemp hasPrefix:@"+"]) {		// 先頭が[-]や[+]ならば符号として処理する
			zFlag = [zTemp substringToIndex:1]; // 先頭の1字
			zTemp = [zTemp substringFromIndex:1]; // 先頭の1字を除く
		}
		// マイナス符号 ⇒ " -"
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"×-" withString:@"× s"];  
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"÷-" withString:@"÷ s"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"+-" withString:@"+ s"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"--" withString:@"- s"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"(-" withString:@"( s"];
		// マイナス演算子 ⇒ " - "
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@")-" withString:@") s "]; 
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"-(" withString:@" s ("];
		// 残った "-" を演算子になるように " s " にする
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"-" withString:@" s "];  
		// "s" を "-" に戻す
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"s" withString:@"-"];
		
		// [+]を挿入した結果、おかしくなる組み合わせを補正する
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"×+" withString:@"×"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"÷+" withString:@"÷"];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"++" withString:@"+"];
		// 演算子の両側にスペース挿入
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"*" withString:@" * "]; // 前後スペース
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"/" withString:@" / "]; // 前後スペース
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"×" withString:@" * "]; // 半角文字化
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"÷" withString:@" / "]; // 半角文字化
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"+" withString:@" + "]; // [-]は演算子ではない
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@"(" withString:@" ( "];
		zTemp = [zTemp stringByReplacingOccurrencesOfString:@")" withString:@" ) "];
		
		if (zFlag) {
			zTemp = [zFlag stringByAppendingString:zTemp]; // 先頭に符号を付ける
		}
		// スペースで区切られたコンポーネント(部分文字列)を切り出す
		NSArray *arComp = [zTemp componentsSeparatedByString:@" "];
		NSLog(@"arComp[]=%@", arComp);
		
		NSInteger iCapLeft = 0;
		NSInteger iCapRight = 0;
		NSInteger iCntOperator = 0;	// 演算子の数　（関数は除外）
		NSInteger iCntNumber = 0;	// 数値の数
		
		for (int index = 0; index < [arComp count]; index++) 
		{
			zTokn = [arComp objectAtIndex:index];
			AzLOG(@"arComp[%d]='%@'", index, zTokn);
			
			if ([zTokn length] < 1 || [zTokn hasPrefix:@" "]) {
				// パス
			}
			else if ([zTokn doubleValue] != 0.0 || [zTokn hasSuffix:@"0"]) {		// 数値ならば
				iCntNumber++;
				[maRpn push:zTokn];
			}
			else if ([zTokn isEqualToString:@")"]) {	// "("までスタックから取り出してRPNへ追加、両括弧は破棄する
				iCapRight++;
				while ((zz = [maStack pop])) {
					if ([zz isEqualToString:@"("]) break; // 両カッコは、破棄する
					[maRpn push:zz];
				}
			}
			else if ([zTokn isEqualToString:@"("]) {
				iCapLeft++;
				[maStack push:zTokn];
			}
			else {
				while (0 < [maStack count]) {
					//			 スタック最上位の演算子優先順位 ＜ トークンの演算子優先順位
					if (levelOperator([maStack lastObject]) <= levelOperator(zTokn)) {
						[maRpn push:[maStack pop]];  // スタックから取り出して、それをRPNへ追加
					} else {
						break;
					}
				}
				// スタックが空ならばトークンをスタックへ追加する
				iCntOperator++;
				[maStack push:zTokn];
			}
		}
		// スタックに残っているトークンを全て逆ポーランドPUSH
		while ((zz = [maStack pop])) {
			[maRpn push:zz];
		}
		
		// 数値と演算子の数チェック
		if (iCntNumber < iCntOperator + 1) {
			@throw NSLocalizedString(@"Too many operators", nil); // 演算子が多すぎる
		}
		else if (iCntNumber > iCntOperator + 1) {
			@throw NSLocalizedString(@"Insufficient operator", nil); // 演算子が足らない
		}
		// 括弧チェック
		if (iCapLeft < iCapRight) {
			@throw NSLocalizedString(@"Closing parenthesis is excessive", nil); // 括弧が閉じ過ぎ
		}
		else if (iCapLeft > iCapRight) {
			@throw NSLocalizedString(@"Unclosed parenthesis", nil); // 括弧が閉じていない
		}
		
#ifdef AzDEBUG
		for (int index = 0; index < [maRpn count]; index++) 
		{
			AzLOG(@"maRpn[%d]='%@'", index, [maRpn objectAtIndex:index]);
		}
#endif
		
		// スタック クリア
		[maStack removeAllObjects]; //iStackIdx = 0;
		//-------------------------------------------------------------------------------------
		// maRpn 逆ポーランド記法を計算する
		NSDecimalNumber *d1, *d2;
		
		// この内部だけの丸め指定
		NSDecimalNumberHandler *behavior = [[NSDecimalNumberHandler alloc]
											initWithRoundingMode:NSRoundBankers		// 偶数丸め
											scale:MiRoundingScale + 12	// 丸めた後の桁数
											raiseOnExactness:YES		// 精度
											raiseOnOverflow:YES			// オーバーフロー
											raiseOnUnderflow:YES		// アンダーフロー
											raiseOnDivideByZero:YES ];	// アンダーフロー
		[NSDecimalNumber setDefaultBehavior:behavior];	// 計算途中の丸め
		[behavior release];
		
		for (int index = 0; index < [maRpn count]; index++) 
		{
			NSString *zTokn = [maRpn objectAtIndex:index];
			
			if ([zTokn isEqualToString:@"*"]) {
				if (2 <= [maStack count]) {
					d2 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					d1 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					d1 = [d1 decimalNumberByMultiplyingBy:d2]; // d1 * d2
					[maStack push:[d1 description]];
				}
			}
			else if ([zTokn isEqualToString:@"/"]) {
				if (2 <= [maStack count]) {
					d2 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					d1 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					if ([d2 doubleValue] == 0.0) { // 0割
						@throw NSLocalizedString(@"How do you divide by zero", nil);
					}
					d1 = [d1 decimalNumberByDividingBy:d2]; // d1 / d2
					[maStack push:[d1 description]];
				}
			}
			else if ([zTokn isEqualToString:@"-"]) {
				if (1 <= [maStack count]) {
					d2 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					if (1 <= [maStack count]) {
						d1 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					} else {
						d1 = [NSDecimalNumber zero]; // 0.0;
					}
					d1 = [d1 decimalNumberBySubtracting:d2]; // d1 - d2
					[maStack push:[d1 description]];
				}
			}
			else if ([zTokn isEqualToString:@"+"]) {
				if (1 <= [maStack count]) {
					d2 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					if (1 <= [maStack count]) {
						d1 = [NSDecimalNumber decimalNumberWithString:[maStack pop]]; // スタックからPOP
					} else {
						d1 = [NSDecimalNumber zero]; // 0.0;
					}
					d1 = [d1 decimalNumberByAdding:d2]; // d1 + d2
					[maStack push:[d1 description]];
				}
			}
			else {
				//[maStack addObject:zTokn];  iStackIdx++; // スタックPUSH
				[maStack push:zTokn]; // 数値をスタックへPUSH
			}
		}
		
		// スタックに残った最後が答え
		if ([maStack count] == 1) {
			//計算途中精度を通貨小数＋2桁にする
			decAns = [NSDecimalNumber decimalNumberWithString:[maStack pop]];
			//NSLog(@"**********1 decAns=%@", decAns);
			decAns = [decAns decimalNumberByRoundingAccordingToBehavior:MbehaviorCalc]; // 計算結果の丸め処理
			//NSLog(@"**********2 decAns=%@", decAns);
			[decAns retain]; // localPool release されないように retain しておく。
		}
		else {
			@throw @"zRpnCalc:ERROR: [maStack count] != 1";
//			GA_TRACK_EVENT_ERROR(@"zRpnCalc:ERROR: [maStack count] != 1",0)
		}
	}
	@catch (NSException * errEx) {
//		GA_TRACK_EVENT_ERROR([errEx description],0);
		NSLog(@"Calc: error %@ : %@\n", [errEx name], [errEx reason]);
		decAns = nil;
	}
	@catch (NSString *errMsg) {
//		GA_TRACK_EVENT_ERROR(errMsg,0);
		NSLog(@"Calc: error=%@", errMsg);
		decAns = nil;
	}
	@finally {
//		[autoPool release];
		//-------------------------------------------------localPool END
		[maRpn release];
		[maStack release];
	}
	return decAns;
}



#pragma mark - View lifecicle

- (id)initWithFrame:(CGRect)rect withE3:(E3record*)e3
{
	NSLog(@"CalcView: rect=(%f,%f)-(%f,%f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

	MrectInit = rect;		// 表示位置を記録　showにて復元に使う
	rect.origin.y += 600;  // rect.size.height; 横向きからタテにしても完全に隠れるようにするため。

	if (!(self = [super initWithFrame:rect])) return self; // ERROR
	
	Re3edit = [e3 retain];	//=nil: E6partモード　　結果をラベル(Rlabel.text)で返す
	
	self.backgroundColor = [UIColor clearColor];	// 透明でもTouchイベントが受け取れるようだ。
	self.userInteractionEnabled = YES; // このViewがタッチを受けるか

	MbShow = NO;
	MdecAnswer = nil;
	
	//------------------------------------------
	MtextField = [[UITextField alloc] init];
	MtextField.borderStyle = UITextBorderStyleBezel;
	MtextField.backgroundColor = [UIColor brownColor];
	MtextField.textColor = [UIColor whiteColor];
	MtextField.text = @"";
  	MtextField.textAlignment = UITextAlignmentLeft;		// 演算子が入と、左寄書式なし2行表示
	MtextField.font = [UIFont boldSystemFontOfSize:22];
	MtextField.hidden = YES;
	MtextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	MtextField.autocorrectionType = NO;
	MtextField.returnKeyType = UIReturnKeyDone;
	MtextField.delegate = self;	// UITextFieldDelegate には、変更「前」のイベントしか無い
	[MtextField addTarget:self	// UITextFieldDelegate に、 変更「後」イベント textFieldDidChange を追加する
				   action:@selector(textFieldDidChange:) // 変更「後」に呼び出される
		 forControlEvents:UIControlEventEditingChanged];
	[self addSubview:MtextField];
	[MtextField release];
	
	//------------------------------------------
	MscrollView = [[UIScrollView alloc] init];
	MscrollView.pagingEnabled = NO;
	MscrollView.showsVerticalScrollIndicator = NO;
	MscrollView.showsHorizontalScrollIndicator = NO;
	MscrollView.scrollsToTop = NO;
	MscrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	MscrollView.backgroundColor = [UIColor blackColor];
#ifdef AzPAD
	MscrollView.delaysContentTouches = NO; //iPadではスクロール不要なのでＮＯにし、タッチ感度を向上させる。
	//UIScrollView を止めて UIViewを試したが、ボタン隙間のタッチで touchesBegan:が呼び出されて閉じてしまう不具合により没。
#else
	MscrollView.delaysContentTouches = YES; //default//ボタンより先に 0.5s タッチを監視してスクロール操作であるか判断する
#endif
	[self addSubview:MscrollView]; [MscrollView release];
	
	//------------------------------------------
	NSMutableArray *maBu = [NSMutableArray new];
	int iIndex = 0;
	for (int iCol=0; iCol<6; iCol++)
	{
		for (int iRow=0; iRow<4; iRow++)
		{
			UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
			bu.titleLabel.font = [UIFont boldSystemFontOfSize:32];
			[bu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			
			switch (iIndex) // bu.tag=1:数値　2:演算子　3:関数　4:Ac 5:BS 6:+/-   9:=
			{
				case  0: bu.tag=4; [bu setTitle:@"AC" forState:UIControlStateNormal];  
					bu.titleLabel.font = [UIFont boldSystemFontOfSize:24]; 
					[bu setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
					break;

				case  1: bu.tag=5; [bu setTitle:@"BS" forState:UIControlStateNormal];  
					bu.titleLabel.font = [UIFont boldSystemFontOfSize:24]; 
					[bu setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
					break;
				
				case  2: bu.tag=6; [bu setTitle:@"+/-" forState:UIControlStateNormal]; break;
				case  3: bu.tag=1; [bu setTitle:@"00" forState:UIControlStateNormal]; break;
				
					
				case  4: bu.tag=1; [bu setTitle:@"7" forState:UIControlStateNormal]; break;
				case  5: bu.tag=1; [bu setTitle:@"4" forState:UIControlStateNormal]; break;
				case  6: bu.tag=1; [bu setTitle:@"1" forState:UIControlStateNormal]; break;
				case  7: bu.tag=1; [bu setTitle:@"0" forState:UIControlStateNormal]; break;

				case  8: bu.tag=1; [bu setTitle:@"8" forState:UIControlStateNormal]; break;
				case  9: bu.tag=1; [bu setTitle:@"5" forState:UIControlStateNormal]; break;
				case 10: bu.tag=1; [bu setTitle:@"2" forState:UIControlStateNormal]; break;
				case 11: bu.tag=1; [bu setTitle:@"." forState:UIControlStateNormal]; break;

				case 12: bu.tag=1; [bu setTitle:@"9" forState:UIControlStateNormal]; break;
				case 13: bu.tag=1; [bu setTitle:@"6" forState:UIControlStateNormal]; break;
				case 14: bu.tag=1; [bu setTitle:@"3" forState:UIControlStateNormal]; break;
				case 15: bu.tag=9; 
					[bu setTitle:NSLocalizedString(@"Calc Done",nil) forState:UIControlStateNormal];
					bu.titleLabel.font = [UIFont boldSystemFontOfSize:20];
					[bu setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
					break;
					
				case 16: bu.tag=2; [bu setTitle:@"÷" forState:UIControlStateNormal]; break;
				case 17: bu.tag=2; [bu setTitle:@"×" forState:UIControlStateNormal]; break;
				case 18: bu.tag=2; [bu setTitle:@"-" forState:UIControlStateNormal]; break;
				case 19: bu.tag=2; [bu setTitle:@"+" forState:UIControlStateNormal]; break;

				case 20: bu.tag=2; [bu setTitle:@"(" forState:UIControlStateNormal]; break;
				case 21: bu.tag=2; [bu setTitle:@")" forState:UIControlStateNormal]; break;
				
				case 22: bu.tag=7; 
					[bu setTitle:NSLocalizedString(@"Calc NoTax",nil) forState:UIControlStateNormal]; 
					bu.titleLabel.font = [UIFont boldSystemFontOfSize:18]; 
					break;

				case 23: bu.tag=8; 
					[bu setTitle:NSLocalizedString(@"Calc InTax",nil) forState:UIControlStateNormal]; 
					bu.titleLabel.font = [UIFont boldSystemFontOfSize:18]; 
					break;
			}
			
			if (1 < bu.tag)	bu.alpha = 0.8;
			else			bu.alpha = 1.0;

			[bu setBackgroundImage:[UIImage imageNamed:@"Icon-Drum.png"] forState:UIControlStateNormal];
			[bu setBackgroundImage:[UIImage imageNamed:@"Icon-DrumPush.png"] forState:UIControlStateHighlighted];
			[bu addTarget:self action:@selector(buttonCalc:) forControlEvents:UIControlEventTouchUpInside];
			[maBu addObject:bu];
			[MscrollView addSubview:bu]; //[bu release]; autoreleaseされるため
			iIndex++;
		}
	}
	
	RaKeyButtons = [[NSArray alloc] initWithArray:maBu];
	[maBu release];
	
	[self viewDesign:rect]; // コントロール配置

	// Calc 初期化
	//RzCalc = [[NSMutableString alloc] init];
	//MdRegister = [NSDecimalNumber zero]; // 0.0;
	MiFunc = 0;
	
	// 丸め方法
	NSUInteger uiRound = NSRoundPlain; //　四捨五入
	if ([[NSUserDefaults standardUserDefaults] boolForKey:GD_OptRoundBankers]) {
		uiRound = NSRoundBankers; // 偶数丸め
	}
	// 通貨型に合った丸め位置を取得
	if ([[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier] isEqualToString:@"ja_JP"]) { // 言語 + 国、地域
		MiRoundingScale = 0;
	} else {
		MiRoundingScale = 2;
	}
	// 計算結果の丸め設定　show にてデフォルト設定
	MbehaviorCalc = [[NSDecimalNumberHandler alloc] initWithRoundingMode:uiRound				// 丸め
																   scale:MiRoundingScale + 2	// 丸めた後の桁数
														raiseOnExactness:YES					// 精度
														 raiseOnOverflow:YES					// オーバーフロー
														raiseOnUnderflow:YES					// アンダーフロー
													 raiseOnDivideByZero:YES ];					// アンダーフロー

	// 答えの丸め　hide にてデフォルト設定
	MbehaviorDefault = [[NSDecimalNumberHandler alloc] initWithRoundingMode:uiRound			// 丸め
																	  scale:MiRoundingScale	// 丸めた後の桁数
														   raiseOnExactness:YES				// 精度
															raiseOnOverflow:YES				// オーバーフロー
														   raiseOnUnderflow:YES				// アンダーフロー
														raiseOnDivideByZero:YES ];			// アンダーフロー
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	//self.userInteractionEnabled = YES; //タッチの可否  どこでもDone
}

- (void)viewDesign:(CGRect)rect
{
	AzLOG(@"viewDesign:rect (x,y)=(%f,%f) (w,h)=(%f,%f)", rect.origin.x,rect.origin.y, rect.size.width,rect.size.height);
	
	float fxGap = 2;	// Xボタン間隔
	float fyGap;		// Yボタン間隔
	float fx = fxGap;
	float fy;
	float fyTop;
	float fW;
	float fH;
	
#ifdef AzPAD
	if (Re3edit) {
		fy = 90;
	} else {
		fy = 113;
	}
	MtextField.frame = CGRectMake(5,fy, rect.size.width-10,30);	// 1行
	fy += MtextField.frame.size.height;
	MscrollView.frame = CGRectMake(5,fy, rect.size.width-10, 214);
	fW = (rect.size.width-10 - fxGap) / 6 - fxGap; //Pad//6列まで全部表示
	MscrollView.contentSize = MscrollView.frame.size; //同じ＝1ページのみ固定
	// 以下、MscrollView座標
	fyGap = 5;	// Yボタン間隔
	fy = 0;
	fH = fW / GOLDENPER; // 黄金比
	fyTop = fy + fyGap;
#else
	if (rect.size.width < rect.size.height)
	{	// タテ
		//MlbCalc.frame = CGRectMake(fx,fy, 320-fx-fx,20);	// 3行
		fy = 95;
		MtextField.frame = CGRectMake(5,fy, 320-10,30);	// 1行
		fy += MtextField.frame.size.height;
		MscrollView.frame = CGRectMake(0,fy, 320,220);
		//fW = (320 - fxGap) / 4 - fxGap; // 1ページ4列まで表示、5列目は2ページ目へ
		fW = (320 - fxGap) / 5 - fxGap; // 1ページ5列まで表示、6列目は2ページ目へ
																								  //↓2ページ目の列数=1
		MscrollView.contentSize = CGSizeMake(320+(fW+fxGap)*1, MscrollView.frame.size.height);
		// 以下、MscrollView座標
		fyGap = 5;	// Yボタン間隔
		fy = 0;
		//fH = (MscrollView.frame.size.height - fyGap) / 4 - fyGap;
		//fH = fW / GOLDENPER; // 黄金比
		fH = fW / 1.30;
		fyTop = fy + fyGap;
	}
	else {	// ヨコ
		//MlbCalc.frame = CGRectMake(fx,fy, 480-fx-fx,20);	// 1行
		fy = 40;
		MtextField.frame = CGRectMake(5,fy, 480-10,30);	// 1行
		fy += MtextField.frame.size.height;
		MscrollView.frame = CGRectMake(0,fy, 480,180);
		//fW = (480 - fxGap) / 5 - fxGap; // 5列まで表示
		MscrollView.contentSize = MscrollView.frame.size;
		// 以下、MscrollView座標
		fyGap = 4;	// Yボタン間隔
		fy = 0;
		fH = (MscrollView.frame.size.height - fyGap) / 4 - fyGap;
		fW = fH * GOLDENPER; // 黄金比
		fx = (480 - (fxGap + (fW+fxGap)*6 + fxGap)) / 2;
		fx += fxGap;
		fyTop = fy + fyGap;
	}
#endif
	
	NSInteger iIndex = 0;
	for (int iCol=0; iCol<6; iCol++)
	{
		fy = fyTop;
		for (int iRow=0; iRow<4; iRow++)
		{
			UIButton *bu = [RaKeyButtons objectAtIndex:iIndex++];
			if (bu) {
				bu.frame = CGRectMake(fx,fy, fW,fH);
				//[bu setFrame:CGRectMake(fx,fy, fW,fH)];
			}
			fy += (fH + fyGap);
		}
		fx += (fW + fxGap);
	}
}

/***** UIView には回転は無い！！！
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
 */


#pragma mark  View - Unload - dealloc
- (void)dealloc 
{
//	AzRETAIN_CHECK(@"dealloc: MdecAnswer", MdecAnswer, 0);
	if (MdecAnswer) {
		[MdecAnswer release], MdecAnswer = nil;
	}
	
	[MbehaviorCalc release];
	[MbehaviorDefault release];
	[RaKeyButtons release];
	[RzLabelText release],		RzLabelText = nil;
	//[RzKey release];
	//[Rentity release];
	[Re3edit release];
	[Rlabel release];
	[super dealloc];
}



#pragma mark - <UITextFieldDelegate>

// UITextFieldDelegate：変更「前」に呼び出される
- (BOOL)textField:(UITextField *)textField 
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)text
{
	const NSString *zList = @" 0123456789.+-×÷*/()";  // 許可文字
	
	NSLog(@"textField-----[%@]", text);
	if ([text length]<=0) return YES; // [BS]
	
	NSRange rg = [zList rangeOfString:text];
	if (rg.length==1) return YES;
	//
	if ([text hasPrefix:@"\n"]) {
		[textField resignFirstResponder]; // キーボードを隠す 
	}
	//[self MtextFieldDidChange:textField];
	return NO;
}

// UITextFieldDelegate に無い、 変更「後」イベント。 initWithFrameにてaddTarget追加実装。
- (void)textFieldDidChange:(UITextField *)textField
{
	if (0 < [textField.text length]) {
		if (MdecAnswer) {
			[MdecAnswer release], MdecAnswer = nil;
		}
		if (MtextField.hidden) {  // 数値文字列
			MdecAnswer = [[NSDecimalNumber alloc] initWithString:textField.text];
			if (12 < [textField.text length]) {
				textField.text = [textField.text substringToIndex:12-1];
				Rlabel.text = @"Game Over";
			} else {
				Rlabel.text = textField.text; // 小数以下[0]を入れたとき表示されるように、入力のままにした。
			}
		}
		else {	// 計算式文字列 <<< 演算子が入った
			if (100 < [textField.text length]) {
				textField.text = [textField.text substringToIndex:100-1];
				Rlabel.text = @"Game Over";
			} else {
				// 計算し、答えを MdecAnswer に保持しながら Rlabel.text に表示する
				[self finalAnswer:textField.text];
			}
		}
	} else {
		Rlabel.text = @"";
	}
}


#pragma mark - <Touches>

// タッチイベント
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	//Cancel//[self save];
	Rlabel.text = RzLabelText; // 初期値復元
	[self hide];
}




@end

