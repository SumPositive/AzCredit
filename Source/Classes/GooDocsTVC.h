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
#import "GData.h"
#import "GDataFeedDocList.h"


@interface GooDocsTVC : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> 
{
	E0root		*Re0root;

@private
	//-------------------------------------------------------viewDidLoadでnil, retain > release必要
	NSAutoreleasePool	*MautoreleasePool;		// [0.3]autorelease独自解放のため
	UITextField			*MtfUsername;
	UITextField			*MtfPassword;
	GDataFeedDocList	*mDocListFeed;
	NSError				*mDocListFetchError;
	GDataServiceTicket	*mDocListFetchTicket;
	GDataServiceTicket	*mUploadTicket;
	//----------------------------------------------------------------assign
	BOOL			MbLogin;
	BOOL			MbOptAntirotation;
	BOOL			MbUpload;
	NSInteger		MiRowDownload;		// Download対象行
	NSInteger		PiSelectedRow;
	NSString		*MzOldUsername;
	GDataHTTPFetcher *fetcherActive;  // STOPのため保持
	UIActionSheet	*actionProgress;
	UIProgressView	*MprogressView;
}

@property (nonatomic, retain) E0root		*Re0root;
//@property BOOL	 PbUpload; 

@end

