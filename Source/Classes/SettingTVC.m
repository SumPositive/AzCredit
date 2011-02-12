//
//  SettingTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SFHFKeychainUtils.h"
#import "Global.h"
#import "SettingTVC.h"

//#define TAG_GD_OptBootTopView			992  // GD_OptAntirotation
#define TAG_GD_OptAntirotation			983
#define TAG_GD_OptEnableSchedule		974
#define TAG_GD_OptEnableCategory		965
#define TAG_GD_OptEnableInstallment		956
//#define TAG_GD_OptAmountCalc			947
#define TAG_GD_OptLoginPass1			938	//[4.0]
#define TAG_GD_OptLoginPass2			929	//[4.0]
#define TAG_GD_OptRoundBankers			910 //[4.0]
#define TAG_GD_OptTaxRate				901 //[4.0]


@interface SettingTVC (PrivateMethods)
- (void)buttonTaxRate:(UIButton *)button;
- (void)switchAction:(UISwitch *)sender;
@end

@implementation SettingTVC

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
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
*/

/*
- (void)viewDidUnload {
	AzLOG(@"MEMORY! SettingTVC: viewDidUnload");
}
*/

// 回転の許可
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	// 回転禁止でも、正面は常に許可しておくこと。
	return !MbOptAntirotation OR (interfaceOrientation == UIInterfaceOrientationPortrait);
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
	//[0.4]以降、ヨコでもツールバーを表示するようにした。
	[self.navigationController setToolbarHidden:YES animated:animated]; // ツールバー消す

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



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return 5;
}

// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	switch (indexPath.row) {
		case 4:	// OptLoginPass
			return 70;
			break;
	}
	return 55; // デフォルト：44ピクセル
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
/*[0.4]			case 0:
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
					break;*/
				
				case 0:
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
				} break;
				
				case 1:
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
					[cell.contentView addSubview:sw]; [sw release];
				} break;
					
				case 2:
/*				{ // OptAmountCalc
					cell.textLabel.text = NSLocalizedString(@"OptAmountCalc",nil);
					cell.detailTextLabel.text = NSLocalizedString(@"OptAmountCalc msg",nil);
					// add UISwitch
					UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width-120, 5, 120, 25)];
					BOOL bOpt = [userDefaults boolForKey:GD_OptAmountCalc];
					[sw setOn:bOpt animated:NO]; // 初期値セット
					[sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
					sw.tag = TAG_GD_OptAmountCalc;
					sw.backgroundColor = [UIColor clearColor]; //背景透明
					[cell.contentView  addSubview:sw];
					[sw release];
				} break;*/
				{ // OptRoundBankers
					cell.textLabel.text = NSLocalizedString(@"OptRoundBankers",nil);
					cell.detailTextLabel.text = NSLocalizedString(@"OptRoundBankers msg",nil);
					// add UISwitch
					UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width-120, 5, 120, 25)];
					BOOL bOpt = [userDefaults boolForKey:GD_OptRoundBankers];
					[sw setOn:bOpt animated:NO]; // 初期値セット
					[sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
					sw.tag = TAG_GD_OptRoundBankers;
					sw.backgroundColor = [UIColor clearColor]; //背景透明
					[cell.contentView addSubview:sw]; [sw release];
				} break;
					
				case 3:
				{ // OptTaxRate
					cell.textLabel.text = NSLocalizedString(@"OptTaxRate",nil);
					cell.detailTextLabel.text = NSLocalizedString(@"OptTaxRate msg",nil);
					// add UILabel
					MlbTaxRate = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-115, 5, 50, 25)];
					NSInteger iOpt = [userDefaults integerForKey:GD_OptTaxRate];
					MlbTaxRate.text = [NSString stringWithFormat:@"%ld", (long)iOpt];
					MlbTaxRate.tag = TAG_GD_OptTaxRate;
					MlbTaxRate.backgroundColor = [UIColor clearColor]; //背景透明
					MlbTaxRate.textAlignment = UITextAlignmentCenter;
					MlbTaxRate.font = [UIFont boldSystemFontOfSize:20];
					[cell.contentView  addSubview:MlbTaxRate]; [MlbTaxRate release];
					// Left UIButton
					UIButton *buLeft = [UIButton buttonWithType:UIButtonTypeRoundedRect];
					buLeft.frame = CGRectMake(cell.frame.size.width-155, 5, 35, 25);
					buLeft.titleLabel.font = [UIFont boldSystemFontOfSize:20];
					[buLeft setTitle:@"-" forState:UIControlStateNormal];
					buLeft.tag = -1;
					[buLeft addTarget:self action:@selector(buttonTaxRate:) forControlEvents:UIControlEventTouchUpInside];
					[cell.contentView  addSubview:buLeft]; //auto//[buLeft release];
					// Right UIButton
					UIButton *buRight = [UIButton buttonWithType:UIButtonTypeRoundedRect];
					buRight.frame = CGRectMake(cell.frame.size.width-65, 5, 35, 25);
					buRight.titleLabel.font = [UIFont boldSystemFontOfSize:20];
					[buRight setTitle:@"+" forState:UIControlStateNormal];
					buRight.tag = +1;
					[buRight addTarget:self action:@selector(buttonTaxRate:) forControlEvents:UIControlEventTouchUpInside];
					[cell.contentView  addSubview:buRight]; //auto//[buRight release];
				} break;
					
				case 4:
				{ // OptLoginPass
					cell.textLabel.text = NSLocalizedString(@"OptLoginPass",nil);
					cell.detailTextLabel.text = NSLocalizedString(@"OptLoginPass msg",nil);
					// add UITextField1
					MtfPass1 = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width-155, 5, 130, 25)];
					MtfPass1.borderStyle = UITextBorderStyleRoundedRect;
					MtfPass1.placeholder = NSLocalizedString(@"OptLoginPass1 place",nil);
					MtfPass1.keyboardType = UIKeyboardTypeASCIICapable;
					MtfPass1.secureTextEntry = YES;
					MtfPass1.returnKeyType = UIReturnKeyNext;
					MtfPass1.tag = TAG_GD_OptLoginPass1;
					MtfPass1.delegate = self;
					// KeyChainから保存しているパスワードを取得する
					NSError *error; // nilを渡すと異常終了するので注意
					MtfPass1.text = [SFHFKeychainUtils getPasswordForUsername:GD_KEY_LOGINPASS
															   andServiceName:GD_PRODUCTNAME error:&error];
					[cell.contentView  addSubview:MtfPass1];
					[MtfPass1 release];
					// add UITextField2
					MtfPass2 = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width-155,35, 130, 25)];
					MtfPass2.borderStyle = UITextBorderStyleRoundedRect;
					MtfPass2.placeholder = NSLocalizedString(@"OptLoginPass2 place",nil);
					MtfPass2.keyboardType = UIKeyboardTypeASCIICapable;
					MtfPass2.secureTextEntry = YES;
					MtfPass2.returnKeyType = UIReturnKeyDone;
					MtfPass2.tag = TAG_GD_OptLoginPass2;
					MtfPass2.delegate = self;
					MtfPass2.text = MtfPass1.text;
					[cell.contentView  addSubview:MtfPass2];
					[MtfPass2 release];
				} break;
			}
			break;
	}
    return cell;
}

- (void)buttonTaxRate:(UIButton *)button
{
	long lRate = (long)[MlbTaxRate.text integerValue] + button.tag;
	if (0 <= lRate && lRate <= 99) {
		MlbTaxRate.text = [NSString stringWithFormat:@"%ld", lRate];
		[[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld", lRate] 
												 forKey:GD_OptTaxRate];
	}
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
/*		case TAG_GD_OptBootTopView:
			[defaults setBool:[sender isOn] forKey:GD_OptBootTopView];
			break;*/
		case TAG_GD_OptAntirotation:
			MbOptAntirotation = [sender isOn];  // このViewでも反映させるため。
			[defaults setBool:MbOptAntirotation forKey:GD_OptAntirotation];
			break;
		case TAG_GD_OptEnableInstallment:
			[defaults setBool:[sender isOn] forKey:GD_OptEnableInstallment];
			break;
/*		case TAG_GD_OptAmountCalc:
			[defaults setBool:[sender isOn] forKey:GD_OptAmountCalc];
			break;*/
		case TAG_GD_OptRoundBankers:
			[defaults setBool:[sender isOn] forKey:GD_OptRoundBankers];
			break;
	}
}


//--------------------------------------<UITextFieldDelegate>
// 編集を開始した直後に呼ばれる
/*- (void)textFieldDidBeginEditing:(UITextField *)sender 
{

}*/

// 編集が完了する直前に呼ばれる
/*- (BOOL)textFieldShouldEndEditing:(UITextField *)sender 
{
    return YES;
}*/

// キーボードのリターンキーを押したときに呼ばれる
- (BOOL)textFieldShouldReturn:(UITextField *)sender 
{
	if (sender==MtfPass1) {
		if (20 < [sender.text length]) {
			sender.text = @"";
			alertBox(NSLocalizedString(@"OptLoginPass Over",nil), 
					 NSLocalizedString(@"OptLoginPass Over msg",nil), 
					 NSLocalizedString(@"Roger",nil));
			return NO;
		}
		MtfPass2.text = @"";
		[MtfPass2 becomeFirstResponder];
	}
	else if (sender==MtfPass2) {
		[MtfPass2 resignFirstResponder];
		if ([MtfPass1.text isEqualToString:MtfPass2.text]) {
			// 一致、パス変更
			// PasswordをKeyChainに保存する
			NSError *error; // nilを渡すと異常終了するので注意
			[SFHFKeychainUtils storeUsername:GD_KEY_LOGINPASS
								 andPassword:MtfPass1.text 
							  forServiceName:GD_PRODUCTNAME 
							  updateExisting:YES error:&error];
			if (error) {
				alertBox(NSLocalizedString(@"OptLoginPass Error",nil), 
						 [error localizedDescription],
						 NSLocalizedString(@"Roger",nil));
			} else {
				alertBox(NSLocalizedString(@"OptLoginPass Changed",nil), 
						 NSLocalizedString(@"OptLoginPass Changed msg",nil), 
						 @"OK");
			}
		}
		else {
			// 不一致　　Does not match.
			alertBox(NSLocalizedString(@"OptLoginPass NoMatch",nil), 
					 NSLocalizedString(@"OptLoginPass NoMatch msg",nil), 
					 NSLocalizedString(@"Roger",nil));
			MtfPass2.text = @"";
			[MtfPass2 becomeFirstResponder];
		}
	}
    return YES;
}




/*
- (void)done:(id)sender
{
	//[self.navigationController dismissModalViewControllerAnimated:YES];	// モーダルView閉じる
	[self.navigationController popViewControllerAnimated:YES];
}
*/

@end

