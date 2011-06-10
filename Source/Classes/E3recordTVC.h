//
//  E3recordTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

//@class E2invoice;

@interface E3recordTVC : UITableViewController <UIActionSheetDelegate>
{
@private
	//----------------------------------------------retain
	E0root			*Re0root;
	//----------------------------------------------assign
	E4shop			*Pe4shop;		// 
	E5category		*Pe5category;	// 
	E8bank			*Pe8bank;		//[0.3]New
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSMutableArray		*RaE3list;
	NSMutableArray		*RaSection;
	NSMutableArray		*RaIndex;
#ifdef FREE_AD
	GADBannerView		*RoAdMobView;
#endif
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	BOOL		MbOptAntirotation;
	CGPoint		McontentOffsetDidSelect; // didSelect時のScrollView位置を記録
}

@property (nonatomic, retain) E0root			*Re0root;
@property (nonatomic, assign) E4shop			*Pe4shop;
@property (nonatomic, assign) E5category		*Pe5category;
@property (nonatomic, assign) E8bank			*Pe8bank;
//@property (nonatomic, assign) NSDate			*MdateTarget;

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用

@end
