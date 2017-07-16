//
//  E1editPayDayVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//--------------------------------------------------------------------------
// 締日	1〜28,29=末日, Debit(0)当日
// 支払月 (0)当月　(1)翌月　(2)翌々月, Debit(0)当月
// 支払日 1〜28,29=末日, Debit(0〜99)日後払
//--------------------------------------------------------------------------

@class E1card;
@interface E1editPayDayVC : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
@private
//	E1card		*Re1edit;
	UIPickerView	*Mpicker;
	UILabel			*MlbClosing;
	UILabel			*MlbPayMonth;
	UILabel			*MlbPayDay;
	UIButton			*MbuDebit;
	UILabel			*MlbDebit;
	//BOOL MbOptAntirotation;
	NSInteger	sourceClosingDay;
	NSInteger	sourcePayMonth;
	NSInteger	sourcePayDay;
}

@property (nonatomic, strong) E1card		*Re1edit;

@end
