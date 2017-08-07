//
//  E4shopDetailTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface E4shopDetailTVC : UITableViewController 

@property (nonatomic, strong) E4shop	*Re4edit;
@property BOOL							PbAdd;
@property BOOL							PbSave;
@property (nonatomic, assign) E3record	*Pe3edit;
@property (nonatomic, assign) id		delegate;

// 公開メソッド
- (void)cancelClose:(id)sender ;

@end
