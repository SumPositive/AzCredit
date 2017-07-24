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

@property (nonatomic, strong) UILabel				*Rlabel;
@property (nonatomic, strong) UITableView             *PoParentTableView;
@property (nonatomic, strong) id						delegate;

// 公開メソッド
- (instancetype)initWithFrame:(CGRect)rect withE3:(E3record*)e3; // NS_DESIGNATED_INITIALIZER;
- (void)show;
- (void)save;
- (void)cancel;
- (void)hide;
- (void)viewDesign:(CGRect)rect;	// 回転時に呼び出す

@end
