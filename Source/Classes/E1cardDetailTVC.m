//
//  E1cardDetailTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "E1cardTVC.h"
#import "E1cardDetailTVC.h"
#import "EditTextVC.h"
#import "E1editPayDayVC.h"
#import "E1editBonusVC.h"
#import "E8bankTVC.h"

#define LABEL_NOTE_SUFFIX   @"\n\n\n\n\n\n\n\n\n\n"  // UILabel *MlbNoteを上寄せするための改行（10行）

@interface E1cardDetailTVC (PrivateMethods)
- (void)viewDesign;
@end

@implementation E1cardDetailTVC
@synthesize Re1edit;
@synthesize PiAddRow;
#ifdef AzPAD
@synthesize delegate;
@synthesize selfPopover;
#endif



#pragma mark - Action

- (void)cancelClose:(id)sender
{
	[MocFunctions rollBack]; // 前回のSAVE以降を取り消す
	
	if (0 <= PiAddRow) { // Add
		// Add mode: 新オブジェクトのキャンセルなので、呼び出し元で挿入したオブジェクトを削除する
		[MocFunctions deleteEntity:Re1edit];
	}
	
#ifdef AzPAD
	if (selfPopover) {
		[selfPopover dismissPopoverAnimated:YES];
	} else {
		[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
	}
#else
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
#endif
}

// 編集フィールドの値を self.e3target にセットする
- (void)saveClose:(id)sender 
{
	if (0 <= PiAddRow) { // Add
		Re1edit.nRow = @(PiAddRow);
	}
	
	// E1,E2,E3,E6,E7 の関係を保ちながら更新する
	[MocFunctions e1update:Re1edit];
	[MocFunctions commit];
	
#ifdef AzPAD
	if (selfPopover) {
		if ([delegate respondsToSelector:@selector(refreshTable)]) {	// メソッドの存在を確認する
			[delegate refreshTable];// 親の再描画を呼び出す
		}
		[selfPopover dismissPopoverAnimated:YES];
	}
#else
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
#endif
}

#ifdef xxxAzPAD
- (void)closePopover
{
	if (MpopoverView) {	//dismissPopoverCancel
		[MpopoverView dismissPopoverAnimated:YES];
	}
}
#endif



#pragma mark - View lifecicle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (instancetype)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStyleGrouped];  // セクションありテーブル
	if (self) {
		// 初期化成功
#ifdef AzPAD
		self.preferredContentSize = GD_POPOVER_SIZE;
#endif
  	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
//【Tips】ここでaddSubviewするオブジェクトは全てautoreleaseにすること。メモリ不足時には自動的に解放後、改めてここを通るので、初回同様に生成するだけ。
- (void)loadView
{
    [super loadView];

	// ここは、alloc直後に呼ばれるため、下記のようなパラは未セット状態である。==>> viewWillAppearで参照すること

	//self.tableView.backgroundColor = [UIColor brownColor];
#ifdef AzPAD
	//Popoverサイズが変わらないようにするため、ToolBarを常時表示する
	[self.navigationController setToolbarHidden:NO animated:NO]; // ツールバー表示
#endif
	
	// Set up NEXT Left [Back] buttons.
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"Cancel",nil) 
									   style:UIBarButtonItemStylePlain  target:nil  action:nil];
	
	// CANCELボタンを左側に追加する  Navi標準の戻るボタンでは cancelClose:処理ができないため
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
											  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
											  target:self action:@selector(cancelClose:)];
	// SAVEボタンを右側に追加する
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
											   target:self action:@selector(saveClose:)];
}

- (void)viewDesign
{
	// 回転によるリサイズ
	CGRect rect;
	float fWidth = self.tableView.frame.size.width;
	
	rect = MlbNote.frame;
	rect.size.width = fWidth - 60;
	MlbNote.frame = rect;
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:YES];
	
#ifdef AzPAD
#else
	//[0.4]以降、ヨコでもツールバーを表示するようにした。
	[self.navigationController setToolbarHidden:YES animated:animated]; // ツールバー消す
#endif
	
	// 画面表示に関係する Option Setting を取得する
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	
	[self viewDesign]; // 下層で回転して戻ったときに再描画が必要

	// テーブルビューを更新
    [self.tableView reloadData];
}


// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
}

#pragma mark  View - Rotate

// 回転の許可　ここでは許可、禁止の判定だけする
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	//iPad//Popover内につき回転不要
	// 回転禁止でも、正面は常に許可しておくこと。
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	//[self.tableView reloadData];
	[self viewDesign]; // cell生成の後
}


#pragma mark  View - Unload - dealloc


/*
 - (void)viewDidUnload 
 {
 [super viewDidUnload];
 AzLOG(@"MEMORY! E1cardDetailTVC: viewDidUnload");
 }
 */


#pragma mark - TableView lifecicle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section) {
		case 0:	return 3;
			break;
		case 1:	return 1;
			break;
	}
	return 0;
}

// TableView セクションタイトルを応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			return nil; //NSLocalizedString(@"Indispensable",nil);
			break;
		case 1:
			return NSLocalizedString(@"Note",nil);
			break;
	}
	return nil;
}

 // セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.section==1 && indexPath.row==0) return 200; // Note
	return 44; // デフォルト：44ピクセル
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *zCellIndex = [NSString stringWithFormat:@"E1detail%d:%d", (int)indexPath.section, (int)indexPath.row];
	UITableViewCell *cell = nil;

	cell = [tableView dequeueReusableCellWithIdentifier:zCellIndex];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
									   reuseIdentifier:zCellIndex];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
		cell.showsReorderControl = NO; // Move禁止
#ifdef AzPAD
		cell.textLabel.font = [UIFont systemFontOfSize:12];
		cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
#else
		cell.textLabel.font = [UIFont systemFontOfSize:12];
		cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
#endif
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.textLabel.textColor = [UIColor grayColor];
		//cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
		cell.detailTextLabel.textColor = [UIColor blackColor];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case 0: //-------------------------------------Indispensable
			switch (indexPath.row) {
				case 0: // Card name
				{
					cell.textLabel.text = NSLocalizedString(@"CardName",nil);
					cell.detailTextLabel.text = Re1edit.zName;
				}
					break;
				case 1: // PayDay
				{
					cell.textLabel.text = NSLocalizedString(@"PayDay",nil);

					if ((Re1edit.nClosingDay).integerValue <= 0) {	//Debit
						if ((Re1edit.nPayDay).integerValue <= 0) {
							//当日締⇒Debit⇒ 当日払
							cell.detailTextLabel.text = NSLocalizedString(@"Closing-Debit",nil);
						} else {
							//当日締⇒Debit⇒ ○日後払
							cell.detailTextLabel.text = [NSString stringWithFormat:
														 NSLocalizedString(@"Closing-DebitAfter",nil),
														 GstringDay((Re1edit.nPayDay).integerValue)];
						}
					} 
					else {
						NSString *zClosingDay = nil;
						if ((Re1edit.nClosingDay).integerValue==29) {
							zClosingDay = NSLocalizedString(@"EndDay",nil); // 末日
						} else {
							zClosingDay = GstringDay((Re1edit.nClosingDay).integerValue);
						}
						NSString *zPayMonth = nil;
						switch ((Re1edit.nPayMonth).integerValue) {
							case 0:
								zPayMonth = NSLocalizedString(@"This month",nil);
								break;
							case 1:
								zPayMonth = NSLocalizedString(@"Next month",nil);
								break;
							case 2:
								zPayMonth = NSLocalizedString(@"Twice months",nil);
								break;
							default:
								zPayMonth = @"ERR:Debit?";
								break;
						}
						NSString *zPayDay = nil;
						if ((Re1edit.nPayDay).integerValue==29) {
							zPayDay = NSLocalizedString(@"EndDay",nil); // 末日
						} else {
							zPayDay = GstringDay((Re1edit.nPayDay).integerValue);
						}
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Closing-Payment",nil),
																							zClosingDay, zPayMonth, zPayDay];
					}
				}
					break;
/******************** Bonus 未対応  　didSelectRowAtIndexPathの方も忘れず。
			case 2: // Bonus
				{
					cell.textLabel.text = NSLocalizedString(@"CardBonus",nil);
					NSInteger iB1 = [Re1edit.nBonus1 integerValue];
					NSInteger iB2 = [Re1edit.nBonus2 integerValue];
					if (1 <= iB1 && iB1 <= 12) {
						if (1 <= iB2 && iB2 <= 12 && iB1 != iB2) {
							cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  %@", 
														 GstringMonth( iB1 ), 
														 GstringMonth( iB2 )];
						} else {
							cell.detailTextLabel.text = GstringMonth( iB1 );
						}
					} else {
						cell.detailTextLabel.text = NSLocalizedString(@"Unused", nil);
					}
				}
					break;
 */
				case 2: // Bank
				{
					cell.textLabel.text = NSLocalizedString(@"CardBank",nil);
					if (Re1edit.e8bank)
						cell.detailTextLabel.text = Re1edit.e8bank.zName;
					else
						cell.detailTextLabel.text = NSLocalizedString(@"(Untitled)", nil);
				}
					break;
			}
			break;
		case 1: //--------------------------------------Option
			switch (indexPath.row) {
				case 0: // Card note
				{
					//cell.textLabel.text = NSLocalizedString(@"CardNote",nil);
					//cell.detailTextLabel.text = Re1edit.zNote;
					if (MlbNote == nil) {
						MlbNote = [[UILabel alloc] init];
#ifdef AzPAD
						MlbNote.font = [UIFont systemFontOfSize:20];
#else
						MlbNote.font = [UIFont systemFontOfSize:14];
#endif
						MlbNote.numberOfLines = 0;
						MlbNote.lineBreakMode = NSLineBreakByWordWrapping; //UILineBreakModeWordWrap; // 単語を途切れさせないように改行する
						MlbNote.backgroundColor = [UIColor clearColor];
						[cell.contentView addSubview:MlbNote];  
					}
#ifdef AzPAD
					MlbNote.frame = CGRectMake(20,10, self.tableView.frame.size.width-110,180);
#else
					MlbNote.frame = CGRectMake(20,10, self.tableView.frame.size.width-60,180);
#endif
					if (Re1edit.zNote == nil) {
						MlbNote.text = @"";  // TextViewは、(nil) と表示されるので、それを消すため。
					} else {
						MlbNote.text = [NSString stringWithFormat:@"%@%@", 
										Re1edit.zNote, LABEL_NOTE_SUFFIX]; //上寄せするため
					}
				}
					break;
				case 1: // 
				{
					cell.textLabel.text = NSLocalizedString(@"Bonus1",nil);
					if ((Re1edit.nBonus1).integerValue <= 0) {
						cell.detailTextLabel.text = NSLocalizedString(@"(Untitled)",nil);
					} else {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%2d月 %@", 
													 (Re1edit.nBonus1).integerValue,
													 GstringMonth((Re1edit.nBonus1).integerValue)];
					}
				}
					break;
				case 2: // 
				{
					cell.textLabel.text = NSLocalizedString(@"Bonus2",nil);
					if ((Re1edit.nBonus2).integerValue <= 0) {
						cell.detailTextLabel.text = NSLocalizedString(@"(Untitled)",nil);
					} else {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%2d月 %@", 
													 (Re1edit.nBonus2).integerValue,
													 GstringMonth((Re1edit.nBonus2).integerValue)];
					}
				}
					break;
			}
			break;
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

	switch (indexPath.section) {
		case 0: //-------------------------------------Indispensable
			switch (indexPath.row) {
				case 0: // Card name
				{
					EditTextVC *evc = [[EditTextVC alloc] init];
					evc.title = NSLocalizedString(@"CardName", nil);
					evc.Rentity = Re1edit;
					evc.RzKey = @"zName";
					evc.PiMaxLength = AzMAX_NAME_LENGTH;
					evc.PiSuffixLength = 0;
					self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
					[self.navigationController pushViewController:evc animated:YES];
					// 変更ありを AppDelegateへ通知	// EditTextVC：内から通知している
				}
					break;
				case 1: // PayDay
				{
					E1editPayDayVC *evc = [[E1editPayDayVC alloc] init];
					evc.title = NSLocalizedString(@"PayDay", nil);
					evc.Re1edit = Re1edit;
					self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
					[self.navigationController pushViewController:evc animated:YES];
					// 変更ありを AppDelegateへ通知	// E1editPayDayVC：内から通知している
				}
					break;
				case 2: // Bank
				{
					// E8bankTVC へ
					E8bankTVC *tvc = [[E8bankTVC alloc] init];
					tvc.title = NSLocalizedString(@"Bank choice",nil);
					tvc.Re0root = [MocFunctions e0root];
					tvc.Pe1card = Re1edit;
					[self.navigationController pushViewController:tvc animated:YES];
					// 変更ありを AppDelegateへ通知	// E8bankTVC：内から通知している
				}
					break;
			}
			break;
		case 1: //--------------------------------------Option
			switch (indexPath.row) {
				case 0: // Card note
				{
					EditTextVC *evc = [[EditTextVC alloc] init];
					evc.title = NSLocalizedString(@"CardNote", nil);
					evc.Rentity = Re1edit;
					evc.RzKey = @"zNote";
					evc.PiMaxLength = AzMAX_NOTE_LENGTH;
					evc.PiSuffixLength = 0;
					self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
					[self.navigationController pushViewController:evc animated:YES];
					// 変更ありを AppDelegateへ通知	// EditTextVC：内から通知している
				}
					break;
			}
			break;
	}
}
		
@end

