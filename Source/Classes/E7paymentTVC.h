//
//  E7paymentTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class E1card;

@interface E7paymentTVC : UITableViewController 
{
@private
	//----------------------------------------------retain
	E0root				*Re0root;
	//----------------------------------------------assign
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//NSAutoreleasePool	*MautoreleasePool;		// [0.3]autorelease独自解放のため
	NSMutableArray		*RaE7list;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	BOOL		MbFirstAppear;
	BOOL		MbOptAntirotation;
	E7payment	*Me7cellButton; // cellLeftButton:にて button.tag をセットして、alertView:にて参照。
}

@property (nonatomic, retain) E0root	*Re0root;

- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用

@end
