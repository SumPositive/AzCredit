//
//  E3selectPayTypeTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "Entity.h"
#import "E3selectPayTypeTVC.h"

@interface E3selectPayTypeTVC (PrivateMethods)
//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
//----------------------------------------------Owner移管につきdealloc時のrelese不要
//----------------------------------------------assign
BOOL MbOptAntirotation;
@end
@implementation E3selectPayTypeTVC
@synthesize Re3edit;

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{

	// @property (retain)
	[Re3edit release];
	[super dealloc];
}

- (void)viewDidUnload 
{
	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。

	// @property (retain) は解放しない。
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"viewDidUnload" 
													 message:@"E3selectPayTypeTVC" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"didReceiveMemoryWarning" 
													 message:@"E3selectPayTypeTVC" 
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
}

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// 回転禁止でも万一ヨコからはじまった場合、タテにはなるようにしてある。
	return !MbOptAntirotation OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated 	// ＜＜見せない処理＞＞
{
    [super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];

	// テーブルビューを更新します。
	[self.tableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated {	// ＜＜魅せる処理＞＞
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // セクションは1つだけ section==0
	return 2;  // [0.1] ボーナス未対応
}
/*
// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 44; // デフォルト：44ピクセル
}*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  // Subtitle
									   reuseIdentifier:CellIdentifier] autorelease];

		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.font = [UIFont systemFontOfSize:16];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
    }
	cell.accessoryType = UITableViewCellAccessoryNone;
    
	// セクションは1つだけ section==0
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"PayType 001", nil);
			if ([Re3edit.nPayType integerValue] == 1)
				cell.accessoryType = UITableViewCellAccessoryCheckmark; // チェックマーク
			break;
		case 1:
			cell.textLabel.text = NSLocalizedString(@"PayType 002", nil);
			if ([Re3edit.nPayType integerValue] == 2)
				cell.accessoryType = UITableViewCellAccessoryCheckmark; // チェックマーク
			break;
		case 2:
			cell.textLabel.text = NSLocalizedString(@"PayType 101", nil);
			if ([Re3edit.nPayType integerValue] == 101)
				cell.accessoryType = UITableViewCellAccessoryCheckmark; // チェックマーク
			break;
		case 3:
			cell.textLabel.text = NSLocalizedString(@"PayType 102", nil);
			if ([Re3edit.nPayType integerValue] == 102)
				cell.accessoryType = UITableViewCellAccessoryCheckmark; // チェックマーク
			break;
		default:
			break;
	}
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
	// DONE
	switch (indexPath.row) {
		case 0:
			Re3edit.nPayType = [NSNumber numberWithInt:1];
			break;
		case 1:
			Re3edit.nPayType = [NSNumber numberWithInt:2];
			break;
		case 2:
			Re3edit.nPayType = [NSNumber numberWithInt:101];
			break;
		case 3:
			Re3edit.nPayType = [NSNumber numberWithInt:102];
			break;
		default:
			Re3edit.nPayType = [NSNumber numberWithInt:1];
			break;
	}

	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

@end

