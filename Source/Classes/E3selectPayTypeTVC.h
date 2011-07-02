//
//  E3selectPayTypeTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef AzPAD
@class PadPopoverInNaviCon;
#endif

@interface E3selectPayTypeTVC : UITableViewController 
{
@private
	//--------------------------retain
	E3record		*Re3edit;
#ifdef AzPAD
	UIPopoverController*	Rpopover;
#endif
	//--------------------------assign
	id					delegate;
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E3record		*Re3edit;
@property (nonatomic, assign) id					delegate;
#ifdef AzPAD
@property (nonatomic, retain) UIPopoverController*	Rpopover;
#endif

@end
