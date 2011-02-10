//
//  E2edit.h
//  iPack
//
//  Created by 松山 和正 on 09/12/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
// InterfaceBuilderを使わずに作ったViewController

#import <UIKit/UIKit.h>

@interface E2edit : UIViewController  <UITextFieldDelegate, UITextViewDelegate> 
{
	E1 *Pe1selected;  // Edit時は IaE2target.parent と同値であるが、Add時にはこれを頼りにする必要がある。 
	E2 *Pe2target;
	NSInteger PiAddRow;  // (>=0)Add  (-1)Edit
}

@property (nonatomic, retain) E1 *Pe1selected;
@property (nonatomic, retain) E2 *Pe2target;
@property NSInteger PiAddRow;

@end
