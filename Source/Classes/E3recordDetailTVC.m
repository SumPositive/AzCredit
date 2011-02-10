//
//  E3recordDetailTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "EntityRelation.h"
#import "E3recordDetailTVC.h"
#import "EditDateVC.h"
#import "EditTextVC.h"
#import "EditAmountVC.h"
#import "E1cardTVC.h"
#import "E3selectPayTypeTVC.h"
#import "E4shopTVC.h"
#import "E5categoryTVC.h"
#import "CalcView.h"

#define ACTIONSEET_TAG_DELETE		190

#define TAG_BAR_BUTTON_TOPVIEW		901		// barButtonCopyAdd:にて、これ以上のものを無効にしている
#define TAG_BAR_BUTTON_DEL			902
#define TAG_BAR_BUTTON_ADD			903

#define TAG_BAR_BUTTON_NEW			911		// 新規
#define TAG_BAR_BUTTON_PAST			912		// 過去へ
#define TAG_BAR_BUTTON_RETURN		913		// 戻す


@interface E3recordDetailTVC (PrivateMethods)
- (void)cancel:(id)sender;
- (void)save:(id)sender;
- (void)viewDesign;
- (void)alertAmountOver;
- (void)cellButtonE6check: (UIButton *)button;
- (void)barButton: (UIButton *)button;
- (void)showCalcAmount;
@end

@implementation E3recordDetailTVC
@synthesize Re3edit;
//@synthesize PbAdd;
@synthesize PiAdd;
@synthesize PiFirstYearMMDD;


- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
//	[Me3editMask release]; // save: or cancel: にて deleteObject: されていること
	[Me6parts release];
	[Me3lasts release];
	
	// @property (retain)
	[Re3edit release];
	[super dealloc];
}

- (void)viewDidUnload 
{
	// メモリ不足時、裏側にある場合に呼び出されるので、Private Allocで生成したObjを解放する。
	[Me6parts release];		Me6parts = nil;
	[Me3lasts release];		Me3lasts = nil;
	// @property (retain) は解放しない。
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"viewDidUnload" 
													 message:@"E3recordDetailTVC" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
}

- (void)didReceiveMemoryWarning {
#ifdef AzDEBUG
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"didReceiveMemoryWarning" 
													 message:@"E3recordDetailTVC" 
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
#endif	
    [super didReceiveMemoryWarning];
}

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {  // セクションありテーブル
		//self.navigationItem.rightBarButtonItem = self.editButtonItem;
		//self.tableView.allowsSelectionDuringEditing = YES;
		//self.tableView.backgroundColor = MpColorBlue(0.3f);
	}
	MbCopyAdd = NO;
	MiIndexE3lasts = (-1); // (-2)過去コピー機能無効
	return self;
}

// UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != actionSheet.destructiveButtonIndex) return;

	if (Re3edit && actionSheet.tag == ACTIONSEET_TAG_DELETE) { // Re3edit 削除
		// E1,E2,E3,E6,E7 の関係を保ちながら E3削除 する
		//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[EntityRelation e3delete:Re3edit];
		[EntityRelation commit];
		//
		[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
	}
}

/*
- (void)e3editMaskSet	// これ以降、変更された項目を検出するために用いる
{
	if (Me3editMask == nil) {
		// retain すること。
		Me3editMask = [[NSEntityDescription insertNewObjectForEntityForName:@"E3record"
													 inManagedObjectContext:Re3edit.managedObjectContext] retain];
		Me3editMask.dateUse = [NSDate date]; // 迷子にならないように念のため
	}
	//
	Me3editMask.nAmount		= Re3edit.nAmount;
	Me3editMask.nPayType	= Re3edit.nPayType;
	Me3editMask.zName		= Re3edit.zName;
	Me3editMask.zNote		= Re3edit.zNote;
	Me3editMask.e1card		= Re3edit.e1card;
	Me3editMask.e4shop		= Re3edit.e4shop;
	Me3editMask.e5category	= Re3edit.e5category;

	//Me3editMask.nAnnual = Re3edit.nAnnual;
}*/

- (void)barButtonCopyAdd 
{
	[McalcView hide]; // Calcが出てれば隠す

	// もし修正していた場合、それが保存されてしまわないように、まずrollBackする　＜＜Re3edit生成直後までrollBackされる＞＞
	[Re3edit.managedObjectContext rollback]; // 前回のSAVE以降を取り消す
	
	// E3を新規追加し、コピー後、Re3editを置き換える。
	E3record *e3new = [NSEntityDescription insertNewObjectForEntityForName:@"E3record"
													inManagedObjectContext:Re3edit.managedObjectContext];
	// Copy
	e3new.nAmount		= [NSNumber numberWithInt:0]; // Re3edit.nAmount;
	//e3new.nAnnual		= Re3edit.nAnnual;
	e3new.nPayType		= Re3edit.nPayType;
	e3new.zName			= Re3edit.zName;
	e3new.zNote			= Re3edit.zNote;
	e3new.e1card		= Re3edit.e1card;
	e3new.e4shop		= Re3edit.e4shop;
	e3new.e5category	= Re3edit.e5category;
	// Initial
	e3new.dateUse		= [NSDate date];
	e3new.sumNoCheck	= [NSNumber numberWithInt:1];
	e3new.e6parts		= nil;
	// Replace
	[Re3edit release];
	Re3edit = nil;
	Re3edit = [e3new retain];  // retain 必須！ この後、deallocにてreleaseされますから。
	// Args
	//self.title = NSLocalizedString(@"Add Record", nil);
	self.title = NSLocalizedString(@"CopyAdd Record", nil);
	PiAdd = (1); // (1)New Add
	MbCopyAdd = YES; // YES:既存明細をコピーして新規追加している状態
	// Tool Bar ボタンを無効にする
	for (id obj in self.toolbarItems) {
		if (TAG_BAR_BUTTON_TOPVIEW <= [[obj valueForKey:@"tag"] intValue]) {
			[obj setEnabled:NO];
		}
	}
	// テーブルビューを更新
	[self.tableView reloadData];

//	// rollbackされたので、改めてマスクセット
//	[self e3editMaskSet];

/*	if (MbOptNumAutoShow) { // viewDidAppearを通らないので、ここで表示
		[self showCalcAmount]; // 自動テンキー
	}*/
}

- (void)barButtonDelete 
{
	[McalcView hide]; // Calcが出てれば隠す

	// 削除コマンド警告　==>> (void)actionSheet にて処理  ＜＜PAIDでも削除する＞＞
	UIActionSheet *action = [[UIActionSheet alloc] 
							 initWithTitle:NSLocalizedString(@"DELETE Record", nil)
							 delegate:self 
							 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
							 destructiveButtonTitle:NSLocalizedString(@"DELETE Record button", nil)
							 otherButtonTitles:nil];
	action.tag = ACTIONSEET_TAG_DELETE;
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait 
		OR self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		// タテ：ToolBar表示
		[action showFromToolbar:self.navigationController.toolbar]; // ToolBarがある場合
	} else {
		// ヨコ：ToolBar非表示（TabBarも無い）　＜＜ToolBar無しでshowFromToolbarするとFreeze＞＞
		[action showInView:self.view]; //windowから出すと回転対応しない
	}
	[action release];
}


- (void)barButton:(UIButton *)button
{
	[McalcView hide]; // Calcが出てれば隠す

	E3record *e3obj = nil;
	switch (button.tag) {
		case TAG_BAR_BUTTON_NEW:
			// New
			MiIndexE3lasts = (-1);
			// 両方向の Tool Bar ボタンを有効にする
			for (id obj in self.toolbarItems) {
				switch ([[obj valueForKey:@"tag"] intValue]) {
					case TAG_BAR_BUTTON_PAST:	[obj setEnabled:YES];	break;
					case TAG_BAR_BUTTON_RETURN:	[obj setEnabled:NO];	break;
				}
			}
			break;

		case TAG_BAR_BUTTON_PAST:
			if (MiIndexE3lasts < -1) {
				// Min under
				MiIndexE3lasts = (-1);
			}
			else if ([Me3lasts count] <= MiIndexE3lasts + 1) {  // [Me3lasts count]-1 とするとエラー
				// Max over
				MiIndexE3lasts = [Me3lasts count] - 1;
				button.enabled = NO;
			}
			else {
				MiIndexE3lasts++;
				e3obj = [Me3lasts objectAtIndex:MiIndexE3lasts];
				// 対向の Tool Bar ボタンを有効にする
				for (id obj in self.toolbarItems) {
					if ([[obj valueForKey:@"tag"] intValue] == TAG_BAR_BUTTON_RETURN) [obj setEnabled:YES];
				}
				if ([Me3lasts count] <= MiIndexE3lasts + 1) {  // さらに前回でオーバーするならばボタン無効にする
					// Max
					button.enabled = NO;
				}
			}
			break;
		
		case TAG_BAR_BUTTON_RETURN:
			if (MiIndexE3lasts <= 0) {
				// Min under
				MiIndexE3lasts = (-1);
				button.enabled = NO;
			}
			else if ([Me3lasts count] <= MiIndexE3lasts) {
				// Max over
				MiIndexE3lasts = [Me3lasts count] - 1;
			}
			else {
				MiIndexE3lasts--;
				e3obj = [Me3lasts objectAtIndex:MiIndexE3lasts];
				// 対向の Tool Bar ボタンを有効にする
				for (id obj in self.toolbarItems) {
					if ([[obj valueForKey:@"tag"] intValue] == TAG_BAR_BUTTON_PAST) [obj setEnabled:YES];
				}
				if (MiIndexE3lasts <= 0) {  // さらに戻してオーバーするならばボタン無効にする
					// Max
					button.enabled = NO;
				}
			}
			break;
			
		default:
			return;
	}

/*	if (e3obj) { // Copy
		// マスクと同値ならば変化なし(入力なし）なので、コピー上書きする
		if (!MbOptFixedPriority OR [Me3editMask.nAmount integerValue] == [Re3edit.nAmount integerValue]) {
			Re3edit.nAmount = e3obj.nAmount;
			Me3editMask.nAmount = Re3edit.nAmount; // マスク更新：改めて、これ以降に入力や選択されたものを検出するため
		}
		if (!MbOptFixedPriority OR [Me3editMask.nPayType integerValue] == [Re3edit.nPayType integerValue]) {
			Re3edit.nPayType = e3obj.nPayType;
			Me3editMask.nPayType = Re3edit.nPayType;
		}
		if (!MbOptFixedPriority OR Me3editMask.zName == Re3edit.zName) {
			Re3edit.zName = e3obj.zName;
			Me3editMask.zName = Re3edit.zName;
		}
		if (!MbOptFixedPriority OR Me3editMask.e1card == Re3edit.e1card) {
			Re3edit.e1card = e3obj.e1card;
			Me3editMask.e1card = Re3edit.e1card;
		}
		if (!MbOptFixedPriority OR Me3editMask.e4shop == Re3edit.e4shop) {
			Re3edit.e4shop = e3obj.e4shop;
			Me3editMask.e4shop = Re3edit.e4shop;
		}
		if (!MbOptFixedPriority OR Me3editMask.e5category == Re3edit.e5category) {
			Re3edit.e5category = e3obj.e5category;
			Me3editMask.e5category = Re3edit.e5category;
		}
	}
	else { // New
		// マスクと同値ならば変化なし(入力なし）なので、初期化（未定）にする
		if (!MbOptFixedPriority OR [Me3editMask.nAmount integerValue] == [Re3edit.nAmount integerValue]) {
			Re3edit.nAmount = [NSNumber numberWithInt:0];
			Me3editMask.nAmount = Re3edit.nAmount; // マスク更新：改めて、これ以降に入力や選択されたものを検出するため
		}
		if (!MbOptFixedPriority OR [Me3editMask.nPayType integerValue] == [Re3edit.nPayType integerValue]) {
			Re3edit.nPayType = [NSNumber numberWithInt:1];
			Me3editMask.nPayType = Re3edit.nPayType;
		}
		if (!MbOptFixedPriority OR Me3editMask.zName == Re3edit.zName) {
			Re3edit.zName = @"";
			Me3editMask.zName = Re3edit.zName;
		}
		if (!MbOptFixedPriority OR Me3editMask.e1card == Re3edit.e1card && PiFirstYearMMDD == 0) {
			Re3edit.e1card = nil;			  // && ↑ Card選択時、消さないようにするため
			Me3editMask.e1card = Re3edit.e1card;
		}
		if (!MbOptFixedPriority OR Me3editMask.e4shop == Re3edit.e4shop) {
			Re3edit.e4shop = nil;
			Me3editMask.e4shop = Re3edit.e4shop;
		}
		if (!MbOptFixedPriority OR Me3editMask.e5category == Re3edit.e5category) {
			Re3edit.e5category = nil;
			Me3editMask.e5category = Re3edit.e5category;
		}
	}*/

	if (e3obj) { // Copy
		if (MlbAmount.tag == 0) { // Calc入力が0(未定)ならば過去コピーする
			Re3edit.nAmount = e3obj.nAmount;
		}
		Re3edit.nPayType	= e3obj.nPayType;
		Re3edit.zName		= e3obj.zName;
		Re3edit.e1card		= e3obj.e1card;
		Re3edit.e4shop		= e3obj.e4shop;
		Re3edit.e5category  = e3obj.e5category;
	}
	else { // New
		// 初期化（未定）にする
		if (MlbAmount.tag == 0) { // Calc入力が0(未定)ならば初期化する
			Re3edit.nAmount		= [NSNumber numberWithInt:0];
		}
		Re3edit.nPayType	= [NSNumber numberWithInt:1];
		Re3edit.zName		= @"";
		if (PiAdd != 2) Re3edit.e1card = nil; // (2)Card固定時、消さない
		if (PiAdd != 3) Re3edit.e4shop = nil;
		if (PiAdd != 4) Re3edit.e5category = nil;
	}
	// テーブルビューを更新します。
	[self.tableView reloadData];
}


// viewDidLoadメソッドは，TableViewContorllerオブジェクトが生成された後，実際に表示される際に呼び出されるメソッド
- (void)viewDidLoad 
{
    [super viewDidLoad];
	Me0root = nil;
	Me6parts = nil;
	MbuTop = nil;
	MsegAddPrevious = nil;
	
	// ここは、alloc直後に呼ばれるため、下記のようなパラは未セット状態である。==>> viewWillAppearで参照すること

	// Set up NEXT Left [Back] buttons.
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"Cancel",nil) 
									   style:UIBarButtonItemStylePlain  target:nil  action:nil];
	self.navigationItem.backBarButtonItem = backButtonItem;
	[backButtonItem release];		

	
	// CANCELボタンを左側に追加する  Navi標準の戻るボタンでは cancel:処理ができないため
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
											  target:self action:@selector(cancel:)] autorelease];
	// SAVEボタンを右側に追加する
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
											   target:self action:@selector(save:)] autorelease];


	// Tool Bar Button
	if (0 < PiAdd) {
		UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				target:nil action:nil];
		
		UIBarButtonItem *buNew = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Bar32-CopyStop.png"]
																  style:UIBarButtonItemStylePlain
																 target:self action:@selector(barButton:)];
		buNew.tag = TAG_BAR_BUTTON_NEW;

		UIBarButtonItem *buPast = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Bar32-CopyLeft.png"]
																  style:UIBarButtonItemStylePlain
																 target:self action:@selector(barButton:)];
		buPast.tag = TAG_BAR_BUTTON_PAST;
		
		UIBarButtonItem *buReturn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Bar32-CopyRight.png"]
																   style:UIBarButtonItemStylePlain
																  target:self action:@selector(barButton:)];
		buReturn.tag = TAG_BAR_BUTTON_RETURN;
		buReturn.enabled = NO; // 最初、戻るは無効
		
		NSArray *buArray = [NSArray arrayWithObjects: buFlex, buPast, buFlex, buNew, buFlex, buReturn, buFlex, nil];
		[self setToolbarItems:buArray animated:YES];
		[buReturn release];
		[buPast release];
		[buNew release];
		[buFlex release];
	} 
	else {
		UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				target:nil action:nil];
		
		MbuTop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Bar32-Top.png"]
												  style:UIBarButtonItemStylePlain  //Bordered
												 target:self action:@selector(cancel:)]; // ＜＜ cancel:YES<<--TopView ＞＞
		MbuTop.tag = TAG_BAR_BUTTON_TOPVIEW; // cancel:にて判断に使用
		
		UIBarButtonItem *buCopyAdd = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Bar32-CopyAdd.png"]
																	  style:UIBarButtonItemStylePlain  //Bordered
																	 target:self action:@selector(barButtonCopyAdd)];
		buCopyAdd.tag = TAG_BAR_BUTTON_ADD;
		
		UIBarButtonItem *buDelete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
																				  target:self action:@selector(barButtonDelete)];
		buDelete.tag = TAG_BAR_BUTTON_DEL;

		NSArray *buArray = [NSArray arrayWithObjects: MbuTop, buFlex, buCopyAdd, buFlex, buDelete, nil];
		[self setToolbarItems:buArray animated:YES];
		[MbuTop release];
		[buCopyAdd release];
		[buDelete release];
		[buFlex release];
	}
	
	// 初回処理のため
	MiE1cardRow = (-1);
}

// 他のViewやキーボードが隠れて、現れる都度、呼び出される
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:YES];
	
	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	MbOptEnableCategory = [defaults boolForKey:GD_OptEnableCategory];
	MbOptEnableInstallment = [defaults boolForKey:GD_OptEnableInstallment];
	MbOptUseDateTime = [defaults boolForKey:GD_OptUseDateTime];
//	MbOptNumAutoShow = [defaults boolForKey:GD_OptNumAutoShow];
//	MbOptFixedPriority = [defaults boolForKey:GD_OptFixedPriority];
	
	if (MbuTop) {
		// hasChanges時にTop戻りボタンを無効にする
		MbuTop.enabled = ![Re3edit.managedObjectContext hasChanges]; // YES:contextに変更あり
	}
	
	//--------------------------------------------------------------------------------.
	// Me0root はArreyじゃない！からrelese不要
	Me0root = nil;

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"E0root" 
											  inManagedObjectContext:Re3edit.managedObjectContext];
	[fetchRequest setEntity:entity];
	// Fitch
	NSError *error = nil;
	NSArray *arFetch = [Re3edit.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		AzLOG(@"Error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	[fetchRequest release];
	//
	if ([arFetch count] == 1) {
		Me0root = [arFetch objectAtIndex:0];
	}
	else {
		AzLOG(@"Error: Me0root count = %d", [arFetch count]);
		exit(-1);  // Fail
	}
	
	//--------------------------------------------------Pe3select.e6parts
	if (Me6parts != nil) {
		[Me6parts release];
		Me6parts = nil;
	}
	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"nPartNo" ascending:YES];
	NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
	[sort1 release];
	// 
	Me6parts = [[NSMutableArray alloc] initWithArray:[Re3edit.e6parts allObjects]];
	[Me6parts sortUsingDescriptors:sortArray];
	[sortArray release];
	
	MbE6paid = NO;
	for (E6part *e6 in Me6parts) {
		if (e6.e2invoice.e1paid OR e6.e2invoice.e7payment.e0paid) {
			MbE6paid = YES; // YES:PAIDあり、主要条件の変更禁止！
		}
	}
	
	//--------------------------------------------------Me3lasts: 前回引用するための直近3件
	if (Me3lasts != nil) {
		[Me3lasts release];
		Me3lasts = nil;
	}
	// Sorting
	sort1 = [[NSSortDescriptor alloc] initWithKey:@"dateUse" ascending:NO]; // NO=降順
	sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
	[sort1 release];

	if (Re3edit.e1card) {
		// e1card以下、最近の全E3
		Me3lasts = [[NSMutableArray alloc] initWithArray:[Re3edit.e1card.e3records allObjects]];
		[Me3lasts sortUsingDescriptors:sortArray];
	}
	else if (Re3edit.e4shop) {
		// e4shop以下、最近の全E3
		Me3lasts = [[NSMutableArray alloc] initWithArray:[Re3edit.e4shop.e3records allObjects]];
		[Me3lasts sortUsingDescriptors:sortArray];
	}
	else if (Re3edit.e5category) {
		// e5category以下、最近の全E3
		Me3lasts = [[NSMutableArray alloc] initWithArray:[Re3edit.e5category.e3records allObjects]];
		[Me3lasts sortUsingDescriptors:sortArray];
	}
	else {
		//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		// 利用明細一覧用：最近の全E3
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"E3record" 
												  inManagedObjectContext:Re3edit.managedObjectContext];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortArray];
		// Fitch
		NSError *error = nil;
		NSArray *arFetch = [Re3edit.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (error) {
			AzLOG(@"Error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		[fetchRequest release];
		Me3lasts = [[NSMutableArray alloc] initWithArray:arFetch];
	}
	[sortArray release];
	// 重要！Me3lastsには、新規追加されたRe3editが含まれているので、ここで除外する。
	[Me3lasts removeObject:Re3edit];
//	[Me3lasts removeObject:Me3editMask]; // Me3editMaskも含まれている場合があるので除外する

	
	// 初期値
	if (Re3edit.dateUse == nil) {
		Re3edit.dateUse = [NSDate date]; // Now
	}

	if (Re3edit.e1card == nil) {
		// Re3edit.e1card = 最上行のカードにする
	}
	
	if (PiAdd==0 OR PiFirstYearMMDD < AzMIN_YearMMDD) {
		PiFirstYearMMDD = 0;
	}
	
	[self viewDesign]; // 下層で回転して戻ったときに再描画が必要
	// テーブルビューを更新します。
	[self.tableView reloadData];
	
//	if (PbAdd && Me3editMask == nil) {
//		// 比較項目のみコピー　（初期値）
//		[self e3editMaskSet];
//	}
}

// 回転サポート
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		// 正面（ホームボタンが画面の下側にある状態）
		[self.navigationController setToolbarHidden:NO animated:YES]; // ツールバー表示
		return YES; // この方向だけは常に許可する
	} 
	else if (MbOptAntirotation) return NO; // 回転禁止
	
	if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		// 逆面（ホームボタンが画面の上側にある状態）
		[self.navigationController setToolbarHidden:NO animated:YES]; // ツールバー表示
	} else {
		// 横方向や逆向きのとき
		[self.navigationController setToolbarHidden:YES animated:YES]; // ツールバー非表示=YES
	}
	return YES;
	// 現在の向きは、self.interfaceOrientation で取得できる
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜OS 3.0以降は非推奨＞＞
//- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)orientation 
//													   duration:(NSTimeInterval)duration

// ユーザインタフェースの回転を始める前にこの処理が呼ばれる。 ＜＜OS 3.0以降の推奨メソッド＞＞
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
	// この開始時に消す。　　この時点で self.view.frame は回転していない。
	if (McalcView && [McalcView isShow]) {
		[McalcView hide]; //　ここでは隠すだけ。 removeFromSuperviewするとアニメ無く即消えてしまう。
		MbRotatShowCalc = YES;
	} else {
		MbRotatShowCalc = NO;
	}
}
// ユーザインタフェースが回転した後この処理が呼ばれる。
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	// この完了時に再表示する。　　この時点で self.view.frame は回転済み。
	[self viewDesign];

	[self showCalcAmount]; // 再表示
}

- (void)showCalcAmount
{
	if (McalcView) {
		[McalcView hide];
		[McalcView removeFromSuperview];
		McalcView = nil;
	}
	McalcView = [[CalcView alloc] initWithFrame:[self.tableView bounds]];
	McalcView.Rlabel = MlbAmount; // MlbAmount.tag にはCalc入力された数値(long)が記録される
	McalcView.Rentity = Re3edit;
	McalcView.RzKey = @"nAmount";
	//[self.tableView addSubview:McalcView];
	[self.view addSubview:McalcView];
	[McalcView release]; // addSubviewにてretain(+1)されるため、こちらはrelease(-1)して解放
	[McalcView show];
}

- (void)viewDesign
{
	// 回転によるリサイズ
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
	
/*	if (MbOptNumAutoShow && [Re3edit.nAmount integerValue] == 0) { // viewWillAppearだとタイミングが早すぎてダメ
		[self showCalcAmount]; // 自動テンキー
	}*/
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	if (0 < PiAdd) return 2; // 新規追加時、支払明細なし
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			if (MbOptEnableInstallment) return 4;
			else						return 3;
			break;
		case 1:
			if (MbOptEnableCategory) return 3;
			else					 return 2;
			break;
		case 2:	return [Re3edit.e6parts count];
			break;
	}
	return 0;
}

// TableView セクションタイトルを応答
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			//return NSLocalizedString(@"Indispensable",nil);
			break;
		case 1:
			//if (PbAdd) return NSLocalizedString(@"Option",nil);
			break;
		case 2:
			return NSLocalizedString(@"Payment Details",nil);
			break;
	}
	return nil;
}

// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			if (MbCopyAdd) {
					return NSLocalizedString(@"CopyAdd Msg", nil);
			}
			else if	(0 <= MiIndexE3lasts) {
				return [NSString stringWithFormat:@"%@%ld%@", 
						NSLocalizedString(@"PastCopyPre",nil),
						1 + MiIndexE3lasts, 
						NSLocalizedString(@"PastCopySuf",nil)];
			}
			break;

		case 1:
			if (0 < PiAdd && !MbCopyAdd && (-1) <= MiIndexE3lasts) {
				return NSLocalizedString(@"E3AddBar Help",nil);
			}
			break;
	}
	return nil;
}


// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//if (indexPath.section==1 && indexPath.row==2) return 200; // zNote
	return 44; // デフォルト：44ピクセル
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *zCellIndex = [NSString stringWithFormat:@"E3detail%d:%d", (int)indexPath.section, (int)indexPath.row];
    static NSString *zCellE6part = @"CellE6part";
	UITableViewCell *cell = nil;
	UILabel *cellLabel = nil;
	
	switch (indexPath.section) {
		case 0: //----------------------------------------------------------------------SECTION 必須
			cell = [tableView dequeueReusableCellWithIdentifier:zCellIndex];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
											   reuseIdentifier:zCellIndex] autorelease];
				cell.showsReorderControl = NO; // Move禁止
				
				cell.textLabel.font = [UIFont systemFontOfSize:12];  // 見出し
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				cell.textLabel.textColor = [UIColor grayColor];
				
				//cell.detailTextLabel.font = [UIFont systemFontOfSize:16];セクション別に指定している
				//cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
				cell.detailTextLabel.textColor = [UIColor blackColor];
			}
			cell.detailTextLabel.font = [UIFont systemFontOfSize:17]; // 必須内容表示　大きく
			if (MbE6paid) {
				//cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
				cell.accessoryType = UITableViewCellAccessoryNone; // 変更禁止
			} else {
				//cell.selectionStyle = UITableViewCellSelectionStyleBlue; // 選択時ハイライト
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
			}
			switch (indexPath.row) {
				case 0: // Use date
					cell.textLabel.text = NSLocalizedString(@"Use date",nil);
					NSDateFormatter *df = [[NSDateFormatter alloc] init];
					//[df setLocale:[NSLocale systemLocale]];これがあると曜日が表示されない。
					if (MbOptUseDateTime) {
						[df setDateFormat:NSLocalizedString(@"E3detailDateTime",nil)];
					} else {
						[df setDateFormat:NSLocalizedString(@"E3detailDate",nil)];
					}
					//AzLOG(@"Me3zDateUse=%@", Me3zDateUse);
//					NSDate *dt = [[NSDate alloc] initWithString:Me3zDateUse];
					cell.detailTextLabel.text = [df stringFromDate:Re3edit.dateUse];
					[df release];
//					[dt release];
					break;
				case 1: // Amount
					if (MlbAmount == nil) {
						MlbAmount = [[UILabel alloc] initWithFrame:CGRectMake(70,5, 180,35)];
						MlbAmount.lineBreakMode = UILineBreakModeWordWrap; // 単語を途切れさせないように改行する
						MlbAmount.textAlignment = UITextAlignmentRight;
						MlbAmount.tag = 0; // Calc入力された数値(long)を記録する
#ifdef AzDEBUG
						//MlbAmount.backgroundColor = [UIColor grayColor]; //範囲チェック用
#endif
						MlbAmount.font = [UIFont systemFontOfSize:30];
						[cell.contentView addSubview:MlbAmount]; [MlbAmount release];
					}
					cell.textLabel.text = NSLocalizedString(@"Use Amount",nil);

					if ([Re3edit.nAmount integerValue] <= 0) {
						MlbAmount.textColor = [UIColor blueColor];
					} else {
						MlbAmount.textColor = [UIColor blackColor];
					}
					// JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
					NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
					//[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4]; MACOSに必要な定義
					[formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // CurrencyStyle]; // 通貨スタイル
					//[formatter setLocale:[NSLocale currentLocale]];
					//NSLocale *localeJP = [[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"];
					//[formatter setLocale:localeJP];
					//[localeJP release];
					//cell.detailTextLabel.text = [formatter stringFromNumber:Re3edit.nAmount];
					MlbAmount.text = [formatter stringFromNumber:Re3edit.nAmount];
					[formatter release];
					cell.accessoryType = UITableViewCellAccessoryNone; // なし
					break;
				case 2: // Card
					cell.textLabel.text = NSLocalizedString(@"Use Card",nil);
					if (Re3edit.e1card) {
						cell.detailTextLabel.text = Re3edit.e1card.zName;
					} else {
						cell.detailTextLabel.text = NSLocalizedString(@"(Untitled)", nil);
					}
					if (PiAdd == 2) { // Card固定
						cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
						cell.accessoryType = UITableViewCellAccessoryNone; // なし
					}
					break;
				case 3: // nPayType
					cell.textLabel.text = NSLocalizedString(@"Use Payment",nil);
					switch ([Re3edit.nPayType integerValue]) {
						case 1:
							cell.detailTextLabel.text = NSLocalizedString(@"PayType 001",nil);
							break;
						case 2:
							cell.detailTextLabel.text = NSLocalizedString(@"PayType 002",nil);
							break;
						case 101:
							cell.detailTextLabel.text = NSLocalizedString(@"PayType 101",nil);
							break;
						case 102:
							cell.detailTextLabel.text = NSLocalizedString(@"PayType 102",nil);
							break;
						default:
							cell.detailTextLabel.text = NSLocalizedString(@"(Untitled)",nil);
							break;
					}
					break;
			}
			break;
			
		case 1: //----------------------------------------------------------------------SECTION 任意
			cell = [tableView dequeueReusableCellWithIdentifier:zCellIndex];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
											   reuseIdentifier:zCellIndex] autorelease];
				cell.showsReorderControl = NO; // Move禁止
				
				cell.textLabel.font = [UIFont systemFontOfSize:12];  // 見出し
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				cell.textLabel.textColor = [UIColor grayColor];
				
				//cell.detailTextLabel.font = [UIFont systemFontOfSize:16];セクション別に指定している
				//cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
				cell.detailTextLabel.textColor = [UIColor blackColor];
			}
			cell.detailTextLabel.font = [UIFont systemFontOfSize:14]; // 任意内容表示
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
			switch (indexPath.row) {
				case 0: // Shop
				{
					cell.textLabel.text = NSLocalizedString(@"Use Shop",nil);
					if (Re3edit.e4shop)
						cell.detailTextLabel.text = Re3edit.e4shop.zName;
					else
						cell.detailTextLabel.text = NSLocalizedString(@"(Untitled)", nil);

					if (PiAdd == 3) { // Shop固定Add時
						cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
						cell.accessoryType = UITableViewCellAccessoryNone; // なし
					}
				}
					break;
				case 1: // Category
					if (MbOptEnableCategory)
					{
						cell.textLabel.text = NSLocalizedString(@"Use Category",nil);
						if (Re3edit.e5category)
							cell.detailTextLabel.text = Re3edit.e5category.zName;
						else
							cell.detailTextLabel.text = NSLocalizedString(@"(Untitled)", nil);

						if (PiAdd == 4) { // Category固定Add時
							cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
							cell.accessoryType = UITableViewCellAccessoryNone; // なし
						}
						break;
					}
					//break ↓ MbOptEnableCategory==NO ならばメモ(Name)を表示
				case 2: // Name
				{
					cell.textLabel.text = NSLocalizedString(@"Use Name",nil);
					if (0 < [Re3edit.zName length])
						cell.detailTextLabel.text = Re3edit.zName;
					else
						cell.detailTextLabel.text = NSLocalizedString(@"(Untitled)", nil);
				}
					break;
			}
			break;
		case 2:  //----------------------------------------------------------------------SECTION 支払明細
		{ // E6partTVC - cellForRowAtIndexPath 内よりコピー
			cell = [tableView dequeueReusableCellWithIdentifier:zCellE6part];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault // Subtitle
											   reuseIdentifier:zCellE6part] autorelease];
				// 行毎に変化の無い定義は、ここで最初に1度だけする
				cell.textLabel.font = [UIFont systemFontOfSize:14];
				//cell.textLabel.textAlignment = UITextAlignmentLeft;
				//cell.textLabel.textColor = [UIColor blackColor];
				cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
				cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
				cell.detailTextLabel.textColor = [UIColor blackColor];
				//cell.showsReorderControl = YES; // MoveOK
				
				cellLabel = [[UILabel alloc] init];
				cellLabel.textAlignment = UITextAlignmentRight;
				cellLabel.textColor = [UIColor blackColor];
				//cellLabel.backgroundColor = [UIColor grayColor]; //DEBUG範囲チェック用
				cellLabel.font = [UIFont systemFontOfSize:14];
				cellLabel.tag = -1;
				[cell addSubview:cellLabel]; [cellLabel release];
			}
			else {
				cellLabel = (UILabel *)[cell viewWithTag:-1];
			}
			// 回転対応のため
			cellLabel.frame = CGRectMake(self.tableView.frame.size.width-125, 12, 90, 20);
			
			// 左ボタン --------------------＜＜cellLabelのようにはできない！.tagに個別記録するため＞＞
			UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom]; // autorelease
			cellButton.frame = CGRectMake(0,0, 44,44);
			[cellButton addTarget:self action:@selector(cellButtonE6check:) forControlEvents:UIControlEventTouchUpInside];
			cellButton.backgroundColor = [UIColor clearColor]; //背景透明
			cellButton.showsTouchWhenHighlighted = YES;
			cellButton.tag = indexPath.section * GD_SECTION_TIMES + indexPath.row;
			[cell.contentView addSubview:cellButton]; //[bu release]; buttonWithTypeにてautoreleseされるため不要。UIButtonにinitは無い。
			// 左ボタン ------------------------------------------------------------------

			E6part *e6obj = [Me6parts objectAtIndex:indexPath.row];
			
			if (e6obj.e2invoice.e7payment.e0paid) {
				cell.imageView.image = [UIImage imageNamed:@"Paid32.png"]; // PAID 変更禁止
				cellButton.enabled = NO;
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			else if ([e6obj.nNoCheck intValue] == 1) {
				cell.imageView.image = [UIImage imageNamed:@"Circle32.png"];
				cellButton.enabled = YES;
				if (MbE6paid) {
					cell.accessoryType = UITableViewCellAccessoryNone; // 変更禁止
				} else {
					//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
					cell.accessoryType = UITableViewCellAccessoryNone;
				}
			} 
			else {
				cell.imageView.image = [UIImage imageNamed:@"Circle32-check.png"];
				cellButton.enabled = YES;
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			
			// 支払日
			NSInteger iYearMMDD = [e6obj.e2invoice.e7payment.nYearMMDD integerValue];
			if (e6obj.e2invoice.e1paid) {
				cell.textLabel.text = [NSString stringWithFormat:@"%@%@", GstringYearMMDD(iYearMMDD),
									   NSLocalizedString(@"Pre",nil)];
			} else {
				cell.textLabel.text = [NSString stringWithFormat:@"%@%@", GstringYearMMDD(iYearMMDD),
									   NSLocalizedString(@"Due",nil)];
			}
			
			// 金額
			// Amount JPY専用　＜＜日本以外に締支払いする国はないハズ＞＞
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			[formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // CurrencyStyle]; // 通貨スタイル
			NSLocale *localeJP = [[NSLocale alloc] initWithLocaleIdentifier:@"ja-JP"];
			[formatter setLocale:localeJP];
			[localeJP release];
			cellLabel.text = [formatter stringFromNumber:e6obj.nAmount];
			[formatter release];
		}
	}
    return cell;
}

- (void)cellButtonE6check: (UIButton *)button 
{
	if (button.tag < 0) return;
	
	NSInteger iSec = button.tag / GD_SECTION_TIMES;
	if (iSec != 2) return;
	NSInteger iRow = button.tag - (iSec * GD_SECTION_TIMES);
	if (iRow < 0 OR [Me6parts count] <= iRow) return;
	
	E6part *e6obj = [Me6parts objectAtIndex:iRow];
	// E6 Check
	if (0 < [e6obj.nNoCheck intValue]) {
		[EntityRelation e6check:YES inE6obj:e6obj inAlert:YES];
	} else {
		[EntityRelation e6check:NO inE6obj:e6obj inAlert:YES];
	}
	//------------------＜＜ここでは保存しない！ E3修正の cancel:でrollBack, save:でcommitする＞＞
	// [EntityRelation commit];
	
	[self.tableView reloadData];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[McalcView hide]; // Calcが出てれば隠す
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

	switch (indexPath.section) {
		case 0:
			if (MbE6paid) {
				UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MAINTAIN",nil) 
																 message:NSLocalizedString(@"MAINTAIN msg",nil) 
																delegate:nil 
													   cancelButtonTitle:nil 
													   otherButtonTitles:@"OK", nil] autorelease];
				[alert show];
				return;
			}
			switch (indexPath.row) {
				case 0: // Use date
					if (!MbE6paid) {
						// 変更あれば[DONE]にて配下E6全削除すること
						EditDateVC *evc = [[EditDateVC alloc] init];
						evc.title = NSLocalizedString(@"Use date", nil);
						evc.Rentity = Re3edit;
						evc.RzKey = @"dateUse";
						evc.PiMinYearMMDD = AzMIN_YearMMDD;
						evc.PiMaxYearMMDD = PiFirstYearMMDD;
						evc.hidesBottomBarWhenPushed = YES; // 次画面のToolBarを消す
						[self.navigationController pushViewController:evc animated:YES];
						[evc release];
					}
					break;
				case 1: // Amount
					if (!MbE6paid) {
						[self showCalcAmount];
						return; // Tool Bar ボタンを無効にしない！ため
					}
					break;
				case 2: // Card
					if (PiAdd == 2) return; // (2)Card固定
					if (!MbE6paid) 
					{
						// 変更あれば[DONE]にて配下E6全削除すること
						E1cardTVC *tvc = [[E1cardTVC alloc] init];
						tvc.title = NSLocalizedString(@"Card choice",nil);
						tvc.Re0root = Me0root;
						tvc.Re3edit = Re3edit;
						//tvc.hidesBottomBarWhenPushed = YES; // 次画面のToolBarを消す
						[self.navigationController pushViewController:tvc animated:YES];
						[tvc release];
					}
					break;
				case 3: // PayType
					if (!MbE6paid) {
						// 変更あれば[DONE]にて配下E6全削除すること
						// E3selectPaymentTVC へ
						E3selectPayTypeTVC *tvc = [[E3selectPayTypeTVC alloc] init];
						tvc.title = NSLocalizedString(@"Use Payment",nil);
						tvc.Re3edit = Re3edit;
						tvc.hidesBottomBarWhenPushed = YES; // 次画面のToolBarを消す
						[self.navigationController pushViewController:tvc animated:YES];
						[tvc release];
					}
					break;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0: // Shop
						if (PiAdd == 3) return; // (3)Shop固定
						else 
						{
							// E4shop へ
							E4shopTVC *tvc = [[E4shopTVC alloc] init];
							tvc.title = NSLocalizedString(@"Shop choice",nil);
							tvc.Re0root = Me0root;
							tvc.Pe3edit = Re3edit;
							[self.navigationController pushViewController:tvc animated:YES];
							[tvc release];
						}
						break;
				case 1: // Category
					if (PiAdd == 4) return; // (4)Category固定
					if (MbOptEnableCategory)
					{
						E5categoryTVC *tvc = [[E5categoryTVC alloc] init];
						tvc.title = NSLocalizedString(@"Category choice",nil);
						tvc.Re0root = Me0root;
						tvc.Pe3edit = Re3edit;
						[self.navigationController pushViewController:tvc animated:YES];
						[tvc release];
						break;
					}
					//break ↓ MbOptEnableCategory==NO ならばメモ(Name)を表示
				case 2: // Name
				{
					EditTextVC *evc = [[EditTextVC alloc] init];
					evc.title = NSLocalizedString(@"Use Name", nil);
					evc.Rentity = Re3edit;
					evc.RzKey = @"zName";
					evc.PiMaxLength = AzMAX_NAME_LENGTH;
					evc.PiSuffixLength = 0;
					evc.hidesBottomBarWhenPushed = YES; // 次画面のToolBarを消す
					[self.navigationController pushViewController:evc animated:YES];
					[evc release];
				}
					break;
			}
			break;
		case 2: //--------------------------------E6part: 全unpaid時に金額調整を可能にする予定
			
			break;
	}

	// 修正をはじめたら、Tool Bar ボタンを無効にする & Footerのコピーメッセージを消す
	for (id obj in self.toolbarItems) {
		if (TAG_BAR_BUTTON_TOPVIEW <= [[obj valueForKey:@"tag"] intValue]) {
			[obj setEnabled:NO];
		}
	}
	MiIndexE3lasts = (-2); // Footerメッセージを非表示にするため
}


- (void)cancel:(id)sender
{
	[McalcView hide]; // Calcが出てれば隠す
	
	NSManagedObjectContext *contx = Re3edit.managedObjectContext;
	if (0 < PiAdd) {  // MbCopyAdd=YES:のRe3editも同様に削除してコミットしておく。
//		if (Me3editMask) {
//			[contx deleteObject:Me3editMask];
//		}
		// Add mode: 新オブジェクトのキャンセルなので、呼び出し元で挿入したオブジェクトを削除する
		[contx deleteObject:Re3edit];
		// SAVE
		NSError *err = nil;
		if (![contx save:&err]) {
			NSLog(@"Unresolved error %@, %@", err, [err userInfo]);
			abort();
		}
	}
	else {
		// E4,E5のAdd保存した場合、それまでは同時に保存されてしまう。とりあえず対応保留
		[contx rollback]; // 前回のSAVE以降を取り消す
	}

	if ([sender tag] == TAG_BAR_BUTTON_TOPVIEW) {
		[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
	} else {
		[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
	}
}

// 編集フィールドの値を self.e3target にセットする
- (void)save:(id)sender 
{
	if (McalcView) {
		[McalcView save]; // Calcが出てれば保存してから、
		[McalcView hide]; // Calcが出てれば隠す
	}

	if (AzMAX_AMOUNT < [Re3edit.nAmount integerValue]) {
		[self alertAmountOver]; // 2カ所から呼び出しているので関数化
		return;
	}

	if ([Re3edit.nAmount integerValue] == 0) {  // マイナス対応
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AmountZero",nil)
														 message:NSLocalizedString(@"AmountZero msg",nil)
														delegate:nil 
											   cancelButtonTitle:nil 
											   otherButtonTitles:@"OK", nil] autorelease];
		[alert show];
		return;
	}
	
	if( AzMAX_NAME_LENGTH < [Re3edit.zName length] ){
		// 長さがAzMAX_NAME_LENGTH超ならば、0文字目から50文字を切り出して保存　＜以下で切り出すとフリーズする＞
		[Re3edit.zName substringToIndex:AzMAX_NAME_LENGTH-1];
	}
	
/*カード未定許可
	if (Re3edit.e1card == nil) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoCardSelect",nil)
														 message:NSLocalizedString(@"NoCardSelect msg",nil)
														delegate:nil 
											   cancelButtonTitle:nil 
											   otherButtonTitles:@"OK", nil] autorelease];
		[alert show];
		return;
	}*/
	
	//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	// 主要条件（利用日、金額、支払条件）が変更されると配下の E6(unpaid) は全削除される　＜＜PAIDが無い前提＞＞
	// クイック追加時、＜この時点で配下のE6は無い。また、E6が追加された後に.e1card==nilになることは無い＞
	if (!MbE6paid && Re3edit.e1card)  // クイック追加時、カード未定(.e1card==nil)許可のため　
	{	// 配下のE6を生成または更新する
		if ([EntityRelation e3makeE6:Re3edit inFirstYearMMDD:PiFirstYearMMDD]==NO) return;
	}

	Re3edit.sumNoCheck = [Re3edit valueForKeyPath:@"e6parts.@sum.nNoCheck"];
	
	if (Re3edit.e4shop) {
		E4shop *e4node = Re3edit.e4shop;
		e4node.sortDate = [NSDate date]; // [e4node valueForKeyPath:@"e3records.@max.dateUse"];
		e4node.sortAmount = [e4node valueForKeyPath:@"e3records.@sum.nAmount"];
		e4node.sortCount = [e4node valueForKeyPath:@"e3records.@count"];
	}

	if (Re3edit.e5category) {
		E5category *e5node = Re3edit.e5category;
		e5node.sortDate = [NSDate date]; // [e5node valueForKeyPath:@"e3records.@max.dateUse"];
		e5node.sortAmount = [e5node valueForKeyPath:@"e3records.@sum.nAmount"];
		e5node.sortCount = [e5node valueForKeyPath:@"e3records.@count"];
	}
	
	NSManagedObjectContext *contx = Re3edit.managedObjectContext;
//	if (Me3editMask) {
//		[contx deleteObject:Me3editMask];
//	}
	// SAVE
	NSError *err = nil;
	if (![contx save:&err]) {
		NSLog(@"Unresolved error %@, %@", err, [err userInfo]);
		abort();
	}

	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}

- (void)alertAmountOver {  // 現在2カ所から呼び出されている
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AmountOver",nil)
													 message:NSLocalizedString(@"AmountOver msg",nil)
													delegate:nil 
										   cancelButtonTitle:nil 
										   otherButtonTitles:@"OK", nil] autorelease];
	[alert show];
}



@end

