//
//  EditTextVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTextVC : UIViewController <UITextViewDelegate>
{
@private
	//--------------------------retain
	id					Rentity;
	NSString		*RzKey;			// @"zName"
	//--------------------------assign
	NSInteger	PiMaxLength;	// 最大文字数　==0:無制限
	NSInteger	PiSuffixLength; // 末尾の改行の数（UILabel複数行で上寄せするために入っている）
	NSString		*sourceText;	//変更前の文字列を記録し、[Done]にて比較して変更の有無を判定している
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UITextView	*MtextView; // self.viewがOwner
	//----------------------------------------------assign
	//BOOL MbOptAntirotation;
}

@property (nonatomic, strong) id			Rentity;
@property (nonatomic, strong) NSString		*RzKey;	
@property NSInteger	PiMaxLength;
@property NSInteger	PiSuffixLength;

//#ifdef AzPAD
- (id)initWithFrameSize:(CGSize)size;
//#endif

@end
