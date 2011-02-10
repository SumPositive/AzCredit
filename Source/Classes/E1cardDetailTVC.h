//
//  E1cardDetailTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E0root;

@interface E1cardDetailTVC : UITableViewController 
{
	//----------------------------------------------retain
	E1card		*Re1edit;
	//----------------------------------------------assign
	NSInteger	PiAddRow;	// (-1)Edit
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSAutoreleasePool	*MautoreleasePool;		// [0.3]autorelease独自解放のため
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UILabel		*MlbNote;
	//----------------------------------------------assign - Entity fields
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E1card	*Re1edit;
@property NSInteger						PiAddRow;

@end
