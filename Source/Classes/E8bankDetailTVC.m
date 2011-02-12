//
//  E8bankDetailTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "E8bankDetailTVC.h"
#import "EditTextVC.h"
//#import "E1editPayDayVC.h"


#define LABEL_NOTE_SUFFIX   @"\n\n\n\n\n\n\n\n\n\n"  // UILabel *MlbNoteを上寄せするための改行（10行）

@interface E8bankDetailTVC (PrivateMethods)
- (void)viewDesign;
@end

@implementation E8bankDetailTVC
@synthesize Re8edit;
@synthesize PiAddRow;
@synthesize PbSave;
@synthesize Pe1edit;


- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
	//--------------------------------Private Alloc
	//--------------------------------@property (retain)
	[Re8edit release];
	[super dealloc];
}


// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {  // セクションありテーブル
		// 初期化成功
		Pe1edit = nil;
  	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
	[super loadView];
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
	MlbNote = nil;		// cellForRowAtIndexPathにて生成

	// Set up NEXT Left [Back] buttons.
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"Cancel",nil) 
									   style:UIBarButtonItemStylePlain  target:nil  action:nil] autorelease];
	
	// CANCELボタンを左側に追加する  Navi標準の戻るボタンでは cancel:処理ができないため
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
											  target:self action:@selector(cancel:)] autorelease];
	if (PbSave) {
		// SAVEボタンを右側に追加する
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
												   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
												   target:self action:@selector(save:)] autorelease];
	} else {
		// DONEボタンを右側に追加する　＜＜E1cardDetailTVCから呼び出されたとき＞＞
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
												   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
												   target:self action:@selector(save:)] autorelease];
	}
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	// 呼び出し側(親)にてツールバーを常に非表示にしているが、念のため
	[self.navigationController setToolbarHidden:YES animated:animated]; // ツールバー消す
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];

	[self viewDesign]; // 下層で回転して戻ったときに再描画が必要
	// テーブルビューを更新します。
    [self.tableView reloadData];
}

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

- (void)viewDesign
{
	// 回転によるリサイズ
	CGRect rect;
	float fWidth = self.tableView.frame.size.width;
	
	rect = MlbNote.frame;
	rect.size.width = fWidth - 60;
	MlbNote.frame = rect;
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section) {
		case 0:	return 1;
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

// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			break;
		case 1:
			return NSLocalizedString(@"E8section1Footer",nil);
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
    NSString *zCellIndex = [NSString stringWithFormat:@"E8detail%d:%d", (int)indexPath.section, (int)indexPath.row];
	UITableViewCell *cell = nil;

	cell = [tableView dequeueReusableCellWithIdentifier:zCellIndex];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
									   reuseIdentifier:zCellIndex] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
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
					cell.textLabel.text = NSLocalizedString(@"BankName",nil);
					cell.detailTextLabel.text = Re8edit.zName;
				}
					break;
			}
			break;
		case 1: //--------------------------------------Option
			switch (indexPath.row) {
				case 0: // Note
				{
					if (MlbNote == nil) {
						MlbNote = [[UILabel alloc] initWithFrame:
								   CGRectMake(20,10, self.tableView.frame.size.width-60,180)];
						MlbNote.numberOfLines = 0;
						MlbNote.lineBreakMode = UILineBreakModeWordWrap; // 単語を途切れさせないように改行する
						//MlbNote.textAlignment = UITextAlignmentLeft; // 左寄せ(Default)
						MlbNote.font = [UIFont systemFontOfSize:14];
#ifdef AzDEBUG
						//MlbNote.backgroundColor = [UIColor grayColor]; //範囲チェック用
#endif
						[cell.contentView addSubview:MlbNote]; [MlbNote release];
					}
					if (Re8edit.zNote == nil) {
						MlbNote.text = @"";  // TextViewは、(nil) と表示されるので、それを消すため。
					} else {
						MlbNote.text = [NSString stringWithFormat:@"%@%@", 
										Re8edit.zNote, LABEL_NOTE_SUFFIX]; //上寄せするため
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
					evc.title = NSLocalizedString(@"BankName", nil);
					evc.Rentity = Re8edit;
					evc.RzKey = @"zName";
					evc.PiMaxLength = AzMAX_NAME_LENGTH;
					evc.PiSuffixLength = 0;
					self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
					[self.navigationController pushViewController:evc animated:YES];
					[evc release];
				}
					break;
			}
			break;
		case 1: //--------------------------------------Option
			switch (indexPath.row) {
				case 0: // Note
				{
					EditTextVC *evc = [[EditTextVC alloc] init];
					evc.title = NSLocalizedString(@"BankNote", nil);
					evc.Rentity = Re8edit;
					evc.RzKey = @"zNote";
					evc.PiMaxLength = AzMAX_NOTE_LENGTH;
					evc.PiSuffixLength = 0;
					self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
					[self.navigationController pushViewController:evc animated:YES];
					[evc release];
				}
					break;
			}
			break;
	}
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

- (void)cancel:(id)sender 
{
	if (PbSave) {
		[MocFunctions rollBack]; // 前回のSAVE以降を取り消す
	}
	
	if (0 <= PiAddRow) { // Add
		// Add mode: 新オブジェクトのキャンセルなので、呼び出し元で挿入したオブジェクトを削除する
		[MocFunctions deleteEntity:Re8edit];
	}

	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

// 編集フィールドの値を self.e3target にセットする
- (void)save:(id)sender 
{
	if (0 <= PiAddRow) { // Add
		Re8edit.nRow = [NSNumber numberWithInteger:PiAddRow];
	}
	
	NSError *err = nil;
	NSManagedObjectContext *contx = Re8edit.managedObjectContext;

	// E1,E2,E3,E6,E7 の関係を保ちながら更新する
	//[EntityRelation e1update:Re8edit];
	//[EntityRelation commit];

	// トリム（両端のスペース除去）　＜＜Load時に zNameで検索するから厳密にする＞＞
	NSString *zName = [Re8edit.zName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([zName length] <= 0) {
		alertBox(NSLocalizedString(@"E8zNameLess",nil),
				 NSLocalizedString(@"E8zNameLessMsg",nil),
				 NSLocalizedString(@"Roger",nil));
		return;
	}
	
	// 重複が無いか調べる
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	// 取り出すエンティティを設定する
	[request setEntity:[NSEntityDescription entityForName:@"E8bank" inManagedObjectContext:contx]];
	// NSPredicateを使って、検索条件式を設定する
	[request setPredicate:[NSPredicate predicateWithFormat:@"(%K = %@)", @"zName", zName]];
	// コンテキストにリクエストを送る
	NSArray* aRes = [contx executeFetchRequest:request error:&err];
	[request release];
	NSInteger iCnt = 2;
	if (0 <= PiAddRow) iCnt = 1;
	if (iCnt < [aRes count]) {
		alertBox(NSLocalizedString(@"E8zNameDups",nil),
				 NSLocalizedString(@"E8zNameDupsMsg",nil),
				 NSLocalizedString(@"Roger",nil));
		return;
	}
	// OK トリム済み＆重複なし
	//Re8edit.sortDate = [NSDate date]; // Now
	
	if (PbSave) { // マスタモードのみ保存する。 以外は、E3recordDetailTVC側のsave:により保存。
		// SAVE
		[MocFunctions commit];
	}
	
	if (Pe1edit) {	// E3から選択モードで呼ばれて、新規登録したとき、E3まで2段階戻る処理
		Pe1edit.e8bank = Re8edit;
		NSInteger iPos = [self.navigationController.viewControllers count];
		if (3 < iPos) {
			// 2つ前のViewへ戻る
			UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:iPos-3];
			[self.navigationController popToViewController:vc animated:YES];	// < vcまで戻る
			return;
		}
	}
	
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

		
@end

