//
//  E4shopDetailTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface E4shopDetailTVC : UITableViewController 
{
	//----------------------------------------------retain
	E4shop		*Re4edit;
	//----------------------------------------------assign
	BOOL		PbAdd;		// =YES:新規追加モード
	BOOL		PbSave;		//
	E3record	*Pe3edit;	// =nil:マスタモード  !=nil:選択モード
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E4shop	*Re4edit;
@property BOOL							PbAdd;
@property BOOL							PbSave;
@property (nonatomic, assign) E3record	*Pe3edit;

@end
