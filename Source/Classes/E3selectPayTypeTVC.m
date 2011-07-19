//
//  E3selectPayTypeTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "E3selectPayTypeTVC.h"

@interface E3selectPayTypeTVC (PrivateMethods)
//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
//----------------------------------------------Owner移管につきdealloc時のrelese不要
//----------------------------------------------assign
//BOOL MbOptAntirotation;
@end
@implementation E3selectPayTypeTVC
@synthesize Re3edit;


#pragma mark - Action

#pragma mark - View lifecicle

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
		// OK
#ifdef AzPAD
		self.contentSizeForViewInPopover = GD_POPOVER_SIZE;
#endif
    }
    return self;
}

/*
// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
	[super loadView];
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
}

 - (void)viewDidUnload 
 {
	[super viewDidUnload];
 }
 
 - (void)viewDidLoad 
{
    [super viewDidLoad];
}
*/

- (void)viewWillAppear:(BOOL)animated 	// ＜＜見せない処理＞＞
{
    [super viewWillAppear:animated];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];

	// テーブルビューを更新します。
	[self.tableView reloadData];
	sourcePayType = [Re3edit.nPayType integerValue]; //初期値
}


- (void)viewDidAppear:(BOOL)animated {	// ＜＜魅せる処理＞＞
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
}

#pragma mark  View - Rotate

// 回転の許可　ここでは許可、禁止の判定だけする
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
#ifdef AzPAD
	return NO;	// Popover内につき回転不要
#else
	// 回転禁止でも、正面は常に許可しておくこと。
	return !MbOptAntirotation OR (interfaceOrientation == UIInterfaceOrientationPortrait);
#endif
}

#pragma mark  View - Unload - dealloc

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[Re3edit release];
	[super dealloc];
}


#pragma mark - TableView lifecicle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // セクションは1つだけ section==0
	return 2;  //4;  // [0.3] (101)ボーナス　(201)支払日指定
}
/*
// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 44; // デフォルト：44ピクセル
}*/

// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			return	NSLocalizedString(@"PayType Footer", nil);
			break;
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  // Subtitle
									   reuseIdentifier:CellIdentifier] autorelease];

#ifdef AzPAD
		cell.textLabel.font = [UIFont systemFontOfSize:20];
#else
		cell.textLabel.font = [UIFont systemFontOfSize:16];
#endif
		cell.textLabel.textColor = [UIColor blackColor];
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
			cell.textLabel.text = NSLocalizedString(@"PayType 201", nil);
			if ([Re3edit.nPayType integerValue] == 201)
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
			Re3edit.nPayType = [NSNumber numberWithInt:201];
			break;
		default:
			Re3edit.nPayType = [NSNumber numberWithInt:1];
			break;
	}

	if (sourcePayType != [Re3edit.nPayType integerValue]) {
		AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		apd.entityModified = YES;	//変更あり
	}
	
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

@end

