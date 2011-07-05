//
//  E3selectRepeatTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/02/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "Entity.h"
#import "E3selectRepeatTVC.h"


@interface E3selectRepeatTVC (PrivateMethods)
//----------------------------------------------viewDidLoadでnil, dealloc時にrelese
//----------------------------------------------Owner移管につきdealloc時のrelese不要
//----------------------------------------------assign
//BOOL MbOptAntirotation;
@end

@implementation E3selectRepeatTVC
@synthesize Re3edit;
#ifdef xxxAzPAD
@synthesize delegate;
@synthesize selfPopover;
#endif

#pragma mark - Action

#pragma mark - View lifecicle

- (id)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
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
#ifdef xxxAzPAD
	delegate = nil;
	[selfPopover release], selfPopover = nil;
#endif
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
	return 4;
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
			return	NSLocalizedString(@"Repeat Footer", nil);
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

		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.font = [UIFont systemFontOfSize:16];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
    }
	cell.accessoryType = UITableViewCellAccessoryNone;
    
	// セクションは1つだけ section==0
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"Repeat00", nil);
			if ([Re3edit.nRepeat integerValue] == 0)
				cell.accessoryType = UITableViewCellAccessoryCheckmark; // チェックマーク
			break;
		case 1:
			cell.textLabel.text = NSLocalizedString(@"Repeat01", nil);
			if ([Re3edit.nRepeat integerValue] == 1)
				cell.accessoryType = UITableViewCellAccessoryCheckmark; // チェックマーク
			break;
		case 2:
			cell.textLabel.text = NSLocalizedString(@"Repeat02", nil);
			if ([Re3edit.nRepeat integerValue] == 2)
				cell.accessoryType = UITableViewCellAccessoryCheckmark; // チェックマーク
			break;
		case 3:
			cell.textLabel.text = NSLocalizedString(@"Repeat12", nil);
			if ([Re3edit.nRepeat integerValue] == 12)
				cell.accessoryType = UITableViewCellAccessoryCheckmark; // チェックマーク
			break;
	}
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
	// DONE
	switch (indexPath.row) {
		case  1: Re3edit.nRepeat = [NSNumber numberWithInteger: 1]; break;
		case  2: Re3edit.nRepeat = [NSNumber numberWithInteger: 2]; break;
		case  3: Re3edit.nRepeat = [NSNumber numberWithInteger:12]; break;
		default: Re3edit.nRepeat = [NSNumber numberWithInteger: 0]; break;
	}

#ifdef xxxAzPAD
	if (selfPopover) {
		if ([delegate respondsToSelector:@selector(viewWillAppear:)]) {	// メソッドの存在を確認する
			[delegate viewWillAppear:YES];// 再描画
		}
		[selfPopover dismissPopoverAnimated:YES];
	}
#else
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
#endif
}

@end

