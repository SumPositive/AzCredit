//
//  SettingTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "SettingTVC.h"

#define TAG_GD_OptBootTopView			992  // GD_OptAntirotation
#define TAG_GD_OptAntirotation			983
#define TAG_GD_OptEnableSchedule		974
#define TAG_GD_OptEnableCategory		965
#define TAG_GD_OptEnableInstallment		956
/*#define TAG_GD_OptNumAutoShow			947
#define TAG_GD_OptFixedPriority			938 */


@interface SettingTVC (PrivateMethods)
- (void)switchAction:(UISwitch *)sender;
@end

@implementation SettingTVC

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	// @property (retain)
	
	[super dealloc];
}


// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {  // セクションありテーブル
		// OK
	}
	return self;
}

/*
// viewDidLoadメソッドは，TableViewContorllerオブジェクトが生成された後，実際に表示される際に呼び出されるメソッド
- (void)viewDidLoad 
{
    [super viewDidLoad];
}

- (void)viewDidUnload {
	AzLOG(@"MEMORY! SettingTVC: viewDidUnload");
}
*/

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		// 正面（ホームボタンが画面の下側にある状態）
		[self.navigationController setToolbarHidden:NO animated:YES]; // ツールバー表示する
		return YES; // この方向だけは常に許可する
	} 
	else if (!MbOptAntirotation) {
		// 横方向や逆向きのとき
		[self.navigationController setToolbarHidden:YES animated:YES]; // ツールバー消す
	}
	// 現在の向きは、self.interfaceOrientation で取得できる
	return !MbOptAntirotation;
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	[self.tableView reloadData];
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];

	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [userDefaults boolForKey:GD_OptAntirotation];
	
	self.title = NSLocalizedString(@"Setting", nil);
	
	// テーブルビューを更新します。
    [self.tableView reloadData];	// これにより修正結果が表示される
}


// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];

	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
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

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section) {
		case 0: // 
			return 3;
			break;
	}
    return 0;
}

// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 60; // デフォルト：44ピクセル
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *zCellIndex = [NSString stringWithFormat:@"Setting%d:%d", (int)indexPath.section, (int)indexPath.row];
	UITableViewCell *cell = nil;

	cell = [tableView dequeueReusableCellWithIdentifier:zCellIndex];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:zCellIndex] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.showsReorderControl = NO; // Move禁止
		
		cell.textLabel.font = [UIFont systemFontOfSize:20];
		cell.textLabel.textColor = [UIColor blackColor];
		
		cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
		cell.detailTextLabel.textColor = [UIColor grayColor];

		cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
	}
	else {
		// 回転対応：
		NSArray *aSub = [NSArray arrayWithArray:cell.contentView.subviews];
		UIView *sub = [aSub objectAtIndex:1]; // 実験的に(1)が追加コントロールだった。少し不安な実装だ
		if (sub != nil && 900 < sub.tag) { // 念のためにsub.tagチェックしている。
			CGRect rect = sub.frame;
			rect.origin.x = cell.frame.size.width - 30 - rect.size.width;
			sub.frame = rect;
		}
		return cell; // このTVだけCell個体識別しているため
	}
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	switch (indexPath.section) {
		case 0: // 
			switch (indexPath.row) {
				case 0:
				{ // OptBootTopView
					cell.textLabel.text = NSLocalizedString(@"OptBootTopView",nil);
					cell.detailTextLabel.text = NSLocalizedString(@"OptBootTopView msg",nil);
					// add UISwitch
					UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width-120, 5, 120, 25)];
					BOOL bOpt = [userDefaults boolForKey:GD_OptBootTopView];
					[sw setOn:bOpt animated:NO]; // 初期値セット
					[sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
					sw.tag = TAG_GD_OptBootTopView;
					sw.backgroundColor = [UIColor clearColor]; //背景透明
					[cell.contentView  addSubview:sw];
					[sw release];
				}
					break;
				case 1:
				{ // OptAntirotation
					cell.textLabel.text = NSLocalizedString(@"OptAntirotation",nil);
					cell.detailTextLabel.text = NSLocalizedString(@"OptAntirotation msg",nil);
					// add UISwitch
					UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width-120, 5, 120, 25)];
					BOOL bOpt = [userDefaults boolForKey:GD_OptAntirotation];
					[sw setOn:bOpt animated:NO]; // 初期値セット
					[sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
					sw.tag = TAG_GD_OptAntirotation;
					sw.backgroundColor = [UIColor clearColor]; //背景透明
					[cell.contentView  addSubview:sw]; [sw release];
				}
					break;
				case 2:
				{ // OptEnableInstallment
					cell.textLabel.text = NSLocalizedString(@"OptEnableInstallment",nil);
					cell.detailTextLabel.text = NSLocalizedString(@"OptEnableInstallment msg",nil);
					// add UISwitch
					UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width-120, 5, 120, 25)];
					BOOL bOpt = [userDefaults boolForKey:GD_OptEnableInstallment];
					[sw setOn:bOpt animated:NO]; // 初期値セット
					[sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
					sw.tag = TAG_GD_OptEnableInstallment;
					sw.backgroundColor = [UIColor clearColor]; //背景透明
					[cell.contentView  addSubview:sw];
					[sw release];
				}
					break;
/*				case 2:
				{ // OptEnableSchedule
					cell.textLabel.text = NSLocalizedString(@"OptEnableSchedule",nil);
					cell.detailTextLabel.text = NSLocalizedString(@"OptEnableSchedule msg",nil);
					// add UISwitch
					UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width-120, 5, 120, 25)];
					BOOL bOpt = [userDefaults boolForKey:GD_OptEnableSchedule];
					[sw setOn:bOpt animated:NO]; // 初期値セット
					[sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
					sw.tag = TAG_GD_OptEnableSchedule;
					sw.backgroundColor = [UIColor clearColor]; //背景透明
					[cell.contentView  addSubview:sw];
					[sw release];
				}
					break;*/
/*				case 3:
					 { // OptEnableCategory
					 cell.textLabel.text = NSLocalizedString(@"OptEnableCategory",nil);
					 cell.detailTextLabel.text = NSLocalizedString(@"OptEnableCategory msg",nil);
					 // add UISwitch
					 UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width-120, 5, 120, 25)];
					 BOOL bOpt = [userDefaults boolForKey:GD_OptEnableCategory];
					 [sw setOn:bOpt animated:NO]; // 初期値セット
					 [sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
					 sw.tag = TAG_GD_OptEnableCategory;
					 sw.backgroundColor = [UIColor clearColor]; //背景透明
					 [cell.contentView  addSubview:sw];
					 [sw release];
					 }
					 break; */
/*				case 5:
				{ // OptNumAutoShow
					cell.textLabel.text = NSLocalizedString(@"OptNumAutoShow",nil);
					cell.detailTextLabel.text = NSLocalizedString(@"OptNumAutoShow msg",nil);
					// add UISwitch
					UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width-120, 5, 120, 25)];
					BOOL bOpt = [userDefaults boolForKey:GD_OptNumAutoShow];
					[sw setOn:bOpt animated:NO]; // 初期値セット
					[sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
					sw.tag = TAG_GD_OptNumAutoShow;
					sw.backgroundColor = [UIColor clearColor]; //背景透明
					[cell.contentView  addSubview:sw];
					[sw release];
				}
					break;
				case 6:
				{ // OptFixedPriority
					cell.textLabel.text = NSLocalizedString(@"OptFixedPriority",nil);
					cell.detailTextLabel.text = NSLocalizedString(@"OptFixedPriority msg",nil);
					// add UISwitch
					UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width-120, 5, 120, 25)];
					BOOL bOpt = [userDefaults boolForKey:GD_OptFixedPriority];
					[sw setOn:bOpt animated:NO]; // 初期値セット
					[sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
					sw.tag = TAG_GD_OptFixedPriority;
					sw.backgroundColor = [UIColor clearColor]; //背景透明
					[cell.contentView  addSubview:sw];
					[sw release];
				}
					break;*/
			}
			break;
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
}


// UISwitch Action
- (void)switchAction: (UISwitch *)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	switch (sender.tag) {  // .tag は UIView にて NSInteger で存在する、　
		case TAG_GD_OptBootTopView:
			[defaults setBool:[sender isOn] forKey:GD_OptBootTopView];
			break;
		case TAG_GD_OptAntirotation:
			MbOptAntirotation = [sender isOn];  // このViewでも反映させるため。
			[defaults setBool:MbOptAntirotation forKey:GD_OptAntirotation];
			break;
/*		case TAG_GD_OptEnableSchedule:
			[defaults setBool:[sender isOn] forKey:GD_OptEnableSchedule];
			break;*/
		case TAG_GD_OptEnableInstallment:
			[defaults setBool:[sender isOn] forKey:GD_OptEnableInstallment];
			break;

/*		case TAG_GD_OptEnableCategory:
			[defaults setBool:[sender isOn] forKey:GD_OptEnableCategory];
			break;*/
/*		case TAG_GD_OptNumAutoShow:
			[defaults setBool:[sender isOn] forKey:GD_OptNumAutoShow];
			break;
		case TAG_GD_OptFixedPriority:
			[defaults setBool:[sender isOn] forKey:GD_OptFixedPriority];
			break;*/
	}
}

/*
- (void)done:(id)sender
{
	//[self.navigationController dismissModalViewControllerAnimated:YES];	// モーダルView閉じる
	[self.navigationController popViewControllerAnimated:YES];
}
*/

@end

