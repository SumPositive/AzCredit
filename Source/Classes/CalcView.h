//
//  CalcView.h
//
//  Created by 松山 和正 on 10/01/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CalcView : UIView {
@private
	//--------------------------retain
	UILabel		*Rlabel;		// Rlabel.tag にはCalc入力された数値(long)を記録する
	id			Rentity;		// NSNumber
	NSString	*RzKey;			// @"nAmount"
	//----------------------------------------------assign
	UITableView	*PoParentTableView;	//[0.3] スクロールして電卓が画面外に出ると再描画されずに欠けてしまうことを防ぐためスクロール禁止にするため

	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableString		*RzCalc;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UILabel				*MlbCalc;
	//NSMutableArray		*MaObjects;
	//----------------------------------------------assign
	BOOL				MbShow;
	double				MdRegister; // 演算ボタンを押す度に記録される回答値
	int					MiFunc;		// (0)Non (-4)+ (-5)- (-6)* (-7)/
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
