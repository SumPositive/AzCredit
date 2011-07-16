//
//  AppDelegate.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#ifdef AzPAD
#import "padRootVC.h"
#endif

@class TopMenuTVC;
@class LoginPassVC;

@interface AppDelegate : NSObject <UIApplicationDelegate, UITextFieldDelegate>
{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;

#ifdef AzPAD
	//PadRootVC						*padRootVC;
	UISplitViewController		*mainController;
    UIBarButtonItem				*barMenu;
#else
    UINavigationController	*mainController;
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
	NSDate				*Me3dateUse;
	//-------------------------------------assign
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) UIWindow					*window;
#ifdef AzPAD
//@property (nonatomic, retain) PadRootVC						*padRootVC;  //解放されないようにretain
@property (nonatomic, retain) UISplitViewController		*mainController;
@property (nonatomic, assign) UIBarButtonItem				*barMenu;
#else
@property (nonatomic, retain) UINavigationController		*mainController;
#endif
@property (nonatomic, retain) NSDate					*Me3dateUse;

@property (nonatomic, assign, readonly) NSString		*applicationDocumentsDirectory;

@end

