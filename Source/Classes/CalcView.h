//
//  CalcView.h
//
//  Created by 松山 和正 on 10/01/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GOLDENPER				1.618	// 黄金比
#define MINUS_SIGN				@"−"	// Unicode[2212] 表示用文字　[002D]より大きくするため
#define ANSWER_MAX				99999999.991	// double近似値で比較するため+0.001してある


@interface CalcView : UIView <UITextFieldDelegate>
{
@private
	//--------------------------retain
	UILabel		*Rlabel;		// Rlabel.tag にはCalc入力された数値(long)を記録する
	id			Rentity;		// NSNumber
	NSString	*RzKey;			// @"nAmount"
	//----------------------------------------------assign
	UITableView	*PoParentTableView;	//[0.3] スクロールして電卓が画面外に出ると再描画されずに欠けてしまうことを防ぐためスクロール禁止にするため

	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//NSMutableString			*RzCalc;
	NSDecimalNumberHandler	*MbehaviorDefault;	// 通貨既定の丸め処理
	NSDecimalNumberHandler	*MbehaviorCalc;		// 計算途中の丸め処理
	NSArray					*RaKeyButtons;
	NSDecimalNumber			*MdecAnswer;
	
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//UILabel			*MlbCalc;
	UIScrollView		*MscrollView;
	//UITextView		*MtextView;
	UITextField			*MtextField;
	//NSMutableArray	*MaObjects;

	//----------------------------------------------assign
	NSInteger			MiRoundingScale;
	BOOL				MbShow;
	//double				MdRegister; // 演算ボタンを押す度に記録される回答値
	//NSDecimalNumber		*MdRegister; // 演算ボタンを押す度に記録される回答値
	int					MiFunc;		// (0)Non (-4)+ (-5)- (-6)* (-7)/
	CGRect				MrectInit;
}

@property (nonatomic, retain) UILabel		*Rlabel;
@property (nonatomic, retain) id			Rentity;
@property (nonatomic, retain) NSString		*RzKey;	
@property (nonatomic, assign) UITableView	*PoParentTableView;

// 公開メソッド
- (id)initWithFrame:(CGRect)rect;
- (void)show;
- (void)save;
- (void)hide;
- (void)viewDesign:(CGRect)rect;	// 回転時に呼び出す
- (BOOL)isShow;

@end
