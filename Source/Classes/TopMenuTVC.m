//
//  TopMenuTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//#import "SFHFKeychainUtils.h"
#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "TopMenuTVC.h"
#import "E1cardTVC.h"
//#import "GooDocsTVC.h"
#import "InformationView.h"
#import "SettingTVC.h"
#import "E2invoiceTVC.h"
#import "E3recordTVC.h"
#import "E3recordDetailTVC.h"
#import "E4shopTVC.h"
#import "E5categoryTVC.h"
#import "E7paymentTVC.h"
#import "E8bankTVC.h"
#import "WebSiteVC.h"
//#import "HttpServerView.h"
#import "PadRootVC.h"


#define TAG_VIEW_HttpServer			118
#define FREE_AD_OFFSET_Y			200.0


@interface TopMenuTVC () // メソッドのみ記述：ここに変数を書くとグローバルになる。他に同じ名称があると不具合発生する
{
    InformationView		*MinformationView;
    UIBarButtonItem		*MbuToolBarInfo;	// 正面ON,以外OFFにするため
    NSInteger	MiE1cardCount;
    BOOL			MbInformationOpen;	//[1.0.2]InformationViewを初回自動表示するため
    CGFloat		mAdPositionY;
}
#ifdef FREE_AD
//- (void)AdRefresh;
//- (void)AdMobWillRotate:(UIInterfaceOrientation)toInterfaceOrientation;
//- (void)AdAppWillRotate:(UIInterfaceOrientation)toInterfaceOrientation;
#endif
@end


@implementation TopMenuTVC

#pragma mark - Delegate

//#ifdef AzPAD
//- (void)setPopover:(UIPopoverController*)pc
//{
//	selfPopover = pc;
//}

- (void)refreshTopMenuTVC	// 「未払合計額」再描画するため
{
	[self viewWillAppear:YES];
}

//- (void)popoverClose
//{
//	if ([Mpopover isPopoverVisible]) 
//	{	//[1.1.0]Popover(E3recordDetailTVC) あれば閉じる(Cancel) 　＜＜閉じなければ、アプリ終了⇒起動⇒パスワード画面にPopoverが現れてしまう。
//		[MocFunctions rollBack];	// 修正取り消し
//		[Mpopover dismissPopoverAnimated:NO];	//YES=だと残像が残る
//	}
//}
//#endif


#pragma mark - Action

- (void)azInformationView
{
    if (IS_PAD) {
        InformationView* vc = [[InformationView alloc] init];  //[1.0.2]Pad対応に伴いControllerにした。
        AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController* naviRight = [apd.mainSplit.viewControllers objectAtIndex:1];	//[1]Right
        if ([naviRight.visibleViewController isMemberOfClass:[InformationView class]]) return; //既に開いてる
        [naviRight setViewControllers:@[naviRight.viewControllers.firstObject, vc] animated:YES]; //ごっそり入れ替える
    }else{
        if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) return; // 正面でなければ禁止
        // モーダル UIViewController
        if (MinformationView) {
            MinformationView = nil;
        }
        MinformationView = [[InformationView alloc] init];  //[1.0.2]Pad対応に伴いControllerにした。
        MinformationView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        //dep//[self presentModalViewController:MinformationView animated:YES];
        [self presentViewController:MinformationView animated:YES completion:nil];
        //[MinformationView show];
    }
}

- (void)azSettingView
{
    SettingTVC *tvc = [[SettingTVC alloc] init];
    if (IS_PAD) {
        AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController* naviRight = [apd.mainSplit.viewControllers objectAtIndex:1];	//[1]Right
        if ([naviRight.visibleViewController isMemberOfClass:[SettingTVC class]]) return; //既に開いてる
        [naviRight setViewControllers:@[naviRight.viewControllers.firstObject, tvc] animated:YES]; //ごっそり入れ替える
    }else{
        [self.navigationController pushViewController:tvc animated:YES];
    }
}

- (void)e3detailAdd		//PadRootVCからdelegate呼び出しされる
{
//#if defined (FREE_AD)
//    if (IS_PAD) {
//        MbAdCanVisible = YES;	//iPad// E3Add状態のときだけｉＡｄ表示する
//        [self AdRefresh];
//    }
//#endif
	// Add E3  【注意】同じE3Addが、E3recordTVC内にもある。
	E3record *e3obj = [MocFunctions insertAutoEntity:@"E3record"]; // autorelese
	e3obj.dateUse = [NSDate date]; // 迷子にならないように念のため
	//e3obj.e1card = nil;
	//e3obj.e4shop = nil;
	//e3obj.e5category = nil;
	//e3obj.e6parts = nil;
	
	E3recordDetailTVC *e3detail = [[E3recordDetailTVC alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	e3detail.title = NSLocalizedString(@"Add Record", nil);
	e3detail.Re3edit = e3obj;
	e3detail.PiAdd = (1); // (1)New Add
	
	AppDelegate *apd = (AppDelegate *)[UIApplication sharedApplication].delegate;
	apd.entityModified = NO;  //リセット
	
    if (IS_PAD) {
        UINavigationController* naviRight = [apd.mainSplit.viewControllers objectAtIndex:1];	//[1]Right
        
        UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:e3detail];
//        Mpopover = [[UIPopoverController alloc] initWithContentViewController:nc];
//        Mpopover.delegate = self;	// popoverControllerDidDismissPopover:を呼び出してもらうため
//        // [+]Add mode
//        CGRect rc = naviRight.view.bounds;  //  .navigationController.toolbar.frame;
//        rc.origin.x += (rc.size.width/2 + 2);		rc.size.width = 1;
//        rc.origin.y += (rc.size.height - 30);		rc.size.height = 1;
//        [Mpopover presentPopoverFromRect:rc
//                                  inView:naviRight.view  permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
//        e3detail.selfPopover = Mpopover;  //[Mpopover release];
//        //e3detail.delegate = nil;		// 不要

        e3detail.delegate = naviRight.viewControllers.lastObject; // 呼び出し元の表示をリフレッシュするため
        nc.modalPresentationStyle = UIModalPresentationFormSheet; // iPad画面1/4サイズ
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
        
    }else{
        [self.navigationController pushViewController:e3detail animated: YES];
    }
	 // self.navigationControllerがOwnerになる
    
    // iCloud Drive 実験
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* url = [fm URLForUbiquityContainerIdentifier:nil];
    NSURL* fileUrl = [url URLByAppendingPathComponent:@"PayNoteData"];
    AzLOG(@"fileUrl: %@", fileUrl);
    
//    // WRITE
//    NSString* testData = @"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbag4tgarghqar5hwah";
//    @try {
//        if ([testData writeToURL:fileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
//            AzLOG(@"writeToURL: OK");
//        }else{
//            AzLOG(@"writeToURL: NG");
//        }
//        
//    } @catch (NSException *exception) {
//        AzLOG(@"writeToURL: @catch: %@", exception);
//    } @finally {
//        AzLOG(@"writeToURL: @finally");
//    }
    
    // READ
    @try {
        NSString* test = [NSString stringWithContentsOfURL:fileUrl encoding:NSUTF8StringEncoding error:nil];
        AzLOG(@"stringWithContentsOfURL: test: %@", test);
        
    } @catch (NSException *exception) {
        AzLOG(@"stringWithContentsOfURL: @catch: %@", exception);
    } @finally {
        AzLOG(@"stringWithContentsOfURL: @finally");
    }
    
    
}

- (void)e3record
{
	if (MiE1cardCount <= 0) {
        [AZAlert target:self
                  title:NSLocalizedString(@"No Card",nil)
                message:NSLocalizedString(@"No Card msg",nil)
                b1title:NSLocalizedString(@"Roger",nil)
                b1style:UIAlertActionStyleDefault
               b1action:nil];
		return;
	}

	E3recordTVC *tvc = [[E3recordTVC alloc] init];
	tvc.title = NSLocalizedString(@"Record list", nil);
	tvc.Re0root = _Re0root;
	tvc.PbAddMode = NO; //Default

    if (IS_PAD) {
        AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController* naviRight = [apd.mainSplit.viewControllers objectAtIndex:1];	//[1]Right
        if ([naviRight.visibleViewController isMemberOfClass:[E3recordTVC class]]){
            E3recordTVC* vc = (E3recordTVC*)naviRight.visibleViewController;
            if (vc.Pe4shop == nil && vc.Pe5category == nil && vc.Pe8bank == nil ){
                AzLOG(@"naviRight.viewControllers: %@", naviRight.viewControllers);
                return; //既に開いてる
            }
        }
        [naviRight setViewControllers:@[naviRight.viewControllers.firstObject, tvc] animated:YES]; //ごっそり入れ替える
        AzLOG(@"naviRight.viewControllers: %@", naviRight.viewControllers);
    }else{
        [self.navigationController pushViewController:tvc animated: YES];
    }
}


- (void)barButtonAdd {
	// Add Card
	[self e3detailAdd];
}




#pragma mark - View lifecycle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (instancetype)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStyleGrouped]; // セクションありテーブル
	if (self) {
		// 初期化成功
        if (IS_PAD) {
            self.preferredContentSize = CGSizeMake(320, 650);
        }
		// インストールやアップデート後、1度だけ処理する
		NSString *zNew = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]; //(Version)
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString* zDef = [defaults valueForKey:@"DefVersion"];
		if (![zDef isEqualToString:zNew]) {
			[defaults setValue:zNew forKey:@"DefVersion"];
			MbInformationOpen = YES; // Informationを自動オープンする
		} else {
			MbInformationOpen = NO;
		}
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
//【Tips】ここでaddSubviewするオブジェクトは全てautoreleaseにすること。メモリ不足時には自動的に解放後、改めてここを通るので、初回同様に生成するだけ。
- (void)loadView
{
	NSLog(@"--- loadView --- TopMenuTVC");
	[super loadView];

	self.title = NSLocalizedString(@"Product Title",nil);

//    self.view.backgroundColor = [UIColor colorWithRed:240/255.0f
//                                                green:240/255.0f
//                                                 blue:240/255.0f
//                                                alpha:1];

    if (IS_PAD) {
        self.navigationItem.hidesBackButton = YES;
    }else{
        // Set up NEXT Left [Back] buttons.
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithImage:[UIImage imageNamed:@"Icon16-Return1.png"]
                                                 style:UIBarButtonItemStylePlain  target:nil  action:nil];
    }
	
#if defined(AzFREE) //&& !defined(AzPAD) //Not iPad//
    if (IS_PAD) {
    }else{
        UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon24-Free.png"]];
        UIBarButtonItem* bui = [[UIBarButtonItem alloc] initWithCustomView:iv];
        self.navigationItem.leftBarButtonItem	= bui;
    }
#endif

	// Tool Bar Button
#ifdef AzPAD
	// Cell配置により、ボタンなし
#else
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			 target:nil action:nil];
	MbuToolBarInfo = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon16-Information.png"]
													   style:UIBarButtonItemStylePlain  //Bordered
													  target:self action:@selector(azInformationView)];
	UIBarButtonItem *buSet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon16-Setting.png"]
															   style:UIBarButtonItemStylePlain  //Bordered
															  target:self action:@selector(azSettingView)];
	UIBarButtonItem *buAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																			target:self action:@selector(barButtonAdd)];
	NSArray *buArray = @[MbuToolBarInfo, buFlex, buAdd, buFlex, buSet];
	[self setToolbarItems:buArray animated:YES];
#endif
	
	// ToolBar表示は、viewWillAppearにて回転方向により制御している。
}

// loadView の次に呼び出される
- (void)viewDidLoad 
{
	NSLog(@"--- viewDidLoad ---");
	MiE1cardCount = 0;			// viewWillAppearにてセット
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated 	// ＜＜見せない処理＞＞
{
    [super viewWillAppear:animated];

    if (IS_PAD) {
        [self.navigationController setToolbarHidden:YES animated:animated]; // ツールバー消す
    }else{
        [self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示する
    }
	
	// 画面表示に関係する Option Setting を取得する
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	//MbOptEnableSchedule = [defaults boolForKey:GD_OptEnableSchedule];
	//MbOptEnableCategory = [defaults boolForKey:GD_OptEnableCategory];
	
	
	
	//-----------------------------------------------------------------------------
	// E1card 件数を求める
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"E1card" 
											  inManagedObjectContext:_Re0root.managedObjectContext];
	fetchRequest.entity = entity;
	// Fitch
	NSError *error = nil;
	NSArray *arFetch = [_Re0root.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
//		GA_TRACK_EVENT_ERROR([error localizedDescription],0);
		AzLOG(@"Error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	MiE1cardCount = arFetch.count;
	
	// TableView Reflesh
	[self.tableView reloadData];
	
	if (MbInformationOpen) {	//initWithStyleにて判定処理している
		MbInformationOpen = NO;	// 以後、自動初期表示しない。
		[self azInformationView];  //[1.0.2]最初に表示する。バックグランド復帰時には通らない
		//----------------------------------------
		[MocFunctions bugFix113]; //[1.1.3.0] Bugデータ修正処理、1度だけ通すため。
		//----------------------------------------
	}
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
//iPad//注意！タテから起動したとき通らない。
- (void)viewDidAppear:(BOOL)animated
{	// ＜＜魅せる処理＞＞			
    [super viewDidAppear:animated];
	//Menuは不要でしょう [self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる

	// E7E2クリーンアップ：配下のE6が無くなったE2を削除し、さらに配下のE2が無くなったE7も削除する。
	//iPad-NG// [MocFunctions e7e2clean];  // [0.4.18]レス向上のためここで処理。バックグランド時だとE2やE7表示に戻ったとき落ちる可能性あるので没にした。
	//iPad-NG//【原因】左ペインにTopMenuが表示されたタイミングで、TopMenu:viewDidAppear:e7e2clean により削除されてしまい不具合発生した。
	//iPad-NG//【対応】[MocFunctions e7e2clean] 処理を E2 または E7 の unloadRelease に入れた。
	
	// Comback (-1)にして未選択状態にする
	//	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	// (0)This clear
	//	[appDelegate.RaComebackIndex replaceObjectAtIndex:0 withObject:[NSNumber numberWithLong:-1]];
}

// この画面が非表示になる直前に呼ばれる
- (void)viewWillDisappear:(BOOL)animated 
{
	//iPad// [Mpopover dismissPopoverAnimated:NO] ＜＜ TopMenuだけ、AppDelegate:applicationDidEnterBackground:から (void)popoverClose を呼び出して処理している。
	
	[super viewWillDisappear:animated];
}


#pragma mark View 回転

//---------------------------------------------------------------------------回転
// YES を返すと、回転と同時に willRotateToInterfaceOrientation が呼び出され、
//				回転後に didRotateFromInterfaceOrientation が呼び出される。
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	// ここでは回転の許可、禁止だけを判定する  （現在の向きは、[[UIApplication sharedApplication] statusBarOrientation] で取得できる）

	//if ([self.view viewWithTag:TAG_VIEW_HttpServer]) return NO;		// HttpServerView が表示中なので回転禁止

    if (IS_PAD) {
        return YES;
    }else{
        return (interfaceOrientation == UIInterfaceOrientationPortrait); // 正面は常に許可
    }
}

// shouldAutorotateToInterfaceOrientation で YES を返すと、回転開始時に呼び出される
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
								duration:(NSTimeInterval)duration
{
#ifdef FREE_AD
//	[self AdMobWillRotate:toInterfaceOrientation];
//	[self AdAppWillRotate:toInterfaceOrientation];
#endif
}

// 回転した後に呼び出される
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (IS_PAD) {
//        if ([Mpopover isPopoverVisible])
//        {	// Popoverの位置を調整する　＜＜UIPopoverController の矢印が画面回転時にターゲットから外れてはならない＞＞
//            // アンカー位置 [Menu]
//            // [+]Add mode
//            AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//            UINavigationController* naviRight = [apd.mainSplit.viewControllers objectAtIndex:1];	//[1]Right
//            CGRect rc = naviRight.view.bounds;  //  .navigationController.toolbar.frame;
//            rc.origin.x += (rc.size.width/2 + 2);		rc.size.width = 1;
//            rc.origin.y += (rc.size.height - 30);		rc.size.height = 1;
//            [Mpopover presentPopoverFromRect:rc
//                                      inView:naviRight.view  permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
//        }
    }else{
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
            // 正面：infoボタン表示
            MbuToolBarInfo.enabled = YES;
        } else {
            MbuToolBarInfo.enabled = NO;
            if (MinformationView) {
                [MinformationView hide]; // 正面でなければhide
            }
        }
    }
}


#pragma mark  View - Unload - dealloc

- (void)unloadRelease {	// dealloc, viewDidUnload から呼び出される
	//【Tips】loadViewでautorelease＆addSubviewしたオブジェクトは全てself.viewと同時に解放されるので、ここでは解放前の停止処理だけする。
	//【Tips】デリゲートなどで参照される可能性のあるデータなどは破棄してはいけない。
	NSLog(@"--- unloadRelease --- TopMenuTVC");
	
    if (IS_PHONE) {
        [MinformationView hide];
        MinformationView = nil;	// azInformationViewにて生成
    }
}

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[self unloadRelease];
	// @property (retain)
	_Re0root = nil;
  //  [super dealloc];
}

// メモリ不足時に呼び出されるので不要メモリを解放する。 ただし、カレント画面は呼ばない。
- (void)viewDidUnload 
{
	//NSLog(@"--- viewDidUnload ---"); 
	[self unloadRelease]; //必ずsuperより先に処理
	[super viewDidUnload];
	// この後に loadView ⇒ viewDidLoad ⇒ viewWillAppear がコールされる
}


/* iOS3.0以降では、viewDidUnload を使うようになった。
 - (void)didReceiveMemoryWarning {
 AzLOG(@"MEMORY! TopMenuTVC: didReceiveMemoryWarning");
 [super didReceiveMemoryWarning];
 }
 */


#pragma mark - TableView lifecycle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // セクションは1つだけ section==0
#ifdef AzMAKE_SPLASHFACE
	return 0;
#else
	switch (section) {
		case 0:			// 利用明細
			return 2;
			break;
		case 1:			// 集計
			return 3;
			break;
		case 2:			// 分類
			return 2;
			break;
		case 3:			// 機能
			return 3;
			break;
	}
	return 0;
#endif
}

//// セクションのヘッダの高さを返却
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//	return 5.0;
//}

//#if defined(FREE_AD) && defined(AzPAD)
//// TableView セクションタイトルを応答
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
//{
//	if (section==0) return @"\n     Free Edition.\n\n";	// iAd上部スペース
//	return nil;
//}
//#endif

//// セクションのフッタの高さを返却
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//	return 0.0;
//}

//// TableView セクションフッタを応答
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
//{
//#ifndef AzMAKE_SPLASHFACE
//	switch (section) {
//		case 3:
//#if defined(FREE_AD) && defined(AzPAD)
//			return	@"\n\n\n\n\n\nAzukiSoft Project\n©2000-2017 Azukid\n\n\n\n\n\n\n";  //iPad//AdMobが表示されているとき最終セルが隠れないようにする
//#else
//			return	@"\nAzukiSoft Project  ©2000-2017 Azukid\n";
//#endif
//			break;
//	}
//#endif
//	return nil;
//}

// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (IS_PAD) {
        return 55;
    }
	return 44; // デフォルト：44ピクセル
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	@try {	//[1.1.8]
		static NSString *CellIdentifier = @"CellMenu";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:CellIdentifier];
			
            if (IS_PAD) {
                cell.textLabel.font = [UIFont systemFontOfSize:18];
            }else{
                cell.textLabel.font = [UIFont systemFontOfSize:16];
            }
			//cell.textLabel.textAlignment = NSTextAlignmentCenter;
			cell.textLabel.textColor = [UIColor blackColor];
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //[>]
		
		switch (indexPath.section) {
			case 0: //-------------------------------------------------------------Statement
			{
				switch (indexPath.row) {
					case 0:
						cell.imageView.image = [UIImage imageNamed:@"Icon32-GreenPlus.png"];
						cell.textLabel.text = NSLocalizedString(@"Add Record", nil);
						break;
					case 1:
						cell.imageView.image = [UIImage imageNamed:@"Icon32-Statements.png"];
						cell.textLabel.text = NSLocalizedString(@"Record list", nil);
						break;
				}
			} break;
				
			case 1: //-------------------------------------------------------------Paid/Unpaid
			{
				switch (indexPath.row) {
					case 0:
						cell.imageView.image = [UIImage imageNamed:@"Icon32-Schedule.png"];
						//cell.textLabel.text = NSLocalizedString(@"Payment list", nil);
						// E7 未払い総額
						cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
						if ((_Re0root.e7unpaids).count <= 0) {
							cell.textLabel.text = [NSString stringWithFormat:@"%@   %@",
												   NSLocalizedString(@"Payment list",nil), 
												   NSLocalizedString(@"No unpaid",nil)];
						} else {
							NSDecimalNumber *decUnpaid = [_Re0root valueForKeyPath:@"e7unpaids.@sum.sumAmount"];
							// Amount
							NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
							formatter.numberStyle = NSNumberFormatterCurrencyStyle; // 通貨スタイル（先頭に通貨記号が付く）
							formatter.locale = [NSLocale currentLocale]; 
							cell.textLabel.text = [NSString stringWithFormat:@"%@   %@", 
												   NSLocalizedString(@"Payment list",nil), 
												   [formatter stringFromNumber:decUnpaid]];
						}
						break;
					case 1:
						cell.imageView.image = [UIImage imageNamed:@"Icon32-Recipient.png"];
						cell.textLabel.text = NSLocalizedString(@"Recipient list", nil);
						break;
					case 2:
						cell.imageView.image = [UIImage imageNamed:@"Icon32-Bank.png"];
						cell.textLabel.text = NSLocalizedString(@"Bank list", nil);
						break;
				}
			} break;
				
			case 2: //-------------------------------------------------------------Groups
			{
				switch (indexPath.row) {
					case 0:
						cell.imageView.image = [UIImage imageNamed:@"Icon32-Shop.png"];
						cell.textLabel.text = NSLocalizedString(@"Shop list", nil);
						break;
					case 1:
						cell.imageView.image = [UIImage imageNamed:@"Icon32-Category.png"];
						cell.textLabel.text = NSLocalizedString(@"Category list", nil);
						break;
				}
			} break;
				
			case 3: //-------------------------------------------------------------Function
			{
				switch (indexPath.row) {
					case 0:
						cell.imageView.image = [UIImage imageNamed:@"iCloud-Up"];
						cell.textLabel.text = NSLocalizedString(@"iCloud Upload", nil);
                        cell.accessoryType = UITableViewCellAccessoryNone;
						break;
					case 1:
						cell.imageView.image = [UIImage imageNamed:@"Icon32-Setting.png"];
						cell.textLabel.text = NSLocalizedString(@"Setting", nil);
						break;
					case 2:
						cell.imageView.image = [UIImage imageNamed:@"Icon32-Information.png"];
						cell.textLabel.text = NSLocalizedString(@"Information", nil);
						break;
				}
			} break;
				
		}
		return cell;
	}
	@catch (NSException *exception) {
//		GA_TRACK_EVENT_ERROR([exception description],0);
		return nil;
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{

	UITableViewCell *cell = nil;
	@try {	//[1.1.8]
		[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
		cell = [self.tableView cellForRowAtIndexPath:indexPath];
	}
	@catch (NSException *exception) {
		//alertBox([exception name], [exception reason], @"OK (705)");
//		GA_TRACK_EVENT_ERROR([exception description],0);
		return;
	}

	switch (indexPath.section) {
		case 0:
		{
			switch (indexPath.row) {
				case 0: // Add Record  //[1.0.2]E3一覧後、Addする。＜＜一覧に戻って確認することが多いため
					[self e3detailAdd];
					break;
					
				case 1: // 最近の明細
					[self e3record];
					break;
			}
		}
			break;
		case 1:
		{
			switch (indexPath.row) {
				case 0: // 支払予定　E7 < E2 < E6 < E3detail
				{
					// E7paymentTVC へ
					E7paymentTVC *tvc = [[E7paymentTVC alloc] init];
#ifdef AzDEBUG
					tvc.title = [NSString stringWithFormat:@"E7 %@", NSLocalizedString(@"Payment list",nil)];
#else
					tvc.title = NSLocalizedString(@"Payment list",nil); //cell.textLabel.text;
#endif
					tvc.Re0root = _Re0root;
                    
                    if (IS_PAD) {
                        AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        UINavigationController* naviRight = [apd.mainSplit.viewControllers objectAtIndex:1];	//[1]Right
                        if ([naviRight.visibleViewController isMemberOfClass:[E7paymentTVC class]]) break; //既に開いてる
                        //[naviRight popToRootViewControllerAnimated:NO];<<<<<<これがチラついて見える
                        //[naviRight pushViewController:tvc animated:YES];
                        [naviRight setViewControllers:@[naviRight.viewControllers.firstObject, tvc] animated:YES]; //ごっそり入れ替える
                    }else{
                        [self.navigationController pushViewController:tvc animated:YES];
                    }
				}
					break;
				case 1: // カード一覧  E1 < E2 < E6 < E3detail
				{
					// E1card へ
					E1cardTVC *tvc = [[E1cardTVC alloc] init];
#ifdef AzDEBUG
					tvc.title = [NSString stringWithFormat:@"E1 %@", cell.textLabel.text];
#else
					tvc.title = cell.textLabel.text;
#endif
					tvc.Re0root = _Re0root;
					tvc.Re3edit = nil;
                    
                    if (IS_PAD) {
                        AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        UINavigationController* naviRight = [apd.mainSplit.viewControllers objectAtIndex:1];	//[1]Right
                        if ([naviRight.visibleViewController isMemberOfClass:[E1cardTVC class]]) break; //既に開いてる
                        //[naviRight popToRootViewControllerAnimated:NO];<<<<<<これがチラついて見える
                        //[naviRight pushViewController:tvc animated:YES];
                        [naviRight setViewControllers:@[naviRight.viewControllers.firstObject, tvc] animated:YES]; //ごっそり入れ替える
                    }else{
                        [self.navigationController pushViewController:tvc animated:YES];
                    }
				}
					break;
				case 2: // 銀行等口座一覧  E8 
				{
					// E8bank へ
					E8bankTVC *tvc = [[E8bankTVC alloc] init];
#ifdef AzDEBUG
					tvc.title = [NSString stringWithFormat:@"E8 %@", cell.textLabel.text];
#else
					tvc.title = cell.textLabel.text;
#endif
					tvc.Re0root = _Re0root;
					tvc.Pe1card = nil;
                    
                    if (IS_PAD) {
                        AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        UINavigationController* naviRight = [apd.mainSplit.viewControllers objectAtIndex:1];	//[1]Right
                        if ([naviRight.visibleViewController isMemberOfClass:[E8bankTVC class]]) break; //既に開いてる
                        [naviRight setViewControllers:@[naviRight.viewControllers.firstObject, tvc] animated:YES]; //ごっそり入れ替える
                    }else{
                        [self.navigationController pushViewController:tvc animated:YES];
                    }
				}
					break;
			}
		}
			break;
		case 2:
		{
			switch (indexPath.row) {
				case 0: // 利用店一覧  E4 < E3 < E3detail
				{
					E4shopTVC *tvc = [[E4shopTVC alloc] init];
#ifdef AzDEBUG
					tvc.title = [NSString stringWithFormat:@"E4 %@", cell.textLabel.text];
#else
					tvc.title = cell.textLabel.text;
#endif
					tvc.Re0root = _Re0root;
					tvc.Pe3edit = nil;

                    if (IS_PAD) {
                        AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        UINavigationController* naviRight = [apd.mainSplit.viewControllers objectAtIndex:1];	//[1]Right
                        if ([naviRight.visibleViewController isMemberOfClass:[E4shopTVC class]]) break; //既に開いてる
                        [naviRight setViewControllers:@[naviRight.viewControllers.firstObject, tvc] animated:YES]; //ごっそり入れ替える
                    }else{
                        [self.navigationController pushViewController:tvc animated:YES];
                    }
				}
					break;
				case 1: // 分類一覧  E5 < E3 < E3detail
				{
					E5categoryTVC *tvc = [[E5categoryTVC alloc] init];
#ifdef AzDEBUG
					tvc.title = [NSString stringWithFormat:@"E5 %@", cell.textLabel.text];
#else
					tvc.title = cell.textLabel.text;
#endif
					tvc.Re0root = _Re0root;
					tvc.Pe3edit = nil;
                    
                    if (IS_PAD) {
                        AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        UINavigationController* naviRight = [apd.mainSplit.viewControllers objectAtIndex:1];	//[1]Right
                        if ([naviRight.visibleViewController isMemberOfClass:[E5categoryTVC class]]) break; //既に開いてる
                        [naviRight setViewControllers:@[naviRight.viewControllers.firstObject, tvc] animated:YES]; //ごっそり入れ替える
                    }else{
                        [self.navigationController pushViewController:tvc animated:YES];
                    }
				}
					break;
			}
		}
			break;
		case 3: // Function
		{
			switch (indexPath.row) {
                case 0:
                {  // Upload to iCloud
                    [AZAlert target:self
                         actionRect:[tableView rectForRowAtIndexPath:indexPath]
                              title:NSLocalizedString(@"iCloud Upload", nil)
                            message:NSLocalizedString(@"iCloud Upload Detail", nil)
                            b1title:NSLocalizedString(@"iCloud Upload OK", nil)
                            b1style:UIAlertActionStyleDestructive
                           b1action:^(UIAlertAction * _Nullable action) {
                               // Upload to iCloud
                               [DataManager.singleton iCloudUpload];
                           }
                            b2title:NSLocalizedString(@"Cancel", nil)
                            b2style:UIAlertActionStyleCancel
                           b2action:nil];
                }
                    break;
				case 1:
				{  // Setting
					[self azSettingView];
				}
					break;
				case 2:
				{  // Information
					[self azInformationView];
				}
					break;
			}
		}
			break;
	}
}


//#ifdef AzPAD
//#pragma mark - <UIPopoverControllerDelegate>
//- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
//{	// Popoverの外部をタップして閉じる前に通知
//	AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//	if (apd.entityModified) {	// 変更あり
//		alertBox(NSLocalizedString(@"Cancel or Save",nil), 
//				 NSLocalizedString(@"Cancel or Save msg",nil), NSLocalizedString(@"Roger",nil));
//		return NO; // Popover外部タッチで閉じるのを禁止 ＜＜追加MOCオブジェクトをＣａｎｃｅｌ時に削除する必要があるため＞＞
//	}
//	else {	// 変更なし
//		// E3recordDetailTVC:cancelClose:【insertAutoEntity削除】を通ってないのでここで通す。
//		if ([popoverController.contentViewController isMemberOfClass:[UINavigationController class]]) {
//			UINavigationController* nav = (UINavigationController*)popoverController.contentViewController;
//			if (0 < [nav.viewControllers count] && [[nav.viewControllers objectAtIndex:0] isMemberOfClass:[E3recordDetailTVC class]]) 
//			{	// Popover外側をタッチしたとき cancelClose: を通っていないので、ここで通す。 ＜＜＜同じ処理が E3recordTVC.m にもある＞＞＞
//				E3recordDetailTVC* e3tvc = (E3recordDetailTVC *)[nav.viewControllers objectAtIndex:0]; //Root VC   <<<.topViewControllerではダメ>>>
//				if ([e3tvc respondsToSelector:@selector(cancelClose:)]) {	// メソッドの存在を確認する
//					[e3tvc cancelClose:nil];	// 【insertAutoEntity削除】
//				}
//			}
//		}
//		return YES;	// Popover外部タッチで閉じるのを許可
//	}
//}
//#endif



@end

