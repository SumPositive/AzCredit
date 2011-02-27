//
//  AppDelegate.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

//#import "AdMobDelegateProtocol.h"
//#import "AdMobInterstitialDelegateProtocol.h"
//#import "AdMobInterstitialAd.h"

#define VIEW_TAG_LOGINPASS			9001
#define VIEW_TAG_HttpServer			9010

@class MocFunctions;

@interface AppDelegate : NSObject <UIApplicationDelegate, UITextFieldDelegate>
											// AdMobDelegate, AdMobInterstitialDelegate>
{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;
    UINavigationController *navigationController;

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
	UIView				*MviewLogin;
	BOOL				MbLoginShow;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) UIWindow					*window;
@property (nonatomic, retain) UINavigationController	*navigationController;
@property (nonatomic, retain) NSDate					*Me3dateUse;

@property (nonatomic, assign, readonly) NSString		*applicationDocumentsDirectory;
@property (nonatomic, assign, readonly) BOOL			MbLoginShow;

- (IBAction)saveAction:sender;
//- (BOOL)appDidBecomeActive;

@end

