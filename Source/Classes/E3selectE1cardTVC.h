//
//  E3selectE1cardTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E3selectE1cardTVC : UITableViewController 
{
	//--------------------------retain
	//--------------------------assign
	E1card		**PPe1card;	// ＜＜オブジェクトのポインタをポインタ渡ししている＞＞
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray	*Me1cards;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	BOOL MbOptShouldAutorotate;
}

@property (nonatomic, assign) E1card	**PPe1card;
@end
