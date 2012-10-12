//
//  EditDateVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E3record;
@class CalcView;

@interface EditDateVC : UIViewController
{
@private
	//--------------------------retain
	E3record		*Re3edit;			// !=nil : E3record変更モード（日付）
	E6part			*Re6edit;			// !=nil : E6part変更モード（日付、金額）
	//--------------------------assign
	id						delegate;			// editDateE6change を呼び出すため
	NSInteger	PiMinYearMMDD;
	NSInteger	PiMaxYearMMDD;
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UIDatePicker	*MdatePicker;
	UIButton		*MbuToday;			// E3:Todayにリセットする
	UIButton		*MbuYearTime;		// E3:時刻部有無　　　E6：金額
	UILabel		*MlbAmount;
	CalcView					*McalcView;
	//----------------------------------------------assign
	//NSInteger	PiE6row;				//[1.0.0]E6date変更モード
	//BOOL MbOptAntirotation;
	BOOL MbOptUseDateTime;
	NSTimeInterval	MintervalPrev;
}

//@property (nonatomic, retain) id					Rentity;
//@property (nonatomic, retain) NSString		*RzKey;	
@property (nonatomic, assign) id					delegate;
@property (nonatomic, assign) NSInteger	PiMinYearMMDD;
@property (nonatomic, assign) NSInteger	PiMaxYearMMDD;

//- (id)init;	//E3.dateUser
//- (id)initWithE6row:(NSUInteger)iRow;	//[1.0.0]E6date変更モード
- (id)initWithE3:(E3record*)e3 orE6:(E6part*)e6;

@end
