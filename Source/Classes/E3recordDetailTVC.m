////
//  E3recordDetailTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "TopMenuTVC.h"
#import "E1cardTVC.h"
#import "E3recordTVC.h"
#import "E3recordDetailTVC.h"
#import "E3selectPayTypeTVC.h"
#import "E3selectRepeatTVC.h"
#import "E4shopTVC.h"
#import "E5categoryTVC.h"
#import "E6partTVC.h"
#import "EditDateVC.h"
#import "EditTextVC.h"
#import "CalcView.h"


#define ACTIONSEET_TAG_DELETE		190

#define TAG_BAR_BUTTON_TOPVIEW		901		// viewWillAppear()にて、これ以上のものを無効にしている
#define TAG_BAR_BUTTON_DEL			902
#define TAG_BAR_BUTTON_ADD			903

#define TAG_BAR_BUTTON_NEW			911		// 新規
#define TAG_BAR_BUTTON_PAST			912		// 過去へ
#define TAG_BAR_BUTTON_RETURN		913		// 戻す

@interface E3recordDetailTVC (PrivateMethods)
//- (void)cancel:(id)sender;  iPad対応のため公開メソッド(cancelClose:)になった。
- (void)saveClose:(id)sender;
- (void)viewDesign;
- (void)cellButtonE6check: (UIButton *)button;
- (void)barButton: (UIButton *)button;
- (void)showCalcAmount;
@end

@implementation E3recordDetailTVC
@synthesize Re3edit;
@synthesize PiAdd;
@synthesize PiFirstYearMMDD;
#ifdef AzPAD
@synthesize delegate;
@synthesize selfPopover;
#endif


#pragma mark - Delegate method

// E6partsに影響する項目が変更されたので、E6partsを再生成する　 ＜＜安全快適のため、1回と2回払いだけに限定、かつ未チェックに限る＞＞
// return(BOOL) YES=OK, NO=E6変更禁止につき、保存禁止すること
- (void)remakeE6change:(int)iChange
{
	assert(Re3edit);
	// 【iChange】 変化した項目番号：この項目を基（主）に関連項目を調整する
	// (1) dateUse変更 ⇒ 支払先条件通りにE6更新
	// (2) nAmount変更 ⇒ 
	// (3) e1card変更 ⇒ 
	// (4) nPayType	変更 ⇒ 　支払方法（=1 or 2)	＜＜1回と2回払いだけに限定＞＞
	// 以上は、E6partのうち1つでもPAIDになれば禁止。
	// (5) E6part1変更 ⇒ E6part1を固定してE6part2またはE3を調整更新する。E6part2がCheckedならば解除する。
	// (6) E6part2変更 ⇒ E6part2を固定してE6part1またはE3を調整更新する。E6part1がCheckedまたはPAIDならば禁止。
	// 【withFirstYMD】 1回目の支払日を指定。　=0:指定なし
	if ([MocFunctions e3record:Re3edit makeE6change:iChange withFirstYMD:PiFirstYearMMDD]) {
		// 再描画
		[self viewWillAppear:YES];
	}
}


#pragma mark - Action

// UIActionSheetDelegate 処理部
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != actionSheet.destructiveButtonIndex) return;
	
	if (Re3edit && actionSheet.tag == ACTIONSEET_TAG_DELETE) { // Re3edit 削除
		//[0.4] E3recordTVCに戻ったとき更新＆再描画するため
		AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		// 自身は削除されてしまうのでcopyする。この日時以降の行が中央に表示されることになる。
		//autoreleaseにより不要//[app.Me3dateUse release], app.Me3dateUse = nil; //1.0.0//
		app.Me3dateUse = [[Re3edit.dateUse copy] autorelease];  // Me3dateUseはretainプロパティ
		[MocFunctions e3delete:Re3edit];
		[MocFunctions commit];

#ifdef AzPAD
		if (selfPopover) {
			if ([delegate respondsToSelector:@selector(refreshE3recordTVC:)]) {	// メソッドの存在を確認する
				[delegate refreshE3recordTVC:NO];// 親の再描画を呼び出す
			}
			else if ([delegate respondsToSelector:@selector(refreshE6partTVC:)]) {	// メソッドの存在を確認する
				[delegate refreshE6partTVC:NO];// 親の再描画を呼び出す
			}
			// TopMenuTVCにある 「未払合計額」を再描画するための処理
			UINavigationController* naviLeft = [app.mainController.viewControllers objectAtIndex:0];	//[0]Left
			TopMenuTVC* tvc = (TopMenuTVC *)[naviLeft.viewControllers objectAtIndex:0]; //<<<.topViewControllerではダメ>>>
			if ([tvc respondsToSelector:@selector(refreshTopMenuTVC)]) {	// メソッドの存在を確認する
				[tvc refreshTopMenuTVC]; // 「未払合計額」再描画を呼び出す
			}
			[selfPopover dismissPopoverAnimated:YES];
		}
#else
		[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
#endif
	}
}

- (void)showCalcAmount
{
#ifdef AzPAD
	// ToolBar常時表示
#else
	// ToolBar非表示  ＜＜ツールバーがあるとキー下段が押せない＞＞
	[self.navigationController setToolbarHidden:YES];
#endif
	
	if (McalcView) {
		[McalcView hide];
		McalcView.delegate = nil;
		[McalcView removeFromSuperview];
		McalcView = nil;
	}
	
	CGRect rect = self.view.bounds;
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:0]; // 利用金額行
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		// 横
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionTop	// 上端へ
									  animated:YES];
		rect.origin.y = 52; //55;
	}
	else {
		// 縦   ＜＜iPadの場合は、常にタテ
		[self.tableView scrollToRowAtIndexPath:indexPath 
							  atScrollPosition:UITableViewScrollPositionMiddle	// 中央へ
									  animated:YES];
		rect.origin.y = 65; //0;
	}
	
	McalcView = [[CalcView alloc] initWithFrame:rect withE3:Re3edit];
	McalcView.Rlabel = MlbAmount;  // MlbAmount.tag にはCalc入力された数値(long)が記録される
	McalcView.PoParentTableView = self.tableView; // これによりスクロール禁止している
	McalcView.delegate = self;	// viewWillAppear:を呼び出すため
	[self.navigationController.view addSubview:McalcView];	//[1.0.1]万一広告が残ってもキーが上になるようにした。
	[McalcView release]; // addSubviewにてretain(+1)されるため、こちらはrelease(-1)して解放
	[McalcView show];
}

- (void)cancelClose:(id)sender
{
	[McalcView hide]; // Calcが出てれば隠す
	
	if (0 < PiAdd) {
		// Add mode: 呼び出し元で挿入したオブジェクトはrollbackされないので削除する
		// E3配下のE6は、随時生成更新されているので、ここで同時に削除する
		[MocFunctions e3delete:Re3edit]; //remakeE6change：処理により配下E6もあれば削除する
		//[MocFunctions commit]; delete後のcommit不要
	}
	
	// E4,E5で新規追加したものもcommitしていないので、ここでrollbackされる
	[MocFunctions rollBack]; // 前回のSAVE以降を取り消す
	
	//[0.4]
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//[Me3dateUse release],// autoreleseにしたので解放不要（すれば落ちる）
	app.Me3dateUse = nil; //1.0.0//

#ifdef AzPAD
	[selfPopover dismissPopoverAnimated:YES];
#else
	if ([sender tag] == TAG_BAR_BUTTON_TOPVIEW) {
		[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
	} else {
		[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
	}
#endif
}

// 編集フィールドの値を self.e3target にセットする
- (void)saveClose:(id)sender 
{
	if (McalcView) {
		[McalcView save]; // Calcが出てれば保存してから、
		[McalcView hide]; // Calcが出てれば隠す
	}
	
	if (ANSWER_MAX < fabs([Re3edit.nAmount doubleValue])) {
		alertBox(NSLocalizedString(@"AmountOver",nil),
				 NSLocalizedString(@"AmountOver msg",nil),
				 NSLocalizedString(@"Roger",nil));
		return;
	}
	else if ([Re3edit.nAmount doubleValue]==0.0) {
		alertBox(NSLocalizedString(@"AmountZero",nil),
				 NSLocalizedString(@"AmountZero msg",nil),
				 NSLocalizedString(@"Roger",nil));
		return;
	}
	
	if( AzMAX_NAME_LENGTH < [Re3edit.zName length] ){
		// 長さがAzMAX_NAME_LENGTH超ならば、0文字目から50文字を切り出して保存　＜以下で切り出すとフリーズする＞
		[Re3edit.zName substringToIndex:AzMAX_NAME_LENGTH-1];
	}

	// E3配下のE6は、随時更新されている。
	// E3配下の E4,E5あれば更新
	[MocFunctions e3saved:Re3edit]; 
	// 保存
	[MocFunctions commit];
	//[0.4.17]この直後、前のViewへ戻るまでの間に、cellForRowAtIndexPath「支払明細(E6)のセル再描画」を通ると落ちる。
	//[0.4.17]（原因）E3配下の更新処理にてE6が削除されることが原因。
	//[0.4.17]（対応）この後、MbSaved=YES にして再描画を禁止する。
	MbSaved = YES;
	
	//[0.4] E3recordTVCに戻ったとき更新＆再描画するため
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//autoreleaseにより不要//[app.Me3dateUse release], app.Me3dateUse = nil; //1.0.0//
	app.Me3dateUse = [[Re3edit.dateUse copy] autorelease];
	
#ifdef AzPAD
	if (selfPopover) {
		if ([delegate respondsToSelector:@selector(refreshE3recordTVC:)]) {	// メソッドの存在を確認する
			BOOL bSame = (MiSourceYearMMDD == GiYearMMDD( Re3edit.dateUse ));
			[delegate refreshE3recordTVC:bSame];// 親の再描画を呼び出す
		}
		else if ([delegate respondsToSelector:@selector(refreshE6partTVC:)]) {	// メソッドの存在を確認する
			BOOL bSame = !MbE1cardChange;
			[delegate refreshE6partTVC:bSame];// 親の再描画を呼び出す
		}

		// TopMenuTVCにある 「未払合計額」を再描画するための処理
		UINavigationController* naviLeft = [app.mainController.viewControllers objectAtIndex:0];	//[0]Left
		TopMenuTVC* tvc = (TopMenuTVC *)[naviLeft.viewControllers objectAtIndex:0]; //<<<.topViewControllerではダメ>>>
		if ([tvc respondsToSelector:@selector(refreshTopMenuTVC)]) {	// メソッドの存在を確認する
			[tvc refreshTopMenuTVC]; // 「未払合計額」再描画を呼び出す
		}

		[selfPopover dismissPopoverAnimated:YES];
	}
#else
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
#endif
}


#pragma mark barButton

- (void)barButtonCopyAdd 
{
	[McalcView hide]; // Calcが出てれば隠す
	
	// もし修正していた場合、それが保存されてしまわないように、まずrollBackする　＜＜Re3edit生成直後までrollBackされる＞＞
	[Re3edit.managedObjectContext rollback]; // 前回のSAVE以降を取り消す
	
	// Re3edit のコピーを生成して、Re3edit と置き換える。
	E3record *e3new = [MocFunctions replicateE3record:Re3edit]; //retain されているので relese が必要
	MbE6paid = NO;	//[0.3] NO = 配下のE6にPAIDは1つも無い ⇒ 主要項目も修正可能
	// Replace
	[e3new retain];		// Re3editが解放される前に確保する必要あり
	[Re3edit release];	// 解放
	Re3edit = e3new;	// 置換　e3new から Re3edit へオーナー移管。　Re3edit は dealloc で release される。
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
			else if ([RaE3lasts count] <= MiIndexE3lasts + 1) {  // [Me3lasts count]-1 とするとエラー
				// Max over
				MiIndexE3lasts = [RaE3lasts count] - 1;
				button.enabled = NO;
			}
			else {
				MiIndexE3lasts++;
				e3obj = [RaE3lasts objectAtIndex:MiIndexE3lasts];
				// 対向の Tool Bar ボタンを有効にする
				for (id obj in self.toolbarItems) {
					if ([[obj valueForKey:@"tag"] intValue] == TAG_BAR_BUTTON_RETURN) [obj setEnabled:YES];
				}
				if ([RaE3lasts count] <= MiIndexE3lasts + 1) {  // さらに前回でオーバーするならばボタン無効にする
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
			else if ([RaE3lasts count] <= MiIndexE3lasts) {
				// Max over
				MiIndexE3lasts = [RaE3lasts count] - 1;
			}
			else {
				MiIndexE3lasts--;
				e3obj = [RaE3lasts objectAtIndex:MiIndexE3lasts];
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
			Re3edit.nAmount		= [NSDecimalNumber zero];
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



#pragma mark - View lifecycle

// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (id)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStyleGrouped]; // セクションありテーブル
	if (self) {
		// 初期化
		PiFirstYearMMDD = 0;
		MbSaved = NO;
		MbE1cardChange = NO;
		MbModified = NO;
#ifdef AzPAD
		MiSourceYearMMDD = 0;		// 初回のみ通すため
		self.contentSizeForViewInPopover = GD_POPOVER_SIZE_INIT;
		// この後、viewDidAppearにて GD_POPOVER_SIZE を設定することにより、ようやくPopoverサイズの変動が無くなった。
#endif
	}
	return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
//【Tips】ここでaddSubviewするオブジェクトは全てautoreleaseにすること。メモリ不足時には自動的に解放後、改めてここを通るので、初回同様に生成するだけ。
- (void)loadView
{
	//NSLog(@"--- loadView --- E3recordDetailTVC");
	[super loadView];
	
	// 初期化
	MbCopyAdd = NO;
	MiIndexE3lasts = (-1); // (-2)過去コピー機能無効
	Me0root = nil;		// viewWillAppearにて生成
	MlbAmount = nil;	// cellForRowAtIndexPathにて生成
	
	//self.tableView.backgroundColor = [UIColor brownColor];

	// Set up NEXT Left [Back] buttons.
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"Cancel",nil) 
									   style:UIBarButtonItemStylePlain  target:nil  action:nil] autorelease];
	
	// CANCELボタンを左側に追加する  Navi標準の戻るボタンでは cancelClose:処理ができないため
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
											  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
											  target:self action:@selector(cancelClose:)] autorelease];
	// SAVEボタンを右側に追加する
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
											   target:self action:@selector(saveClose:)] autorelease];
	self.navigationItem.rightBarButtonItem.enabled = NO; // 変更あればYESにする
	
	// Tool Bar Button
	if (0 < PiAdd) {
		UIBarButtonItem *buFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				 target:nil action:nil] autorelease];
		
		UIBarButtonItem *buNew = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-CopyStop.png"]
																  style:UIBarButtonItemStylePlain
																  target:self action:@selector(barButton:)] autorelease];
		buNew.tag = TAG_BAR_BUTTON_NEW;
		
		UIBarButtonItem *buPast = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-CopyLeft.png"]
																   style:UIBarButtonItemStylePlain
																   target:self action:@selector(barButton:)] autorelease];
		buPast.tag = TAG_BAR_BUTTON_PAST;
		
		UIBarButtonItem *buReturn = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-CopyRight.png"]
																	 style:UIBarButtonItemStylePlain
																	 target:self action:@selector(barButton:)] autorelease];
		buReturn.tag = TAG_BAR_BUTTON_RETURN;
		buReturn.enabled = NO; // 最初、戻るは無効
		
		NSArray *buArray = [NSArray arrayWithObjects: buFlex, buPast, buFlex, buNew, buFlex, buReturn, buFlex, nil];
		[self setToolbarItems:buArray animated:YES];
		//[buReturn release];
		//[buPast release];
		//[buNew release];
		//[buFlex release];
	} 
	else {
		UIBarButtonItem *buFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				 target:nil action:nil] autorelease];
#ifdef AzPAD
		// Top不要
#else
		MbuTop = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-Top.png"]
												  style:UIBarButtonItemStylePlain  //Bordered
												  target:self action:@selector(cancelClose:)] autorelease]; // ＜＜ cancelClose:YES<<--TopView ＞＞
		MbuTop.tag = TAG_BAR_BUTTON_TOPVIEW; // cancelClose:にて判断に使用
#endif
		
		UIBarButtonItem *buCopyAdd = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-CopyAdd.png"]
																	  style:UIBarButtonItemStylePlain  //Bordered
																	  target:self action:@selector(barButtonCopyAdd)] autorelease];
		buCopyAdd.tag = TAG_BAR_BUTTON_ADD;
		
		MbuDelete = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
																   target:self action:@selector(barButtonDelete)] autorelease];
		MbuDelete.tag = TAG_BAR_BUTTON_DEL;
		
#ifdef AzPAD
		// Top不要
		NSArray *buArray = [NSArray arrayWithObjects: buFlex, buCopyAdd, buFlex, MbuDelete, nil];
		[self setToolbarItems:buArray animated:YES];
#else
		NSArray *buArray = [NSArray arrayWithObjects: MbuTop, buFlex, buCopyAdd, buFlex, MbuDelete, nil];
		[self setToolbarItems:buArray animated:YES];
		//[MbuTop release];
#endif
		//[buCopyAdd release];
		//[MbuDelete release];
		//[buFlex release];
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
	MbOptEnableInstallment = [defaults boolForKey:GD_OptEnableInstallment];
	MbOptUseDateTime = [defaults boolForKey:GD_OptUseDateTime];
	//MbOptAmountCalc = [defaults boolForKey:GD_OptAmountCalc];
	//[0.4]以降、ヨコでもツールバーを表示するようにした。
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示

	// データ更新＆再表示
	if (MbSaved) return; // SAVE直後、E6が削除されている可能性があるためE6参照禁止するため
	//--------------------------------------------------------------------------------.
	// Me0root はArreyじゃない！からrelese不要
	if (Me0root==nil) {
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
	}
	
	//--------------------------------------------------Pe3select.e6parts
	if (RaE6parts) {
		[RaE6parts release], RaE6parts = nil;
	}
	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"nPartNo" ascending:YES];
	NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
	[sort1 release];
	// 
	RaE6parts = [[NSMutableArray alloc] initWithArray:[Re3edit.e6parts allObjects]];
	[RaE6parts sortUsingDescriptors:sortArray];
	[sortArray release];
	
	MbE6paid = NO;
	MbE6checked = NO;
	int iChecked = [RaE6parts count];
	if (0 < iChecked) {
		for (E6part *e6 in RaE6parts) {
			if (e6.e2invoice.e1paid OR e6.e2invoice.e7payment.e0paid) {
				MbE6paid = YES; // YES:PAIDあり、主要条件の変更禁止！
			}
			if ([e6.nNoCheck integerValue]==0) { //チェック
				iChecked--;
			}
		}
		MbE6checked = (iChecked<=0); //YES=E6parts全チェック済
	}

	if (MbuDelete) {
		// E3配下のE6に1つでもPAIDがあるならば、削除(ごみ箱)ボタンを無効にする     [0.3]
		MbuDelete.enabled = !MbE6paid;
	}
	
	//--------------------------------------------------Me3lasts: 前回引用するため
	if (RaE3lasts) {
		[RaE3lasts release], RaE3lasts = nil;
	}
	// Sorting
	sort1 = [[NSSortDescriptor alloc] initWithKey:@"dateUse" ascending:NO]; // NO=降順
	sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
	[sort1 release];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entityE3 = [NSEntityDescription entityForName:@"E3record" 
												inManagedObjectContext:Re3edit.managedObjectContext];
	[fetchRequest setEntity:entityE3];
	[fetchRequest setFetchLimit:21];
	//[fetchRequest setFetchOffset:page * limit ];
	
	if (Re3edit.e4shop) {
		// e4shop以下、最近の全E3
		//RaE3lasts = [[NSMutableArray alloc] initWithArray:[Re3edit.e4shop.e3records allObjects]];
		NSPredicate* pred = [NSPredicate predicateWithFormat:@"(e4shop == %@) AND (dateUse <= %@)",
							 Re3edit.e4shop, [NSDate date]]; // 現在以前、Limitまで
		[fetchRequest setPredicate:pred];
	}
	else if (Re3edit.e5category) {
		// e5category以下、最近の全E3
		//RaE3lasts = [[NSMutableArray alloc] initWithArray:[Re3edit.e5category.e3records allObjects]];
		NSPredicate* pred = [NSPredicate predicateWithFormat:@"(e5category == %@) AND (dateUse <= %@)",
							 Re3edit.e5category, [NSDate date]]; // 現在以前、Limitまで
		[fetchRequest setPredicate:pred];
	}
	else {
		//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		// 利用明細一覧用：最近の全E3
		// datePrev 〜 dateBottom 間を抽出する	＜＜＜dateUse は,UTC(+0000)記録されている＞＞＞
		//[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(dateUse > %@) && (dateUse <= %@)", 
		//							[NSDate dateWithTimeIntervalSinceNow:-100*24*60*60], [NSDate date]]]; // 100日前〜今日まで抽出
		[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(dateUse <= %@)", [NSDate date]]]; // 現在以前、Limitまで
	}
	
	[fetchRequest setSortDescriptors:sortArray];
	// Fitch
	NSError *error = nil;
	NSArray *arFetch = [Re3edit.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error) {
		AzLOG(@"Error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	[fetchRequest release];
	RaE3lasts = [[NSMutableArray alloc] initWithArray:arFetch];
	[sortArray release];
	// 重要！Me3lastsには、新規追加されたRe3editが含まれているので、ここで除外する。
	[RaE3lasts removeObject:Re3edit];
	
	// 初期値
	if (Re3edit.dateUse == nil) {
		Re3edit.dateUse = [NSDate date]; // Now
	}
#ifdef AzPAD
	if (PiAdd==0 && MiSourceYearMMDD==0) {	// 初回のみ通す
		MiSourceYearMMDD = GiYearMMDD( Re3edit.dateUse ); // saveClose:にて日付の変化を判定するため
	}
#endif
	
	if (Re3edit.e1card == nil) {
		// Re3edit.e1card = 最上行のカードにする
	}
	
	if (PiAdd==0 OR PiFirstYearMMDD < AzMIN_YearMMDD) {
		PiFirstYearMMDD = 0;
	}
	
	
	[self viewDesign]; // 下層で回転して戻ったときに再描画が必要
	// テーブルビューを更新します。
	[self.tableView reloadData];
	
	// 変更あれば、ツールバー(Top, Add, Delete)を非表示にする
	//if (PiAdd <= 0 && [Re3edit.managedObjectContext hasChanges]) {
	//if (MbModified) {
	AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (apd.entityModified) {	// 変更あり
		self.navigationItem.rightBarButtonItem.enabled = ([Re3edit.nAmount doubleValue] != 0.0); // 金額0で無ければYES
		MbModified = YES; // titleForFooterInSection:にて参照
		for (id obj in self.toolbarItems) {
			if (TAG_BAR_BUTTON_TOPVIEW <= [[obj valueForKey:@"tag"] intValue]) {
				[obj setEnabled:NO];
			}
		}
		// 金額または支払方法に変更があればE6partsを非表示にする
		
		//MiIndexE3lasts = (-2); // Footerメッセージを非表示にするため
	}
}

- (void)viewDesign
{
	// 回転によるリサイズ
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated 
{
#ifdef AzPAD
	// init 時に GD_POPOVER_SIZE_INIT を設定してから、この処理により、ようやくPopoverサイズの変動が無くなった。
	self.contentSizeForViewInPopover = GD_POPOVER_SIZE;
#endif
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
}




#pragma mark View - Rotate

// 回転の許可　ここでは許可、禁止の判定だけする
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	// 回転禁止でも、正面は常に許可しておくこと。
	return !MbOptAntirotation OR (interfaceOrientation == UIInterfaceOrientationPortrait);
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
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation // 直前の向き
{
	// この完了時に再表示する。　　この時点で self.view.frame は回転済み。
	[self viewDesign];

	if (MbRotatShowCalc) {
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:0]; // 利用金額行
		if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
			// 横から縦になった
			[self.tableView scrollToRowAtIndexPath:indexPath 
								  atScrollPosition:UITableViewScrollPositionMiddle	// 中央へ
										  animated:YES];
		} else {
			// 縦から横になった
			[self.tableView scrollToRowAtIndexPath:indexPath 
								  atScrollPosition:UITableViewScrollPositionTop	// 上端へ
										  animated:YES];
		}
		[self showCalcAmount]; // 再表示
	}
}

#pragma mark  View - Unload - dealloc

- (void)unloadRelease {	// dealloc, viewDidUnload から呼び出される
	//【Tips】loadViewでautorelease＆addSubviewしたオブジェクトは全てself.viewと同時に解放されるので、ここでは解放前の停止処理だけする。
	NSLog(@"--- unloadRelease --- E3recordDetailTVC");
	if (McalcView) {
		McalcView.delegate = nil;
		[McalcView hide];
		[McalcView removeFromSuperview];
		McalcView = nil;
	}
	
	//【Tips】デリゲートなどで参照される可能性のあるデータなどは破棄してはいけない。
	// 他オブジェクトからの参照無く、viewWillAppearにて生成されるので破棄可能
	[RaE6parts release], RaE6parts = nil;
	[RaE3lasts release], RaE3lasts = nil;
}

- (void)dealloc    // 生成とは逆順に解放するのが好ましい
{
#ifdef AzPAD
	[selfPopover release], selfPopover = nil;
#endif
	[self unloadRelease];
	//--------------------------------@property (retain)
	[Re3edit release], Re3edit = nil;
	[super dealloc];
}

// メモリ不足時に呼び出されるので不要メモリを解放する。 ただし、カレント画面は呼ばない。
- (void)viewDidUnload 
{
	//NSLog(@"--- viewDidUnload ---"); 
	// メモリ不足時、裏側にある場合に呼び出される。addSubviewされたOBJは、self.viewと同時に解放される
	[self unloadRelease];
	[super viewDidUnload];
	// この後に loadView ⇒ viewDidLoad ⇒ viewWillAppear がコールされる
}


#pragma mark - TableView lifecycle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section) {
		case 0:
			if (!MbOptEnableInstallment || (Re3edit.e1card.nPayDay && [Re3edit.e1card.nPayDay integerValue]==0)) 
			{												// [Debit]E3.dateUse を支払日とするモード
				return 4; // 支払方法の選択不要
			}
			return 5; //[0.4]繰り返し対応
			break;
		case 1:
			return 3;
			break;
		case 2:
			if (0 < [Re3edit.e6parts count]) {
				return [Re3edit.e6parts count]; // 支払明細
			} else {
				return 1; // 新規追加時の電卓描画範囲を確保するためダミーセル表示する
			}
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
			//if (PiAdd <= 0) {
			if (0 < [Re3edit.e6parts count]) {
				return NSLocalizedString(@"Payment Details",nil);
			}
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
			else if	(0 <= MiIndexE3lasts && !MbModified) {
				return [NSString stringWithFormat:@"%@%ld%@", 
						NSLocalizedString(@"PastCopyPre",nil),
						1 + MiIndexE3lasts, 
						NSLocalizedString(@"PastCopySuf",nil)];
			}
			else if (0 < PiAdd && !MbCopyAdd && (-1) <= MiIndexE3lasts && !MbModified) {
				return NSLocalizedString(@"E3AddBar Help",nil); // 画面ヨコで電卓出たときのスクロール範囲を確保するため5行表示
			}
			break;

		case 1:
			if (MbE6paid) {
				return NSLocalizedString(@"E6PAID Help",nil);
			}
			else if ([Re3edit.e6parts count] <= 0) {
				return	@"\n\n\n\n\n\n\n\n"; // 画面ヨコで電卓出たときのスクロール範囲を確保するため5行表示
			}
			break;

		case 2:
			return	@"\n\n\n"; //[1.0.1]万一広告が残ったとき、支払明細が見える所までスクロールできるようにするため
	}
	return nil;
}


// セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.section==0 && 3<=indexPath.row) {
#ifdef AzPAD
		return 36; // Repeat, Payment
#else
		return 30; // Repeat, Payment
#endif
	}
	return 44; // デフォルト：44ピクセル
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *zCellIndex = [NSString stringWithFormat:@"E3detail%d:%d", (int)indexPath.section, (int)indexPath.row];
    static NSString *zCellE6part = @"CellE6part";
	UITableViewCell *cell = nil;
	
	switch (indexPath.section) {
		case 0: //----------------------------------------------------------------------SECTION 必須
			cell = [tableView dequeueReusableCellWithIdentifier:zCellIndex];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
											   reuseIdentifier:zCellIndex] autorelease];
				cell.showsReorderControl = NO; // Move禁止
#ifdef AzPAD
				cell.textLabel.font = [UIFont systemFontOfSize:12];  // 見出し
				cell.detailTextLabel.font = [UIFont systemFontOfSize:20]; // 必須内容表示　大きく
#else
				cell.textLabel.font = [UIFont systemFontOfSize:12];  // 見出し
				cell.detailTextLabel.font = [UIFont systemFontOfSize:17]; // 必須内容表示　大きく
#endif
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				cell.textLabel.textColor = [UIColor grayColor];
				
				cell.detailTextLabel.textColor = [UIColor blackColor];
			}

			if (MbE6paid OR MbE6checked) {
				cell.accessoryType = UITableViewCellAccessoryNone; // 変更禁止
			} else {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
			}

			switch (indexPath.row) {
				case 0: { // Use date	// NSDateは、GTM(+0000)協定時刻で記録 ⇒ 表示でタイムゾーン変換する
					if (Re3edit.e1card && [Re3edit.e1card.nPayDay integerValue]==0) {	//[0.4]E3.dateUse を支払日とするモード
						cell.textLabel.text = NSLocalizedString(@"Due date",nil);
					} else {
						cell.textLabel.text = NSLocalizedString(@"Use date",nil);
					}
					NSDateFormatter *df = [[NSDateFormatter alloc] init];
					if (MbOptUseDateTime) {
						[df setDateFormat:NSLocalizedString(@"E3detailDateTime",nil)];
					} else {
						[df setDateFormat:NSLocalizedString(@"E3detailDate",nil)];
					}
					//AzLOG(@"Me3zDateUse=%@", Me3zDateUse);
#ifdef AzPAD
					cell.detailTextLabel.font = [UIFont systemFontOfSize:24]; // 特に大きく
#endif
					cell.detailTextLabel.text = [df stringFromDate:Re3edit.dateUse];
					[df release];
				} break;
					
				case 1: // Amount
					if (MlbAmount == nil) {
						MlbAmount = [[UILabel alloc] initWithFrame:CGRectMake(65,5, 210,35)];
						MlbAmount.lineBreakMode = UILineBreakModeWordWrap; // 単語を途切れさせないように改行する
						MlbAmount.textAlignment = UITextAlignmentCenter;
						MlbAmount.tag = 0; // Calc入力された数値(long)を記録する
#ifdef AzDEBUG
						//MlbAmount.backgroundColor = [UIColor grayColor]; //範囲チェック用
#endif
						MlbAmount.font = [UIFont systemFontOfSize:30];
						MlbAmount.backgroundColor = [UIColor clearColor];
						[cell.contentView addSubview:MlbAmount]; [MlbAmount release];
					}
					cell.textLabel.text = NSLocalizedString(@"Use Amount",nil);
					cell.accessoryType = UITableViewCellAccessoryNone; // なし

					if (ANSWER_MAX < fabs([Re3edit.nAmount doubleValue])) {
						MlbAmount.text = @"Game Over";
						MlbAmount.textColor = [UIColor redColor];
						break;
					}
					else if ([Re3edit.nAmount doubleValue] < 0.0) {
						MlbAmount.textColor = [UIColor blueColor];	// 負債のマイナスだから債権、よって青にした
					} else {
						MlbAmount.textColor = [UIColor blackColor];
					}
					//
					NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
					[formatter setNumberStyle:NSNumberFormatterCurrencyStyle]; // 通貨スタイル
					[formatter setLocale:[NSLocale currentLocale]]; 
					//NSLog(@"***** negativeFormat=%@", [formatter negativeFormat]);
					[formatter setNegativeFormat:@"¤-#,##0.####"];
					MlbAmount.text = [formatter stringFromNumber:Re3edit.nAmount];
					[formatter release];
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
					
				case 3: // Repeat	//[0.4] (0)なし　(1)1ヶ月後　(2)2ヶ月後　(12)1年後
				{
					cell.textLabel.text = NSLocalizedString(@"Use Repeat",nil);
#ifdef AzPAD
					cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
#else
					cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
#endif
					switch ([Re3edit.nRepeat integerValue]) {
						case  0: cell.detailTextLabel.text = NSLocalizedString(@"Repeat00", nil); break;
						case  1: cell.detailTextLabel.text = NSLocalizedString(@"Repeat01", nil); break;
						case  2: cell.detailTextLabel.text = NSLocalizedString(@"Repeat02", nil); break;
						case 12: cell.detailTextLabel.text = NSLocalizedString(@"Repeat12", nil); break;
						default: cell.detailTextLabel.text = NSLocalizedString(@"(Untitled)", nil); break;
					}

					if (MbE6paid OR MbE6checked) {
						cell.accessoryType = UITableViewCellAccessoryNone; // 変更禁止
					} else {
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
					}
				} break;
					
				case 4: // nPayType
					cell.textLabel.text = NSLocalizedString(@"Use Payment",nil);
#ifdef AzPAD
					cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
#else
					cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
#endif
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
						case 201:
							cell.detailTextLabel.text = NSLocalizedString(@"PayType 201",nil);
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
#ifdef AzPAD
				cell.textLabel.font = [UIFont systemFontOfSize:12];  // 見出し
				cell.detailTextLabel.font = [UIFont systemFontOfSize:20]; // 任意内容表示
#else
				cell.textLabel.font = [UIFont systemFontOfSize:12];  // 見出し
				cell.detailTextLabel.font = [UIFont systemFontOfSize:16]; // 任意内容表示
#endif
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				cell.textLabel.textColor = [UIColor grayColor];
				cell.detailTextLabel.textColor = [UIColor blackColor];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
			}

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
				} break;
				
				case 1: // Category
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
				} break;
				
				case 2: // Memo
				{
					cell.textLabel.text = NSLocalizedString(@"Use Name",nil);
					if (0 < [Re3edit.zName length])
						cell.detailTextLabel.text = Re3edit.zName;
					else
						cell.detailTextLabel.text = NSLocalizedString(@"(Untitled)", nil);
				} break;
			}
			break;
			
		case 2: {  //----------------------------------------------------------------------SECTION 支払明細
			UILabel *cellLabel;
			cell = [tableView dequeueReusableCellWithIdentifier:zCellE6part];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault // Subtitle
												   reuseIdentifier:zCellE6part] autorelease];
				// 行毎に変化の無い定義は、ここで最初に1度だけする
#ifdef AzPAD
				cell.textLabel.font = [UIFont systemFontOfSize:20];
#else
				cell.textLabel.font = [UIFont systemFontOfSize:14];
#endif
				//cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
				//cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
				//cell.detailTextLabel.textColor = [UIColor blackColor];
				cell.accessoryType = UITableViewCellAccessoryNone; // 変更禁止
				
				cellLabel = [[UILabel alloc] init];
				cellLabel.textAlignment = UITextAlignmentRight;
				cellLabel.textColor = [UIColor blackColor];
				cellLabel.backgroundColor = [UIColor clearColor]; //grayColor <<DEBUG範囲チェック用
#ifdef AzPAD
				cellLabel.font = [UIFont systemFontOfSize:20];
#else
				cellLabel.font = [UIFont systemFontOfSize:14];
#endif
				cellLabel.tag = -1;
				[cell addSubview:cellLabel]; [cellLabel release];
			}
			else {
				cellLabel = (UILabel *)[cell viewWithTag:-1];
			}
			// 回転対応のため
#ifdef AzPAD
			// -25 は、Popoverの余白分だと思われる
			cellLabel.frame = CGRectMake(self.tableView.frame.size.width-180, 12, 125, 20);
#else
			cellLabel.frame = CGRectMake(self.tableView.frame.size.width-125, 12, 90, 20);
#endif
			if (MbSaved) break; //[0.4.17] SAVE直後、E6が削除されている可能性があるためE6参照禁止。
			
			if (RaE6parts==nil OR [RaE6parts count]<=0) {
				//cellButton.enabled = NO;
				//cell.imageView.image = nil;
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				cell.textLabel.text = @"(C)2000-2011 Azukid";
				cellLabel.text = @"";
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.userInteractionEnabled = NO;
				break;
			} else {
				cell.textLabel.textAlignment = UITextAlignmentLeft;
				cell.userInteractionEnabled = YES;
			}

			// 左ボタン --------------------＜＜cellLabelのようにはできない！.tagに個別記録するため＞＞  [1.0.2]viewWithTagにより改善
			// Ｓｅｃｔｉｏｎ２において cell は単一固有だが、cellButton は個別である。
			NSInteger tagButton = indexPath.section * GD_SECTION_TIMES + indexPath.row;
			UIButton *cellButton = (UIButton*)[cell.contentView viewWithTag:tagButton];
			if (cellButton==nil) {
				cellButton = [UIButton buttonWithType:UIButtonTypeCustom]; // autorelease
				cellButton.frame = CGRectMake(0,0, 44,44);
				[cellButton addTarget:self action:@selector(cellButtonE6check:) forControlEvents:UIControlEventTouchUpInside];
				cellButton.backgroundColor = [UIColor clearColor]; //背景透明
				cellButton.showsTouchWhenHighlighted = YES;
				cellButton.tag = tagButton;
				[cell.contentView addSubview:cellButton]; //autorelese
			}
			//------------------------------------------------------------------

			E6part *e6obj = [RaE6parts objectAtIndex:indexPath.row];
			//NSLog(@"*** e6obj.e2invoice=%@", e6obj.e2invoice); [0.4.17]SAVE直後E6が再生成されるため、ここで落ちた。
			if (e6obj.e2invoice.e7payment.e0paid) {
				cell.imageView.image = [UIImage imageNamed:@"Icon32-PAID.png"]; // PAID 変更禁止
				cellButton.enabled = NO;
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			else if ([e6obj.nNoCheck intValue] == 1) {
				cell.imageView.image = [UIImage imageNamed:@"Icon32-Circle.png"];
				cellButton.enabled = YES;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
			} 
			else {
				cell.imageView.image = [UIImage imageNamed:@"Icon32-CircleCheck.png"];
				cellButton.enabled = YES;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
			}
			// 支払日
			NSInteger iYearMMDD = [e6obj.e2invoice.e7payment.nYearMMDD integerValue];
			if (e6obj.e2invoice.e1paid) {
				cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", GstringYearMMDD(iYearMMDD),
									   NSLocalizedString(@"Pre",nil)];
			} else {
				cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", GstringYearMMDD(iYearMMDD),
									   NSLocalizedString(@"Due",nil)];
			}
			// 金額
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			[formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // CurrencyStyle]; // 通貨スタイル
			[formatter setLocale:[NSLocale currentLocale]]; 
			cellLabel.text = [formatter stringFromNumber:e6obj.nAmount];
			[formatter release];
		} break;
	}
    return cell;
}

- (void)cellButtonE6check: (UIButton *)button 
{
	if (button.tag < 0) return;
	
	NSInteger iSec = button.tag / GD_SECTION_TIMES;
	if (iSec != 2) return;
	NSInteger iRow = button.tag - (iSec * GD_SECTION_TIMES);
	if (iRow < 0 OR [RaE6parts count] <= iRow) return;
	
	E6part *e6obj = [RaE6parts objectAtIndex:iRow];
	// E6 Check
	if (0 < [e6obj.nNoCheck intValue]) {
		[MocFunctions e6check:YES inE6obj:e6obj inAlert:YES];
	} else {
		[MocFunctions e6check:NO inE6obj:e6obj inAlert:YES];
	}
	//------------------＜＜ここでは保存しない！ 他の修正に影響するため、E3修正の cancelClose:でrollBack, save:でcommitする＞＞
	// [EntityRelation commit];

	MbE6checked = NO;
	int iChecked = [RaE6parts count];
	if (0 < iChecked) {
		for (E6part *e6 in RaE6parts) {
			if ([e6.nNoCheck integerValue]==0) { //チェック
				iChecked--;
			}
		}
		MbE6checked = (iChecked<=0); //YES=E6parts全チェック済
	}
	
	AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	apd.entityModified = YES;	//変更あり
	//[self viewWillAppear:YES]; これえを呼ぶと、E6partsが非表示にされてしまう。
	[self.tableView reloadData];
	//[Save]ボタン表示だけ必要
	self.navigationItem.rightBarButtonItem.enabled = ([Re3edit.nAmount doubleValue] != 0.0); // 金額0で無ければYES
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[McalcView hide]; // Calcが出てれば隠す
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

	switch (indexPath.section) {
		case 0: // Section-0 主要項目
			if (MbE6paid) {
				alertBox(NSLocalizedString(@"PAID Not change",nil),
						 NSLocalizedString(@"PAID Not change msg",nil),
						 NSLocalizedString(@"Roger",nil));
				return;
			}
			else if (MbE6checked) {
				alertBox(NSLocalizedString(@"Checked Not change",nil), nil, 
						 NSLocalizedString(@"Roger",nil));
				return;
			}
			
			switch (indexPath.row) {
				case 0: // Use date
					if (!MbE6paid) {
						// 変更あれば[DONE]にて配下E6全削除すること
						EditDateVC *evc = [[EditDateVC alloc] initWithE3:Re3edit orE6:nil];
						evc.title = NSLocalizedString(@"Use date", nil);
						evc.PiMinYearMMDD = AzMIN_YearMMDD;
						evc.PiMaxYearMMDD = PiFirstYearMMDD;
						evc.delegate = self;
						//evc.hidesBottomBarWhenPushed = YES; // 次画面のToolBarを消す
						[self.navigationController pushViewController:evc animated:YES];
						[evc release];
						// 変更ありを AppDelegateへ通知	// EditDateVC：内から通知している
					}
					break;
					
				case 1: // Amount
					if (MbE6paid) break;
					[self showCalcAmount];
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
						tvc.delegate = self;
						//tvc.hidesBottomBarWhenPushed = YES; // 次画面のToolBarを消す
						[self.navigationController pushViewController:tvc animated:YES];
						[tvc release];
						MbE1cardChange = YES;
					}
					break;
					
				case 3: //[0.4] Repeat
					if (!MbE6paid) {
						E3selectRepeatTVC *tvc = [[E3selectRepeatTVC alloc] init];
						tvc.title = NSLocalizedString(@"Use Repeat",nil);
						tvc.Re3edit = Re3edit;
						//tvc.hidesBottomBarWhenPushed = YES; // 次画面のToolBarを消す
						[self.navigationController pushViewController:tvc animated:YES];
						[tvc release];
					} break;
					
				case 4: // PayType
					if (!MbE6paid) {
						// 変更あれば[DONE]にて配下E6全削除すること
						// E3selectPaymentTVC へ
						E3selectPayTypeTVC *tvc = [[E3selectPayTypeTVC alloc] init];
						tvc.title = NSLocalizedString(@"Use Payment",nil);
						tvc.Re3edit = Re3edit;
						tvc.delegate = self;
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
#ifdef AzPAD
							tvc.delegate = self;	//選択決定時、viewWillAppear を呼び出すため
#endif
							[self.navigationController pushViewController:tvc animated:YES];
							[tvc release];
						}
						break;
					
				case 1: // Category
					if (PiAdd == 4) return; // (4)Category固定
				{
					E5categoryTVC *tvc = [[E5categoryTVC alloc] init];
					tvc.title = NSLocalizedString(@"Category choice",nil);
					tvc.Re0root = Me0root;
					tvc.Pe3edit = Re3edit;
#ifdef AzPAD
					tvc.delegate = self;	//選択決定時、viewWillAppear を呼び出すため
#endif
					[self.navigationController pushViewController:tvc animated:YES];
					[tvc release];
				} break;
					
				case 2: // Memo
				{
					EditTextVC *evc = [[EditTextVC alloc] init];
					evc.title = NSLocalizedString(@"Use Name", nil);
					evc.Rentity = Re3edit;
					evc.RzKey = @"zName";
					evc.PiMaxLength = AzMAX_NAME_LENGTH;
					evc.PiSuffixLength = 0;
					//evc.hidesBottomBarWhenPushed = YES; // 次画面のToolBarを消す
					[self.navigationController pushViewController:evc animated:YES];
					[evc release];
				} break;
			}
			break;
		case 2: //--------------------------------E6part: 全unpaid時に金額調整を可能にする予定
			if (indexPath.row < [RaE6parts count]) {  // Edit
				if (MbE6paid) {  // PAID
					// [PAID]につき変更禁止
					alertBox(NSLocalizedString(@"PAID Not change",nil),
							 NSLocalizedString(@"PAID Not change msg",nil),
							 NSLocalizedString(@"Roger",nil));
					return;
				}
				else {
					assert(0 <= indexPath.row && indexPath.row < [RaE6parts count]);
					E6part *e6edit = [RaE6parts objectAtIndex:indexPath.row];
					if ([e6edit.nNoCheck integerValue]==0) {
						// チェック済につき変更禁止
						alertBox(NSLocalizedString(@"Checked Not change",nil), nil,
								 NSLocalizedString(@"Roger",nil));
						return;
					}
					//
					EditDateVC *evc = [[EditDateVC alloc] initWithE3:nil orE6:e6edit];
					evc.title = NSLocalizedString(@"Due date", nil);
					if (0 < indexPath.row) { // 前回あり
						E6part *e6 = [RaE6parts objectAtIndex:indexPath.row-1]; //(-1)前回
						evc.PiMinYearMMDD = [e6.e2invoice.nYearMMDD integerValue];	//前回の支払日以降
					} else {
						evc.PiMinYearMMDD = GiYearMMDD( Re3edit.dateUse );	//利用日以降
					}
					if (indexPath.row+1 < [RaE6parts count]) { // 次回あり
						E6part *e6 = [RaE6parts objectAtIndex:indexPath.row+1]; //(+1)次回
						evc.PiMaxYearMMDD = [e6.e2invoice.nYearMMDD integerValue];	//次回の支払日以前
					} else {
						evc.PiMaxYearMMDD = AzMAX_YearMMDD;	
					}
					evc.delegate = self;
#ifdef AzPAD
					//Popoverサイズが変わらないように、BottomBarを表示したままにする。
#else
					evc.hidesBottomBarWhenPushed = YES; // 現状PUSHして次の画面では非表示にする
#endif
					[self.navigationController pushViewController:evc animated:YES];
					[evc release];
				}
			}
			break;
	}
}


@end

