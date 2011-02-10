//
//  E3viewController.h
//  iPack
//
//  Created by 松山 和正 on 09/12/06.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E1;
@class E2;
@class E3edit;
@class ItemTouchView;

@interface E3viewController : UITableViewController <UIActionSheetDelegate> 
{
	NSMutableArray *Pe2array;
	E1 *Pe1selected;  // grandParent: 常にセットされる
	E2 *Pe2selected;  // Parent: = nil; Sort listの場合！注意
	NSInteger  PiFirstSection;  // E2から呼び出されたとき頭出しするセクション viewWillAppear内でジャンプ後、(-1)にする。
	NSInteger  PiSortType;		// (-1)Group  (0〜)Sort list.
}

@property (nonatomic, retain) NSMutableArray *Pe2array;  // assignにするとスクーロール中に「戻る」とフリーズする。
														 // assignだとE3側の処理が完了する前に解放されてしまうようだ。
@property (nonatomic, retain) E1 *Pe1selected; //grandParent;
@property (nonatomic, retain) E2 *Pe2selected; //parent;
@property NSInteger  PiFirstSection;
@property NSInteger  PiSortType;

- (void)viewComeback:(NSArray *)selectionArray;  // 再現復帰処理用

@end
