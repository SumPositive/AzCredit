//
//  GooDocsTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 09/12/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "GooDocsTVC.h"
#import "SFHFKeychainUtils.h"
#import "FileCsv.h"

#define TAG_ACTION_UPLOAD_START		109
#define TAG_ACTION_DOWNLOAD_START	118
#define TAG_ACTION_FETCH_CANCEL		127
#define TAG_ACTION_DOWNLOAD_CANCEL	136
#define TAG_ACTION_UPLOAD_CANCEL	145


@interface GooDocsTVC (PrivateMethods)
	// Google GData Access Methods
	- (void)refreshView;
	- (void)fetchDocList;
	- (void)cancelDocListFetchClicked:(id)sender;
	- (void)saveDocumentEntry:(GDataEntryBase *)docEntry toPath:(NSString *)path;
	- (void)saveDocEntry:(GDataEntryBase *)entry toPath:(NSString *)savePath exportFormat:(NSString *)exportFormat authService:(GDataServiceGoogle *)service;
	- (GDataServiceGoogleDocs *)docsService;
	- (GDataEntryDocBase *)selectedDoc;
	- (GDataFeedDocList *)docListFeed;
	- (void)setDocListFeed:(GDataFeedDocList *)feed;
	- (NSError *)docListFetchError;
	- (void)setDocListFetchError:(NSError *)error;  
	- (void)saveSpreadsheet:(GDataEntrySpreadsheetDoc *)docEntry toPath:(NSString *)savePath;
	- (GDataServiceTicket *)docListFetchTicket;
	- (void)setDocListFetchTicket:(GDataServiceTicket *)ticket;
	- (void)uploadFile: (NSString *)docName;
	- (GDataServiceTicket *)uploadTicket;
	- (void)setUploadTicket:(GDataServiceTicket *)ticket;

	- (void)viewDesign;
	- (void)switchAction:(id)sender;
	- (void)indicatorOn;  // 進捗サインON
	- (void)indicatorOff; // 進捗サインOFF
@end
@interface UIActionSheet (extended)
	- (void)setMessage:(NSString *)message;
@end
@implementation GooDocsTVC
@synthesize Re0root;
//@synthesize PbUpload;


#pragma mark - dealloc

- (void)dealloc 
{
	[self indicatorOff]; // 念のため（リークしないように）入れた。

	AzRETAIN_CHECK(@"GooDocs MtfPassword", RtfPassword, 3) // (1)alloc (2)addSubView (3)TableViewCell
	[RtfPassword release];
	AzRETAIN_CHECK(@"GooDocs MtfUsername", RtfUsername, 3)
	[RtfUsername release];
	
	[mUploadTicket cancelTicket]; // キャンセルするため
	[mDocListFetchTicket cancelTicket]; // キャンセルするため

	AzRETAIN_CHECK(@"GooDocs mUploadTicket", mUploadTicket, 1)
	[mUploadTicket release];
	AzRETAIN_CHECK(@"GooDocs mDocListFetchTicket", mDocListFetchTicket, 1)
	[mDocListFetchTicket release];
	
	
	AzRETAIN_CHECK(@"GooDocs mDocListFetchError", mDocListFetchError, 1)
	[mDocListFetchError release];
	AzRETAIN_CHECK(@"GooDocs mDocListFeed", mDocListFeed, 1)
	[mDocListFeed release];
	
	// @property (retain)
	AzRETAIN_CHECK(@"GooDocs Re0root", Re0root, 1)
	[Re0root release];
	
    [super dealloc];
}


#pragma mark - View lifecicle

- (id)initWithStyle:(UITableViewStyle)style 
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) {  // セクションありテーブルにする
		// 初期化成功
		self.tableView.allowsSelectionDuringEditing = YES;
		MbLogin = NO; // 未ログイン
		MbUpload = NO;
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う
//（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
    [super loadView];
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
	RtfUsername = nil;		// ここ(loadView)で生成
	RtfPassword = nil;		// ここ(loadView)で生成
	

	// ユーザが既に設定済みであればその情報を表示する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// Username
	RtfUsername = [[UITextField alloc] init]; // viewDesignにてrect決定
	RtfUsername.placeholder = NSLocalizedString(@"@gmail.com Optional",nil);
	RtfUsername.text = [defaults objectForKey:GD_DefUsername];
	RtfUsername.clearButtonMode = UITextFieldViewModeWhileEditing; // 全クリアボタン表示
	RtfUsername.keyboardType = UIKeyboardTypeEmailAddress;
	RtfUsername.autocapitalizationType = UITextAutocapitalizationTypeNone; // 自動SHIFTなし
	RtfUsername.returnKeyType = UIReturnKeyDone; // ReturnキーをDoneに変える
	RtfUsername.delegate = self;
	[MzOldUsername initWithString:RtfUsername.text];
	
	// Password
	RtfPassword = [[UITextField alloc] init]; // viewDesignにてrect決定
	// ラッパークラスを利用してKeyChainから保存しているパスワードを取得する処理
	NSError *error; // nilを渡すと異常終了するので注意
	RtfPassword.text = [SFHFKeychainUtils 
						getPasswordForUsername:RtfUsername.text 
								andServiceName:GD_PRODUCTNAME error:&error];

	RtfPassword.secureTextEntry = YES;    // パスワードを画面に表示しないようにする
	RtfPassword.clearButtonMode = UITextFieldViewModeWhileEditing; // 全クリアボタン表示
	RtfPassword.keyboardType = UIKeyboardTypeASCIICapable;
	RtfPassword.autocapitalizationType = UITextAutocapitalizationTypeNone; // 自動SHIFTなし
	RtfPassword.returnKeyType = UIReturnKeyDone; // ReturnキーをDoneに変える
	RtfPassword.delegate = self;

	// 注意！ この時点では、まだ self.managedObjectContext などはセットされていない！
}

/*
- (void)viewDidUnload 
{
	[super viewDidUnload];
}

// viewDidLoadメソッドは，TableViewContorllerオブジェクトが生成(alloc)された直後に呼び出されるメソッド
// 注意！alloc後のパラメータ設定の前に実行されるので、パラメータはまだ設定されていない！
- (void)viewDidLoad 
{
	[super viewDidUnload];
}
*/

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	//[0.4]以降、ヨコでもツールバーを表示するようにした。
	[self.navigationController setToolbarHidden:YES animated:animated]; // ツールバー消す

	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];

	// この時点でようやく self.managedObjectContext self.bUpload などがセットされている。

	[self viewDesign];
}

- (void)viewDesign
{
	CGRect rect;
	rect.origin.y = 12;
#ifdef AzPAD
	rect.origin.x = 140;
	rect.size.width = self.view.frame.size.width - rect.origin.x - 70;
#else
	rect.origin.x = 100;
	rect.size.width = self.view.frame.size.width - rect.origin.x - 30;
#endif
	rect.size.height = 30;
	RtfUsername.frame = rect;
	RtfPassword.frame = rect;
}


// 画面表示された直後に呼び出される
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];

	if ([RtfUsername.text length] <= 0) {
		[RtfUsername becomeFirstResponder];  // キーボード表示
	}
	else if ([RtfPassword.text length] <= 0) {
			[RtfPassword becomeFirstResponder];  // キーボード表示
	}
		
}

// ビューが非表示にされる前や解放される「前」ににこの処理が呼ばれる
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (MfetcherActive) {
		// Cancel the fetch of the request that's currently in progress
		[MfetcherActive stopFetching];
		MfetcherActive = nil;
	}
	[self indicatorOff]; // 進捗サインOFF
	
	// 戻る前にキーボードを消さないと、次に最初から現れた状態になってしまう。
	// キーボードを消すために全てのコントロールへresignFirstResponderを送る ＜表示中にしか効かない＞
	[RtfUsername resignFirstResponder];
	[RtfPassword resignFirstResponder];
}
/*
 // ビューが非表示にされたり解放された時にこの処理が呼ばれる
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

#pragma mark  View Rotate

// 回転の許可　ここでは許可、禁止の判定だけする
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	// 回転禁止でも、正面は常に許可しておくこと。
	return !MbOptAntirotation OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration {
	[self viewDesign]; // これで回転しても編集が継続されるようになった。
}


#pragma mark - Setters and Getters

- (GDataFeedDocList *)docListFeed {
	return mDocListFeed; 
}

- (void)setDocListFeed:(GDataFeedDocList *)feed {
	[mDocListFeed autorelease];
	mDocListFeed = [feed retain];
}

- (NSError *)docListFetchError {
	return mDocListFetchError; 
}

- (void)setDocListFetchError:(NSError *)error {
	[mDocListFetchError release];
	mDocListFetchError = [error retain];
}

- (GDataServiceTicket *)docListFetchTicket {
	return mDocListFetchTicket; 
}

- (void)setDocListFetchTicket:(GDataServiceTicket *)ticket {
	[mDocListFetchTicket release];
	mDocListFetchTicket = [ticket retain];
}

- (GDataServiceTicket *)uploadTicket {
	return mUploadTicket;
}

- (void)setUploadTicket:(GDataServiceTicket *)ticket {
	[mUploadTicket release];
	mUploadTicket = [ticket retain];
}


- (void)refreshView {
	// docList list display
	[self.tableView reloadData];  // [mDocListTable reloadData];
	
	// show the doclist feed fetch result error or the selected entry
	//NSString *docResultStr = @"";
	if (mDocListFetchError) {
		//docResultStr = [mDocListFetchError description];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Fail",nil)
														message:NSLocalizedString(@"Please check your Username and Password",nil)
													   delegate:self 
											  cancelButtonTitle:nil 
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
	}
}

// upload finished callback
- (void)uploadFileFinish:(GDataServiceTicket *)ticket
	   finishedWithEntry:(GDataEntryDocBase *)entry
                   error:(NSError *)error {
	
	[self setUploadTicket:nil];

	//	[mUploadProgressIndicator setDoubleValue:0.0];
	//MprogressView.progress = 0.0;
	// 進捗表示を消す
//	[self.actionProgress release];

	[self indicatorOff]; // 進捗サインOFF

	if (error == nil) {
		// refetch the current doc list
		//前に戻るので再読み込み不要 [self fetchDocList];
		
		// tell the user that the add worked
		// 成功アラート
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uploaded Compleat!",nil)
														message:NSLocalizedString(@"Uploaded Compleat!msg",nil)
													   delegate:self 
											  cancelButtonTitle:nil 
											  otherButtonTitles:@"OK", nil];
		alert.tag = 201;
		[alert show];
		[alert release];
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Upload Fail",nil)
														message:NSLocalizedString(@"Please try again after waiting a little.",nil)
													   delegate:self 
											  cancelButtonTitle:nil 
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
	}

	[self refreshView];
} 

#pragma mark - Action

// get an docList service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for fetched data.)
- (GDataServiceGoogleDocs *)docsService {
	
	static GDataServiceGoogleDocs* service = nil;
	
	if (!service) {
		service = [[GDataServiceGoogleDocs alloc] init];
		
		[service setUserAgent:@"Azukid.com-AzCredit-0.3"]; // set this to yourName-appName-appVersion
		[service setShouldCacheDatedData:YES];
		[service setServiceShouldFollowNextLinks:YES];
		
		// iPhone apps will typically disable caching dated data or will call
		// clearLastModifiedDates after done fetching to avoid wasting
		// memory.
	}
	
	// update the username/password each time the service is requested
	//	NSString *username = @"ipack.info@gmail.com";  // [mUsernameField stringValue];
	//	NSString *password = @"enjiSmei";  // [mPasswordField stringValue];
	
	if ([RtfUsername.text length] && [RtfPassword.text length]) {
		[service setUserCredentialsWithUsername:RtfUsername.text
									   password:RtfPassword.text];
	} else {
		[service setUserCredentialsWithUsername:nil
									   password:nil];
	}
	return service;
}

// UISwitch Action
- (void)switchAction: (id)sender
{
	// NSLog(@"switchAction: value = %d", [sender isOn]);
	// UISwitchが1つしか無いので、区別処理なしに処理している
	BOOL passwordSave = [sender isOn];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:passwordSave forKey:GD_OptPasswordSave]; // スイッチ状態を保存
	
	NSError *error; // nilを渡すと異常終了するので注意
	if (passwordSave) {
		// PasswordをKeyChainに保存する
		[SFHFKeychainUtils storeUsername:RtfUsername.text andPassword:RtfPassword.text 
						  forServiceName:GD_PRODUCTNAME updateExisting:YES error:&error];
	}
	else {
		// パスワードをKeyChainから削除する
		[SFHFKeychainUtils deleteItemForUsername:RtfUsername.text
								  andServiceName:GD_PRODUCTNAME error:&error];
	}
}

- (void)indicatorOn { // 進捗サインON
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // NetworkアクセスサインON
	if (MactionProgress==nil) {
		MactionProgress = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Please Wait",nil) 
													  delegate:self 
#ifdef AzPAD
											 cancelButtonTitle:nil		//なぜか？ Cancelボタンが表示されない？
										destructiveButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"Cancel",nil), nil];
#else
											 cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
										destructiveButtonTitle:nil
											 otherButtonTitles:nil];
#endif
		[MactionProgress setMessage:NSLocalizedString(@"Uploading...",nil)];
		MactionProgress.tag = TAG_ACTION_UPLOAD_CANCEL;
		// アクティビティインジケータ
		UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
		CGPoint point;
#ifdef AzPAD
		point.y = 48;
		point.x = 140;
#else
		point.y = 50.0;
		if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))	point.x = 480.0 / 2.0; // ヨコ
		else																										point.x = 320.0 / 2.0; // タテ
#endif
		[ai setCenter:point];
		[ai setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[ai startAnimating];
		[MactionProgress addSubview:ai];
		[ai release];
		[MactionProgress showInView:self.view];	
		//[MactionProgress release]; indicatorOffにて非表示＆破棄する
	}
	//[self refreshView];
}

- (void)indicatorOff { // 進捗サインOFF    念のためにdeallocにも入れておく。
	if (MactionProgress) {
		[MactionProgress dismissWithClickedButtonIndex:0 animated:YES];
		[MactionProgress release];
		MactionProgress = nil;
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF
	}
}


// UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (actionSheet.tag) 
	{
		case TAG_ACTION_UPLOAD_START:
			if (MbLogin && MzUploadName && buttonIndex==0) {  // UPLOAD START  actionSheetの上から順に(0〜)
				[self indicatorOn];	// 進捗サインON
				// Csv変換 ＆ Upload開始
				[self performSelectorOnMainThread:@selector(uploadFile:)
									   withObject:[NSString stringWithString:MzUploadName] // autorelease
									waitUntilDone:NO];
			}
			break;
			
		case TAG_ACTION_DOWNLOAD_START:
			if (buttonIndex == 0 && 0 <= MiRowDownload) {  // START  actionSheetの上から順に(0〜)
				if (Re0root.e7paids != nil OR Re0root.e7unpaids != nil) {
					// Download前、CSVバックアップする
					//FileCsv *filecsv = [[FileCsv alloc] init];
					NSString *zErr = [FileCsv zSave:Re0root toLocalFileName:GD_CSVBACKFILENAME];
					//[filecsv release];
					if (zErr) {
						//if (MactionProgress) [MactionProgress dismissWithClickedButtonIndex:0 animated:YES];
						//[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF
						[self indicatorOff]; // 進捗サインOFF
						UIAlertView *alert = [[UIAlertView alloc] 
											  initWithTitle:NSLocalizedString(@"Download Fail",nil)
											  message:zErr
											  delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
						[alert show];
						[alert release];
						return;
					}
				}
				// Download前、既存データ全削除する
				{
					NSManagedObjectContext *context = Re0root.managedObjectContext;
					NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
					// E7
					NSEntityDescription *entity = [NSEntityDescription entityForName:@"E7payment" inManagedObjectContext:context];
					[fetchRequest setEntity:entity];
					NSArray *arFetch = [context executeFetchRequest:fetchRequest error:nil];
					for (id node in arFetch) [context deleteObject:node];
					// E6
					entity = [NSEntityDescription entityForName:@"E6part" inManagedObjectContext:context];
					[fetchRequest setEntity:entity];
					arFetch = [context executeFetchRequest:fetchRequest error:nil];
					for (id node in arFetch) [context deleteObject:node];
					// E5
					entity = [NSEntityDescription entityForName:@"E5category" inManagedObjectContext:context];
					[fetchRequest setEntity:entity];
					arFetch = [context executeFetchRequest:fetchRequest error:nil];
					for (id node in arFetch) [context deleteObject:node];
					// E4
					entity = [NSEntityDescription entityForName:@"E4shop" inManagedObjectContext:context];
					[fetchRequest setEntity:entity];
					arFetch = [context executeFetchRequest:fetchRequest error:nil];
					for (id node in arFetch) [context deleteObject:node];
					// E3
					entity = [NSEntityDescription entityForName:@"E3record" inManagedObjectContext:context];
					[fetchRequest setEntity:entity];
					arFetch = [context executeFetchRequest:fetchRequest error:nil];
					for (id node in arFetch) [context deleteObject:node];
					// E2
					entity = [NSEntityDescription entityForName:@"E2invoice" inManagedObjectContext:context];
					[fetchRequest setEntity:entity];
					arFetch = [context executeFetchRequest:fetchRequest error:nil];
					for (id node in arFetch) [context deleteObject:node];
					// E1
					entity = [NSEntityDescription entityForName:@"E1card" inManagedObjectContext:context];
					[fetchRequest setEntity:entity];
					arFetch = [context executeFetchRequest:fetchRequest error:nil];
					for (id node in arFetch) [context deleteObject:node];
					// E0   ＜＜重要！Re0rootポインタが変わらないようにする＞＞
					Re0root.e7paids = nil;
					Re0root.e7unpaids = nil;
					// SAVE
					/*NSError *error = nil;
					 if (![context save:&error]) {
					 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					 exit(-1);  // Fail
					 }*/
					[MocFunctions commit];
				}
				//-------------------------------------------------------------------------
				// 最新版ダウンロード
				GDataEntryBase *docEntry = [mDocListFeed entryAtIndex:MiRowDownload];
				// Save File Path
				NSString *home_dir = NSHomeDirectory();
				NSString *doc_dir = [home_dir stringByAppendingPathComponent:@"Documents"];
				NSString *savePath = [doc_dir stringByAppendingPathComponent:GD_CSVFILENAME];
				// Download開始
				BOOL isSpreadsheet = [docEntry isKindOfClass:[GDataEntrySpreadsheetDoc class]];
				if (!isSpreadsheet) {
					// in a revision entry, we've add a property above indicating if this is a
					// spreadsheet revision
					isSpreadsheet = [[docEntry propertyForKey:@"is spreadsheet"] boolValue];
				}
				
				if (isSpreadsheet) {
					// to save a spreadsheet, we need to authenticate a spreadsheet service
					// object, and then download the spreadsheet file
					[self saveSpreadsheet:(GDataEntrySpreadsheetDoc *)docEntry toPath:savePath];
					// この後、Downloadが成功すれば、downloadFile:finishedWithData の中から csvRead が呼び出される。
				} 
				else {
					// since the user has already fetched the doc list, the service object
					// has the proper authentication token.  We'll use the service object
					// to generate an NSURLRequest with the auth token in the header, and
					// then fetch that asynchronously.
					GDataServiceGoogleDocs *docsService = [self docsService];
					[self saveDocEntry:docEntry
								toPath:savePath
						  exportFormat:@"txt"
						   authService:docsService];
				}
			}
			break;
			
		case TAG_ACTION_FETCH_CANCEL:
		case TAG_ACTION_DOWNLOAD_CANCEL:
			// CANCEL
			[mDocListFetchTicket cancelTicket];
			[self setDocListFetchTicket:nil];
			[self refreshView];
			break;
			
		case TAG_ACTION_UPLOAD_CANCEL:
			//- (IBAction)stopUploadClicked:(id)sender
			[mUploadTicket cancelTicket];
			[self setUploadTicket:nil];
			//[mUploadProgressIndicator setDoubleValue:0.0];
			//MprogressView.progress = 0.0;
			[self refreshView];
			break;
			
		default:
			break;
	}
	
	// actionSheet.tag = 選択行(indexPath.row)が代入されている
	if (actionSheet.tag < 0) {
		// actionProgress CANCEL
		if (MfetcherActive) {
			// Cancel the fetch of the request that's currently in progress
			[MfetcherActive stopFetching];
			MfetcherActive = nil;
		}
		[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
		return;
	}
	else {
	}
}


#pragma mark - DOWNLOAD

- (void)saveSpreadsheet:(GDataEntrySpreadsheetDoc *)docEntry
							toPath:(NSString *)savePath {
	// to download a spreadsheet document, we need a spreadsheet service object,
	// and we first need to fetch a feed or entry with the service object so that
	// it has a valid auth token
	GDataServiceGoogleSpreadsheet *spreadsheetService;
	spreadsheetService = [[[GDataServiceGoogleSpreadsheet alloc] init] autorelease];
	
	GDataServiceGoogleDocs *docsService = [self docsService];
	[spreadsheetService setUserAgent:[docsService userAgent]];
	[spreadsheetService setUserCredentialsWithUsername:[docsService username]
											  password:[docsService password]];
	GDataServiceTicket *ticket;
	ticket = [spreadsheetService authenticateWithDelegate:self
					didAuthenticateSelector:@selector(spreadsheetTicket:authenticatedWithError:)];
	
	// we'll hang on to the spreadsheet service object with a ticket property
	// since we need it to create an authorized NSURLRequest
	[ticket setProperty:docEntry forKey:@"docEntry"];
	[ticket setProperty:savePath forKey:@"savePath"];
}

- (void)spreadsheetTicket:(GDataServiceTicket *)ticket
								authenticatedWithError:(NSError *)error {
	if (error == nil) {
		GDataEntrySpreadsheetDoc *docEntry = [ticket propertyForKey:@"docEntry"];
		NSString *savePath = [ticket propertyForKey:@"savePath"];
		
		[self saveDocEntry:docEntry
					toPath:savePath
			  exportFormat:@"csv"   // "tsv"  ===================================CSV
			   authService:[ticket service]];
	} else {
		// failed to authenticate; give up
		NSLog(@"Spreadsheet authentication error: %@", error);
		return;
	}
}

//- (void)downloadTxt:(GDataEntryBase *)entry
//         authService:(GDataServiceGoogle *)service 
//			toPath:(NSString *)savePath {
- (void)saveDocEntry:(GDataEntryBase *)entry
					toPath:(NSString *)savePath
					exportFormat:(NSString *)exportFormat
					authService:(GDataServiceGoogle *)service 
{
	[self indicatorOn];	// 進捗サインON
/*	// 進捗サインON
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // NetworkアクセスサインON
	{
		MactionProgress = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Please Wait",nil) 
													 delegate:self 
											cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
									   destructiveButtonTitle:nil
											otherButtonTitles:nil];
		[MactionProgress setMessage:NSLocalizedString(@"Downloading...",nil)];
		MactionProgress.tag = TAG_ACTION_DOWNLOAD_CANCEL;
		// アクティビティインジケータ
		UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
		CGPoint point;
		point.y = 50.0;
		if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) point.x = 480.0 / 2.0; // ヨコ
		else															  point.x = 320.0 / 2.0; // タテ
		[ai setCenter:point];
		[ai setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[ai startAnimating];
		[MactionProgress addSubview:ai];
		[ai release];
		//[actionProgress showInView:self.view.window]; windowでは回転非対応
		[MactionProgress showInView:self.view]; // ToolBarが無い場合
		[MactionProgress release];
	}*/
	
	// the content src attribute is used for downloading
	NSURL *exportURL = [[entry content] sourceURL];
	if (exportURL != nil) {
		
		// we'll use GDataQuery as a convenient way to append the exportFormat
		// parameter of the docs export API to the content src URL
		GDataQuery *query = [GDataQuery queryWithFeedURL:exportURL];
		[query addCustomParameterWithName:@"exportFormat" value:exportFormat];
		NSURL *downloadURL = [query URL];
		AzLOG(@"downloadURL=%@", [downloadURL absoluteString]);
		// read the document's contents asynchronously from the network
		NSURLRequest *request = [service requestForURL:downloadURL
												  ETag:nil
											httpMethod:nil];
		
		GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
		[fetcher setUserData:savePath];
		[fetcher beginFetchWithDelegate:self
					  didFinishSelector:@selector(downloadFile:finishedWithData:)
						didFailSelector:@selector(downloadFile:failedWithError:)];
		MfetcherActive = fetcher;
	}
}

- (void)downloadFile:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
	// save the file to the local path specified by the user
	NSString *savePath = [fetcher userData];
	NSError *error = nil;
	BOOL didWrite = [data writeToFile:savePath
							  options:NSAtomicWrite
								error:&error];
	
	if (MfetcherActive) {
		// Cancel the fetch of the request that's currently in progress
		[MfetcherActive stopFetching];
		MfetcherActive = nil;
	}
	[self indicatorOff]; // 進捗サインOFF

	if (!didWrite) {
		NSLog(@"Error saving file: %@", error);
		// ＜＜＜エラー発生！何らかのアラートを出すこと＞＞
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Download Fail",nil)
														message:NSLocalizedString(@"Login please try again.",nil)
													   delegate:self 
											  cancelButtonTitle:nil 
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
	}
	else {
		// ダウンロード成功
		// CSV読み込み
		//FileCsv *filecsv = [[FileCsv alloc] init];
		NSString *zErr = [FileCsv zLoad:Re0root fromLocalFileName:GD_CSVFILENAME]; // この間、待たされるのが問題になるかも！！
		//[filecsv release];
		if (zErr) {
			// CSV読み込み失敗
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Download Fail",nil)
															message:zErr
														   delegate:self 
												  cancelButtonTitle:nil 
												  otherButtonTitles:@"OK", nil];
			[alert show];
			[alert release];
		}
		else {
			// 成功アラート
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Download Compleat!",nil)
															message:NSLocalizedString(@"Restore Credit",nil)
														   delegate:self 
												  cancelButtonTitle:nil 
												  otherButtonTitles:@"OK", nil];
			alert.tag = 101;
			[alert show];
			[alert release];
			//self.bDownloading = YES; // 完了したので繰り返し禁止するため
		}
	}
	// 進捗サインOFF
	//if (MactionProgress) [MactionProgress dismissWithClickedButtonIndex:0 animated:YES];
	[self indicatorOff];
}

- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alert.tag == 101) {
		// (101) Download Compleat! OK
		[self.navigationController popViewControllerAnimated:YES];	// 前のViewへ戻る
	}
	else if (alert.tag == 201) {
		// (201) Upload Compleat! OK
		//[self.navigationController popViewControllerAnimated:YES];	// 前のViewへ戻る
		// Upload完了 ⇒ Download可能にする
		MbUpload = YES;
		[self.tableView reloadData];
	}
}

- (void)downloadFile:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
	NSLog(@"Fetcher error: %@", error);
	// ＜＜＜エラー発生！何らかのアラートを出すこと＞＞
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Download Fail", @"ダウンロード失敗")
													message:NSLocalizedString(@"Login please try again.", @"ログインからやり直してみてください")
												   delegate:self 
										  cancelButtonTitle:nil 
										  otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
	if (MfetcherActive) {
		// Cancel the fetch of the request that's currently in progress
		[MfetcherActive stopFetching];
		MfetcherActive = nil;
	}
	[self indicatorOff]; // 進捗サインOFF
}


#pragma mark - UPLOAD

- (void)uploadFile: (NSString *)docName 
{
	NSString *dir1 = NSHomeDirectory();
	NSString *dir2 = [dir1 stringByAppendingPathComponent:@"Documents"];
	NSString *pathLocal = [dir2 stringByAppendingPathComponent:GD_CSVFILENAME]; // ローカルファイル名
	// ローカルファイル名も .csv を付けないこと。さもなくばExcelタイプで登録されてしまい、ダウンロードしても読めなくなる。
	@try {
		// Upload直前にCSVファイルへ書き出す
		NSString *zCsvErr = [FileCsv zSave:Re0root toLocalFileName:GD_CSVFILENAME]; // この間、待たされるのが問題になるかも！！
		if (zCsvErr) {
			@throw zCsvErr;
		}
		
		NSString *mimeType = @"text/csv";  //@"text/plain";
		
		Class entryClass = NSClassFromString(@"GDataEntryStandardDoc");
		
		GDataEntryDocBase *newEntry = [entryClass documentEntry];
		
		// Google Document 上に表示されるファイル名　＜＜ .csv を付けない！勝手にExcel型に変換されてしまうため＞＞
		// AzCredit仕様：リビジョン対応するまで日時を付けている
		[newEntry setTitleWithString:docName];
		
		// iPhone ローカルファイル名
//		NSData *uploadData = [NSData dataWithContentsOfFile:pathLocal];
//		if (!uploadData) {
//			errorMsg = NSLocalizedString(@"Cannot read file.", @"内部障害：ファイルが読めません");
//		}
		
//		if (uploadData) {
//			[newEntry setUploadData:uploadData];

		NSFileHandle *uploadFileHandle = [NSFileHandle fileHandleForReadingAtPath:pathLocal];
		if (!uploadFileHandle) {
			@throw NSLocalizedString(@"Cannot read file.",nil);
		}
		else {
			[newEntry setUploadFileHandle:uploadFileHandle];
			
			[newEntry setUploadMIMEType:mimeType];
			[newEntry setUploadSlug:[pathLocal lastPathComponent]];
			
			//NSURL *postURL = [[mDocListFeed postLink] URL];
			NSURL *postURL = [GDataServiceGoogleDocs docsUploadURL];

			// make service tickets call back into our upload progress selector
			GDataServiceGoogleDocs *service = [self docsService];
			
			// insert the entry into the docList feed
			GDataServiceTicket *ticket;
			ticket = [service fetchEntryByInsertingEntry:newEntry
											  forFeedURL:postURL
												delegate:self
									   didFinishSelector:@selector(uploadFileFinish:finishedWithEntry:error:)];
			
			// we don't want future tickets to always use the upload progress selector
			//[service setServiceUploadProgressSelector:nil];
			SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
			[ticket setUploadProgressSelector:progressSel];
			
			[self setUploadTicket:ticket];
		}
	}
	@catch (NSException *errEx) {
		NSLog(@"***uploadFile: error: %@ : %@\n", [errEx name], [errEx reason]);
		alertBox(NSLocalizedString(@"Upload Fail",nil), [errEx name], NSLocalizedString(@"Roger",nil));
		[self indicatorOff]; // 進捗サインOFF
	}
	@catch (NSString *throw) {
		NSLog(@"***uploadFile: throw: %@\n", throw);
		alertBox(NSLocalizedString(@"Upload Fail",nil), throw, NSLocalizedString(@"Roger",nil));
		[self indicatorOff]; // 進捗サインOFF
	}
	@finally {
		// 進捗サインONのまま、Upload進行中
	}
	//[self refreshView];
}


// progress callback
- (void)ticket:(GDataServiceTicket *)ticket
							hasDeliveredByteCount:(unsigned long long)numberOfBytesRead 
									ofTotalByteCount:(unsigned long long)dataLength {
	NSLog(@"ticket");
	//	[mUploadProgressIndicator setMinValue:0.0];
	//	[mUploadProgressIndicator setMaxValue:(double)dataLength];
	//	[mUploadProgressIndicator setDoubleValue:(double)numberOfBytesRead];
	//if (MprogressView && 0 < dataLength) {
	//	MprogressView.progress = (double)numberOfBytesRead / (double)dataLength;
	//}
}


// ドキュメントリストを抽出する
- (void)fetchDocList {
	
	[self setDocListFeed:nil];
	[self setDocListFetchError:nil];
	[self setDocListFetchTicket:nil];
	
	// ユーザ名/パスワードを指定して、サービスオブジェクトを生成
	GDataServiceGoogleDocs *service = [self docsService];
	GDataServiceTicket *ticket;
	
	// Fetching a feed gives us 25 responses by default.  We need to use
	// the feed's "next" link to get any more responses.  If we want more than 25
	// at a time, instead of calling fetchDocsFeedWithURL, we can create a
	// GDataQueryDocs object, as shown here.
	
	// ドキュメントの一覧の、フィードを取得するためのURLを生成  
    // GDataServiceGoogleDocs.hに、定数定義されている
	NSURL *feedURL = [GDataServiceGoogleDocs docsFeedURL];
	
	// 一覧を取得するための条件を指定
	GDataQueryDocs *query = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
	[query setMaxResults:300];			// 一度に取得する件数
	[query setShouldShowFolders:NO];	// フォルダを表示するか
	[query setFullTextQueryString:GD_GDOCS_EXT];	// この文字列が含まれるものを抽出する

	[self indicatorOn];	// 進捗サインON
/*	// リスト取得開始、進捗サインON
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // NetworkアクセスサインON
	{
		MactionProgress = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Please Wait",nil) 
													 delegate:self 
											cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
									   destructiveButtonTitle:nil
											otherButtonTitles:nil];
		[MactionProgress setMessage:NSLocalizedString(@"Google Login...",nil)];
		MactionProgress.tag = TAG_ACTION_FETCH_CANCEL;
		// アクティビティインジケータ
		UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
		CGPoint point;
		point.y = 50.0;
		if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) point.x = 480.0 / 2.0; // ヨコ
		else															  point.x = 320.0 / 2.0; // タテ
		[ai setCenter:point];
		[ai setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[ai startAnimating];
		[MactionProgress addSubview:ai];
		[ai release];
		[MactionProgress showInView:self.view];
		[MactionProgress release];
	}*/
	
	// フィードの取得要求を開始
    // didFinishSelectorで指定しているのが、レスポンスを処理するためのコールバックメソッド  
	ticket = [service fetchFeedWithQuery:query
								delegate:self
					   didFinishSelector:@selector(docListFetchTicket: finishedWithFeed: error:)];
	
	// リスト取得開始
	[self setDocListFetchTicket:ticket];
	// 画面更新
	[self refreshView];
}

/* 
 * フィード取得要求のレスポンスを処理するためのコールバックメソッド 　＜＜リスト取得成功後に呼び出される＞＞
 * @param ticket サービスチケットオブジェクト(このサンプルでは使用しない) 
 * @param feed レスポンスとして返されたフィード 
 * @param error エラーオブジェクト 
 */
- (void)docListFetchTicket:(GDataServiceTicket *)ticket
          finishedWithFeed:(GDataFeedDocList *)feed
                     error:(NSError *)error {
	
	[self setDocListFeed:feed];
	[self setDocListFetchError:error];
	[self setDocListFetchTicket:nil];
	
	if (error == nil) MbLogin = YES; // ログイン成功

	[self refreshView];
	
	[self indicatorOff]; // 進捗サインOFF
}

- (GDataEntryDocBase *)selectedDoc {
	if (0 <= MiSelectedRow && MiSelectedRow < [[mDocListFeed entries] count]) {
		GDataEntryDocBase *doc = [mDocListFeed entryAtIndex:MiSelectedRow];
		return doc;
	}
	return nil;
}

/*
// formerly saveSelectedDocumentToPath:
- (void)saveDocumentEntry:(GDataEntryBase *)docEntry
                   toPath:(NSString *)savePath {

	// [*.txt]
	GDataServiceGoogleDocs *docsService = [self docsService];
	[self saveDocEntry:docEntry
				toPath:savePath
		  exportFormat:@"txt"
		   authService:docsService];
}

- (void)saveDocEntry:(GDataEntryBase *)entry
              toPath:(NSString *)savePath
        exportFormat:(NSString *)exportFormat
         authService:(GDataServiceGoogle *)service {
	
	// the content src attribute is used for downloading
	NSURL *exportURL = [[entry content] sourceURL];
	if (exportURL != nil) {
		
		// we'll use GDataQuery as a convenient way to append the exportFormat
		// parameter of the docs export API to the content src URL
		GDataQuery *query = [GDataQuery queryWithFeedURL:exportURL];
		[query addCustomParameterWithName:@"exportFormat"
									value:exportFormat];
		NSURL *downloadURL = [query URL];
		
		// read the document's contents asynchronously from the network
		NSURLRequest *request = [service requestForURL:downloadURL
												  ETag:nil
											httpMethod:nil];
		
		GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
		[fetcher setUserData:savePath];
		[fetcher beginFetchWithDelegate:self
					  didFinishSelector:@selector(fetcher:finishedWithData:)
						didFailSelector:@selector(fetcher:failedWithError:)];
	}
}


- (void)fetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
	// save the file to the local path specified by the user
	NSString *savePath = [fetcher userData];
	NSError *error = nil;
	BOOL didWrite = [data writeToFile:savePath
							  options:NSAtomicWrite
								error:&error];
	if (!didWrite) {
		NSLog(@"Error saving file: %@", error);
		//NSBeep();
		// ＜＜＜エラー発生！何らかのアラートを出すこと＞＞
	} else {
		// ダウンロード成功
		// 前Viewに戻り、「iPack読み込み」する
		[self.navigationController dismissModalViewControllerAnimated:YES]; // 現モーダルViewを閉じて前に戻る

	}
}

- (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
	NSLog(@"Fetcher error: %@", error);
	//NSBeep();
	// ＜＜＜エラー発生！何らかのアラートを出すこと＞＞
}
*/


#pragma mark - <UITableViewDelegate>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	if (!MbLogin) return 1;
	return 3;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			if ([RtfUsername.text length] && [RtfPassword.text length]) {
				return 3;  // Username, Password, Login
			}
			else {
				return 2;  // Username, Password
			}
			break;
		case 1:
			return 1;  // Upload Plan name
			break;
		case 2:
			if (MbUpload) {
				return [[mDocListFeed entries] count];
			} else {
				return 1; // Uploadしないボタン
			}
			break;
	}
	return 0;
}

// TableView セクション名を応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"Google Login",nil);
			break;
		case 1:
			if (MbLogin) return NSLocalizedString(@"Upload - click start",nil);
			else return NSLocalizedString(@"Upload - Please login first",nil);
			break;
		case 2:
			if (MbUpload) {
				if (0 < [[mDocListFeed entries] count]) {
					return NSLocalizedString(@"Download - please select one",nil);
				} 
				else return NSLocalizedString(@"No file",nil);
			}
			else {
				return @"";
			}
			break;
	}
	return @"Err";
}

// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0:
			if (!MbLogin) {
				return NSLocalizedString(@"Google Login Footer",nil);
			}
			break;
		case 1:
			if (MbUpload) {
				return NSLocalizedString(@"Upload After",nil);
			} else {
				return NSLocalizedString(@"Please backup first",nil);
			}
			break;
		case 2:
			if (MbUpload) {
				return NSLocalizedString(@"Download Footer",nil); // Download一覧に表示されるまで数分かかる場合があることを知らせるため
			}
			break;
	}
	return nil;
}


// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	switch (indexPath.section) {
		case 0:
			if (indexPath.row == 2) return 50; // Login save
			break;
		case 2:
			if (0 < indexPath.row) return 30;
			break;
	}
	return 44; // デフォルト：44ピクセル
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *zCellUser = @"CellUser";
    static NSString *zCellPass = @"CellPass";
    static NSString *zCellLogin = @"CellLogin";
    static NSString *zCellList = @"CellList";
	UITableViewCell *cell = nil;
	
#ifdef AzPAD
	float fX = 20 + 60;
#else
	float fX = 20;
#endif

	switch (indexPath.section) {
		case 0: // Login Section
			switch (indexPath.row) {
				case 0: // User name
					cell = [tableView dequeueReusableCellWithIdentifier:zCellUser];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:zCellUser] autorelease];
						[cell addSubview:RtfUsername]; // retain +1=> 2
						cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
						cell.textLabel.font = [UIFont systemFontOfSize:12];
					}
					cell.textLabel.text = NSLocalizedString(@"Username:",nil);
					return cell;
					break;
				case 1: // Password
					cell = [tableView dequeueReusableCellWithIdentifier:zCellPass];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:zCellPass] autorelease];
						[cell addSubview:RtfPassword]; // retain +1=> 2
						cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
						cell.textLabel.font = [UIFont systemFontOfSize:12];
					}
					cell.textLabel.text = NSLocalizedString(@"Password:",nil);
					return cell;
					break;
				case 2: // Login
					cell = [tableView dequeueReusableCellWithIdentifier:zCellLogin];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
													   reuseIdentifier:zCellLogin] autorelease];
						
						UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(fX, 6, 120, 8)];
						label.text = NSLocalizedString(@"Remember Password",nil);
						label.font = [UIFont systemFontOfSize:9];
						label.backgroundColor = [UIColor clearColor];
						[cell addSubview:label];
						[label release];
						
						UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(fX, 18, 40, 20)];
						//switchView.delegate = self;
						BOOL passwordSave = [[NSUserDefaults standardUserDefaults] boolForKey:GD_OptPasswordSave];
						[switchView setOn:passwordSave animated:NO]; // 初期値セット
						[switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
						[cell addSubview:switchView];
						[switchView release];
					}
					cell.textLabel.text = NSLocalizedString(@"Login",nil);
					cell.textLabel.textAlignment = UITextAlignmentRight; 
					return cell;
					break;
			}
		case 1: // Upload Section
		{
			// Upload
			cell = [tableView dequeueReusableCellWithIdentifier:zCellList];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 
											   reuseIdentifier:zCellList] autorelease];
			}
			cell.textLabel.text = NSLocalizedString(@"Upload name",nil);
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			//dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
			dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm";
			// これがUploadファイル名として渡される
			cell.detailTextLabel.text = [NSString stringWithFormat:@"AzCredit %@", [dateFormatter stringFromDate:[NSDate date]]];
			[dateFormatter release];
		}
			return cell;
			break;
		case 2: // Download Section
			cell = [tableView dequeueReusableCellWithIdentifier:zCellList];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											   reuseIdentifier:zCellList] autorelease];
			}
			if (MbUpload) {
				GDataEntryDocBase *doc = [mDocListFeed entryAtIndex:indexPath.row];
				cell.textLabel.text = [[doc title] stringValue];
				cell.textLabel.textAlignment = UITextAlignmentLeft;
			} else {
				cell.textLabel.text = NSLocalizedString(@"Do not backup",nil);
				cell.textLabel.textAlignment = UITextAlignmentCenter;
			}
			return cell;
			break;
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// [DONE]キーを押さなかったとき、キーボードを消すための処理　＜＜アクティブフィールドのレスポンダ解除＞＞
	if ([RtfUsername canResignFirstResponder]) [RtfUsername resignFirstResponder];
	if ([RtfPassword canResignFirstResponder]) [RtfPassword resignFirstResponder];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
	switch (indexPath.section) {
		case 0: // Login Section
			if (indexPath.row == 2) { // Login
				// Document list 抽出
				MbLogin = NO; // 未ログイン ==>> 成功時にYES
				MbUpload = NO;
				[self fetchDocList];
			}
			break;
			
		case 1: // Upload Section
			if (MbLogin) {
				// セルからドキュメント名を取得してUploadドキュメント名として渡す
				UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
				MzUploadName = [NSString stringWithString:cell.detailTextLabel.text]; // autorelease
				UIActionSheet *sheet = [[UIActionSheet alloc] 
										initWithTitle:MzUploadName
										delegate:self 
										cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
										destructiveButtonTitle:nil
										otherButtonTitles:NSLocalizedString(@"Upload START",nil), nil];
				sheet.tag = TAG_ACTION_UPLOAD_START;
				[sheet showInView:self.view];
				[sheet release];
			}
			break;
			
		case 2: // Document list Section
			if (MbUpload) {
				MiRowDownload = indexPath.row; // Download対象行
				GDataEntryDocBase *doc = [mDocListFeed entryAtIndex:MiRowDownload];
				UIActionSheet *sheet = [[UIActionSheet alloc] 
										initWithTitle:[[doc title] stringValue]
										delegate:self 
										cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
										destructiveButtonTitle:NSLocalizedString(@"Download START",nil)
										otherButtonTitles:nil];
				sheet.tag = TAG_ACTION_DOWNLOAD_START;
				[sheet showInView:self.view];
				[sheet release];
			}
			else {
				// バックアップしない ⇒ すぐにリストアできるようにする
				MbUpload = YES;
				[self refreshView];
			}
			break;
	}
}



#pragma mark - <UITextFieldDelegate>

// UITextField 編集終了後　　（終了前もある。それを使えば終了させないことができる）
- (void)textFieldDidEndEditing:(UITextField *)textField 
{
	NSError *error; // nilを渡すと異常終了するので注意
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (textField == RtfUsername) { //Password変更時に同時に保存するように改めた
		if (![MzOldUsername isEqualToString:RtfUsername.text]) {
			[defaults setObject:RtfUsername.text forKey:GD_DefUsername];
			RtfPassword.text = @"";
			if (MzOldUsername != nil) {
				// ユーザ名が変更になっていた場合は、古いユーザ名で保存したパスワードを削除
				[SFHFKeychainUtils deleteItemForUsername:MzOldUsername andServiceName:GD_PRODUCTNAME 
												   error:&error];
			}
			[MzOldUsername initWithString:RtfUsername.text];
		}
		if (0 < [RtfUsername.text length]) {
			[RtfPassword becomeFirstResponder]; // パスワードへフォーカス移動
		}
	}
	else if (textField == RtfPassword) {
		// Passwordは Remember Password == YES のときだけ保存
		if ([defaults boolForKey:GD_OptPasswordSave]) {
			// PasswordをKeyChainに保存する
			[SFHFKeychainUtils storeUsername:RtfUsername.text andPassword:RtfPassword.text 
										forServiceName:GD_PRODUCTNAME updateExisting:YES error:&error];
		}
	}
}

// UITextField Return(DONE)キーが押された
- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	if (textField == RtfUsername && 0 < [RtfUsername.text length]) {
		[RtfPassword becomeFirstResponder]; // パスワードへフォーカス移動
	}
	else if (textField == RtfPassword && 0 < [RtfUsername.text length] && 0 < [RtfPassword.text length]) {
		[RtfPassword resignFirstResponder]; // キーボードを消す
		// ログイン開始
		MbLogin = NO; // 未ログイン ==>> 成功時にYES
		[self fetchDocList];
	}
    return YES;
}


@end

