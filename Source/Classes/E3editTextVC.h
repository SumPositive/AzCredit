//
//  E3editTextVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E3record;

@interface E3editTextVC : UIViewController <UITextViewDelegate>
{
	//--------------------------retain
	//--------------------------assign
	E3record		*Pe3;
	NSInteger	PiField;		// (0)zName  (1)zNote
	NSInteger	PiMaxLength;	// 最大文字数　==nil:無制限
	NSInteger	PiSuffixLength; // 末尾の改行の数（UILabel複数行で上寄せするために入っている）

@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UITextView	*MtextView; // self.viewがOwner
	//----------------------------------------------assign
	BOOL MbOptShouldAutorotate;
}

@property (nonatomic, assign) E3record		*Pe3;
@property NSInteger	PiField;
@property NSInteger	PiMaxLength;
@property NSInteger	PiSuffixLength;
@end
