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
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) id			Rentity;
@property (nonatomic, retain) NSString		*RzKey;	
@end
