//
//  AppDelegate.m
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
// MainWindow.xlb を使用しない

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "EntityRelation.h"
#import "TopMenuTVC.h"

static NSString *kComebackIndexKey = @"ComebackIndex";	// preference key to obtain our restore location

@implementation AppDelegate
@synthesize window;
@synthesize navigationController;
@synthesize comebackIndex;
//@synthesize RentityRelation;

- (void)dealloc 
{
//	AzRETAIN_CHECK(@"AppDelegate RentityRelation", RentityRelation, 1)
//	[RentityRelation release];
	AzRETAIN_CHECK(@"AppDelegate comebackIndex", comebackIndex, 1)
	[comebackIndex release];
	AzRETAIN_CHECK(@"AppDelegate navigationController", navigationController, 1)
	[navigationController release];
	AzRETAIN_CHECK(@"AppDelegate window", window, 1)
	[window release];
	
	AzRETAIN_CHECK(@"AppDelegate persistentStoreCoordinator", persistentStoreCoordinator, 1)
    [persistentStoreCoordinator release];
	AzRETAIN_CHECK(@"AppDelegate managedObjectContext", managedObjectContext, 1)
    [managedObjectContext release];
	AzRETAIN_CHECK(@"AppDelegate managedObjectModel", managedObjectModel, 1)
    [managedObjectModel release];

	[super dealloc];
}

#pragma mark -
#pragma mark Application lifecycle

//<iOS4> - (void)applicationDidFinishLaunching:(UIApplication *)application
- (BOOL)application:(UIApplication *)application 
					didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // MainWindow    ＜＜MainWindow.xlb を使用しないため、ここで生成＞＞
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	//-------------------------------------------------Option Setting Defult
	// User Defaultsを使い，キー値を変更したり読み出す前に，NSUserDefaultsクラスのインスタンスメソッド
	// registerDefaultsメソッドを使い，初期値を指定します。
	// [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	// ここで，appDefaultsは環境設定で初期値となるキー・バリューペアのNSDictonaryオブジェクトです。
	// このメソッドは，すでに同じキーの環境設定が存在する場合，上書きしないので，環境設定の初期値を定めることに使えます。
	NSDictionary *azOptDef = [NSDictionary dictionaryWithObjectsAndKeys: // コンビニエンスコンストラクタにつきrelease不要
							  @"NO",	GD_OptBootTopView,			// TopView
							  @"NO",	GD_OptAntirotation,			// 回転防止
						//	  @"YES",	GD_OptEnableSchedule,		// 支払予定
						//	  @"YES",	GD_OptEnableCategory,		// 分類
							  @"NO",	GD_OptEnableInstallment,	// 分割払い
							  @"NO",	GD_OptUseDateTime,			// 利用日：時刻なし
							  @"NO",	GD_OptNumAutoShow,			// ＜保留＞ テンキー自動表示
							  @"NO",	GD_OptFixedPriority,		// ＜保留＞ 修正を優先
							  @"YES",	GD_OptAmountCalc,			// [0.3.1] 電卓使用
							  nil];

	[userDefaults registerDefaults:azOptDef];	// 未定義のKeyのみ更新される
	[userDefaults synchronize]; // plistへ書き出す ＜＜通常は一定の間隔で自動的に保存されるので、特別に保存したいときにこのメソッドを使う＞＞
	
	//-------------------------------------------------E0（固有ノード）が無ければ追加する
	E0root *e0node = nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"E0root" 
											  inManagedObjectContext:self.managedObjectContext]; 
														//上記の最初の self.managedObjectContextメソッド呼び出しにてCoreData初期化される
	[fetchRequest setEntity:entity];
	// Fitch
	NSError *error = nil;
	NSArray *arFetch = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		AzLOG(@"Error: %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	[fetchRequest release];
	if ([arFetch count] == 1) {
		e0node = [arFetch objectAtIndex:0]; // 未払い計を表示するためTopMenuTVCへ渡す
	}
	else if ([arFetch count] <= 0) {
		// Add E0root
		e0node = [NSEntityDescription insertNewObjectForEntityForName:@"E0root"
											   inManagedObjectContext:self.managedObjectContext];
		// SAVE
		error = nil;
		if (![self.managedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
	}
	else {
		AzLOG(@"Error: E0root count = %d", [arFetch count]);
		exit(-1);  // Fail
	}
	
	//-------------------------------------------------
	TopMenuTVC *topMenuTvc = [[TopMenuTVC alloc] init];
	topMenuTvc.Re0root = e0node; // TopMenuTVC側でretain
	// topMenu を naviCon へ登録
	navigationController = [[UINavigationController alloc] 
									   initWithRootViewController:topMenuTvc];
	[topMenuTvc release];
	// NavCon を window へ登録
	[window addSubview:navigationController.view];
	AzRETAIN_CHECK(@"AppDelegate naviCon", navigationController, 2)
	
	
#ifdef AzMAKE_SPLASHFACE
	self.comebackIndex = nil;
#else
	if ([userDefaults boolForKey:GD_OptBootTopView]) {
		// 起動時、TopView　　（前回復帰しない）
		self.comebackIndex = nil;
	} else {
		// [Comeback] 前回の画面表示に復帰させる
		// load the stored preference of the user's last location from a previous launch
		NSMutableArray *tempMutableCopy = [[userDefaults objectForKey:kComebackIndexKey] mutableCopy];
		self.comebackIndex = tempMutableCopy;
		AzRETAIN_CHECK(@"AppDelegate tempMutableCopy", tempMutableCopy, 2)
		[tempMutableCopy release];
	}
#endif
	
	if (self.comebackIndex == nil)
	{
		// 新規起動時
		// user has not launched this app nor navigated to a particular level yet, start at level 1, with no selection
		self.comebackIndex = [[NSMutableArray arrayWithObjects:	// (long型／intではOverflow)
							   [NSNumber numberWithLong:-1],	//L0: TopMenu
							   [NSNumber numberWithLong:-1],	//L1: E1card, E3record, E4shop, E5category, E7payment
							   [NSNumber numberWithLong:-1],	//L2: E2invoice, E3record, E6part
							   [NSNumber numberWithLong:-1],	//L3: E6part
							   [NSNumber numberWithLong:-1],	//L4: 
							   nil] retain];
	}
	else
	{
		// 復帰
		NSInteger idx = [[self.comebackIndex objectAtIndex:0] integerValue]; // read the saved selection at level 1
		if (idx != -1)
		{
			[topMenuTvc viewWillAppear:NO]; // Fech データセットさせるため
			[topMenuTvc viewComeback:self.comebackIndex];
		}
		else
		{
			// no saved selection, so user was at level 1 the last time
		}
	}

	[window makeKeyAndVisible];	// 表示開始
	
	// register our preference selection data to be archived
	NSDictionary *indexComebackDict = [NSDictionary dictionaryWithObject:self.comebackIndex 
																  forKey:kComebackIndexKey];
	[userDefaults registerDefaults:indexComebackDict];
	[userDefaults synchronize]; // plistへ書き出す

	return YES;  //iOS4
}

- (void)applicationWillResignActive:(UIApplication *)application 
{	//iOS4: アプリケーションがアクティブでなくなる直前に呼ばれる
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
	AzLOG(@"applicationWillResignActive");
}


- (void)applicationDidEnterBackground:(UIApplication *)application 
{	//iOS4: アプリケーションがバックグラウンドになったら呼ばれる
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
	 */
	AzLOG(@"applicationDidEnterBackground");
	
	[self applicationWillTerminate:application]; //iOS3以前の終了処理
}


- (void)applicationWillEnterForeground:(UIApplication *)application 
{	//iOS4: アプリケーションがバックグラウンドから復帰する直前に呼ばれる
	/*
	 Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
	 */
	AzLOG(@"applicationWillEnterForeground");
}


- (void)applicationDidBecomeActive:(UIApplication *)application 
{	//iOS4: アプリケーションがアクティブになったら呼ばれる
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
	AzLOG(@"applicationDidBecomeActive");
}


// saves changes in the application's managed object context before the application terminates.
- (void)applicationWillTerminate:(UIApplication *)application 
{	// バックグラウンド実行中にアプリが終了された場合に呼ばれる。
	// ただしアプリがサスペンド状態の場合アプリを終了してもこのメソッドは呼ばれない。

	// iOS3互換のためにはここが必要。　iOS4以降、applicationDidEnterBackground から呼び出される。

    if (managedObjectContext != nil) {
        /***** 新規登録途中に閉じた場合など、保存しないため。 RollBackする
		 if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        }*/ 

        if ([managedObjectContext hasChanges]) {
			[managedObjectContext rollback];
        } 
    }

	// save the drill-down hierarchy of selections to preferences
	[[NSUserDefaults standardUserDefaults] setObject:self.comebackIndex forKey:kComebackIndexKey];
	// この時点ではメモリ上で更新されただけ。
	[[NSUserDefaults standardUserDefaults] synchronize]; // plistへ書き出す
}


#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel 
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
//	managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
//	return managedObjectModel;

	NSString *path = [[NSBundle mainBundle] pathForResource:GD_PRODUCTNAME ofType:@"momd"];	// "momd"モデルファイルの拡張子
	NSURL *momURL = [NSURL fileURLWithPath:path];
	managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	return managedObjectModel;

}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] 
													stringByAppendingPathComponent:GD_COREDATANAME]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
											initWithManagedObjectModel: [self managedObjectModel]];

	/*
	 if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
															configuration:nil 
															URL:storeUrl 
															options:nil 
															error:&error]) {
		// Handle error
	 }    
	 */

	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
				 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,	// 自動移行
				[NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];	// 自動マッピング推論して処理
	// NSInferMappingModelAutomaticallyOption が無ければ「マッピングモデル」を使って移行処理される。
	
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
												  configuration:nil
															URL:storeUrl 
														options:options 
														  error:&error]) { 
		// Handle the error. 
	} 

    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end

