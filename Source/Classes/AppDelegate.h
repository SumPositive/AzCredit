//
//  AppDelegate.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#include <AVFoundation/AVFoundation.h>
#ifdef AzPAD
#import "padRootVC.h"
#endif

//iOS6以降、回転対応のためサブクラス化が必要になった。
@interface AzNavigationController : UINavigationController
@end

@class TopMenuTVC;
@class LoginPassVC;

@interface AppDelegate : NSObject <UIApplicationDelegate, UITextFieldDelegate, AVAudioPlayerDelegate>
{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow			*window;

	BOOL				entityModified;		// E1,3,4,5,8detail詳細の一部でも変更あり ==> YES

#ifdef AzPAD
	UISplitViewController		*mainController;
    UIBarButtonItem				*barMenu;
#else
    AzNavigationController	*mainController;
#endif
	
//	NSMutableArray		*RaComebackIndex;	// an array of selections for each drill level
	// i.e.
	// [0, 100002, 300015] =	at level 1 drill/ section=0 row=0, (section=100002 / GD_SECTION_TIMES)
	//							at level 2 drill/ section=1 row=2,
	//							at level 3 drill/ section=3 row=15,
	// i.e.
	// [1, -1, -1] =		at level 1 drill/ section=0 row=1,
	//						no selection at level 2 (it's -1) so stay at level 2

//	EntityRelation *RentityRelation;
	
@private
	//-------------------------------------retain
	NSDate				*Me3dateUse;			// autoreleseオブジェクト限定	//ポインタ代入注意！copyすること
	//-------------------------------------assign
}

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, weak, readonly) NSString		*applicationDocumentsDirectory;
@property (nonatomic, strong) UIWindow						*window;
@property (nonatomic, strong) NSDate							*Me3dateUse;
@property (nonatomic, assign) BOOL							entityModified;

#ifdef AzPAD
@property (nonatomic, retain) UISplitViewController		*mainController;
@property (nonatomic, assign) UIBarButtonItem				*barMenu;
#else
@property (nonatomic, strong) UINavigationController		*mainController;
#endif

- (void)audioPlayer:(NSString*)filename;

@end

