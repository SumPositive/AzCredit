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
@private
	//--------------------------retain
	id					Rentity;
	NSString		*RzKey;			// @"dateUse"    //[1.0.0]E6date変更モード="E6date"
	E6part			*Re6edit;
	//--------------------------assign
	NSInteger	PiMinYearMMDD;
	NSInteger	PiMaxYearMMDD;
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UIDatePicker	*MdatePicker;
	UIButton		*MbuToday;			// Todayにリセットする
	UIButton		*MbuYearTime;		// UIDatePickerModeDate, UIDatePickerModeDateAndTime を切り替える
	//----------------------------------------------assign
	NSInteger	PiE6row;				//[1.0.0]E6date変更モード
	BOOL MbOptAntirotation;
	BOOL MbOptUseDateTime;
	NSTimeInterval	MintervalPrev;
}

@property (nonatomic, retain) id					Rentity;
@property (nonatomic, retain) NSString		*RzKey;	
@property (nonatomic, assign) NSInteger	PiMinYearMMDD;
@property (nonatomic, assign) NSInteger	PiMaxYearMMDD;
//@property (nonatomic, assign) NSInteger	PiE6row;

- (id)init;	//E3.dateUser
- (id)initWithE6row:(NSUInteger)iRow;	//[1.0.0]E6date変更モード

@end
