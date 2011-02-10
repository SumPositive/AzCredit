//
//  HttpServerView.h
//  AzCredit-0.3
//
//  Created by 松山 和正 on 10/06/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTTPServer;

@interface HttpServerView : UIView {
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	HTTPServer			*httpServer;
	UIAlertView			*MalertHttpServer;
	//----------------------------------------------assign
	E0root				*Re0root;

@private
	NSAutoreleasePool	*MautoreleasePool;		// [0.3]autorelease独自解放のため
	NSDictionary		*MdicAddresses;
}

@property (nonatomic, assign) E0root		*Re0root;

// 公開メソッド
- (void)show;
- (void)hide;

@end
