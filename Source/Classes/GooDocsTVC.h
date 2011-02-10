//
//  GooDocsTVC.h
//  AzCredit 
//
//  Created by 松山 和正 on 09/12/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
/* -----------------------------------------------------------------------------------------------
 * GData API ライブラリの組み込み手順
 *
 * 1)ダウンロードした gdata-objectivec-client-1 の Source／GData.xcodeproj から Xcode起動
 *
 * 2)グループとファイルに表示される「GData Source」フォルダを丸ごとドラッグして自己のグループとファイルへ「リンク」する
 *																			　（コピーでなく「リンク」にすること）
 *
 * 3)Xcodeメニュー、プロジェクト設定を編集から「検索パス」をセットする
 *		ヘッダ検索パス		/usr/include/libxml2
 *		他のリンカフラグ	-lxml2		（既に他の定義があれば付け足すことになる）
 *
 * 以上でコンパイル可能になる。
 * -----------------------------------------------------------------------------------------------
 */


#import <UIKit/UIKit.h>
#import "GData/GData.h"
#import "GData/GDataFeedDocList.h"


@interface GooDocsTVC : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> 
{
	E0root		*Re0root;

@private
	//-------------------------------------------------------viewDidLoadでnil, retain > release必要
	UITextField *MtfUsername;
	UITextField *MtfPassword;
	GDataFeedDocList *mDocListFeed;
	NSError *mDocListFetchError;
	GDataServiceTicket *mDocListFetchTicket;
	GDataServiceTicket *mUploadTicket;
	//----------------------------------------------------------------assign
	BOOL			MbLogin;
	BOOL			MbOptAntirotation;
	BOOL			MbUpload;
	NSInteger		MiRowDownload;		// Download対象行
	NSInteger		PiSelectedRow;
	NSString		*MzOldUsername;
	GDataHTTPFetcher *fetcherActive;  // STOPのため保持
	UIActionSheet	*actionProgress;
}

@property (nonatomic, retain) E0root		*Re0root;
//@property BOOL	 PbUpload; 

@end

