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
@private
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	HTTPServer			*RhttpServer;
	UIAlertView			*RalertHttpServer;
	//----------------------------------------------assign
	E0root				*Pe0root;

	//NSAutoreleasePool	*MautoreleasePool;		// [0.3]autorelease独自解放のため
	NSDictionary		*MdicAddresses;
}

@property (nonatomic, assign) E0root		*Pe0root;

// 公開メソッド
- (void)show;
- (void)hide;

@end
