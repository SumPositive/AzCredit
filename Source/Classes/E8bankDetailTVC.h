//
//  E8bankDetailTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface E8bankDetailTVC : UITableViewController 
{
@private
	//----------------------------------------------retain
	E8bank		*Re8edit;
#ifdef AzPAD
	id									delegate;
	UIPopoverController*	selfPopover;  // 自身を包むPopover  閉じる為に必要
#endif
	//----------------------------------------------assign
	NSInteger	PiAddRow;	// (-1)Edit
	BOOL		PbSave;		//
	E1card		*Pe1edit;	// =nil:マスタモード  !=nil:選択モード
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UILabel		*MlbNote;
#ifdef xxxxxxxxxAzPAD
	UIPopoverController*	MpopoverView;	// 回転時に強制的に閉じるため
#endif
	//----------------------------------------------assign - Entity fields
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E8bank	*Re8edit;
@property NSInteger						PiAddRow;
@property BOOL								PbSave;
@property (nonatomic, assign) E1card	*Pe1edit;
#ifdef AzPAD
@property (nonatomic, assign) id									delegate;
@property (nonatomic, retain) UIPopoverController*	selfPopover;
#endif

// 公開メソッド
- (void)cancelClose:(id)sender ;

@end
