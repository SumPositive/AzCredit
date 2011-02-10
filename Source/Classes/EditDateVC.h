//
//  EditDateVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E3record;

@interface EditDateVC : UIViewController
{
	//--------------------------retain
	id			Rentity;
	NSString	*RzKey;			// @"dateUse"
	//--------------------------assign
	NSInteger	PiMinYearMMDD;
	NSInteger	PiMaxYearMMDD;
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UIDatePicker	*MdatePicker;
	UIButton		*MbuToday;		// Todayにリセットする
	UIButton		*MbuYearTime;		// UIDatePickerModeDate, UIDatePickerModeDateAndTime を切り替える
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
	BOOL MbOptUseDateTime;
}

@property (nonatomic, retain) id			Rentity;
@property (nonatomic, retain) NSString		*RzKey;	
@property (nonatomic, assign) NSInteger		PiMinYearMMDD;
@property (nonatomic, assign) NSInteger		PiMaxYearMMDD;

@end
