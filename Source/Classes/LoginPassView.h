//
//  LoginPassView.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class E1card;

@interface LoginPassView : UIView <UITextFieldDelegate>
{
@private
	//--------------------------retain
	//--------------------------assign
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
}

@end
