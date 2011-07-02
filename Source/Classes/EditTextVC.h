//
//  EditTextVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef AzPAD
@class PadPopoverInNaviCon;
#endif

@interface EditTextVC : UIViewController <UITextViewDelegate>
{
@private
	//--------------------------retain
	id			Rentity;
	NSString	*RzKey;			// @"zName"
#ifdef AzPAD
	UIPopoverController*	Rpopover;
#endif
	//--------------------------assign
	NSInteger	PiMaxLength;	// 最大文字数　==nil:無制限
	NSInteger	PiSuffixLength; // 末尾の改行の数（UILabel複数行で上寄せするために入っている）
	id					delegate;

	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UITextView	*MtextView; // self.viewがOwner
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) id			Rentity;
@property (nonatomic, retain) NSString		*RzKey;	
@property NSInteger	PiMaxLength;
@property NSInteger	PiSuffixLength;
@property (nonatomic, assign) id					delegate;
#ifdef AzPAD
@property (nonatomic, retain) UIPopoverController*	Rpopover;
#endif

@end
