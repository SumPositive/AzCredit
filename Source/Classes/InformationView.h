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
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
}

// 公開メソッド
//- (id)initWithFrame:(CGRect)rect;
//- (void)show;
- (id)init;
- (void)hide;

@end
