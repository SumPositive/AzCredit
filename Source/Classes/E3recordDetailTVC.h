//
//  E3recordDetailTVC.h.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E3record;

@interface E3recordDetailTVC : UITableViewController  <UIActionSheetDelegate>
{
	//--------------------------retain
	E3record	*Re3edit;
	//--------------------------assign
	BOOL		PbAdd;			// Yes=新規追加（Cancel時にPe3selectを削除する）
	NSInteger	PiFirstYearMMDD;	// PbAdd=YESのとき、E2がこの支払日以降になるように追加する
	
@private
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	E0root			*Me0root;	// Arrayではない！単独　release不要（するとFreeze）
	NSMutableArray	*Me6parts;
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UIBarButtonItem	*MbuTop;		// BarButton ＜hasChanges時に無効にするため＞
	//----------------------------------------------assign
	BOOL			MbOptAntirotation;
	BOOL			MbOptEnableCategory;
	BOOL			MbOptEnableInstallment;
	BOOL			MbOptUseDateTime;
	BOOL			MbAddmode;		// cancel:
	NSInteger		MiE1cardRow;
	BOOL			MbE6paid;		// YES:PAIDあり、主要条件の変更禁止！
}

@property (nonatomic, retain) E3record	*Re3edit;
@property BOOL							PbAdd;
@property NSInteger						PiFirstYearMMDD;	

@end
