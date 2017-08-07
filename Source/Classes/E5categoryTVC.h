//
//  E5categoryTVC.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

//#ifdef AzPAD
//@class PadPopoverInNaviCon;
//#endif

@interface E5categoryTVC : UITableViewController <UISearchBarDelegate,UIPopoverControllerDelegate>

@property (nonatomic, strong) E0root	*Re0root;
@property (nonatomic, assign) E3record	*Pe3edit;
@property (nonatomic, assign) id		delegate;

- (void)refreshTable;

@end
