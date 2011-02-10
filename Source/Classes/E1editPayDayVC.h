//
//  E1editPayDayVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E1card;

@interface E1editPayDayVC : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
	//--------------------------retain
	E1card		*Re1edit;
	//--------------------------assign
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UIPickerView	*Mpicker;
	UILabel *MlbClosing;
	UILabel *MlbPayMonth;
	UILabel *MlbPayDay;
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E1card		*Re1edit;

@end
