//
//  E3selectRepeatTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E3selectRepeatTVC : UITableViewController 
{
@private
	//--------------------------retain
	E3record		*Re3edit;
	//--------------------------assign
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E3record		*Re3edit;
@end