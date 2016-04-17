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
	NSString		*RzLabelText;	// 初期時の Rlabel.text を保持 ⇒ 中止時に戻す
	E3record		*Re3edit;
	//----------------------------------------------assign
	id									__weak delegate;
	UITableView	*__weak PoParentTableView;	//[0.3] スクロールして電卓が画面外に出ると再描画されずに欠けてしまうことを防ぐためスクロール禁止にするため
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSDecimalNumberHandler	*MbehaviorDefault;	// 通貨既定の丸め処理
	NSDecimalNumberHandler	*MbehaviorCalc;		// 計算途中の丸め処理
	NSArray							*RaKeyButtons;
	NSDecimalNumber			*MdecAnswer;
	
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UIScrollView		*MscrollView;
	UITextField			*MtextField;

	//----------------------------------------------assign
	NSInteger			MiRoundingScale;
	BOOL				MbShow;
	int					MiFunc;		// (0)Non (-4)+ (-5)- (-6)* (-7)/
	CGRect				MrectInit;
}

@property (nonatomic, strong) UILabel				*Rlabel;
//@property (nonatomic, retain) id						Rentity;
//@property (nonatomic, retain) NSString			*RzKey;	
@property (nonatomic, weak) UITableView	*PoParentTableView;
@property (nonatomic, weak) id						delegate;

// 公開メソッド
//- (id)initWithFrame:(CGRect)rect;
- (instancetype)initWithFrame:(CGRect)rect withE3:(E3record*)e3 NS_DESIGNATED_INITIALIZER;
- (void)show;
- (void)save;
- (void)cancel;
- (void)hide;
- (void)viewDesign:(CGRect)rect;	// 回転時に呼び出す
@property (NS_NONATOMIC_IOSONLY, getter=isShow, readonly) BOOL show;

@end
