//
//  AppDelegate.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#include <AVFoundation/AVFoundation.h>
#import "PadRootVC.h"

//iOS6以降、回転対応のためサブクラス化が必要になった。
@interface AzNavigationController : UINavigationController
@end

@class TopMenuTVC;
@class LoginPassVC;

@interface AppDelegate : NSObject <UIApplicationDelegate, UITextFieldDelegate>
{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

@private
	NSDate				*Me3dateUse;			// autoreleseオブジェクト限定	//ポインタ代入注意！copyすること
}

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, weak, readonly) NSString		*applicationDocumentsDirectory;
@property (nonatomic, strong) UIWindow						*window;
@property (nonatomic, strong) NSDate						*Me3dateUse;
@property (nonatomic, assign) BOOL							entityModified;

@property (nonatomic, retain) UISplitViewController		*mainSplit;
@property (nonatomic, assign) UIBarButtonItem			*barMenu;
@property (nonatomic, strong) UINavigationController	*mainNavi;

@end

