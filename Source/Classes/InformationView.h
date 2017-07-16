//
//  InformationView.h
//  iPack
//
//  Created by 松山 和正 on 10/01/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InformationView : UIViewController  <MFMailComposeViewControllerDelegate> {
@private
#ifdef AzSTABLE	//2.0移行のため、招待パスコードをコピーする機能を実装
	NSString		*zPassCode_;
#endif
}

// 公開メソッド
//- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (void)hide;

@end
