//
//  SettingTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTVC : UITableViewController  <UITextFieldDelegate>
{

@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UITextField  *MtfPass1;
	UITextField  *MtfPass2;
	//UITextField  *MtfTaxRate;
	UILabel		*MlbTaxRate;
	//----------------------------------------------assign
	//BOOL MbOptBootTopView;
	//BOOL MbOptAntirotation;
}

@end
