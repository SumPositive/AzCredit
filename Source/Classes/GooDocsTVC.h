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
 *		ヘッダ検索パス		/usr/include/libxml2
 *		他のリンカフラグ	-lxml2		（既に他の定義があれば付け足すことになる）
 * -----------------------------------------------------------------------------------------------
 */


#import <UIKit/UIKit.h>


@interface GooDocsTVC : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> 
{
@private
	E0root				*Re0root;

	//-------------------------------------------------------viewDidLoadでnil, retain > release必要
	UITextField			*RtfUsername;
	UITextField			*RtfPassword;
//	GDataFeedDocList	*mDocListFeed;
	NSError				*mDocListFetchError;
//	GDataServiceTicket	*mDocListFetchTicket;
//	GDataServiceTicket	*mUploadTicket;
	NSString			*MzUploadName;
	//----------------------------------------------------------------assign
	BOOL			MbLogin;
	//BOOL			MbOptAntirotation;
	BOOL			MbUpload;
	NSInteger		MiRowDownload;		// Download対象行
	NSInteger		MiSelectedRow;
	NSString			*MzOldUsername;  	//[1.1.2]ポインタ代入注意！copyするように改善した。
//	GTMHTTPFetcher *MfetcherActive;  // STOPのため保持
	UIActionSheet	*MactionProgress;
	//UIProgressView	*MprogressView;
}

@property (nonatomic, retain) E0root		*Re0root;

@end

