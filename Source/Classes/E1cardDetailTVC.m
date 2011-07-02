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
#import "E1cardDetailTVC.h"
#import "EditTextVC.h"
#import "E1editPayDayVC.h"
#import "E1editBonusVC.h"
#import "E8bankTVC.h"

#ifdef AzPAD
#import "PadPopoverInNaviCon.h"
#endif

#define LABEL_NOTE_SUFFIX   @"\n\n\n\n\n\n\n\n\n\n"  // UILabel *MlbNoteを上寄せするための改行（10行）

@interface E1cardDetailTVC (PrivateMethods)
- (void)viewDesign;
@end

@implementation E1cardDetailTVC
@synthesize Re1edit;
@synthesize PiAddRow;


#pragma mark - Action

- (void)cancelClose:(id)sender
{
	[MocFunctions rollBack]; // 前回のSAVE以降を取り消す
	
	if (0 <= PiAddRow) { // Add
		// Add mode: 新オブジェクトのキャンセルなので、呼び出し元で挿入したオブジェクトを削除する
		[MocFunctions deleteEntity:Re1edit];
	}
	
#ifdef AzPAD
	//Padでは、親側の popoverControllerShouldDismissPopover にて処理
	[(PadNaviCon*)self.navigationController dismissPopoverCancel];  // PadNaviCon拡張メソッド
#else
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
#endif
}

// 編集フィールドの値を self.e3target にセットする
- (void)saveClose:(id)sender 
{
	if (0 <= PiAddRow) { // Add
		Re1edit.nRow = [NSNumber numberWithInteger:PiAddRow];
	}
	
	// E1,E2,E3,E6,E7 の関係を保ちながら更新する
	[MocFunctions e1update:Re1edit];
	[MocFunctions commit];
	
#ifdef AzPAD
	[(PadNaviCon*)self.navigationController dismissPopoverSaved];  // SAVE: PadNaviCon拡張メソッド
#else
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
#endif
}

#ifdef AzPAD
- (void)closePopover
{
	if (MpopoverView) {	//dismissPopoverCancel
		[MpopoverView dismissPopoverAnimated:YES];
	}
}
#endif



#pragma mark - View lifecicle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStyleGrouped];  // セクションありテーブル
	if (self) {
		// 初期化成功
  	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
    [super loadView];
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
	MlbNote = nil;		// cellForRowAtIndexPathにて生成

	// ここは、alloc直後に呼ばれるため、下記のようなパラは未セット状態である。==>> viewWillAppearで参照すること

	//self.tableView.backgroundColor = [UIColor brownColor];

	// Set up NEXT Left [Back] buttons.
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"Cancel",nil) 
									   style:UIBarButtonItemStylePlain  target:nil  action:nil] autorelease];
	
	// CANCELボタンを左側に追加する  Navi標準の戻るボタンでは cancel:処理ができないため
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
											  target:self action:@selector(cancelClose:)] autorelease];
	// SAVEボタンを右側に追加する
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
											   target:self action:@selector(saveClose:)] autorelease];
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
	
	//[0.4]以降、ヨコでもツールバーを表示するようにした。
	[self.navigationController setToolbarHidden:YES animated:animated]; // ツールバー消す
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	
	[self viewDesign]; // 下層で回転して戻ったときに再描画が必要
	// テーブルビューを更新します。
    [self.tableView reloadData];
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
#ifdef xxxxxxxAzPAD
	//Popoverサイズ指定。　　下層から戻ったとき、サイズを元に戻すようにも働く
	CGSize currentSetSizeForPopover = E1CardDetailView_SIZE; // 最終的に設定したいサイズ
    CGSize fakeMomentarySize = CGSizeMake(currentSetSizeForPopover.width - 1.0f, currentSetSizeForPopover.height - 1.0f);
    self.contentSizeForViewInPopover = fakeMomentarySize;			// 1回目は、反映されないが、少し変化させる必要あり
    self.contentSizeForViewInPopover = currentSetSizeForPopover;	// この2回目が反映される
#endif	
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
}

#pragma mark  View - Rotate

// 回転の許可　ここでは許可、禁止の判定だけする
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	// 回転禁止でも、正面は常に許可しておくこと。
	return !MbOptAntirotation OR (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	//[self.tableView reloadData];
	[self viewDesign]; // cell生成の後
}


#pragma mark  View - Unload - dealloc

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	//--------------------------------@property (retain)
	[Re1edit release];
	[super dealloc];
}

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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
									   reuseIdentifier:zCellIndex] autorelease];
#ifdef AzPAD
		cell.accessoryType = UITableViewCellAccessoryNone; //Pad:Popover
#else
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
#endif
		cell.showsReorderControl = NO; // Move禁止

		cell.textLabel.font = [UIFont systemFontOfSize:12];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.textColor = [UIColor grayColor];
		
		cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
		//cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
		cell.detailTextLabel.textColor = [UIColor blackColor];
	}
	
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

					if ([Re1edit.nClosingDay integerValue] <= 0) {
						if ([Re1edit.nPayDay integerValue] <= 0) {
							//[0.4]当日締 ⇒ 当日払
							cell.detailTextLabel.text = NSLocalizedString(@"Closing-Debit",nil);
						} else {
							//[0.4]当日締 ⇒ ○○日後払
							cell.detailTextLabel.text = [NSString stringWithFormat:
														 NSLocalizedString(@"Closing-DebitAfter",nil),
														 GstringDay([Re1edit.nPayDay integerValue])];
						}
					} 
					else {
						NSString *zPayMonth = nil;
						switch ([Re1edit.nPayMonth integerValue]) {
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
						cell.detailTextLabel.text = [NSString stringWithFormat:
													 NSLocalizedString(@"Closing-Payment",nil),
													 GstringDay([Re1edit.nClosingDay integerValue]), 
													 zPayMonth, GstringDay([Re1edit.nPayDay integerValue])];
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
						MlbNote = [[UILabel alloc] initWithFrame:
								   CGRectMake(20,10, self.tableView.frame.size.width-60,180)];
						MlbNote.numberOfLines = 0;
						MlbNote.lineBreakMode = UILineBreakModeWordWrap; // 単語を途切れさせないように改行する
						//MlbNote.textAlignment = UITextAlignmentLeft; // 左寄せ(Default)
						MlbNote.font = [UIFont systemFontOfSize:14];
						MlbNote.backgroundColor = [UIColor clearColor];
						[cell.contentView addSubview:MlbNote];  [MlbNote release];
					}
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
					if ([Re1edit.nBonus1 integerValue] <= 0) {
						cell.detailTextLabel.text = NSLocalizedString(@"(Untitled)",nil);
					} else {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%2d月 %@", 
													 [Re1edit.nBonus1 integerValue],
													 GstringMonth([Re1edit.nBonus1 integerValue])];
					}
				}
					break;
				case 2: // 
				{
					cell.textLabel.text = NSLocalizedString(@"Bonus2",nil);
					if ([Re1edit.nBonus2 integerValue] <= 0) {
						cell.detailTextLabel.text = NSLocalizedString(@"(Untitled)",nil);
					} else {
						cell.detailTextLabel.text = [NSString stringWithFormat:@"%2d月 %@", 
													 [Re1edit.nBonus2 integerValue],
													 GstringMonth([Re1edit.nBonus2 integerValue])];
					}
				}
					break;
			}
			break;
	}
    return cell;
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
					evc.delegate = self;	// [Done]にて、viewWillAppear を呼び出すため
#ifdef AzPAD
					UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:evc];
					MpopoverView = [[UIPopoverController alloc] initWithContentViewController:nc];
					[nc release];
					MpopoverView.delegate = self;  //閉じたとき再描画するため
					MpopoverView.popoverContentSize = CGSizeMake(400, 200);
					CGRect rc = [self.tableView rectForRowAtIndexPath:indexPath];
					rc.origin.y += 10;  rc.size.height -= 20;
					[MpopoverView presentPopoverFromRect:rc inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
					evc.Rpopover = MpopoverView; //(retain)  内から閉じるときに必要になる
					[MpopoverView release];
#else
					self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
					[self.navigationController pushViewController:evc animated:YES];
#endif
					[evc release];
				}
					break;
				case 1: // PayDay
				{
					E1editPayDayVC *evc = [[E1editPayDayVC alloc] init];
					evc.title = NSLocalizedString(@"PayDay", nil);
					evc.Re1edit = Re1edit;
					evc.delegate = self;	//[Done]にて、viewWillAppear を呼び出すため
#ifdef AzPAD
					UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:evc];
					MpopoverView = [[UIPopoverController alloc] initWithContentViewController:nc];
					[nc release];
					MpopoverView.delegate = self;  //閉じたとき再描画するため
					MpopoverView.popoverContentSize = CGSizeMake(320, 440);
					CGRect rc = [self.tableView rectForRowAtIndexPath:indexPath];
					rc.origin.y += 10;  rc.size.height -= 20;
					[MpopoverView presentPopoverFromRect:rc inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
					evc.Rpopover = MpopoverView; //(retain)  内から閉じるときに必要になる
					[MpopoverView release];
#else
					self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
					[self.navigationController pushViewController:e1ed animated:YES];
#endif
					[evc release];
				}
					break;
/******************** Bonus 未対応
			case 2: // Bonus
				{
					E1editBonusVC *e1ed = [[E1editBonusVC alloc] init];
					e1ed.title = NSLocalizedString(@"CardBonus", nil);
					e1ed.Re1edit = Re1edit;
					self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
					[self.navigationController pushViewController:e1ed animated:YES];
					[e1ed release];
				}
					break;
 */
				case 2: // Bank
				{
					// E8bankTVC へ
					E8bankTVC *tvc = [[E8bankTVC alloc] init];
					tvc.title = NSLocalizedString(@"Bank choice",nil);
					tvc.Re0root = [MocFunctions e0root];
					tvc.Pe1card = Re1edit;
					tvc.delegate = self;	//選択決定にて、viewWillAppear を呼び出すため
#ifdef AzPAD
					MpopoverView = [[UIPopoverController alloc] initWithContentViewController:tvc];
					MpopoverView.delegate = self;  //閉じたとき再描画するため
					MpopoverView.popoverContentSize = CGSizeMake(380, 500);
					CGRect rc = [self.tableView rectForRowAtIndexPath:indexPath];
					rc.origin.y += 10;  rc.size.height -= 20;
					[MpopoverView presentPopoverFromRect:rc inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
					tvc.Rpopover = MpopoverView; //(retain)  内から閉じるときに必要になる
					[MpopoverView release];
#else
					[self.navigationController pushViewController:tvc animated:YES];
#endif
					[tvc release];
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
					evc.delegate = self;	//[Done]にて、viewWillAppear を呼び出すため
#ifdef AzPAD
					UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:evc];
					MpopoverView = [[UIPopoverController alloc] initWithContentViewController:nc];
					[nc release];
					MpopoverView.delegate = self;  //閉じたとき再描画するため
					MpopoverView.popoverContentSize = CGSizeMake(400, 300);
					CGRect rc = [self.tableView rectForRowAtIndexPath:indexPath];
					rc.origin.y += 10;  rc.size.height -= 20;
					[MpopoverView presentPopoverFromRect:rc inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny  animated:YES];
					evc.Rpopover = MpopoverView; //(retain)  内から閉じるときに必要になる
					[MpopoverView release];
#else
					self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
					[self.navigationController pushViewController:evc animated:YES];
#endif
					[evc release];
				}
					break;
			}
			break;
	}
}


#ifdef AzPAD
#pragma mark - <UIPopoverControllerDelegate>
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{	// Popoverの外部をタップして閉じる前に通知
	return YES; // 閉じることを許可
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{	// Popoverの外部をタップして閉じた後に通知
	// 再描画する
	[self viewWillAppear:YES];
	return;
}
#endif

		
@end

