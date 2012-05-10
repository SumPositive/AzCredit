//
//  SettingTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SFHFKeychainUtils.h"
#import "Global.h"
#import "AppDelegate.h"
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


#pragma mark - dealloc

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	[super dealloc];
}


#pragma mark - View lifecicle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) {  // セクションありテーブル
		// OK
#ifdef AzPAD
		self.contentSizeForViewInPopover = CGSizeMake(480, 300);
		self.navigationItem.hidesBackButton = YES;
#endif
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

- (void)loadView
{
    [super loadView];
#ifdef AzPAD
	self.navigationItem.hidesBackButton = YES;
#endif
	self.title = NSLocalizedString(@"Setting", nil);
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
#ifdef AzPAD
	//Popover [Menu] button
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (app.barMenu) {
		UIBarButtonItem* buFlexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem* buFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
		UIBarButtonItem* buTitle = [[UIBarButtonItem alloc] initWithTitle: self.title  style:UIBarButtonItemStylePlain target:nil action:nil];
		NSMutableArray* items = [[NSMutableArray alloc] initWithObjects: buFixed, app.barMenu, buFlexible, buTitle, buFlexible, nil];
		[buTitle release], buTitle = nil;
		[buFixed release], buFixed = nil;
		[buFlexible release], buFlexible = nil;
		UIToolbar* toolBar = [[UIToolbar alloc] init];
		toolBar.barStyle = UIBarStyleDefault;
		[toolBar setItems:items animated:NO];
		[toolBar sizeToFit];
		self.navigationItem.titleView = toolBar;
		[toolBar release];
		[items release];
	}
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示
#else
	[self.navigationController setToolbarHidden:YES animated:animated]; // ツールバー消す
#endif
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [userDefaults boolForKey:GD_OptAntirotation];
	
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
- (void)viewDidUnload {
	AzLOG(@"MEMORY! SettingTVC: viewDidUnload");
}
*/


#pragma mark  View Rotate
// 回転の許可
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifdef AzPAD
	return YES;
#else
	// 回転禁止でも、正面は常に許可しておくこと。
	return !MbOptAntirotation OR (interfaceOrientation == UIInterfaceOrientationPortrait);
#endif
}
/*
// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{	// self.view.frameは、回転前の状態
	//[self.tableView reloadData];
}
*/
// ユーザインタフェースが回転した後この処理が呼ばれる。
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation // 直前の向き
{	// self.view.frame は、回転後の状態
	[self.tableView reloadData];
}


#pragma mark - Action

- (void)buttonTaxRate:(UIButton *)button
{
	long lRate = (long)[MlbTaxRate.text integerValue] + button.tag;
	if (0 <= lRate && lRate <= 99) {
		MlbTaxRate.text = [NSString stringWithFormat:@"%ld", lRate];
		[[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld", lRate] 
												 forKey:GD_OptTaxRate];
	}
}

// UISwitch Action
- (void)switchAction: (UISwitch *)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	switch (sender.tag) {  // .tag は UIView にて NSInteger で存在する、　
		case TAG_GD_OptAntirotation:
			MbOptAntirotation = [sender isOn];  // このViewでも反映させるため。
			[defaults setBool:MbOptAntirotation forKey:GD_OptAntirotation];
			break;
		case TAG_GD_OptEnableInstallment:
			[defaults setBool:[sender isOn] forKey:GD_OptEnableInstallment];
			break;
		case TAG_GD_OptRoundBankers:
			[defaults setBool:[sender isOn] forKey:GD_OptRoundBankers];
			break;
	}
}


#pragma mark - TableView lifecicle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
#ifdef AzPAD
	return 4;	// (0)回転は不要
#else
	return 5;
#endif
}

#if defined (FREE_AD) && defined (AzPAD)
// TableView セクションタイトルを応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	if (section==0) return @"\n\n";	// iAd上部スペース
	return nil;
}
#endif

// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	switch (indexPath.row) {
#ifdef AzPAD
		case 3:	// OptLoginPass
#else
		case 4:	// OptLoginPass
#endif
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

	if (indexPath.section != 0) return nil;  // section=0 のみ

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
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
#ifdef AzPAD
	float fX = self.tableView.frame.size.width - 100 - 120;
	int  iCase = indexPath.row + 1;
#else
	float fX = cell.frame.size.width - 120;
	int  iCase = indexPath.row;
#endif
	
	switch (iCase) {
		case 0:
		{ // OptAntirotation
			UISwitch *sw = (UISwitch*)[cell.contentView viewWithTag:TAG_GD_OptAntirotation];
			if (sw==nil) {
				// add UISwitch
				sw = [[UISwitch alloc] init];
				BOOL bOpt = [userDefaults boolForKey:GD_OptAntirotation];
				[sw setOn:bOpt animated:NO]; // 初期値セット
				[sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
				sw.tag = TAG_GD_OptAntirotation;
				sw.backgroundColor = [UIColor clearColor]; //背景透明
				[cell.contentView  addSubview:sw]; 
				[sw release];
				cell.textLabel.text = NSLocalizedString(@"OptAntirotation",nil);
				cell.detailTextLabel.text = NSLocalizedString(@"OptAntirotation msg",nil);
			}
			sw.frame = CGRectMake(fX, 8, 120, 25); // 回転対応
		} break;
			
		case 1:
		{ // OptEnableInstallment
			UISwitch *sw = (UISwitch*)[cell.contentView viewWithTag:TAG_GD_OptEnableInstallment];
			if (sw==nil) {
				// add UISwitch
				sw = [[UISwitch alloc] init];
				BOOL bOpt = [userDefaults boolForKey:GD_OptEnableInstallment];
				[sw setOn:bOpt animated:NO]; // 初期値セット
				[sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
				sw.tag = TAG_GD_OptEnableInstallment;
				sw.backgroundColor = [UIColor clearColor]; //背景透明
				[cell.contentView addSubview:sw]; 
				[sw release];
				cell.textLabel.text = NSLocalizedString(@"OptEnableInstallment",nil);
				cell.detailTextLabel.text = NSLocalizedString(@"OptEnableInstallment msg",nil);
			}
			sw.frame = CGRectMake(fX, 8, 120, 25); // 回転対応
		} break;
			
		case 2:
		{ // OptRoundBankers
			UISwitch *sw = (UISwitch*)[cell.contentView viewWithTag:TAG_GD_OptRoundBankers];
			if (sw==nil) {
				// add UISwitch
				sw = [[UISwitch alloc] init];
				BOOL bOpt = [userDefaults boolForKey:GD_OptRoundBankers];
				[sw setOn:bOpt animated:NO]; // 初期値セット
				[sw addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
				sw.tag = TAG_GD_OptRoundBankers;
				sw.backgroundColor = [UIColor clearColor]; //背景透明
				[cell.contentView addSubview:sw]; 
				[sw release];
				cell.textLabel.text = NSLocalizedString(@"OptRoundBankers",nil);
				cell.detailTextLabel.text = NSLocalizedString(@"OptRoundBankers msg",nil);
			}
			sw.frame = CGRectMake(fX, 8, 120, 25); // 回転対応
		} break;
			
		case 3:
		{ // OptTaxRate
			cell.textLabel.text = NSLocalizedString(@"OptTaxRate",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"OptTaxRate msg",nil);

			if (MlbTaxRate==nil) {
				// add UILabel
				MlbTaxRate = [[UILabel alloc] init];
				NSInteger iOpt = [userDefaults integerForKey:GD_OptTaxRate];
				MlbTaxRate.text = [NSString stringWithFormat:@"%ld", (long)iOpt];
				MlbTaxRate.tag = TAG_GD_OptTaxRate;
				MlbTaxRate.backgroundColor = [UIColor clearColor]; //背景透明
				MlbTaxRate.textAlignment = UITextAlignmentCenter;
				MlbTaxRate.font = [UIFont boldSystemFontOfSize:20];
				[cell.contentView  addSubview:MlbTaxRate]; 
				[MlbTaxRate release];
			}
			MlbTaxRate.frame = CGRectMake(fX+5, 8, 50, 25); // 回転対応
			// Left UIButton
			UIButton *buLeft = (UIButton*)[cell.contentView viewWithTag:-1];
			if (buLeft==nil) {
				buLeft = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				buLeft.titleLabel.font = [UIFont boldSystemFontOfSize:20];
				[buLeft setTitle:@"-" forState:UIControlStateNormal];
				buLeft.tag = -1;
				[buLeft addTarget:self action:@selector(buttonTaxRate:) forControlEvents:UIControlEventTouchUpInside];
				[cell.contentView  addSubview:buLeft]; //auto//[buLeft release];
			}
			buLeft.frame = CGRectMake(fX-35, 8, 35, 25); // 回転対応
			// Right UIButton
			UIButton *buRight = (UIButton*)[cell.contentView viewWithTag:+1];
			if (buRight==nil) {
				buRight = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				buRight.titleLabel.font = [UIFont boldSystemFontOfSize:20];
				[buRight setTitle:@"+" forState:UIControlStateNormal];
				buRight.tag = +1;
				[buRight addTarget:self action:@selector(buttonTaxRate:) forControlEvents:UIControlEventTouchUpInside];
				[cell.contentView  addSubview:buRight]; //auto//[buRight release];
			}
			buRight.frame = CGRectMake(fX+55, 8, 35, 25); // 回転対応
		} break;
			
		case 4:
		{ // OptLoginPass
			cell.textLabel.text = NSLocalizedString(@"OptLoginPass",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"OptLoginPass msg",nil);
			// add UITextField1
			if (MtfPass1==nil) {
				MtfPass1 = [[UITextField alloc] init];
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
			}
			MtfPass1.frame = CGRectMake(fX-35, 8, 130, 25); // 回転対応
			// add UITextField2
			if (MtfPass2==nil) {
				MtfPass2 = [[UITextField alloc] init];
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
			}
			MtfPass2.frame = CGRectMake(fX-35,38, 130, 25); // 回転対応
		} break;
	}
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
}


#pragma make - <UITextFieldDelegate>

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
				GA_TRACK_EVENT_ERROR([error localizedDescription],0);
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

