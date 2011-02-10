//
//  E3recordTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class E2invoice;

@interface E3recordTVC : UITableViewController <UIActionSheetDelegate>
{
	//----------------------------------------------retain
	E0root			*Re0root;
	//----------------------------------------------assign
	E4shop			*Pe4shop;		// 
	E5category		*Pe5category;	// 
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray	*Me3list;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	BOOL		MbFirstAppear;
	BOOL		MbOptAntirotation;
	NSInteger	MiForTheFirstSection;		// viewDidAppear内で最初に1回だけ画面スクロール位置調整するため
	NSIndexPath *MindexPathActionDelete;
}

@property (nonatomic, retain) E0root			*Re0root;
//@property (nonatomic, assign) E1card			*Pe1card;
@property (nonatomic, assign) E4shop			*Pe4shop;
@property (nonatomic, assign) E5category		*Pe5category;

- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用

@end
