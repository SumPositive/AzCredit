//
//  WebSiteVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/02/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebSiteVC : UIViewController <UIWebViewDelegate>
{

@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UIWebView *MwebView;
	UIBarButtonItem *MbuBack;
	UIBarButtonItem *MbuReload;
	UIBarButtonItem *MbuForward;
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@end
