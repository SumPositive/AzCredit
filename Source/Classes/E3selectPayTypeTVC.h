//
//  E3selectPayTypeTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface E3selectPayTypeTVC : UITableViewController 
{
@private
	//--------------------------retain
//	E3record			*Re3edit;
//	id						__weak delegate;
	//--------------------------assign
	NSInteger	sourcePayType;
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	//BOOL MbOptAntirotation;
}

@property (nonatomic, strong) E3record		*Re3edit;
@property (nonatomic, weak) id					delegate;

@end
