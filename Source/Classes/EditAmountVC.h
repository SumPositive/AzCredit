//
//  EditAmountVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditAmountVC : UIViewController <UITextFieldDelegate>
{
	//--------------------------retain
	id			Rentity;
	NSString	*RzKey;			// @"zName"
	//--------------------------assign

@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UITextField	*MtfAmount; // self.viewがOwner   // 将来的には外貨対応
	UILabel		*MlbAmount;
/*	//--------------Calc----------
	UIButton	*MbuCalcN0;
	UIButton	*MbuCalcN1;
	UIButton	*MbuCalcN2;
	UIButton	*MbuCalcN3;
	UIButton	*MbuCalcN4;
	UIButton	*MbuCalcN5;
	UIButton	*MbuCalcN6;
	UIButton	*MbuCalcN7;
	UIButton	*MbuCalcN8;
	UIButton	*MbuCalcN9;
	UIButton	*MbuCalc00;
	UIButton	*MbuCalcAdd;
	UIButton	*MbuCalcSubtraction;
	UIButton	*MbuCalcMultiplication;
	UIButton	*MbuCalcDivision;
	UIButton	*MbuCalcEqual;
	UIButton	*MbuCalcBack;
	UIButton	*MbuCalcClear;
	UIButton	*MbuCalcDecimal;
	UIButton	*MbuCalcTaxAdd;
	UIButton	*MbuCalcTaxSubtraction;
*/
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) id			Rentity;
@property (nonatomic, retain) NSString		*RzKey;	
@end
