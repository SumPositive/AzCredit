//
//  E5categoryDetailTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface E5categoryDetailTVC : UITableViewController 
{
	//----------------------------------------------retain
	E5category	*Re5edit;
	//----------------------------------------------assign
	BOOL		PbAdd;		//
	BOOL		PbSave;		//
	E3record	*Pe3edit;	// =nil:マスタモード  !=nil:選択モード
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E5category	*Re5edit;
@property BOOL								PbAdd;
@property BOOL								PbSave;
@property (nonatomic, assign) E3record		*Pe3edit;

@end
