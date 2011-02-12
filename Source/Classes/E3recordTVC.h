//
//  E3recordTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "AdMobDelegateProtocol.h"


//@class E2invoice;

@interface E3recordTVC : UITableViewController <UIActionSheetDelegate, AdMobDelegate>
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
	AdMobView			*RoAdMobView;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//ADBannerView		*MbannerView;
	//----------------------------------------------assign
	//BOOL		MbFirstAppear;
	BOOL		MbOptAntirotation;
	//NSInteger	MiForTheFirstSection;		// viewDidAppear内で最初に1回だけ画面スクロール位置調整するため
	//NSIndexPath *MindexPathActionDelete;
	//NSDate		*MdateTop;	// Me3list に読み込まれている先頭の日付
	//NSDate		*MdateNext;
	//NSDate		*MdateTarget;  // !=nil;この日付位置を中央に表示する、クリックした明細の日付を記録する
}

@property (nonatomic, retain) E0root			*Re0root;
@property (nonatomic, assign) E4shop			*Pe4shop;
@property (nonatomic, assign) E5category		*Pe5category;
@property (nonatomic, assign) E8bank			*Pe8bank;
//@property (nonatomic, assign) NSDate			*MdateTarget;

//- (void)viewComeback:(NSArray *)selectionArray;  // Comeback 再現復帰処理用

@end
