//
//  GooDocsTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 09/12/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "Entity.h"
#import "GooDocsTVC.h"
#import "SFHFKeychainUtils.h"
#import "FileCsv.h"

#define TAG_ACTION_DOWNLOAD_START	900
#define TAG_ACTION_FETCH_CANCEL		901
#define TAG_ACTION_DOWNLOAD_CANCEL	902
#define TAG_ACTION_UPLOAD_CANCEL	903

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
@end
@interface UIActionSheet (extended)
	- (void)setMessage:(NSString *)message;
@end
@implementation GooDocsTVC
@synthesize Re0root;
//@synthesize PbUpload;

- (void)dealloc 
{
	AzRETAIN_CHECK(@"GooDocs MtfPassword", MtfPassword, 3) // (1)alloc (2)addSubView (3)TableViewCell
	[MtfPassword release];
	AzRETAIN_CHECK(@"GooDocs MtfUsername", MtfUsername, 3)
	[MtfUsername release];
	
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

- (void)viewDidUnload {
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。
	AzLOG(@"***viewDidUnload> GooDocsView");
	[MtfPassword release];			MtfPassword = nil;
	[MtfUsername release];			MtfUsername = nil;

	[mUploadTicket cancelTicket];	// キャンセルするため
	[mDocListFetchTicket cancelTicket];	// キャンセルするため

	[mUploadTicket release];		mUploadTicket = nil;
	[mDocListFetchTicket release];	mDocListFetchTicket = nil;
	[mDocListFetchError release];	mDocListFetchError = nil;
	[mDocListFeed release];			mDocListFeed = nil;
	// @property (retain) は解放しない。
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
	alert.title = @"didReceiveMemoryWarning";
	alert.message = @"GooDocsTVC";
	[alert addButtonWithTitle:@"OK"];
	[alert show];
	// autorelease
#endif
    [super didReceiveMemoryWarning];
}


- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {  // セクションありテーブルにする
		//self.navigationItem.rightBarButtonItem = self.editButtonItem;
		self.tableView.allowsSelectionDuringEditing = YES;
	}
	// 初期化
	MbLogin = NO; // 未ログイン
	MbUpload = NO;
	return self;
}

// viewDidLoadメソッドは，TableViewContorllerオブジェクトが生成(alloc)された直後に呼び出されるメソッド
// 注意！alloc後のパラメータ設定の前に実行されるので、パラメータはまだ設定されていない！
- (void)viewDidLoad 
{
    [super viewDidLoad];
	MtfUsername = nil;
	MtfPassword = nil;
	mDocListFeed = nil;
	mDocListFetchError = nil;
	mDocListFetchTicket = nil;
	mUploadTicket = nil;
	
	// ユーザが既に設定済みであればその情報を表示する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// Username
	MtfUsername = [[UITextField alloc] init]; // viewDesignにてrect決定
	MtfUsername.placeholder = NSLocalizedString(@"@gmail.com Optional",nil);
	MtfUsername.text = [defaults objectForKey:GD_DefUsername];
	MtfUsername.clearButtonMode = UITextFieldViewModeWhileEditing; // 全クリアボタン表示
	MtfUsername.keyboardType = UIKeyboardTypeASCIICapable;
	MtfUsername.autocapitalizationType = UITextAutocapitalizationTypeNone; // 自動SHIFTなし
	MtfUsername.returnKeyType = UIReturnKeyDone; // ReturnキーをDoneに変える
	MtfUsername.delegate = self;
	[MzOldUsername initWithString:MtfUsername.text];
	
	// Password
	MtfPassword = [[UITextField alloc] init]; // viewDesignにてrect決定
	// ラッパークラスを利用してKeyChainから保存しているパスワードを取得する処理
	NSError *error; // nilを渡すと異常終了するので注意
	MtfPassword.text = [SFHFKeychainUtils 
						getPasswordForUsername:MtfUsername.text 
								andServiceName:GD_PRODUCTNAME error:&error];

	MtfPassword.secureTextEntry = YES;    // パスワードを画面に表示しないようにする
	MtfPassword.clearButtonMode = UITextFieldViewModeWhileEditing; // 全クリアボタン表示
	MtfPassword.keyboardType = UIKeyboardTypeASCIICapable;
	MtfPassword.autocapitalizationType = UITextAutocapitalizationTypeNone; // 自動SHIFTなし
	MtfPassword.returnKeyType = UIReturnKeyDone; // ReturnキーをDoneに変える
	MtfPassword.delegate = self;

	// 注意！ この時点では、まだ self.managedObjectContext などはセットされていない！
}


- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];

	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];

	// この時点でようやく self.managedObjectContext self.bUpload などがセットされている。

	[self viewDesign];
}

// 画面表示された直後に呼び出される
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];

	if ([MtfUsername.text length] <= 0) {
		[MtfUsername becomeFirstResponder];  // キーボード表示
	}
	else if ([MtfPassword.text length] <= 0) {
			[MtfPassword becomeFirstResponder];  // キーボード表示
	}
		
}

// ビューが非表示にされる前や解放される「前」ににこの処理が呼ばれる
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (fetcherActive) {
		// Cancel the fetch of the request that's currently in progress
		[fetcherActive stopFetching];
		fetcherActive = nil;
	}
	// 進捗サインOFF
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF
	
	// 戻る前にキーボードを消さないと、次に最初から現れた状態になってしまう。
	// キーボードを消すために全てのコントロールへresignFirstResponderを送る ＜表示中にしか効かない＞
	[MtfUsername resignFirstResponder];
	[MtfPassword resignFirstResponder];
}
/*
 // ビューが非表示にされたり解放された時にこの処理が呼ばれる
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// 回転禁止でも万一ヨコからはじまった場合、タテにはなるようにしてある。
	return !MbOptAntirotation OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration {
	[self viewDesign]; // これで回転しても編集が継続されるようになった。
}

- (void)viewDesign
{
	CGRect rect;
	rect.origin.x = 100;
	rect.origin.y = 12;
	rect.size.width = self.view.frame.size.width - 100 - 30;
	rect.size.height = 30;
	MtfUsername.frame = rect;
	MtfPassword.frame = rect;
}


// get an docList service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for fetched data.)
- (GDataServiceGoogleDocs *)docsService {
	
	static GDataServiceGoogleDocs* service = nil;
	
	if (!service) {
		service = [[GDataServiceGoogleDocs alloc] init];
		
		[service setUserAgent:@"Azukid.com-AzCredit-0.0"]; // set this to yourName-appName-appVersion
		[service setShouldCacheDatedData:YES];
		[service setServiceShouldFollowNextLinks:YES];
		
		// iPhone apps will typically disable caching dated data or will call
		// clearLastModifiedDates after done fetching to avoid wasting
		// memory.
	}
	
	// update the username/password each time the service is requested
	//	NSString *username = @"ipack.info@gmail.com";  // [mUsernameField stringValue];
	//	NSString *password = @"enjiSmei";  // [mPasswordField stringValue];
	
	if ([MtfUsername.text length] && [MtfPassword.text length]) {
		[service setUserCredentialsWithUsername:MtfUsername.text
									   password:MtfPassword.text];
	} else {
		[service setUserCredentialsWithUsername:nil
									   password:nil];
	}
	return service;
}


#pragma mark Setters and Getters

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
	NSString *docResultStr = @"";
	if (mDocListFetchError) {
		docResultStr = [mDocListFetchError description];
		
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
	// 進捗表示を消す
//	[self.actionProgress release];

	// 進捗サインOFF
	if (actionProgress) [actionProgress dismissWithClickedButtonIndex:0 animated:YES];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF

	if (error == nil) {
		// refetch the current doc list
		//前に戻るので再読み込み不要 [self fetchDocList];
		
		// tell the user that the add worked
		// 成功アラート
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uploaded Compleat!",nil)
														message:nil
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


#pragma mark DOWNLOAD

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
	// 進捗サインON
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // NetworkアクセスサインON
	{
		actionProgress = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Please Wait",nil) 
													 delegate:self 
											cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
									   destructiveButtonTitle:nil
											otherButtonTitles:nil];
		UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
		[actionProgress setMessage:NSLocalizedString(@"Downloading...",nil)];
		actionProgress.tag = TAG_ACTION_DOWNLOAD_CANCEL;
		[ai setCenter:CGPointMake(160.0f, 90.0f)];
		[ai setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[ai startAnimating];
		[actionProgress addSubview:ai];
		[ai release];
		//[actionProgress showInView:self.view.window]; windowでは回転非対応
		[actionProgress showInView:self.view]; // ToolBarが無い場合
		[actionProgress release];
	}
	
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
		fetcherActive = fetcher;
	}
}

- (void)downloadFile:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
	// save the file to the local path specified by the user
	NSString *savePath = [fetcher userData];
	NSError *error = nil;
	BOOL didWrite = [data writeToFile:savePath
							  options:NSAtomicWrite
								error:&error];
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
	if (fetcherActive) {
		// Cancel the fetch of the request that's currently in progress
		[fetcherActive stopFetching];
		fetcherActive = nil;
	}
	// 進捗サインOFF
	if (actionProgress) [actionProgress dismissWithClickedButtonIndex:0 animated:YES];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF
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
	if (fetcherActive) {
		// Cancel the fetch of the request that's currently in progress
		[fetcherActive stopFetching];
		fetcherActive = nil;
	}
	// 進捗サインOFF
	if (actionProgress) [actionProgress dismissWithClickedButtonIndex:0 animated:YES];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF
}


#pragma mark UPLOAD

- (void)uploadFile: (NSString *)docName {
    
	NSString *dir1 = NSHomeDirectory();
	NSString *dir2 = [dir1 stringByAppendingPathComponent:@"Documents"];
	NSString *pathLocal = [dir2 stringByAppendingPathComponent:GD_CSVFILENAME]; // ローカルファイル名
	// ローカルファイル名も .csv を付けないこと。さもなくばExcelタイプで登録されてしまい、ダウンロードしても読めなくなる。
	@try {
		NSString *errorMsg = nil;
		NSString *mimeType = @"text/csv";  //@"text/plain";
		Class entryClass = NSClassFromString(@"GDataEntryStandardDoc");
		
		GDataEntryDocBase *newEntry = [entryClass documentEntry];
		
		// Google Document 上に表示されるファイル名　＜＜ .csv を付けない！勝手にExcel型に変換されてしまうため＞＞
		// AzCredit仕様：リビジョン対応するまで日時を付けている
		[newEntry setTitleWithString:docName];
		
		// iPhone ローカルファイル名
		NSData *uploadData = [NSData dataWithContentsOfFile:pathLocal];
		if (!uploadData) {
			errorMsg = NSLocalizedString(@"Cannot read file.", @"内部障害：ファイルが読めません");
		}
		
		if (uploadData) {
			[newEntry setUploadData:uploadData];
			[newEntry setUploadMIMEType:mimeType];
			[newEntry setUploadSlug:[pathLocal lastPathComponent]];
			
			NSURL *postURL = [[mDocListFeed postLink] URL];

			// make service tickets call back into our upload progress selector
			GDataServiceGoogleDocs *service = [self docsService];
			
			//SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
			//[service setServiceUploadProgressSelector:progressSel];
/*			// 進捗表示　ActionSheet & ProgressBar & Cancel Button  ＜＜消すとき release するため毎回生成＞＞
			{
				self.actionProgress = [[UIActionSheet alloc] initWithTitle:@"Please wait." 
																  delegate:self 
														 cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
													destructiveButtonTitle:nil 
														 otherButtonTitles:nil];
				[self.actionProgress setNumberOfRows:5];
				[self.actionProgress setMessage:NSLocalizedString(@"Now iPack Uploading.", nil)];
				UIProgressView *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(50, 70, 220, 90)];
				[progress setProgressViewStyle:UIProgressViewStyleDefault];
				[self.actionProgress addSubview:progress];
				[progress release];
			}
			[self.actionProgress showInView:self.view];  // 表示開始　.windowでは回転しない
*/
			
			// insert the entry into the docList feed
			GDataServiceTicket *ticket;
			ticket = [service fetchEntryByInsertingEntry:newEntry
											  forFeedURL:postURL
												delegate:self
									   didFinishSelector:@selector(uploadFileFinish:finishedWithEntry:error:)];
			
			// we don't want future tickets to always use the upload progress selector
//			[service setServiceUploadProgressSelector:nil];
			
			[self setUploadTicket:ticket];
		}
		
		if (errorMsg) {
			// 経過表示 ＆ 中断ボタンを消す
			//[self.actionProgress release];
			// エラーメッセージ表示
			UIAlertView *alert = [[UIAlertView alloc] 
								  initWithTitle:NSLocalizedString(@"Upload Fail",nil)
								  message:errorMsg
								  delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[alert show];
			[alert release];
			// 進捗サインOFF
			if (actionProgress) [actionProgress dismissWithClickedButtonIndex:0 animated:YES];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF
		}
	}
	@catch (NSException *errEx) {
		NSString *name = [errEx name];
		NSLog(@"◆ %@ : %@\n", name, [errEx reason]);
		if ([name isEqualToString:NSRangeException]) {
			NSLog(@"Exception was caught successfully.\n");
		} else {
			[errEx raise];
		}
	}
	@finally {
	}
	[self refreshView];
}


// progress callback
- (void)ticket:(GDataServiceTicket *)ticket
							hasDeliveredByteCount:(unsigned long long)numberOfBytesRead 
									ofTotalByteCount:(unsigned long long)dataLength {
	NSLog(@"ticket");
	//	[mUploadProgressIndicator setMinValue:0.0];
	//	[mUploadProgressIndicator setMaxValue:(double)dataLength];
	//	[mUploadProgressIndicator setDoubleValue:(double)numberOfBytesRead];
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
	NSURL *feedURL = [GDataServiceGoogleDocs docsFeedURLUsingHTTPS:YES];
	
	// 一覧を取得するための条件を指定
	GDataQueryDocs *query = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
	[query setMaxResults:300];			// 一度に取得する件数
	[query setShouldShowFolders:NO];	// フォルダを表示するか
	[query setFullTextQueryString:GD_GDOCS_EXT];	// この文字列が含まれるものを抽出する

	// リスト取得開始、進捗サインON
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // NetworkアクセスサインON
	{
		actionProgress = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Please Wait",nil) 
													 delegate:self 
											cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
									   destructiveButtonTitle:nil
											otherButtonTitles:nil];
		[actionProgress setMessage:NSLocalizedString(@"Google Login...",nil)];
		actionProgress.tag = TAG_ACTION_FETCH_CANCEL;
		UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
		[ai setCenter:CGPointMake(160.0f, 90.0f)];
		[ai setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[ai startAnimating];
		[actionProgress addSubview:ai];
		[ai release];
		[actionProgress showInView:self.view];
		[actionProgress release];
	}
	
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
	
	// 進捗サインOFF
	if (actionProgress) [actionProgress dismissWithClickedButtonIndex:0 animated:YES];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF
}

- (GDataEntryDocBase *)selectedDoc {
	if (0 <= PiSelectedRow && PiSelectedRow < [[mDocListFeed entries] count]) {
		GDataEntryDocBase *doc = [mDocListFeed entryAtIndex:PiSelectedRow];
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


#pragma mark Table view methods

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
			if ([MtfUsername.text length] && [MtfPassword.text length]) {
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
			if (!MbUpload) {
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

// UITextField 編集終了後　　（終了前もある。それを使えば終了させないことができる）
- (void)textFieldDidEndEditing:(UITextField *)textField 
{
	NSError *error; // nilを渡すと異常終了するので注意
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (textField == MtfUsername) { //Password変更時に同時に保存するように改めた
		if (![MzOldUsername isEqualToString:MtfUsername.text]) {
			[defaults setObject:MtfUsername.text forKey:GD_DefUsername];
			MtfPassword.text = @"";
			if (MzOldUsername != nil) {
				// ユーザ名が変更になっていた場合は、古いユーザ名で保存したパスワードを削除
				[SFHFKeychainUtils deleteItemForUsername:MzOldUsername andServiceName:GD_PRODUCTNAME 
												   error:&error];
			}
			[MzOldUsername initWithString:MtfUsername.text];
		}
		if (0 < [MtfUsername.text length]) {
			[MtfPassword becomeFirstResponder]; // パスワードへフォーカス移動
		}
	}
	else if (textField == MtfPassword) {
		// Passwordは Remember Password == YES のときだけ保存
		if ([defaults boolForKey:GD_OptPasswordSave]) {
			// PasswordをKeyChainに保存する
			[SFHFKeychainUtils storeUsername:MtfUsername.text andPassword:MtfPassword.text 
										forServiceName:GD_PRODUCTNAME updateExisting:YES error:&error];
		}
	}
}

// UITextField Return(DONE)キーが押された
- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	if (textField == MtfUsername && 0 < [MtfUsername.text length]) {
		[MtfPassword becomeFirstResponder]; // パスワードへフォーカス移動
	}
	else if (textField == MtfPassword && 0 < [MtfUsername.text length] && 0 < [MtfPassword.text length]) {
		[MtfPassword resignFirstResponder]; // キーボードを消す
		// ログイン開始
		MbLogin = NO; // 未ログイン ==>> 成功時にYES
		[self fetchDocList];
	}
    return YES;
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
		[SFHFKeychainUtils storeUsername:MtfUsername.text andPassword:MtfPassword.text 
							forServiceName:GD_PRODUCTNAME updateExisting:YES error:&error];
	}
	else {
		// パスワードをKeyChainから削除する
		[SFHFKeychainUtils deleteItemForUsername:MtfUsername.text
							andServiceName:GD_PRODUCTNAME error:&error];
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *zCellUser = @"CellUser";
    static NSString *zCellPass = @"CellPass";
    static NSString *zCellLogin = @"CellLogin";
    static NSString *zCellList = @"CellList";
	UITableViewCell *cell = nil;
	
	switch (indexPath.section) {
		case 0: // Login Section
			switch (indexPath.row) {
				case 0: // User name
					cell = [tableView dequeueReusableCellWithIdentifier:zCellUser];
					if (cell == nil) {
						cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:zCellUser] autorelease];
						[cell addSubview:MtfUsername]; // retain +1=> 2
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
						[cell addSubview:MtfPassword]; // retain +1=> 2
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

						UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 120, 8)];
						label.text = NSLocalizedString(@"Remember Password",nil);
						label.font = [UIFont systemFontOfSize:9];
						[cell addSubview:label];
						[label release];
						
						UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(20, 18, 40, 20)];
						//switchView.delegate = self;
						BOOL passwordSave = [[NSUserDefaults standardUserDefaults] boolForKey:GD_OptPasswordSave];
						[switchView setOn:passwordSave animated:NO]; // 初期値セット
						[switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
						[cell addSubview:switchView];
						[switchView release];
					}
					cell.textLabel.text = NSLocalizedString(@"Login",nil);
					cell.textLabel.textAlignment = UITextAlignmentRight;  //Center; // 中央寄せ
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
				dateFormatter.dateFormat = @"yyyy/MM/dd";
				// これがUploadファイル名として渡される
				cell.detailTextLabel.text = [NSString stringWithFormat:@"AzCredit %@", [dateFormatter stringFromDate:[NSDate date]]];
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
	if ([MtfUsername canResignFirstResponder]) [MtfUsername resignFirstResponder];
	if ([MtfPassword canResignFirstResponder]) [MtfPassword resignFirstResponder];

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
				// リスト取得開始、進捗サインON
				[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // NetworkアクセスサインON
				{
					actionProgress = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Please Wait",nil) 
																 delegate:self 
														cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
												   destructiveButtonTitle:nil
														otherButtonTitles:nil];
					UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
					[actionProgress setMessage:NSLocalizedString(@"Uploading...",nil)];
					actionProgress.tag = TAG_ACTION_UPLOAD_CANCEL;
					[ai setCenter:CGPointMake(160.0f, 90.0f)];
					[ai setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
					[ai startAnimating];
					[actionProgress addSubview:ai];
					[ai release];
					[actionProgress showInView:self.view];
					[actionProgress release];
				}

				// Upload直前にファイル iPack へ書き出す
				//FileCsv *filecsv = [[FileCsv alloc] init];
				NSString *zErr = [FileCsv zSave:Re0root toLocalFileName:GD_CSVFILENAME]; // この間、待たされるのが問題になるかも！！
				//[filecsv release];
				if (zErr) {
					// 進捗サインOFF
					if (actionProgress) [actionProgress dismissWithClickedButtonIndex:0 animated:YES];
					[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF
					UIAlertView *alert = [[UIAlertView alloc] 
										  initWithTitle:NSLocalizedString(@"Upload Fail",nil)
										  message:zErr
										  delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
					[alert show];
					[alert release];
					break;
				}
				// セルからドキュメント名を取得してUploadドキュメント名として渡す
				UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
				// Upload開始
				[self uploadFile:cell.detailTextLabel.text];
			}
			break;

		case 2: // Document list Section
			if (MbUpload)
			{
				MiRowDownload = indexPath.row; // Download対象行
				GDataEntryDocBase *doc = [mDocListFeed entryAtIndex:MiRowDownload];
				UIActionSheet *sheet = [[UIActionSheet alloc] 
										initWithTitle:[[doc title] stringValue]
											delegate:self 
									cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
								   destructiveButtonTitle:nil
								   otherButtonTitles:NSLocalizedString(@"Download START",nil), nil];
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

// UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (actionSheet.tag) 
	{
		case TAG_ACTION_DOWNLOAD_START:
			if (buttonIndex == 0 && 0 <= MiRowDownload) {  // START  actionSheetの上から順に(0〜)
				if (Re0root.e7paids != nil OR Re0root.e7unpaids != nil) {
					// Download前、CSVバックアップする
					//FileCsv *filecsv = [[FileCsv alloc] init];
					NSString *zErr = [FileCsv zSave:Re0root toLocalFileName:GD_CSVBACKFILENAME];
					//[filecsv release];
					if (zErr) {
						// 進捗サインOFF
						if (actionProgress) [actionProgress dismissWithClickedButtonIndex:0 animated:YES];
						[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF
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
					NSError *error = nil;
					if (![context save:&error]) {
						NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
						exit(-1);  // Fail
					}
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
			[self refreshView];
			break;

		default:
			break;
	}
	
	// actionSheet.tag = 選択行(indexPath.row)が代入されている
	if (actionSheet.tag < 0) {
		// actionProgress CANCEL
		if (fetcherActive) {
			// Cancel the fetch of the request that's currently in progress
			[fetcherActive stopFetching];
			fetcherActive = nil;
		}
		[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
		return;
	}
	else {
	}
}



@end

