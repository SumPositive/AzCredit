//
//  TopMenuTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class	InformationView;

@interface TopMenuTVC : UITableViewController 
{
	E0root				*Re0root;
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	InformationView *MinformationView;
	//----------------------------------------------assign
	NSInteger	MiE1cardCount;
	BOOL MbOptAntirotation;
	BOOL MbOptEnableSchedule;
	BOOL MbOptEnableCategory;
}

@property (nonatomic, retain) E0root				*Re0root;

- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用
@end
