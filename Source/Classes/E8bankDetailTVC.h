//
//  E8bankDetailTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class E0root;

@interface E8bankDetailTVC : UITableViewController 
{
	//----------------------------------------------retain
	E8bank		*Re8edit;
	//----------------------------------------------assign
	NSInteger	PiAddRow;	// (-1)Edit
	BOOL		PbSave;		//
	E1card		*Pe1edit;	// =nil:マスタモード  !=nil:選択モード
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSAutoreleasePool	*MautoreleasePool;		// [0.3]autorelease独自解放のため
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UILabel		*MlbNote;
	//----------------------------------------------assign - Entity fields
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E8bank	*Re8edit;
@property NSInteger						PiAddRow;
@property BOOL							PbSave;
@property (nonatomic, assign) E1card	*Pe1edit;

@end
