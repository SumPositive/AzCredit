//
//  E3recordTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

//@class E2invoice;

@interface E3recordTVC : UITableViewController <UIActionSheetDelegate>
{
	//----------------------------------------------retain
	E0root			*Re0root;
	//----------------------------------------------assign
	E4shop			*Pe4shop;		// 
	E5category		*Pe5category;	// 
	E8bank			*Pe8bank;		//[0.3]New
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	NSAutoreleasePool	*MautoreleasePool;		// [0.3]autorelease独自解放のため
	NSMutableArray		*Me3list;
	NSMutableArray		*Msection;
	NSMutableArray		*Mindex;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//ADBannerView		*MbannerView;
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
@property (nonatomic, assign) E8bank			*Pe8bank;

- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用

@end
