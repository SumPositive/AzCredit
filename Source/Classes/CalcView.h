//
//  CalcView.h
//
//  Created by 松山 和正 on 10/01/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CalcView : UIView {
	//--------------------------retain
	UILabel		*Rlabel;		// Rlabel.tag にはCalc入力された数値(long)を記録する
	id			Rentity;		// NSNumber
	NSString	*RzKey;			// @"nAmount"

@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
//	UILabel				*MlbCalcValue;
//	UILabel				*MlbCalcFunc;
	NSMutableArray		*MaObjects;
	//----------------------------------------------assign
	BOOL				MbShow;
	NSMutableString		*MzCalc;
//	double				MdCalcAns; // 演算ボタンを押す度に記録される回答値
//	int					MiFunc;		// (0)Non (1)+ (2)- (3)* (4)/
	//NSString			*MzCalcAns;
}

@property (nonatomic, retain) UILabel		*Rlabel;
@property (nonatomic, retain) id			Rentity;
@property (nonatomic, retain) NSString		*RzKey;	

// 公開メソッド
- (id)initWithFrame:(CGRect)rect;
- (void)show;
- (void)save;
- (void)hide;
- (void)viewDesign:(CGRect)rect;	// 回転時に呼び出す
- (BOOL)isShow;

@end
