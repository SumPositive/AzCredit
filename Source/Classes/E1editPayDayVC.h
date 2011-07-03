//
//  E1editPayDayVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E1card;
#ifdef AzPAD
//@class PadPopoverInNaviCon;
#endif

@interface E1editPayDayVC : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
@private
	//--------------------------retain
	E1card		*Re1edit;
#ifdef AzPAD
	id									delegate;
	UIPopoverController*	selfPopover;  // 自身を包むPopover  閉じる為に必要
#endif
	//--------------------------assign
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UIPickerView	*Mpicker;
	UILabel			*MlbClosing;
	UILabel			*MlbPayMonth;
	UILabel			*MlbPayDay;
	UIButton		*MbuDebit;
	UILabel			*MlbDebit;
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E1card		*Re1edit;
#ifdef AzPAD
@property (nonatomic, assign) id									delegate;
@property (nonatomic, retain) UIPopoverController*	selfPopover;
#endif

@end
