//
//  E5categoryDetailTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface E5categoryDetailTVC : UITableViewController 
{
@private
	//----------------------------------------------retain
	E5category	*Re5edit;
//#ifdef AzPAD
	//id									delegate;
	//UIPopoverController*	selfPopover;  // 自身を包むPopover  閉じる為に必要
//#endif
	//----------------------------------------------assign
	BOOL		PbAdd;		//
	BOOL		PbSave;		//
	E3record	*__weak Pe3edit;	// =nil:マスタモード  !=nil:選択モード
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------assign
	//BOOL MbOptAntirotation;
}

@property (nonatomic, strong) E5category	*Re5edit;
@property BOOL								PbAdd;
@property BOOL								PbSave;
@property (nonatomic, weak) E3record		*Pe3edit;
//#ifdef AzPAD
@property (nonatomic, assign) id									delegate;
@property (nonatomic, retain) UIPopoverController*	selfPopover;
//#endif

// 公開メソッド
- (void)cancelClose:(id)sender ;

@end
