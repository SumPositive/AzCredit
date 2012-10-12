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
#ifdef AzPAD
#import "padRootVC.h"
#endif


//iOS6以降、回転対応のためサブクラス化が必要になった。
@implementation AzNavigationController
- (NSUInteger)supportedInterfaceOrientations
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
@synthesize mainController;
@synthesize	Me3dateUse;
@synthesize entityModified;
#ifdef AzPAD
@synthesize barMenu;
#endif


- (void)dealloc 
{
	//AzRETAIN_CHECK(@"AppDelegate Me3dateUse", Me3dateUse, 1)
	//[Me3dateUse release],// autoreleseにしたので解放不要（すれば落ちる）
	Me3dateUse = nil;

	AzRETAIN_CHECK(@"AppDelegate mainController", mainController, 1)
	mainController.delegate = nil;
	[mainController release], mainController = nil;

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
	GA_INIT_TRACKER(@"UA-30305032-6", 10, nil);	//-6:PayNote1
	GA_TRACK_EVENT(@"Device", @"model", [[UIDevice currentDevice] model], 0);
	GA_TRACK_EVENT(@"Device", @"systemVersion", [[UIDevice currentDevice] systemVersion], 0);

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
					//[0.4]// @"NO",	GD_OptBootTopView,			// TopView
						//	  @"NO",	GD_OptAntirotation,			// 回転防止
						//	  @"YES",	GD_OptEnableSchedule,		// 支払予定
						//	  @"YES",	GD_OptEnableCategory,		// 分類
							  @"YES",	GD_OptEnableInstallment,	// 分割払い
							  @"NO",	GD_OptUseDateTime,			// 利用日：時刻なし
							  @"NO",	GD_OptNumAutoShow,			// ＜保留＞ テンキー自動表示
							  @"NO",	GD_OptFixedPriority,		// ＜保留＞ 修正を優先
						//	  @"YES",	GD_OptAmountCalc,			// [0.3.1] 電卓使用
							  @"NO",	GD_OptRoundBankers,			// [0.4] 偶数丸め
							  NSLocalizedString(@"OptTaxRate_PER",nil), GD_OptTaxRate,	// [0.4] 消費税率(%)
							  nil];

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

#ifdef AzPAD
	// topMenu を [0] naviLeft へ登録
	AzNavigationController* naviLeft = [[AzNavigationController alloc] initWithRootViewController:topMenuTvc];
	// padRootVC を [1] naviRight へ登録
	PadRootVC *padRootVC = [[[PadRootVC alloc] init] autorelease];
	padRootVC.delegate = topMenuTvc;	//PadRootVC から e3recordAdd を呼び出すため
	AzNavigationController* naviRight = [[AzNavigationController alloc] initWithRootViewController:padRootVC];
	// mainController へ登録
	mainController = [[UISplitViewController alloc] init];
	mainController.viewControllers = [NSArray arrayWithObjects:naviLeft, naviRight, nil];
	mainController.delegate = padRootVC; 
	//[padRootVC release];
	[naviLeft release];
	[naviRight release];
#else
	// topMenu を navigationController へ登録
	mainController = [[AzNavigationController alloc] initWithRootViewController:topMenuTvc];
#endif
	
	// mainController を window へ登録
	//[window addSubview:mainController.view];
	[window setRootViewController: mainController];	//iOS6以降、こうしなければ回転しない。
	AzRETAIN_CHECK(@"AppDelegate mainController", mainController, 2)

	[topMenuTvc release];
	
	
#ifdef AzMAKE_SPLASHFACE
	//self.RaComebackIndex = nil;
#else
	// [Comeback] 前回の画面表示に復帰させる
	// load the stored preference of the user's last location from a previous launch
	//NSMutableArray *tempMutableCopy = [[userDefaults objectForKey:kComebackIndexKey] mutableCopy];
	//self.RaComebackIndex = tempMutableCopy;
	//AzRETAIN_CHECK(@"AppDelegate tempMutableCopy", tempMutableCopy, 2)
	//[tempMutableCopy release];
#endif
	
/*	//if (self.RaComebackIndex == nil)
	{
		// 新規起動時
		// user has not launched this app nor navigated to a particular level yet, start at level 1, with no selection
		self.RaComebackIndex = [[NSMutableArray arrayWithObjects:	// (long型／intではOverflow)
							   [NSNumber numberWithLong:-1],	//L0: TopMenu
							   [NSNumber numberWithLong:-1],	//L1: E1card, E3record, E4shop, E5category, E7payment
							   [NSNumber numberWithLong:-1],	//L2: E2invoice, E3record, E6part
							   [NSNumber numberWithLong:-1],	//L3: E6part
							   [NSNumber numberWithLong:-1],	//L4: 
							   nil] retain];
	}
	else	//[0.4]viewComeback廃止：とりあえずここだけリマークしたが、問題無ければ[0.5]では関連全削除する予定。
	{
		// 復帰
		NSInteger idx = [[self.RaComebackIndex objectAtIndex:0] integerValue]; // read the saved selection at level 1
		if (idx != -1)
		{
			[topMenuTvc viewWillAppear:NO]; // Fech データセットさせるため
			[topMenuTvc viewComeback:self.RaComebackIndex];
		}
		else
		{
			// no saved selection, so user was at level 1 the last time
		}
	}*/

	[window makeKeyAndVisible];	// 表示開始
	//[0.4]-----------------------------------------------ログイン画面処理
	[self appLoginPassView];
	
	// register our preference selection data to be archived
//	NSDictionary *indexComebackDict = [NSDictionary dictionaryWithObject:self.RaComebackIndex 
//																  forKey:kComebackIndexKey];
//	[userDefaults registerDefaults:indexComebackDict];
//	[userDefaults synchronize]; // plistへ書き出す

/*
#ifdef ADMOB_INTERSTITIAL_ENABLED
	// Request an interstitial at "Application Open" time.
	// optionally retain the returned AdMobInterstitialAd.
	interstitialAd = [[AdMobInterstitialAd requestInterstitialAt:AdMobInterstitialEventAppOpen 
														delegate:self 
											interstitialDelegate:self] retain];
#endif
*/
	return YES;  //iOS4
}


- (void)applicationWillResignActive:(UIApplication *)application 
{	//iOS4: アプリケーションがアクティブでなくなる直前に呼ばれる
	AzLOG(@"applicationWillResignActive");
}


- (void)applicationDidEnterBackground:(UIApplication *)application 
{	//iOS4: アプリケーションがバックグラウンドになったら呼ばれる
	AzLOG(@"applicationDidEnterBackground");

#ifdef AzPAD
	UINavigationController* naviLeft = [self.mainController.viewControllers objectAtIndex:0];	//[0]Left
	if ([[naviLeft.viewControllers objectAtIndex:0] isMemberOfClass:[TopMenuTVC class]]) {
		TopMenuTVC* tvc = (TopMenuTVC *)[naviLeft.viewControllers objectAtIndex:0]; //Root VC   <<<.topViewControllerではダメ>>>
		if ([tvc respondsToSelector:@selector(popoverClose)]) {	// メソッドの存在を確認する
			[tvc popoverClose];	// Popoverが開いておれば、rollbackして閉じる
		}
	}
#endif
	
	[self applicationWillTerminate:application]; //iOS3以前の終了処理

	//[0.4]-----------------------------------------------ログイン画面処理
	[self appLoginPassView];	// このタイミングが重要。復帰するときには既に隠れている状態になる。
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

	/***[0.4.20]Bug:E3detail,E4shopなどで保存前に終了＞バックグランド＞復帰したとき、画面は復帰するがEntityデータは失われている
				原因＞ 終了処理でMOC:rollbackしているため。
				対応＞「applicationWillTerminate > hasChanges > rollback」を廃止。
						・終了＞バックグランド＞復帰した場合、MOCは維持されているため。
						・了＞破棄された場合、MOCはcommit以降は破棄されるのでrollbackと同じ。
	 **************************************************************************
	if (managedObjectContext != nil) {
        // 新規登録途中に閉じた場合など、保存しないため。 RollBackする
        if ([managedObjectContext hasChanges]) {
			NSLog(@"applicationWillTerminate > hasChanges > rollback");
			[managedObjectContext rollback];
        } 
    }
	*/

	// save the drill-down hierarchy of selections to preferences
//	[[NSUserDefaults standardUserDefaults] setObject:self.RaComebackIndex forKey:kComebackIndexKey];
	// この時点ではメモリ上で更新されただけ。
//	[[NSUserDefaults standardUserDefaults] synchronize]; // plistへ書き出す
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


#pragma mark - Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark - Login password

// ログイン画面処理
- (void)appLoginPassView 
{
	// KeyChainから保存しているパスワードを取得する
	NSError *error; // nilを渡すと異常終了するので注意
	NSString *pass = [SFHFKeychainUtils getPasswordForUsername:GD_KEY_LOGINPASS
												andServiceName:GD_PRODUCTNAME error:&error];
	if (error) {
		NSLog(@"SFHFKeychainUtils: getPasswordForUsername %@", [error localizedDescription]);
		GA_TRACK_EVENT_ERROR([error localizedDescription],0)
		return;
	}
	if ([pass length]<=0) {
		return; // パスなし、自動ログイン
	}

	//回転対応
	LoginPassVC *vc = [[LoginPassVC alloc] init];
	vc.modalPresentationStyle = UIModalPresentationFullScreen;
	vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	//[self.window  presentModalViewController:vc animated:YES];
	//[mainController.navigationController presentModalViewController:vc animated:NO]; 
	[mainController presentModalViewController:vc animated:NO]; // 即隠すためNO
	[vc release];
}


#pragma mark - AVAudioPlayer
- (void)audioPlayer:(NSString*)filename
{
	//if (MfAudioVolume <= 0.0 || 1.0 < MfAudioVolume) return;
#if (TARGET_IPHONE_SIMULATOR)
	// シミュレータで動作している場合のコード
	NSLog(@"AVAudioPlayer -　SIMULATOR");
#else
	// 実機で動作している場合のコード
 	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@", filename]];
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	player.volume = 1.0;  //MfAudioVolume;  // 0.0〜1.0
	player.delegate = self;		// audioPlayerDidFinishPlaying:にて release するため。
	[player play];
#endif
}

#pragma mark  <AVAudioPlayerDelegate>
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{	// 再生が終了したとき、破棄する	＜＜ シミュレータでは呼び出されない
	NSLog(@"- audioPlayerDidFinishPlaying -");
	player.delegate = nil;
    [player release];
}

- (void)audioPlayerDecodeErrorDidOccur: (AVAudioPlayer*)player error:(NSError*)error
{	// エラー発生
	NSLog(@"- audioPlayerDecodeErrorDidOccur -");
	player.delegate = nil;
	[player release];
}


@end

