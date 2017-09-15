//
//  SettingTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//#import "SFHFKeychainUtils.h"
#import "Global.h"
#import "AppDelegate.h"
#import "SettingTVC.h"

#define TAG_GD_OptEnableSchedule		974
#define TAG_GD_OptEnableCategory		965
#define TAG_GD_OptEnableInstallment		956
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



#pragma mark - View lifecicle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (instancetype)initWithStyle:(UITableViewStyle)style 
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) {  // セクションありテーブル
		// OK
        if (IS_PAD) {
            self.preferredContentSize = CGSizeMake(480, 300);
            self.navigationItem.hidesBackButton = YES;
        }
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
    if (IS_PAD) {
        self.navigationItem.hidesBackButton = YES;
    }
	self.title = NSLocalizedString(@"Setting", nil);
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    if (IS_PAD) {
        //Popover [Menu] button
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (app.barMenu) {
            UIBarButtonItem* buFlexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem* buFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            UIBarButtonItem* buTitle = [[UIBarButtonItem alloc] initWithTitle: self.title  style:UIBarButtonItemStylePlain target:nil action:nil];
            NSMutableArray* items = [[NSMutableArray alloc] initWithObjects: buFixed, app.barMenu, buFlexible, buTitle, buFlexible, nil];
            UIToolbar* toolBar = [[UIToolbar alloc] init];
            toolBar.barStyle = UIBarStyleDefault;
            [toolBar setItems:items animated:NO];
            [toolBar sizeToFit];
            self.navigationItem.titleView = toolBar;
        }
        [self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示
    }else{
        [self.navigationController setToolbarHidden:YES animated:animated]; // ツールバー消す
    }
	
	// 画面表示に関係する Option Setting を取得する
	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	//MbOptAntirotation = [userDefaults boolForKey:GD_OptAntirotation];
	
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
    if (IS_PAD) {
        return YES;
    }else{
        // 回転禁止でも、正面は常に許可しておくこと。
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
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
	long lRate = (long)(MlbTaxRate.text).integerValue + button.tag;
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
	/*	case TAG_GD_OptAntirotation:
			MbOptAntirotation = [sender isOn];  // このViewでも反映させるため。
			[defaults setBool:MbOptAntirotation forKey:GD_OptAntirotation];
			break;*/
		case TAG_GD_OptEnableInstallment:
			[defaults setBool:sender.on forKey:GD_OptEnableInstallment];
			break;
		case TAG_GD_OptRoundBankers:
			[defaults setBool:sender.on forKey:GD_OptRoundBankers];
			break;
	}
}


#pragma mark - TableView lifecicle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#ifdef AZ_LEGACY
    return 1;  // iCloud Downloadなし
#else
    return 2;
#endif
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    switch (section) {
        case 0: return 3;
        case 1: return 1;
    }
	return 0;
}

#if defined (FREE_AD) //&& defined (AzPAD)
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
	return 55; // デフォルト：44ピクセル
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *zCellIndex = [NSString stringWithFormat:@"Setting%d:%d", (int)indexPath.section, (int)indexPath.row];
	UITableViewCell *cell = nil;

	if (1 < indexPath.section) return nil;  // section=0,1 のみ

	cell = [tableView dequeueReusableCellWithIdentifier:zCellIndex];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:zCellIndex];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.showsReorderControl = NO; // Move禁止
		
		cell.textLabel.font = [UIFont systemFontOfSize:20];
		cell.textLabel.textColor = [UIColor blackColor];
		
		cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
		cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            // Download from iCloud
            cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
            cell.imageView.image = [UIImage imageNamed:@"R32_iCloud-Down"];
            cell.textLabel.text = NSLocalizedString(@"iCloud Download",nil);
            cell.detailTextLabel.text = NSLocalizedString(@"iCloud Download Detail",nil);
            // iCloud KVS
            NSUbiquitousKeyValueStore *ukvs = [NSUbiquitousKeyValueStore defaultStore];
            NSString* zTimestamp = [ukvs stringForKey:UKVS_UPLOAD_DATE];
            if (zTimestamp.length < 1) {
                cell.detailTextLabel.text = [cell.detailTextLabel.text
                                             stringByAppendingString:NSLocalizedString(@"iCloud Download Detail NON",nil)];
            }else{
                cell.detailTextLabel.text = [cell.detailTextLabel.text
                                             stringByAppendingString:zTimestamp];
            }
        }
        return cell;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray; // 選択時ハイライト
    
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
    float fX;
    if (IS_PAD) {
        fX = self.tableView.frame.size.width - 100 - 120;
    }else{
        fX = cell.frame.size.width - 120;
        if (320.0 < self.view.frame.size.width) {  //iPhone6以降対応
            fX += (self.view.frame.size.width - 320.0);
        }
    }
	
	switch (indexPath.row) {
		case 0:
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
				cell.textLabel.text = NSLocalizedString(@"OptEnableInstallment",nil);
				cell.detailTextLabel.text = NSLocalizedString(@"OptEnableInstallment msg",nil);
			}
			sw.frame = CGRectMake(fX, 8, 120, 25); // 回転対応
		} break;
			
		case 1:
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
				cell.textLabel.text = NSLocalizedString(@"OptRoundBankers",nil);
				cell.detailTextLabel.text = NSLocalizedString(@"OptRoundBankers msg",nil);
			}
			sw.frame = CGRectMake(fX, 8, 120, 25); // 回転対応
		} break;
			
		case 2:
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
				MlbTaxRate.textAlignment = NSTextAlignmentCenter;
				MlbTaxRate.font = [UIFont boldSystemFontOfSize:20];
				[cell.contentView  addSubview:MlbTaxRate]; 
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
	}
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            // Download from iCloud
            [AZAlert target:self
                 actionRect:[tableView rectForRowAtIndexPath:indexPath]
                      title:NSLocalizedString(@"iCloud Download", nil)
                    message:NSLocalizedString(@"iCloud Download Detail", nil)
                    b1title:NSLocalizedString(@"iCloud Download OK", nil)
                    b1style:UIAlertActionStyleDestructive
                   b1action:^(UIAlertAction * _Nullable action) {
                       // Download to iCloud
                       [DataManager.singleton iCloudDownloadAlert];
                   }
                    b2title:NSLocalizedString(@"Cancel", nil)
                    b2style:UIAlertActionStyleCancel
                   b2action:nil];
        }
        return;
    }
}


#pragma make - <UITextFieldDelegate>

// キーボードのリターンキーを押したときに呼ばれる
- (BOOL)textFieldShouldReturn:(UITextField *)sender 
{
	if (sender==MtfPass1) {
		if (20 < (sender.text).length) {
			sender.text = @"";
//			alertBox(NSLocalizedString(@"OptLoginPass Over",nil), 
//					 NSLocalizedString(@"OptLoginPass Over msg",nil), 
//					 NSLocalizedString(@"Roger",nil));
            [AZAlert target:self
                 actionRect:sender.frame
                      title:NSLocalizedString(@"OptLoginPass Over",nil)
                    message:NSLocalizedString(@"OptLoginPass Over msg",nil)
                    b1title:NSLocalizedString(@"Roger",nil)
                    b1style:UIAlertActionStyleDefault
                   b1action:nil];

			return NO;
		}
		MtfPass2.text = @"";
		[MtfPass2 becomeFirstResponder];
	}
	else if (sender==MtfPass2) {
		[MtfPass2 resignFirstResponder];
		if ([MtfPass1.text isEqualToString:MtfPass2.text]) {
			// 一致、パス変更
//			// PasswordをKeyChainに保存する
//			NSError *error; // nilを渡すと異常終了するので注意
//			[SFHFKeychainUtils storeUsername:GD_KEY_LOGINPASS
//								 andPassword:MtfPass1.text 
//							  forServiceName:GD_PRODUCTNAME 
//							  updateExisting:YES error:&error];
//			if (error) {
////				GA_TRACK_EVENT_ERROR([error localizedDescription],0);
//				alertBox(NSLocalizedString(@"OptLoginPass Error",nil),
//						 error.localizedDescription,
//						 NSLocalizedString(@"Roger",nil));
//			} else {
//				alertBox(NSLocalizedString(@"OptLoginPass Changed",nil), 
//						 NSLocalizedString(@"OptLoginPass Changed msg",nil), 
//						 @"OK");
//			}
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

