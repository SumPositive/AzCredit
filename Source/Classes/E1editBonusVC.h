//
//  E1editBonusVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E1card;

@interface E1editBonusVC : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
@private
	//--------------------------retain
	E1card		*Re1edit;
	//--------------------------assign
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UIPickerView	*Mpicker;
	UILabel *MlbBonus1;
	UILabel *MlbBonus2;
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E1card		*Re1edit;

@end
