//
//  E5categoryDetailTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "E5categoryTVC.h"
#import "E5categoryDetailTVC.h"
#import "EditTextVC.h"


#define LABEL_NOTE_SUFFIX   @"\n\n\n\n\n"  // UILabel *MlbNoteを上寄せするための改行（5行）

@interface E5categoryDetailTVC (PrivateMethods)
//- (void)viewDesign;
@end

@implementation E5categoryDetailTVC
@synthesize Re5edit;
@synthesize PbAdd;
@synthesize PbSave;
//@synthesize Pe3edit;
//#ifdef AzPAD
@synthesize delegate;
//@synthesize selfPopover;
//#endif


#pragma mark - Action

- (void)cancelClose:(id)sender
{
	if (PbSave) {
		[MocFunctions rollBack]; // 前回のSAVE以降を取り消す
	}
	
	if (PbAdd) { // Add
		// Add mode: 新オブジェクトのキャンセルなので、呼び出し元で挿入したオブジェクトを削除する
		[MocFunctions deleteEntity:Re5edit];
	}
	
    if (IS_PAD) {
//        if (selfPopover) {
//            [selfPopover dismissPopoverAnimated:YES];
//        } else {
//            [self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
//        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
    }
}

// 編集フィールドの値を self.e3target にセットする
- (void)saveClose:(id)sender 
{
	
	// zName : トリムや重複チェックは、E4editTextVC.done にて処理済みである。ここでは追加直後のSAVE時の抜け穴を防ぐ。
	NSError *err = nil;
	NSManagedObjectContext *contx = Re5edit.managedObjectContext;
	// トリム（両端のスペース除去）　＜＜Load時に zNameで検索するから厳密にする＞＞
	NSString *zName = [Re5edit.zName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if (zName.length <= 0) {
		alertBox(NSLocalizedString(@"E5zNameLess",nil),
				 NSLocalizedString(@"E5zNameLessMsg",nil),
				 NSLocalizedString(@"Roger",nil));
		return;
	}
	// 重複が無いか調べる
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	// 取り出すエンティティを設定する
	request.entity = [NSEntityDescription entityForName:@"E5category" inManagedObjectContext:contx];
	// NSPredicateを使って、検索条件式を設定する
	request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", @"zName", zName];
	// コンテキストにリクエストを送る
	NSArray* aRes = [contx executeFetchRequest:request error:&err];
	NSInteger iCnt = 2;
	if (PbAdd) iCnt = 1;
	if (iCnt < aRes.count) {
		alertBox(NSLocalizedString(@"E5zNameDups",nil),
				 NSLocalizedString(@"E5zNameDupsMsg",nil),
				 NSLocalizedString(@"Roger",nil));
		return;
	}
	// OK トリム済み＆重複なし
	Re5edit.sortDate = [NSDate date]; // Now
	
	if (PbSave) { // マスタモードのみ保存する。 以外は、E3recordDetailTVC側のsave:により保存。
		// SAVE
		[MocFunctions commit];
	}
	
	if (self.Pe3edit) {	// E3から選択モードで呼ばれて、新規登録したとき、E3まで2段階戻る処理
		self.Pe3edit.e5category = Re5edit;
        if (IS_PAD) {
            [self.navigationController  popToRootViewControllerAnimated:YES];  // < RootViewへ戻る
            return;
        }else{
            NSInteger iPos = (self.navigationController.viewControllers).count;
            if (3 < iPos) {
                // 2つ前のViewへ戻る
                UIViewController *vc = (self.navigationController.viewControllers)[iPos-3];
                [self.navigationController popToViewController:vc animated:YES];	// < vcまで戻る
                return;
            }
        }
	}

    if (IS_PAD) {
//        if (selfPopover) {
            if ([delegate respondsToSelector:@selector(refreshTable)]) {	// メソッドの存在を確認する
                [delegate refreshTable];// 親の再描画を呼び出す
            }
//            [selfPopover dismissPopoverAnimated:YES];
//        } else {
//            [self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
//        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
    }
}


#pragma mark - View lifecicle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (instancetype)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStyleGrouped];  // セクションありテーブル
	if (self) {
		// 初期値
		PbAdd = NO;
		self.Pe3edit = nil;
        if (IS_PAD) {
            self.preferredContentSize = CGSizeMake(480, 250); //GD_POPOVER_SIZE;
        }
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
//【Tips】ここでaddSubviewするオブジェクトは全てautoreleaseにすること。メモリ不足時には自動的に解放後、改めてここを通るので、初回同様に生成するだけ。
- (void)loadView
{
	[super loadView];
	// メモリ不足時に self.viewが破棄されると同時に破棄されるオブジェクトを初期化する
	// なし

	// Set up NEXT Left [Back] buttons.
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"Cancel",nil) 
									   style:UIBarButtonItemStylePlain  target:nil  action:nil];
	
	// CANCELボタンを左側に追加する  Navi標準の戻るボタンでは cancelClose:処理ができないため
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
											  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
											  target:self action:@selector(cancelClose:)];
	if (PbSave) {
		// SAVEボタンを右側に追加する
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
												   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
												   target:self action:@selector(saveClose:)];
	} else {
		// DONEボタンを右側に追加する　＜＜E3recordDetailTVCから呼び出されたとき＞＞
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
												   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
												   target:self action:@selector(saveClose:)];
	}

}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	// 呼び出し側(親)にてツールバーを常に非表示にしているが、念のため
	[self.navigationController setToolbarHidden:YES animated:animated]; // ツールバー消す
	
	// 画面表示に関係する Option Setting を取得する
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];

	//[self viewDesign]; // 下層で回転して戻ったときに再描画が必要
	// テーブルビューを更新します。
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

/*
// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	//[self.tableView reloadData];
	[self viewDesign]; // cell生成の後
}

- (void)viewDesign
{
	// 回転によるリサイズ
}
*/

#pragma mark  View - Unload - dealloc



#pragma mark - TableView lifecicle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section) {
		case 0:	return 1;
			break;
		case 1:	return 2;
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
			return NSLocalizedString(@"Option",nil);
			break;
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *zCellIndex = [NSString stringWithFormat:@"E5detail%d:%d", (int)indexPath.section, (int)indexPath.row];
	UITableViewCell *cell = nil;

	cell = [tableView dequeueReusableCellWithIdentifier:zCellIndex];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
									   reuseIdentifier:zCellIndex];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
		cell.showsReorderControl = NO; // Move禁止

        if (IS_PAD) {
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
        }else{
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
        }
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.textLabel.textColor = [UIColor grayColor];
		
		//cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
		cell.detailTextLabel.textColor = [UIColor blackColor];
	}
	
	switch (indexPath.section) {
		case 0: //-------------------------------------Indispensable
			switch (indexPath.row) {
				case 0: // Name
				{
					cell.textLabel.text = NSLocalizedString(@"Category name",nil);
					cell.detailTextLabel.text = Re5edit.zName;
				}
					break;
			}
			break;
		case 1: //-------------------------------------Option
			switch (indexPath.row) {
				case 0: // sortName
				{
					cell.textLabel.text = NSLocalizedString(@"Category index",nil);
					cell.detailTextLabel.text = Re5edit.sortName;
				}
					break;
				case 1: // Note
				{
					cell.textLabel.text = NSLocalizedString(@"Category note",nil);
					cell.detailTextLabel.text = Re5edit.zNote;
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
				case 0: // Name
				{
                    EditTextVC *evc;
                    if (IS_PAD) {
                        evc = [[EditTextVC alloc] initWithFrameSize:self.preferredContentSize];
                    }else{
                        evc = [[EditTextVC alloc] init];
                    }
					evc.title = NSLocalizedString(@"Category name", nil);
					evc.Rentity = Re5edit;
					evc.RzKey = @"zName";
					evc.PiMaxLength = AzMAX_NAME_LENGTH;
					evc.PiSuffixLength = 0;
					self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
					[self.navigationController pushViewController:evc animated:YES];
				}
					break;
			}
			break;
		case 1: //-------------------------------------Option
			switch (indexPath.row) {
				case 0: // sortName
				{
                    EditTextVC *evc;
                    if (IS_PAD) {
                        evc = [[EditTextVC alloc] initWithFrameSize:self.preferredContentSize];
                    }else{
                        evc = [[EditTextVC alloc] init];
                    }
					evc.title = NSLocalizedString(@"Category index", nil);
					evc.Rentity = Re5edit;
					evc.RzKey = @"sortName";
					evc.PiMaxLength = AzMAX_NAME_LENGTH;
					evc.PiSuffixLength = 0;
					self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
					[self.navigationController pushViewController:evc animated:YES];
				}
					break;
				case 1: // Note
				{
                    EditTextVC *evc;
                    if (IS_PAD) {
                        evc = [[EditTextVC alloc] initWithFrameSize:self.preferredContentSize];
                    }else{
                        evc = [[EditTextVC alloc] init];
                    }
					evc.title = NSLocalizedString(@"Category note", nil);
					evc.Rentity = Re5edit;
					evc.RzKey = @"zNote";
					evc.PiMaxLength = AzMAX_NAME_LENGTH;
					evc.PiSuffixLength = 0;
					self.navigationController.hidesBottomBarWhenPushed = YES; // この画面では非表示であるから
					[self.navigationController pushViewController:evc animated:YES];
				}
					break;
			}
			break;
	}
}

		
@end

