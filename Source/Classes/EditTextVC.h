//
//  EditTextVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTextVC : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) id			Rentity;
@property (nonatomic, strong) NSString		*RzKey;	
@property NSInteger	PiMaxLength;
@property NSInteger	PiSuffixLength;

- (id)initWithFrameSize:(CGSize)size;

@end
