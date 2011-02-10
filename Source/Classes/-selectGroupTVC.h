//
//  selectGroupTVC.h
//  AzPacking
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface selectGroupTVC : UITableViewController 
{
	NSMutableArray	*Pe2array;	// E2(Group) List.
	UILabel			*PlbGroup;	// .tag に E2.row が入る。 選択時、.tag .text に書き込んで返す。
}

@property (nonatomic, retain) NSMutableArray	*Pe2array;
@property (nonatomic, retain) UILabel			*PlbGroup;	

@end
