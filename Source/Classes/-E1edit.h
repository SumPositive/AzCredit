//
//  E1edit.h
//  iPack
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
// InterfaceBuilderを使わずに作ったViewController

#import <UIKit/UIKit.h>

@interface E1edit : UIViewController  <UITextFieldDelegate, UITextViewDelegate>
{
	E1			*Pe1target;  // IはInstance、aはassign を示す
	NSInteger	PiAddRow;    // (>=0)Add  (-1)Edit
}

@property (nonatomic, retain) E1 *Pe1target;
@property NSInteger PiAddRow;

@end

