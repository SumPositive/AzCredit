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
	UITextField  *MtfPass1;
	UITextField  *MtfPass2;
	UILabel		*MlbTaxRate;
}

@end
