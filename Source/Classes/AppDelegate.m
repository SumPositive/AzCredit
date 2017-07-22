//
//  AppDelegate.m
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
// MainWindow.xlb を使用しない

#import <TargetConditionals.h>  // TARGET_IPHONE_SIMULATOR のため
#import "SFHFKeychainUtils.h"
#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "TopMenuTVC.h"
#import "LoginPassVC.h"
#import "PadRootVC.h"
#import "UpdateVC.h"



//iOS6以降、回転対応のためサブクラス化が必要になった。
@implementation AzNavigationController
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{	//iOS6以降
	//トップビューの向きを返す
	return self.topViewController.supportedInterfaceOrientations;
}
- (BOOL)shouldAutorotate
{	//iOS6以降
    return YES;
}
@end



@interface AppDelegate (PrivateMethods) // メソッドのみ記述：ここに変数を書くとグローバルになる。他に同じ名称があると不具合発生する
- (void)appLoginPassView;
@end


@implementation AppDelegate

@synthesize window;
@synthesize mainSplit, mainNavi;
@synthesize	Me3dateUse;
@synthesize entityModified;
@synthesize barMenu;


#ifdef AzDEBUG
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{	// メモリ不足警告があったことを知らせる
	application.statusBarStyle = !application.statusBarStyle;	//ステータスバーが反転する
}
#endif


#pragma mark - Application lifecycle

//<iOS4> - (void)applicationDidFinishLaunching:(UIApplication *)application
- (BOOL)application:(UIApplication *)application 
					didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
//	GA_INIT_TRACKER(@"UA-30305032-6", 10, nil);	//-6:PayNote1
//	GA_TRACK_EVENT(@"Device", @"model", [[UIDevice currentDevice] model], 0);
//	GA_TRACK_EVENT(@"Device", @"systemVersion", [[UIDevice currentDevice] systemVersion], 0);

    // MainWindow    ＜＜MainWindow.xlb を使用しないため、ここで生成＞＞
	window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	//-------------------------------------------------Option Setting Defult
	// User Defaultsを使い，キー値を変更したり読み出す前に，NSUserDefaultsクラスのインスタンスメソッド
	// registerDefaultsメソッドを使い，初期値を指定します。
	// [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	// ここで，appDefaultsは環境設定で初期値となるキー・バリューペアのNSDictonaryオブジェクトです。
	// このメソッドは，すでに同じキーの環境設定が存在する場合，上書きしないので，環境設定の初期値を定めることに使えます。
	NSDictionary *azOptDef = @{GD_OptEnableInstallment: @"YES",	// 分割払い
							  GD_OptUseDateTime: @"NO",			// 利用日：時刻なし
							  GD_OptNumAutoShow: @"NO",			// ＜保留＞ テンキー自動表示
							  GD_OptFixedPriority: @"NO",		// ＜保留＞ 修正を優先
						//	  @"YES",	GD_OptAmountCalc,			// [0.3.1] 電卓使用
							  GD_OptRoundBankers: @"NO",			// [0.4] 偶数丸め
							  GD_OptTaxRate: NSLocalizedString(@"OptTaxRate_PER",nil)};

	[userDefaults registerDefaults:azOptDef];	// 未定義のKeyのみ更新される
	[userDefaults synchronize]; // plistへ書き出す ＜＜通常は一定の間隔で自動的に保存されるので、特別に保存したいときにこのメソッドを使う＞＞
	
	// EntityRelation 初期化：
	[MocFunctions setMoc:self.managedObjectContext];
	//上記の最初の self.managedObjectContextメソッド呼び出しにてCoreDataが初期化される
	//-------------------------------------------------E0（固有ノード）が無ければ追加する
	E0root *e0node = [MocFunctions e0root];	// E0（固有ノード）を取得する。無ければ生成する。

	//-------------------------------------------------
	TopMenuTVC *topMenuTvc = [[TopMenuTVC alloc] init];
	topMenuTvc.Re0root = e0node; // TopMenuTVC側でretain

    if (IS_PAD) {
        // topMenu を [0] naviLeft へ登録
        AzNavigationController* naviLeft = [[AzNavigationController alloc] initWithRootViewController:topMenuTvc];
        // padRootVC を [1] naviRight へ登録
        PadRootVC *padRootVC = [[PadRootVC alloc] init];
        padRootVC.delegate = topMenuTvc;	//PadRootVC から e3recordAdd を呼び出すため
        AzNavigationController* naviRight = [[AzNavigationController alloc] initWithRootViewController:padRootVC];
        // mainController へ登録
        mainSplit = [[UISplitViewController alloc] init];
        mainSplit.viewControllers = [NSArray arrayWithObjects:naviLeft, naviRight, nil];
        mainSplit.delegate = padRootVC;
        mainSplit.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible; //iOS9// 常時タテ2分割が可能になった
        window.rootViewController = mainSplit;	//iOS6以降、こうしなければ回転しない。
    } else {
        // topMenu を navigationController へ登録
        mainNavi = [[AzNavigationController alloc] initWithRootViewController:topMenuTvc];
        window.rootViewController = mainNavi;	//iOS6以降、こうしなければ回転しない。
    }
	
	[window makeKeyAndVisible];	// 表示開始

    //[0.4]-----------------------------------------------ログイン画面処理
	//[self appLoginPassView];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application 
{	//iOS4: アプリケーションがアクティブでなくなる直前に呼ばれる
	//AzLOG(@"applicationWillResignActive");
}


- (void)applicationDidEnterBackground:(UIApplication *)application 
{	//iOS4: アプリケーションがバックグラウンドになったら呼ばれる
	[self applicationWillTerminate:application]; //iOS3以前の終了処理

	//[0.4]-----------------------------------------------ログイン画面処理
	//[self appLoginPassView];	// このタイミングが重要。復帰するときには既に隠れている状態になる。
}


- (void)applicationWillEnterForeground:(UIApplication *)application 
{	//iOS4: アプリケーションがバックグラウンドから復帰する直前に呼ばれる
	//AzLOG(@"applicationWillEnterForeground");
}


- (void)applicationDidBecomeActive:(UIApplication *)application 
{	//iOS4: アプリケーションがアクティブになったら呼ばれる
	//AzLOG(@"applicationDidBecomeActive");

//    // Update
//    NSString* bundleID = [NSBundle mainBundle].bundleIdentifier;
//    AzLOG(@"bundleID: %@",bundleID);
//    if ([bundleID isEqualToString:@"com.azukid.azcredits1"]) {
//        // iCloud 読み込み
//        
//    } else {
//        // iCloud 保存
//        UpdateVC* vc = [[UpdateVC alloc] init];
//        vc.Re0root = [MocFunctions e0root];	// CoreDataのRoot E0（固有ノード）を渡す
//        vc.modalPresentationStyle = UIModalPresentationFormSheet; // iPad画面1/4サイズ
//        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        [window.rootViewController presentViewController:vc animated:YES completion:nil];
//    }
}



// saves changes in the application's managed object context before the application terminates.
- (void)applicationWillTerminate:(UIApplication *)application 
{	// バックグラウンド実行中にアプリが終了された場合に呼ばれる。
	// ただしアプリがサスペンド状態の場合アプリを終了してもこのメソッドは呼ばれない。

}


#pragma mark - Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
/*- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}*/


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
	
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
		managedObjectContext = [[NSManagedObjectContext alloc]
								initWithConcurrencyType:NSMainQueueConcurrencyType]; // メインスレッドで実行
        managedObjectContext.persistentStoreCoordinator = coordinator;
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
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [self.applicationDocumentsDirectory 
													stringByAppendingPathComponent:GD_COREDATANAME]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
											initWithManagedObjectModel: self.managedObjectModel];

	/*
	 if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
															configuration:nil 
															URL:storeUrl 
															options:nil 
															error:&error]) {
		// Handle error
	 }    
	 */

	NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,	// 自動移行
				NSInferMappingModelAutomaticallyOption: @YES};	// 自動マッピング推論して処理
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


#pragma mark - Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = (paths.count > 0) ? paths[0] : nil;
    return basePath;
}


//#pragma mark - Login password
//
//// ログイン画面処理
//- (void)appLoginPassView 
//{
//	// KeyChainから保存しているパスワードを取得する
//	NSError *error; // nilを渡すと異常終了するので注意
//	NSString *pass = [SFHFKeychainUtils getPasswordForUsername:GD_KEY_LOGINPASS
//												andServiceName:GD_PRODUCTNAME error:&error];
//	if (error) {
//		NSLog(@"SFHFKeychainUtils: getPasswordForUsername %@", [error localizedDescription]);
////		GA_TRACK_EVENT_ERROR([error localizedDescription],0)
//		return;
//	}
//	if (pass.length<=0) {
//		return; // パスなし、自動ログイン
//	}
//
//	//回転対応
//	LoginPassVC *vc = [[LoginPassVC alloc] init];
//	vc.modalPresentationStyle = UIModalPresentationFullScreen;
//	vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//	//[self.window  presentModalViewController:vc animated:YES];
//	//[mainController.navigationController presentModalViewController:vc animated:NO]; 
//	//[mainController presentModalViewController:vc animated:NO]; // 即隠すためNO
//    if (IS_PAD) {
//        [mainSplit presentViewController:vc animated:NO completion:nil];
//    }else{
//        [mainNavi presentViewController:vc animated:NO completion:nil];
//    }
//}

@end

