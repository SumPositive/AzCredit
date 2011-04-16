//
//  AppDelegate.m
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
// MainWindow.xlb を使用しない

#import "SFHFKeychainUtils.h"
#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "TopMenuTVC.h"


#define TAG_TF_LOGINPASS			901


@interface AppDelegate (PrivateMethods) // メソッドのみ記述：ここに変数を書くとグローバルになる。他に同じ名称があると不具合発生する
- (void)appLoginPassView;
@end


//static NSString *kComebackIndexKey = @"ComebackIndex";	// preference key to obtain our restore location

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
//@synthesize RaComebackIndex;
@synthesize	Me3dateUse;
@synthesize MbLoginShow;


- (void)dealloc 
{
	AzRETAIN_CHECK(@"AppDelegate Me3dateUse", Me3dateUse, 1)
	[Me3dateUse release], Me3dateUse = nil;

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
					//[0.4]// @"NO",	GD_OptBootTopView,			// TopView
							  @"NO",	GD_OptAntirotation,			// 回転防止
						//	  @"YES",	GD_OptEnableSchedule,		// 支払予定
						//	  @"YES",	GD_OptEnableCategory,		// 分類
							  @"NO",	GD_OptEnableInstallment,	// 分割払い
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
	// topMenu を naviCon へ登録
	navigationController = [[UINavigationController alloc] 
									   initWithRootViewController:topMenuTvc];
	[topMenuTvc release];
	// NavCon を window へ登録
	[window addSubview:navigationController.view];
	AzRETAIN_CHECK(@"AppDelegate naviCon", navigationController, 2)
	
	
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

/*
#pragma mark -
#pragma mark AdMobInterstitialDelegate methods

- (NSString *)publisherIdForAd:(AdMobView *)adView 
{
	NSLog(@"*** AdMob: publisherId");
	return @"a14d4c11a95320e"; // クレメモ　パブリッシャー ID
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView
{
	return navigationController;
}
// Sent when an interstitial ad request succefully returned an ad.  At the next transition
// point in your application call [ad show] to display the interstitial.
- (void)didReceiveInterstitial:(AdMobInterstitialAd *)ad
{
	if(ad == interstitialAd)
	{
		[ad show];
	}
}
// Sent when an interstitial ad request completed without an interstitial to show.  This is
// common since interstitials are shown sparingly to users.
- (void)didFailToReceiveInterstitial:(AdMobInterstitialAd *)ad
{
	NSLog(@"No interstitial ad retrieved.  This is ok.");
	[interstitialAd release];
	interstitialAd = nil;
}

- (void)interstitialDidDisappear:(AdMobInterstitialAd *)ad
{
	[interstitialAd release];
	interstitialAd = nil;
}
*/


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


// ログイン画面処理
- (void)appLoginPassView 
{
	// KeyChainから保存しているパスワードを取得する
	NSError *error; // nilを渡すと異常終了するので注意
	NSString *pass = [SFHFKeychainUtils getPasswordForUsername:GD_KEY_LOGINPASS
												andServiceName:GD_PRODUCTNAME error:&error];
	if (error) {
		NSLog(@"SFHFKeychainUtils: getPasswordForUsername %@", [error localizedDescription]);
		return;
	}
	if ([pass length]<=0) {
		return; // パスなし、自動ログイン
	}
	if (MviewLogin==nil) {
		//NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoginPassView" owner:self options:nil];
		//MviewLogin = [nib objectAtIndex:[nib count] – 1];
		MviewLogin = [[UIView alloc] initWithFrame:self.window.frame];
		MviewLogin.backgroundColor = [UIColor colorWithRed:151.0/255.0 
													 green:80.0/255.0 
													  blue:77.0/255.0 
													 alpha:1.0]; // Azukid Color
		MviewLogin.tag = VIEW_TAG_LOGINPASS; // TopMenuTVC:shouldAutorotateToInterfaceOrientationにて参照
		//------------------------------------------アイコン
		UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(130, 50, 57, 57)];
		[iv setImage:[UIImage imageNamed:@"Icon.png"]];
		[MviewLogin addSubview:iv]; [iv release];
		//------------------------------------------ログイン
		UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(83,120, 154,28)];
		tf.borderStyle = UITextBorderStyleRoundedRect;
		tf.placeholder = NSLocalizedString(@"OptLoginPass1 place",nil);
		tf.keyboardType = UIKeyboardTypeASCIICapable;
		tf.secureTextEntry = YES;
		tf.returnKeyType = UIReturnKeyDone;
		tf.delegate = self;			//<UITextFieldDelegate>
		tf.tag = TAG_TF_LOGINPASS;
		[MviewLogin addSubview:tf]; [tf release];
		//------------------------------------------■注意■
		UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(34, 170, 266, 80)];
		lb.text = NSLocalizedString(@"LoginPass Attention",nil);
		lb.numberOfLines = 4;
		lb.textAlignment = UITextAlignmentLeft;
		lb.textColor = [UIColor whiteColor];
		lb.backgroundColor = [UIColor clearColor]; //背景透明
		lb.font = [UIFont systemFontOfSize:12];
		[MviewLogin addSubview:lb]; [lb release];	
		//------------------------------------------パスワードを忘れた場合
		lb = [[UILabel alloc] initWithFrame:CGRectMake(34, 270, 266, 120)];
		lb.text = NSLocalizedString(@"LoginPass Lost",nil);
		lb.numberOfLines = 7;
		lb.textAlignment = UITextAlignmentLeft;
		lb.textColor = [UIColor whiteColor];
		lb.backgroundColor = [UIColor clearColor]; //背景透明
		lb.font = [UIFont systemFontOfSize:12];
		[MviewLogin addSubview:lb]; [lb release];	
		//
		[self.window addSubview:MviewLogin];
		[MviewLogin release];
	}
	CGRect rc = MviewLogin.frame;
	rc.origin.y = 0;
	MviewLogin.frame = rc;
	MviewLogin.alpha = 1.0; // 完全に隠す
	[self.window bringSubviewToFront:MviewLogin];
	UITextField *tf = (UITextField *)[MviewLogin viewWithTag:TAG_TF_LOGINPASS];
	[tf becomeFirstResponder];
	MbLoginShow = YES;
}

//--------------------------------------<UITextFieldDelegate>
// キーボードのリターンキーを押したときに呼ばれる
- (BOOL)textFieldShouldReturn:(UITextField *)sender 
{
	if (sender.tag==TAG_TF_LOGINPASS) 
	{
		// KeyChainから保存しているパスワードを取得する
		NSError *error; // nilを渡すと異常終了するので注意
		NSString *pass = [SFHFKeychainUtils getPasswordForUsername:GD_KEY_LOGINPASS
													andServiceName:GD_PRODUCTNAME error:&error];
		if (error) {
			alertBox(NSLocalizedString(@"OptLoginPass Error",nil), 
					 [error localizedDescription],
					 NSLocalizedString(@"Roger",nil));
			return YES;
		}
		[sender resignFirstResponder];
		if ([pass isEqualToString:sender.text]) {
			// OK
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
			CGRect rc = MviewLogin.frame;
			rc.origin.y = 500;
			MviewLogin.frame = rc;
			MviewLogin.alpha = 0.3;
			[UIView commitAnimations];
			MbLoginShow = NO;
			//[MviewLogin removeFromSuperview]; 破棄しない！するとE4shopTVCでフリーズ発生
			//MviewLogin = nil;
		}
		else {
			// NG
		}
		sender.text = @""; // 次回のためクリアしておく
	}
	return YES;
}


@end

