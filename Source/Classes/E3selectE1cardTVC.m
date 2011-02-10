//
//  E3selectE1cardTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "E3selectE1cardTVC.h"

@interface E3selectE1cardTVC (PrivateMethods)
//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
//----------------------------------------------Owner移管につきdealloc時のrelese不要
//----------------------------------------------assign
BOOL MbOptShouldAutorotate;
@end
@implementation E3selectE1cardTVC
@synthesize PPe1card;

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[Me1cards release];

	// @property (retain)
	
	[super dealloc];
}

- (void)viewDidUnload 
{
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。
	[Me1cards release];		Me1cards = nil;

	// @property (retain) は解放しない。
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"viewDidUnload" 
													 message:@"E3selectE1TVC" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"didReceiveMemoryWarning" 
													 message:@"E3selectE1TVC" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
    [super didReceiveMemoryWarning];
}


- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}


- (void)viewDidLoad 
{
    [super viewDidLoad];
	Me1cards = nil;
	(*PPe1card) = nil; // これが無いと、中止で戻るときFreeze
}

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// 回転禁止でも万一ヨコからはじまった場合、タテにはなるようにしてある。
	return MbOptShouldAutorotate OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated 	// ＜＜見せない処理＞＞
{
    [super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptShouldAutorotate = [defaults boolForKey:GD_OptShouldAutorotate];

	//self.title = NSLocalizedString(@"Card choice",nil);
	
	// Pe1list Requery. 
	//--------------------------------------------------------------------------------
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"E1card" 
											  inManagedObjectContext:appDelegate.managedObjectContext];
	[fetchRequest setEntity:entity];
	// Sorting
	NSSortDescriptor *sortRow = [[NSSortDescriptor alloc] initWithKey:@"nRow" ascending:YES];
	NSArray *sortArray = [[NSArray alloc] initWithObjects:sortRow, nil];
	[fetchRequest setSortDescriptors:sortArray];
	// Fitch
	NSError *error = nil;
	NSArray *arFetch = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		AzLOG(@"Error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	[fetchRequest release];
	//
	if (Me1cards) {
		[Me1cards setArray:arFetch]; // 既存全削除して置き換える
	} else {
		Me1cards = [[NSMutableArray alloc] initWithArray:arFetch];
	}
	[sortArray release];
	[sortRow release];
	// テーブルビューを更新します。
	[self.tableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated {	// ＜＜魅せる処理＞＞
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
	
	// 選択グループを中央に近づける
//	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:PlbGroup.tag inSection:0];
//	[self.tableView scrollToRowAtIndexPath:indexPath 
//							atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // セクションは1つだけ section==0
	return [Me1cards count];
}
/*
// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 36; // デフォルト：44ピクセル
}*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  // Subtitle
									   reuseIdentifier:CellIdentifier] autorelease];

		cell.textLabel.font = [UIFont systemFontOfSize:16];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.textColor = [UIColor blackColor];
    }

    // セクションは1つだけ section==0
	E1card *e1obj = [Me1cards objectAtIndex:indexPath.row];

	if ([e1obj.zName length] <= 0) 
		cell.textLabel.text = NSLocalizedString(@"Untitled", nil);
	else
		cell.textLabel.text = e1obj.zName;

	/*＜＜不可！e1objは、都度生成されているポインタだから一致しない＞＞
	 if ((*PPe1card) == e1obj) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark; // チェックマーク
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	 */
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
	// DONE
	(*PPe1card) = [Me1cards objectAtIndex:indexPath.row]; 
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

@end

