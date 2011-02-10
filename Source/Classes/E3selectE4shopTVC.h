//
//  E3selectE4shopTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E3selectE4shopTVC : UITableViewController 
{
	//--------------------------retain
	//--------------------------assign
	E4shop		**PPe4shop;	// ＜＜オブジェクトのポインタをポインタ渡ししている＞＞
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray	*Me4shops;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	BOOL MbOptShouldAutorotate;
}

@property (nonatomic, assign) E4shop		**PPe4shop;
@end
