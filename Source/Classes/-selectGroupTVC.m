//
//  selectGroupTVC.m
//  AzPacking
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "Elements.h"
#import "selectGroupTVC.h"

@interface selectGroupTVC (PrivateMethods)
//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
//----------------------------------------------Owner移管につきdealloc時のrelese不要
//----------------------------------------------assign
BOOL MbOptShouldAutorotate;
@end
@implementation selectGroupTVC
@synthesize Pe2array;
@synthesize PlbGroup;

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	// @property (retain)
	AzRETAIN_CHECK(@"selectGroupTVC PlbGroup", PlbGroup, 0)
	[PlbGroup release];
	AzRETAIN_CHECK(@"selectGroupTVC Pe2array", Pe2array, 0)
	[Pe2array release];
	
	[super dealloc];
}

- (void)viewDidUnload 
{
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。

	// @property (retain) は解放しない。
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"viewDidUnload" 
													 message:@"selectGroupTVC" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"didReceiveMemoryWarning" 
													 message:@"selectGroupTVC" 
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

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/


- (void)viewWillAppear:(BOOL)animated 	// ＜＜見せない処理＞＞
{
    [super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptShouldAutorotate = [defaults boolForKey:GD_OptShouldAutorotate];

	self.title = NSLocalizedString(@"Group choice",nil);

	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
}


- (void)viewDidAppear:(BOOL)animated {	// ＜＜魅せる処理＞＞
    [super viewDidAppear:animated];
	
	// 選択グループを中央に近づける
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:PlbGroup.tag inSection:0];
	[self.tableView scrollToRowAtIndexPath:indexPath 
							atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// 回転禁止でも万一ヨコからはじまった場合、タテにはなるようにしてある。
	return MbOptShouldAutorotate OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // セクションは1つだけ section==0
	return [Pe2array count];
}

// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 30; // デフォルト：44ピクセル
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  // Subtitle
									   reuseIdentifier:CellIdentifier] autorelease];
    }

    // セクションは1つだけ section==0
	E2 *e2obj = [Pe2array objectAtIndex:indexPath.row];

	if ([e2obj.name length] <= 0) 
		cell.textLabel.text = NSLocalizedString(@"Untitled", nil);
	else
		cell.textLabel.text = e2obj.name;

//	cell.detailTextLabel.text = e2obj.note;
	
	cell.textLabel.font = [UIFont systemFontOfSize:16];
	cell.textLabel.textAlignment = UITextAlignmentLeft;
	cell.textLabel.textColor = [UIColor blackColor];
	
//	cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
//	cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
//	cell.detailTextLabel.textColor = [UIColor grayColor];
	
	if (PlbGroup.tag == indexPath.row) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark; // チェックマーク
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark; // チェックマーク
	
	PlbGroup.tag = indexPath.row;
	PlbGroup.text = cell.textLabel.text;
	
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end

