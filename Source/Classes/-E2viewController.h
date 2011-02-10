//
//  E2viewController.h
//  iPack E2 Section
//
//  Created by 松山 和正 on 09/12/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E1;
//@class E2edit;

@interface E2viewController : UITableViewController <UIActionSheetDelegate> 
{
	E1 *Pe1selected;
}

@property (nonatomic, retain) E1 *Pe1selected;

- (void)viewComeback:(NSArray *)selectionArray;  // 再現復帰処理用

@end
