//
//  E8bankDetailTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface E8bankDetailTVC : UITableViewController 

@property (nonatomic, strong) E8bank	*Re8edit;
@property NSInteger						PiAddRow;
@property BOOL							PbSave;
@property (nonatomic, assign) E1card      *Pe1edit;
@property (nonatomic, assign) id		delegate;

// 公開メソッド
- (void)cancelClose:(id)sender ;

@end
