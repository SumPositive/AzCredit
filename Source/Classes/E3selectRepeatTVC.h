//
//  E3selectRepeatTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef AzPAD
@class PadPopoverInNaviCon;
#endif

@interface E3selectRepeatTVC : UITableViewController 
{
@private
	//--------------------------retain
	E3record		*Re3edit;
#ifdef AzPAD
	PadPopoverInNaviCon*	RpopNaviCon;
#endif
	//--------------------------assign
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E3record		*Re3edit;
#ifdef AzPAD
@property (nonatomic, retain) PadPopoverInNaviCon*	RpopNaviCon;
#endif

@end
