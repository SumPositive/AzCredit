//
//  SampleTVC.m
//  AzPacking
//
//  Created by 松山 和正 on 10/01/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "Elements.h"
#import "SampleTVC.h"

#define TAG_ACTION_FETCH_START_ROW	1000 // 1000 + .row
#define TAG_ACTION_FETCH_CANCEL		 999

@interface SampleTVC (PrivateMethods)
	// csvRead Converter Methods
	- (NSString *)csvRead;
	- (NSString *)csvString:(NSMutableArray *)muStruc csvLine:(NSArray *)arLine csvCol:(NSString *)zColName;
	- (NSNumber *)csvNumber:(NSMutableArray *)muStruc csvLine:(NSArray *)arLine csvCol:(NSString *)zColName;
//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
//----------------------------------------------Owner移管につきdealloc時のrelese不要
	URLDownload		*downloader;  // downloadDidFinishなどで独自にreleaseしている
//	UIProgressView  *Mprogress;
//----------------------------------------------assign
	BOOL MbOptShouldAutorotate;
	BOOL MbActionCancel; // Download開始後、キャンセルボタンが押されるとYES
//	long long MulExLength;  // コンテンツの総容量
//	long long MulDlLength;  // ダウンロードした量
@end
@interface UIActionSheet (PrivateMethods)
	- (void)setMessage:(NSString *)message;
	- (void)progress:(NSNumber *)number;
//-------------------------------------------------------initWithStyleでnil, retain > release必要
	UIActionSheet	*actionProgress;  // alloc直後にreleaseしている。
@end
@implementation SampleTVC
@synthesize PmanagedObjectContext;
@synthesize PiSelectedRow;  // Downloadの新規追加される行になる

- (void)dealloc 
{
	[actionProgress release];
//	[Mprogress release];

	// @property (retain)
	AzRETAIN_CHECK(@"SampleTVC PmanagedObjectContext", PmanagedObjectContext, 4)
	[PmanagedObjectContext release];

    [super dealloc];
}

- (void)viewDidUnload 
{
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。
	AzLOG(@"SampleTVC viewDidUnload");
	[actionProgress release];	actionProgress = nil;
//	[Mprogress release];		Mprogress = nil;
	// @property (retain) は解放しない。
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
	alert.title = @"didReceiveMemoryWarning" ;
	alert.message = @"SampleTVC" ;
	[alert addButtonWithTitle:@"OK"];
	[alert show];
	// autorelease
#endif
    [super didReceiveMemoryWarning];
}



- (id)initWithStyle:(UITableViewStyle)style 
{
	actionProgress = nil;
//	Mprogress = nil;
	downloader = nil;
	
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {  // セクションありテーブルにする
		//self.navigationItem.rightBarButtonItem = self.editButtonItem;
		self.tableView.allowsSelectionDuringEditing = YES;
	}
	return self;
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// 回転禁止でも万一ヨコからはじまった場合、タテにはなるようにしてある。
	return MbOptShouldAutorotate OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptShouldAutorotate = [defaults boolForKey:GD_OptShouldAutorotate];
}


/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

// TableView セクション名を応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"AzPack - please select one.",nil);
			break;
	}
	return @"Err";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *zCellDefault = @"CellDefault";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:zCellDefault];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] 
				 initWithStyle:UITableViewCellStyleDefault
				 reuseIdentifier:zCellDefault] autorelease];
	}
	cell.textLabel.font = [UIFont systemFontOfSize:18];
	cell.textLabel.textAlignment = UITextAlignmentLeft;
	cell.textLabel.textColor = [UIColor blackColor];
	
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"Sports Club", @"S000 スポーツクラブ");
			break;
		case 1:
			cell.textLabel.text = NSLocalizedString(@"Domestic business trips", @"S001 国内出張");
			break;
		case 2:
			cell.textLabel.text = NSLocalizedString(@"Domestic travel", @"S002 国内旅行");
			break;
		case 3:
			cell.textLabel.text = NSLocalizedString(@"Overseas Travel", @"S003 海外旅行");
			break;
		case 4:
			cell.textLabel.text = NSLocalizedString(@"Camping equipment", @"S004 キャンプ機材");
			break;
		case 5:
			cell.textLabel.text = NSLocalizedString(@"Disaster Equipment", @"S005 災害備品");
			break;
		default:
			cell.textLabel.text = @"ERR";
			break;
	}
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	UIActionSheet *sheet = [[UIActionSheet alloc] 
							initWithTitle:cell.textLabel.text
							delegate:self 
							cancelButtonTitle:NSLocalizedString(@"Cancel", @"中止")
							destructiveButtonTitle:nil
							otherButtonTitles:NSLocalizedString(@"Download START", @"ダウンロード開始"), nil];
	sheet.tag = TAG_ACTION_FETCH_START_ROW + indexPath.row;  // Sample%3d 
	[sheet showInView:self.view];
	[sheet release];
}	

// UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0 && TAG_ACTION_FETCH_START_ROW <= actionSheet.tag) {  // START (0〜)
		// リスト取得開始、進捗サインON
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // NetworkアクセスサインON
		// 進捗＆キャンセル表示にする
		if (actionProgress==nil) {
			actionProgress = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Please Wait",nil) 
														 delegate:self 
												cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
										   destructiveButtonTitle:nil
												otherButtonTitles:nil];
			[actionProgress setMessage:NSLocalizedString(@"Sample PACK Downloading", nil)];
			actionProgress.tag = TAG_ACTION_FETCH_CANCEL;
			/*サイズが小さいのでプログレスは不要
				// サイズ取得できたのでプログレスバー準備
				UIProgressView *Mprogress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
				Mprogress.frame = CGRectMake(0,0,200,32);
				Mprogress.center = CGPointMake(160,120);
				[Mprogress setProgress:0.0f]; // Max:1.0f
				[actionProgress addSubview:Mprogress]; [Mprogress release]; // retain & release
			*/
			// サイズ不明のためアクティビティインジケータ準備
			UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] 
										   initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
			[ai setCenter:CGPointMake(160.0f, 110.0f)];
			[ai setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
			[ai startAnimating];
			[actionProgress addSubview:ai]; [ai release];
			//[actionProgress release]; deallocにてrelease
		}
		[actionProgress showInView:self.view];
		
		// Sample download 開始
		NSInteger iRow = actionSheet.tag - TAG_ACTION_FETCH_START_ROW;
		NSString *zUrl = [NSString stringWithFormat:@"https://sites.google.com/a/azukid.com/azpacking/home"
						  @"/sample/files/Sample%03d%@.AzPack.csv?attredirects=0&d=1", 
						  (int)iRow, NSLocalizedString(@"Country2code", @"国識別2文字")];
		
		NSString *tmpPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
		NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:zUrl]];
		// ここからダウンロード開始
		MbActionCancel = NO;
		downloader = [[URLDownload alloc] initWithRequest:req directory:tmpPath delegate:self];
	}
	else if (actionSheet.tag == TAG_ACTION_FETCH_CANCEL) {
		// URL Download Cancel
		MbActionCancel = YES; // 次にdidReceiveDataOfLengthが呼ばれたらキャンセルされる
	}
}


///////////////////////////////////////////////////////////////////////
//URLDownloadDelegate implements
// ダウンロード完了
- (void)downloadDidFinish:(URLDownload *)download 
{
	AzLOG(@"downloadDidFinish: %@", download.filePath);
	//[self releaseDownloader];
	[downloader release];
	// ダウンロード成功
	// CSV読み込み
	NSString *zErr = [self csvRead]; 
	
	// 進捗サインOFF
	if (actionProgress) [actionProgress dismissWithClickedButtonIndex:0 animated:YES];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF
	
	if (zErr) {
		// CSV読み込み失敗
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Download Fail", @"ダウンロード失敗")
														message:zErr
													   delegate:nil 
											  cancelButtonTitle:nil 
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
	}
	else {
		// 成功アラート
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Download Compleat!", @"ダウンロード成功")
														message:NSLocalizedString(@"Added Plan", @"プランを追加しました")
													   delegate:nil 
											  cancelButtonTitle:nil 
											  otherButtonTitles:@"OK", nil];
		alert.tag = 101;
		[alert show];
		[alert release];
		//self.bDownloading = YES; // 完了したので繰り返し禁止するため
	}
}

// ダウンロードが中断されたときに呼ばれる　exception==nilならばキャンセル操作による中断
- (void)download:(URLDownload *)download didCancelBecauseOf:(NSException *)exception 
{
	// 進捗サインOFF
	if (actionProgress) [actionProgress dismissWithClickedButtonIndex:0 animated:YES];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF
	//
	UIAlertView *alert = [[UIAlertView alloc] init];
	if (exception == nil) {
		// キャンセル操作による中断
		alert.title = NSLocalizedString(@"Download Canceled",nil);
		alert.message = NSLocalizedString(@"Download Canceled message",nil);
	} else {
		// エラーによる中断
		alert.title = NSLocalizedString(@"Download Fail",nil);
		alert.message = [exception reason];
	}
	[alert addButtonWithTitle:@"OK"];
	[alert show];
	[alert release];
	[downloader release];
}

// ダウンロードに失敗した際に呼ばれる
- (void)download:(URLDownload *)download didFailWithError:(NSError *)error 
{
	// 進捗サインOFF
	if (actionProgress) [actionProgress dismissWithClickedButtonIndex:0 animated:YES];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // NetworkアクセスサインOFF
	// ＜＜＜エラー発生！何らかのアラートを出す＞＞
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Download Fail", @"ダウンロード失敗")
													message:[error localizedDescription] 
												   delegate:self 
										  cancelButtonTitle:nil 
										  otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
	[downloader release];
}

/*
// Optional: サーバからのレスポンス取得
- (void)download:(URLDownload *)download didReceiveResponse:(NSURLResponse *) response 
{
	// (1) MIME text/ 以外はダウンロード中止
	AzLOG(@"SampleDL: MIMEType: %@",[response MIMEType]);
//	if ( ! [ [ response MIMEType ] hasPrefix : @"application/octet-stream" ] ) {
//		MbActionCancel = YES;
//		return;
//	}
	
	// (2) サーバから取得したコンテンツ容量を取得
	MulExLength = [response expectedContentLength];
	
	// (3) プログレスバー属性変更
	if (MulExLength != NSURLResponseUnknownLength) 
	{
		// サイズ取得できたのでプログレスバー準備
		MulExLength *= 2; // csvReadにて同容量処理するため2倍にする
	}
	else {
		// サイズ不明のためアクティビティインジケータ準備
		UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] 
									   initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
		[ai setCenter:CGPointMake(160.0f, 90.0f)];
		[ai setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[ai startAnimating];
		[actionProgress addSubview:ai]; [ai release];
	}
	// (4) ダウンロードしたサイズの初期化
	MulDlLength = 0;
}
*/

/*
// バックグラウンドでprogressを変更
- (void)progress:(NSNumber *)number
{
	Mprogress.progress = [number floatValue];
}
*/

//  Optional: ダウンロード進行中に呼ばれる
- (BOOL)download:(URLDownload *)download didReceiveDataOfLength:(NSUInteger)length 
{
/*	// プログレスバーの表示
	if (MulExLength != NSURLResponseUnknownLength) {
		MulDlLength += length;
		float f = (float)MulDlLength;
		//[Mprogress setProgress:f/(float)MulExLength]; // Max:1.0f
		[self performSelectorInBackground:@selector(progress:) 
							   withObject:[NSNumber numberWithFloat:(f/(float)MulExLength)]];
	}*/
	
	return !(MbActionCancel); // NOを返すと通信が中断されて中途ファイルが削除される。
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



// csvRead:muStrucに従って文字列項目を取得する（文字列マーク["]があれば除外する  シングル[']は許可）
- (NSString *)csvString:(NSMutableArray *)muStruc csvLine:(NSArray *)arLine csvCol:(NSString *)zColName {
	NSInteger ui = [muStruc indexOfObject:zColName];
	if (ui != NSNotFound) {
		NSString *zz = [arLine objectAtIndex:ui];
		if ([zz hasPrefix:@"\""]) // 先頭文字が["]ならば先頭と末尾の["]を除外する
			return  [zz substringWithRange:NSMakeRange(1,[zz length]-2)]; // 両端除外
		else 
			return zz;
	}
	return nil;
}

// csvRead:muStrucに従って数値項目を取得する
- (NSNumber *)csvNumber:(NSMutableArray *)muStruc csvLine:(NSArray *)arLine csvCol:(NSString *)zColName {
	NSInteger ui = [muStruc indexOfObject:zColName];
	if (ui != NSNotFound) {
		NSString *zz = [arLine objectAtIndex:ui];
		return [NSNumber numberWithInteger:[zz integerValue]];
	}
	return nil;
}

/////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)csvRead   // iPack から managedObjectContext へ読み込む
{
	NSString *home_dir = NSHomeDirectory();
	NSString *doc_dir = [home_dir stringByAppendingPathComponent:@"Documents"];
	NSString *csvPath = [doc_dir stringByAppendingPathComponent:GD_CSVFILENAME];		
	
	unsigned long ulStart = 0;
	unsigned long ulEnd = 0;
	NSData *one;
	NSData *data;
	NSInteger iSection = 0;
	E1 *e1obj;
	E2 *e2obj;
	E3 *e3obj;
	NSInteger e2row = 0;  // CSV読み込み順に連番付与する
	NSInteger e3row = 0;
	BOOL bManagedObjectContextSave = NO;  // YES=CoreData Saveする
	BOOL bDQSection = NO;
	NSData *dDQ = [@"\"" dataUsingEncoding:NSUTF8StringEncoding]; // ["]ダブルクォーテーション
	
	// 以下、release 必要
	unsigned char uChar[1];
	uChar[0] = 0x0a; // LF(0x0a)
	NSData *dLF = [[NSData alloc] initWithBytes:uChar length:1];
	uChar[0] = 0x0d; // CR(0x0d)
	NSData *dCR = [[NSData alloc] initWithBytes:uChar length:1];
	
	NSMutableArray *maE1struc = [[NSMutableArray alloc] initWithCapacity:256];
	NSMutableArray *maE2struc = [[NSMutableArray alloc] initWithCapacity:256];
	NSMutableArray *maE3struc = [[NSMutableArray alloc] initWithCapacity:256];
	
	
	NSString *zErrMsg = nil;
	// input OPEN
	NSFileHandle *input = [NSFileHandle fileHandleForReadingAtPath:csvPath];
	@try {
		while (1) {
			bDQSection = NO; // Reset
/*			// プログレスバーの表示
			if (MulExLength != NSURLResponseUnknownLength) {
				MulDlLength += ulEnd;
				float f = (float)MulDlLength;
				//[Mprogress setProgress:f/(float)MulExLength]; // Max:1.0f
				[self performSelectorInBackground:@selector(progress:) 
									   withObject:[NSNumber numberWithFloat:(f/(float)MulExLength)]];
			}*/
			// 1行を切り出す
			while (one = [input readDataOfLength:1]) { 
				if ([one length] <= 0) {
					AzLOG(@"Break1");
					break;	// ファイル終端
				}
				// ["]文字列区間にあるCRやLFは無視するための処理
				if ([one isEqualToData:dDQ]) bDQSection = !bDQSection; // ["]区間判定　トグルになる
				// 文字列区間でないところに、CRやLFがあれば行末と判断する
				if (!bDQSection && ([one isEqualToData:dLF] || [one isEqualToData:dCR])) break; // 行末
			}
			
			ulEnd = [input offsetInFile]; // [LF]または[CR]の次の位置を示す
			if (ulEnd <= ulStart) {
				AzLOG(@"Break2");
				break;	// ファイル終端
			}
			if ([one length] <= 0) ulEnd++; // ファイル末尾対策  ＜＜これが無いと "End"の[d]が欠ける＞＞
			
			// [CRLF] [LFCR] 対応のため、次の1バイトを調べてCRまたはLFならば終端を1バイト進める
			one = [input readDataOfLength:1]; // 次の1バイトを先取りしておく 「次の読み込みの開始位置をセットする」ために使用
			
			// 最初に見つかった[CR]または[LF]の直前までを切り出して文字列にする
			[input seekToFileOffset:ulStart]; 
			data = [input readDataOfLength:(ulEnd - ulStart - 1)];  // 1行分読み込み
			NSString *csvStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			NSString *csvSplit = [csvStr stringByAppendingString:@",,,,,,,,,,"]; // 最大項目数以上追加しておく
			[csvStr release];	// 行毎に生成＆破棄
			AzLOG(@"%@", csvSplit);
			// さらに、切り出した文字列をCSV区切りで配列に切り出す
			NSArray *csvArray = [csvSplit componentsSeparatedByString:@","];
			AzLOG(@"(%@,%@,%@)", [csvArray objectAtIndex:0], [csvArray objectAtIndex:1], [csvArray objectAtIndex:2]);

			
			// 次の読み込みの開始位置をセットする
			// 次の1バイトが[CR]または[LF]ならば、さらに1バイト進める
			if ([one isEqualToData:dLF] || [one isEqualToData:dCR]) ulEnd++; // 終端を1バイト進める
			// LOOPの最後で開始位置をセットしている。
			
			//============================================================================CoreData Set
			
			if (iSection==0 && [[csvArray objectAtIndex:0] isEqualToString:GD_PRODUCTNAME]
				&& [[csvArray objectAtIndex:1] isEqualToString:@"CSV"]) {
				// GD_PRODUCTNAME  @",CSV,UTF-8,Copyright,(C)2010,Azukid.com,,,\n";
				iSection = 1;
			}
			else if (iSection==0) {
				// 1行目が GD_PRODUCTNAME,CSV, で無かったとき
				if (!zErrMsg) zErrMsg = NSLocalizedString(@"Different file formats.", @"CSV形式が違います");
				break; // @finallyを通すため returnはダメ
			}
			else if (iSection==1 && [[csvArray objectAtIndex:0] isEqualToString:@"Structure"]) {
				iSection = 2;
			}
			else if (iSection==2 && [[csvArray objectAtIndex:0] isEqualToString:@"[Plan]"]) { // OLD
				[maE1struc setArray:csvArray];
			}
			else if (iSection==2 && [[csvArray objectAtIndex:0] isEqualToString:@"[Pack]"]) { // NEW
				[maE1struc setArray:csvArray];
			}
			else if (iSection==2 && [[csvArray objectAtIndex:0] isEqualToString:@"[Group]"]) {
				[maE2struc setArray:csvArray];
			}
			else if (iSection==2 && [[csvArray objectAtIndex:0] isEqualToString:@"[Item]"]) {
				[maE3struc setArray:csvArray];
			}
			else if (iSection==2 && [[csvArray objectAtIndex:0] isEqualToString:@"Begin"]) {
				iSection = 3;
			}
			else if (iSection==3 && [[csvArray objectAtIndex:0] isEqualToString:@""]
					 && ![[csvArray objectAtIndex:1] isEqualToString:@""]) {  // 最後は、NOTです！ E2との違い
				// [Plan],name,note,,,,,,
				//-----------------------------------------------E1
				// ContextにE1ノードを追加する　E1edit内でCANCELならば削除している
				e1obj = (E1 *)[NSEntityDescription insertNewObjectForEntityForName:@"E1" 
															inManagedObjectContext:self.PmanagedObjectContext];
				//-----------------------------------------------Numbers
				e1obj.row  = [NSNumber numberWithInteger:self.PiSelectedRow];  // 親からもらった値
				self.PiSelectedRow++;  // 連続Downloadに対応するため。
				//-----------------------------------------------Strings
				e1obj.name = [self csvString:maE1struc csvLine:csvArray csvCol:@"name"];
				e1obj.note = [self csvString:maE1struc csvLine:csvArray csvCol:@"note"];
				//-----------------------------------------------
				iSection = 4;
				e2row = 0;
				bManagedObjectContextSave = YES;  // 少なくとも[Plan]名があれば保存するため
			}
			else if (4<=iSection && [[csvArray objectAtIndex:0] isEqualToString:@""] 
					 && [[csvArray objectAtIndex:1] isEqualToString:@""]
					 && ![[csvArray objectAtIndex:2] isEqualToString:@""]) {  // 最後は、NOTです！ E3との違い
				// [Group],,name,note,,,,,
				//-----------------------------------------------E2
				e2obj = (E2 *)[NSEntityDescription insertNewObjectForEntityForName:@"E2" 
															inManagedObjectContext:self.PmanagedObjectContext];
				e2obj.row = [NSNumber numberWithInteger:e2row++];  //[self csvNumber:maE2struc csvLine:csvArray csvCol:@"row"];
				//-----------------------------------------------Strings
				e2obj.name = [self csvString:maE2struc csvLine:csvArray csvCol:@"name"];
				e2obj.note = [self csvString:maE2struc csvLine:csvArray csvCol:@"note"];
				//-----------------------------------------------
				[e1obj addChildsObject:e2obj];
				iSection = 5;
				e3row = 0;
			}
			else if (iSection==5 && [[csvArray objectAtIndex:0] isEqualToString:@""] 
					 && [[csvArray objectAtIndex:1] isEqualToString:@""]
					 && [[csvArray objectAtIndex:2] isEqualToString:@""]) {
				// [Item],,,name,spec,stock,need,weight,note
				//-----------------------------------------------E3
				e3obj = (E3 *)[NSEntityDescription insertNewObjectForEntityForName:@"E3" 
															inManagedObjectContext:self.PmanagedObjectContext];
				e3obj.row = [NSNumber numberWithInteger:e3row++];  // [self csvNumber:maE3struc csvLine:csvArray csvCol:@"row"];
				//-----------------------------------------------Numbers
				e3obj.stock = [self csvNumber:maE3struc csvLine:csvArray csvCol:@"stock"];
				e3obj.need = [self csvNumber:maE3struc csvLine:csvArray csvCol:@"need"];
				e3obj.weight = [self csvNumber:maE3struc csvLine:csvArray csvCol:@"weight"];
				//-----------------------------------------------Strings
				e3obj.name = [self csvString:maE3struc csvLine:csvArray csvCol:@"name"];
				e3obj.note = [self csvString:maE3struc csvLine:csvArray csvCol:@"note"];
				//-----------------------------------------------E3:冗長計算処理
				NSInteger iStock = [e3obj.stock intValue];
				NSInteger iNeed = [e3obj.need intValue];
				NSInteger iWeight = [e3obj.weight intValue];
				e3obj.weightStk = [NSNumber numberWithInteger:(iWeight * iStock)];
				e3obj.weightNed = [NSNumber numberWithInteger:(iWeight * iNeed)];
				e3obj.lack = [NSNumber numberWithInteger:(iNeed - iStock)];
				e3obj.weightLack = [NSNumber numberWithInteger:((iNeed - iStock) * iWeight)];
				//-----------------------------------------------
				if (0 < iNeed)
					e3obj.noGray = [NSNumber numberWithInteger:1];
				else
					e3obj.noGray = [NSNumber numberWithInteger:0];
				//-----------------------------------------------
				if (0 < iNeed && iStock < iNeed)
					e3obj.noCheck = [NSNumber numberWithInteger:1];
				else
					e3obj.noCheck = [NSNumber numberWithInteger:0];
				//-----------------------------------------------
				[e2obj addChildsObject:e3obj];
				//iSection = 5;
			}
			else if (3<=iSection && [[csvArray objectAtIndex:0] isEqualToString:@"End"]) {
				// 保存する
				bManagedObjectContextSave = YES;
				break; // LOOP OUT
			}
			AzLOG(@"iSection=%d", iSection);
			//============================================================================CoreData Set
			if ([one length] <= 0) {
				AzLOG(@"Break3");
				break; // LOOP OUT
			}
			ulStart = ulEnd;
			[input seekToFileOffset:ulStart]; // 次の開始位置にセット
		} // LOOP END
		
		if (zErrMsg==nil  && e1obj) {
			for (e2obj in e1obj.childs) {
				// E2 sum属性　＜高速化＞ 親sum保持させる
				[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.noGray"] forKey:@"sumNoGray"];
				[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.noCheck"] forKey:@"sumNoCheck"];
				[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.weightStk"] forKey:@"sumWeightStk"];
				[e2obj setValue:[e2obj valueForKeyPath:@"childs.@sum.weightNed"] forKey:@"sumWeightNed"];
			}
			
			// E1 sum属性　＜高速化＞ 親sum保持させる
			[e1obj setValue:[e1obj valueForKeyPath:@"childs.@sum.sumNoGray"] forKey:@"sumNoGray"];
			[e1obj setValue:[e1obj valueForKeyPath:@"childs.@sum.sumNoCheck"] forKey:@"sumNoCheck"];
			[e1obj setValue:[e1obj valueForKeyPath:@"childs.@sum.sumWeightStk"] forKey:@"sumWeightStk"];
			[e1obj setValue:[e1obj valueForKeyPath:@"childs.@sum.sumWeightNed"] forKey:@"sumWeightNed"];
		}
		
		if (zErrMsg==nil  && bManagedObjectContextSave) {
			// 保存する
			NSError *err = nil;
			if (![self.PmanagedObjectContext save:&err]) {
				// 保存失敗
				AzLOG(@"Unresolved error %@, %@", err, [err userInfo]);
				if (!zErrMsg) zErrMsg = NSLocalizedString(@"CoreData failed to save.", @"CoreData 保存失費");
			}
			else {
				// 保存成功
				//self.selectedRow++;  // 次の "Begin" から新たなPlanがはじまるのに対応
				//zErrMsg = nil; // Compleat!
			}
		}
		else {
			// Endが無い ＆ [Plan]も無い
			if (!zErrMsg) zErrMsg = NSLocalizedString(@"No file content.", @"CSV内容なし");
		}
	} 
	@catch (NSException *errEx) {
		if (!zErrMsg) zErrMsg = NSLocalizedString(@"File read error", @"CSV読み込み失敗");
		NSString *name = [errEx name];
		AzLOG(@"◆ %@ : %@\n", name, [errEx reason]);
		if ([name isEqualToString:NSRangeException]) {
			AzLOG(@"Exception was caught successfully.\n");
		} else {
			[errEx raise];
		}
	}
	@finally {
		// CLOSE
        [input closeFile];
		// release
		[maE3struc release];
		[maE2struc release];
		[maE1struc release];
		[dCR release];
		[dLF release];
	}	
	return zErrMsg;
}

@end

