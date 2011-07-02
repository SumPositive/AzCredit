//
//  E1cardDetailTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class E0root;

@interface E1cardDetailTVC : UITableViewController 
#ifdef AzPAD
	<UIPopoverControllerDelegate>
#endif
{
@private
	//----------------------------------------------retain
	E1card		*Re1edit;
	//----------------------------------------------assign
	NSInteger	PiAddRow;	// (-1)Edit
	
	//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------Owner移管につきdealloc時のrelese不要
	UILabel		*MlbNote;
#ifdef AzPAD
	UIPopoverController*	MpopoverView;	// 回転時に強制的に閉じるため
#endif
	//----------------------------------------------assign - Entity fields
	//----------------------------------------------assign
	BOOL MbOptAntirotation;
}

@property (nonatomic, retain) E1card	*Re1edit;
@property NSInteger						PiAddRow;

// 公開メソッド
- (void)cancelClose:(id)sender ;
#ifdef AzPAD
- (void)closePopover;
#endif

@end
