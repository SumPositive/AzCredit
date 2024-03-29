//
//  E4shopTVC.m
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"
#import "E4shopTVC.h"
#import "E4shopDetailTVC.h"
#import "E3recordTVC.h"

#define ACTIONSEET_TAG_DELETE_SHOP	199

@interface E4shopTVC ()
{
    E4shop              *sourceE4shop;
    NSMutableArray		*RaE4shops;
    NSString            *RzSearchText;		//[1.1.2]検索文字列を記録しておき、該当が無くて新しく追加する場合の初期値にする
    NSIndexPath         *MindexPathActionDelete; // 削除するIndexPath  	//[1.1.2]ポインタ代入注意！copyするように改善した。
    NSIndexPath*        MindexPathEdit;	//[1.1.2]ポインタ代入注意！copyするように改善した。
    UIBarButtonItem		*MbuTop;		// BarButton ＜hasChanges時に無効にするため＞
    NSInteger           MiOptE4SortMode;
    CGPoint             McontentOffsetDidSelect; // didSelect時のScrollView位置を記録
}
- (void)e4shopDatail:(NSIndexPath *)indexPath;
- (void)barButtonAdd;
- (void)requeryMe4shops:(NSString *)zSearch;
- (void)viewDesign;
@end

@implementation E4shopTVC


#pragma mark - Delegate

- (void)refreshTable
{
	if (MindexPathEdit && MindexPathEdit.row < [RaE4shops count]) {	// 日付に変更なく、行位置が有効ならば、修正行だけを再表示する
		NSArray* ar = [NSArray arrayWithObject:MindexPathEdit];
		[self.tableView reloadRowsAtIndexPaths:ar withRowAnimation:YES];
	} else {
		// Add または行位置不明のとき
		[self viewWillAppear:YES];
	}
}


#pragma mark - Action

//// UIActionSheetDelegate 処理部
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//	// buttonIndexは、actionSheetの上から順に(0〜)付与されるようだ。
//	if (actionSheet.tag == ACTIONSEET_TAG_DELETE_SHOP && buttonIndex == 0) {
//		//========== E4 削除実行 ==========
//		E4shop *e4objDelete = RaE4shops[MindexPathActionDelete.row];
//		
//		// E3は、削除せずに E4-E3 リンクを断つだけ
//		// E4-E3 リンクは、以下のE4削除すれば全てnilされる
//		// E4shop 削除
//		[RaE4shops removeObjectAtIndex:MindexPathActionDelete.row];
//		[self.Re0root.managedObjectContext deleteObject:e4objDelete];
//		// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する
//		[MocFunctions commit];
//		[self.tableView reloadData];
//	}
//}

- (void)barButtonTop {
	[self.navigationController popToRootViewControllerAnimated:YES];	// 最上層(RootView)へ戻る
}

- (void)barButtonAdd {
	// Add Shop
	[self e4shopDatail:nil]; //Add mode
}

- (void)barButtonUntitled {
	// 未定(nil)にする
	self.Pe3edit.e4shop = nil;
//#ifdef xxxAzPAD
//	if (selfPopover) {
//		if ([delegate respondsToSelector:@selector(viewWillAppear:)]) {	// メソッドの存在を確認する
//			[delegate viewWillAppear:YES];// 再描画
//		}
//		[selfPopover dismissPopoverAnimated:YES];
//	}
//#else
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
//#endif
}

- (void)barSegmentSort:(id)sender {
	MiOptE4SortMode = [sender selectedSegmentIndex];
	// ソート条件を保存する　＜＜切り替えの都度、保存していたが[0.4]にてフリーズ症状発生＞＞
	//[[NSUserDefaults standardUserDefaults] setInteger:MiOptE4SortMode forKey:GD_OptE4SortMode];
	// Requery
	[self requeryMe4shops:nil];
}

- (void)e4shopDatail:(NSIndexPath *)indexPath	//(NSInteger)iE4index
{
	E4shopDetailTVC *e4detail = [[E4shopDetailTVC alloc] init]; // popViewで戻れば解放されているため、毎回alloc必要。
	
	if (indexPath == nil) {	// Add
		e4detail.title = NSLocalizedString(@"Add Shop",nil);
		// ContextにE4ノードを追加する　E4edit内でCANCELならば DELETE している
		e4detail.Re4edit = [NSEntityDescription insertNewObjectForEntityForName:@"E4shop"
														 inManagedObjectContext:self.Re0root.managedObjectContext];
		e4detail.PbAdd = YES;
		e4detail.Pe3edit = self.Pe3edit; // 新規追加後、一気にE3まで戻るため

		if (RzSearchText) {	//[1.1.2]検索文字列を記録しておき、該当が無くて新しく追加する場合の初期値にする
			e4detail.Re4edit.zName = RzSearchText;
			e4detail.Re4edit.sortName = RzSearchText;
		}

        if (IS_PAD) {
            indexPath = [NSIndexPath indexPathForRow:[RaE4shops count] inSection:0];	//Add行、回転時にPopoverの矢印位置のため
        }
	}
	else if (RaE4shops.count <= indexPath.row) {
		return; // Add行以降、パスする
	}
	else {
		e4detail.title = NSLocalizedString(@"Edit Shop",nil);
		e4detail.Re4edit = RaE4shops[indexPath.row]; //[MfetchE1card objectAtIndexPath:indexPath];
		e4detail.PbAdd = NO;
		//e4detail.Pe3edit = nil;
	}
	
	if (self.Pe3edit) {
		e4detail.PbSave = NO;	// 呼び出し元：右上ボタン「完了」　E3recordDetailTVC側のsave:により保存
	} else {
		e4detail.PbSave = YES;	// マスタモード：右上ボタン「保存」
	}
	
    if (IS_PAD) {
        if (self.Pe3edit) { // 選択モード
            e4detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
            [self.navigationController pushViewController:e4detail animated:YES];
        } else {
            AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            apd.entityModified = e4detail.PbAdd;
            
            //MindexPathEdit = indexPath;
            MindexPathEdit = [indexPath copy];
            
            UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:e4detail];
            e4detail.delegate = self;		// refreshTable callback
            nc.modalPresentationStyle = UIModalPresentationFormSheet; // iPad画面1/4サイズ
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nc animated:YES completion:nil];
        }
    }else{
        // 呼び出し側(親)にてツールバーを常に非表示にする
        e4detail.hidesBottomBarWhenPushed = YES; // 現在のToolBar状態をPushした上で、次画面では非表示にする
        [self.navigationController pushViewController:e4detail animated:YES];
    }
	 // self.navigationControllerがOwnerになる
}

//#ifdef AzPAD
- (void)cancelClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}
//#endif


#pragma mark - View lifecicle


// UITableViewインスタンス生成時のイニシャライザ　viewDidLoadより先に1度だけ通る
- (instancetype)initWithStyle:(UITableViewStyle)style 
{
	self = [super initWithStyle:UITableViewStylePlain]; // セクションなしテーブル
	if (self) {
		// 初期化成功
//        if (IS_PAD) {
//            self.preferredContentSize = GD_POPOVER_SIZE;
//        }
	}
	return self;
}


// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
//【Tips】ここでaddSubviewするオブジェクトは全てautoreleaseにすること。メモリ不足時には自動的に解放後、改めてここを通るので、初回同様に生成するだけ。
- (void)loadView
{
    [super loadView];
	
    if (IS_PAD) {
        self.navigationItem.hidesBackButton = YES;
        // Set up NEXT Left Back [<] buttons.
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithImage:[UIImage imageNamed:@"R16_Back1"]
                                                  style:UIBarButtonItemStylePlain  target:nil  action:nil];
    }else{
        // Set up NEXT Left Back [<<] buttons.
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithImage:[UIImage imageNamed:@"R16_Back2"]
                                                 style:UIBarButtonItemStylePlain  target:nil  action:nil];
    }

	if (self.Pe3edit == nil) {
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		self.tableView.allowsSelectionDuringEditing = YES; // 編集モードに入ってる間にユーザがセルを選択できる
	}
	
	// Search Bar
	UISearchBar *searchBar = [[UISearchBar alloc] init];
	searchBar.frame = CGRectMake(0,0, self.tableView.bounds.size.width,0);
	searchBar.showsCancelButton = YES;
	searchBar.delegate = self;
	[searchBar sizeToFit];
	self.tableView.tableHeaderView = searchBar;
	
	// Search segmented
	NSArray *aItems = @[NSLocalizedString(@"Sort Recent",nil),
					   NSLocalizedString(@"Sort Views",nil),
					   NSLocalizedString(@"Sort Amount",nil),
					   NSLocalizedString(@"Sort Index",nil)]; // autorelease
	UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:aItems];
	segment.frame = CGRectMake(0,0, 220,30);
	//segment.segmentedControlStyle = UISegmentedControlStyleBar;
	MiOptE4SortMode = 0; //[[NSUserDefaults standardUserDefaults] integerForKey:GD_OptE4SortMode];
	segment.selectedSegmentIndex = MiOptE4SortMode;
	// .selectedSegmentIndex 代入より後に addTarget:指定すること。 逆になると代入によりaction:コールされてしまう。
	[segment addTarget:self action:@selector(barSegmentSort:) forControlEvents:UIControlEventValueChanged];
	UIBarButtonItem *buSort = [[UIBarButtonItem alloc] initWithCustomView:segment];
	//[segment release];
	
	// Tool Bar Button
	UIBarButtonItem *buFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			 target:nil action:nil];
	UIBarButtonItem *buAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																			target:self action:@selector(barButtonAdd)];
	if (self.Pe3edit) {
		MbuTop = nil;
		UIBarButtonItem *buUntitled = [[UIBarButtonItem alloc] 
									   initWithTitle:NSLocalizedString(@"Untitled",nil)
									   style:UIBarButtonItemStylePlain
										target:self action:@selector(barButtonUntitled)];
		NSArray *buArray = @[buUntitled, buFlex, buSort, buFlex, buAdd];
		[self setToolbarItems:buArray animated:YES];
		//[buUntitled release];
	}
	else {
        if (IS_PAD) {
            NSArray *buArray = [NSArray arrayWithObjects: buFlex, buSort, buFlex, buAdd, nil];
            [self setToolbarItems:buArray animated:YES];
        }else{
            MbuTop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Icon32-Top.png"]
                                                      style:UIBarButtonItemStylePlain  //Bordered
                                                     target:self action:@selector(barButtonTop)];
            NSArray *buArray = @[MbuTop, buFlex, buSort, buFlex, buAdd];
            [self setToolbarItems:buArray animated:YES];
        }
	}
	// ToolBar表示は、viewWillAppearにて回転方向により制御している。
}


- (void)requeryMe4shops:(NSString *)zSearch 
{	// Me4shops Requery. 

	// Where
	NSPredicate *predicate = nil;
	if (zSearch && 0 < zSearch.length) {  // NSPredicateを使って、検索条件式を設定する
		// [c]大文字・小文字の区別なし(case-insensitive)
		predicate = [NSPredicate predicateWithFormat:
					 @"(sortName contains[c] %@) OR (zName contains[c] %@)", zSearch, zSearch];
	}
	
	// Sorting
	NSString *zKey;
	BOOL bAsc;
	switch (MiOptE4SortMode) {
		case 1:  zKey = @"sortCount";	bAsc = NO;	break; // 回数
		case 2:  zKey = @"sortAmount";	bAsc = NO;	break; // 金額
		case 3:  zKey = @"sortName";	bAsc = YES;	break; // かな　＜＜入力が面倒で使われない可能性が高いと思うから優先度を下げた＞＞
		default: zKey = @"sortDate";	bAsc = NO;	break; // 最近
	}
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:zKey ascending:bAsc];
	NSArray *sortArray = @[sort1];
	
	NSArray *arFetch = [MocFunctions select:@"E4shop" 
										limit:0
									   offset:0
										where:predicate
										 sort:sortArray];
	//
	if (RaE4shops) {
		RaE4shops = nil;
	}
	RaE4shops = [[NSMutableArray alloc] initWithArray:arFetch];
	// 
	[self viewDesign];
	[self.tableView reloadData];
}

- (void)viewDesign
{
	// 回転によるリサイズ
	// SerchBar
	self.tableView.tableHeaderView.frame = CGRectMake(0,0, self.tableView.bounds.size.width,0);
	[self.tableView.tableHeaderView sizeToFit];
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	//[0.4]以降、ヨコでもツールバーを表示するようにした。
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示
	
	// 画面表示に関係する Option Setting を取得する
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	
	if (MbuTop) {
		// hasChanges時にTop戻りボタンを無効にする
		MbuTop.enabled = !(self.Re0root.managedObjectContext).hasChanges; // YES:contextに変更あり
	}
	
	// Requery
	[self requeryMe4shops:nil];
	
	if (0 < McontentOffsetDidSelect.y) {
		// app.Me3dateUse=nil のときや、メモリ不足発生時に元の位置に戻すための処理。
		// McontentOffsetDidSelect は、didSelectRowAtIndexPath にて記録している。
		self.tableView.contentOffset = McontentOffsetDidSelect;
	}

	if (self.Pe3edit) {
		sourceE4shop = self.Pe3edit.e4shop;		//初期値
	} else {
		sourceE4shop = nil;
	}
}

// ビューが最後まで描画された後やアニメーションが終了した後にこの処理が呼ばれる
- (void)viewDidAppear:(BOOL)animated
{
    if (IS_PAD) {
        // viewWillAppear:に入れると再描画時に通ってBarが乱れるため、ここにした。 loadViewに入れると配下から戻ったときダメ
        // SplitViewタテのとき [Menu] button を表示する
        if (self.Pe3edit==nil) { // マスタモードのとき、だけ[Menu]ボタン表示
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if (app.barMenu) {
                UIBarButtonItem* buFlexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                UIBarButtonItem* buTitle = [[UIBarButtonItem alloc] initWithTitle: self.title  style:UIBarButtonItemStylePlain target:nil action:nil];
                NSMutableArray* items = [[NSMutableArray alloc] initWithObjects: app.barMenu, buFlexible, buTitle, buFlexible, nil];
                UIToolbar* toolBar = [[UIToolbar alloc] init];
                toolBar.barStyle = UIBarStyleDefault;
                [toolBar setItems:items animated:NO];
                [toolBar sizeToFit];
                self.navigationItem.titleView = toolBar;
                //[items release];
            }
        } else {
            // CANCELボタンを左側に追加する  Navi標準の戻るボタンでは cancelClose:処理ができないため
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                      initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self action:@selector(cancelClose:)];
        }
    }
    [super viewDidAppear:animated];
	[self.tableView flashScrollIndicators]; // Apple基準：スクロールバーを点滅させる
	
	if (self.Pe3edit == nil) {
		// Comback (-1)にして未選択状態にする
		//		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		// (0)TopMenu >> (1)This clear
		//		[appDelegate.RaComebackIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithLong:-1]];
	}
}

//#ifdef AzPAD
- (void)viewDidDisappear:(BOOL)animated
{
//	if ([Mpopover isPopoverVisible]) 
//	{	//[1.1.0]Popover(E4shopDetailTVC) あれば閉じる(Cancel) 　＜＜閉じなければ、アプリ終了⇒起動⇒パスワード画面にPopoverが現れてしまう。
//		[MocFunctions rollBack];	// 修正取り消し
//		[Mpopover dismissPopoverAnimated:NO];	//YES=だと残像が残る
//	}
    [super viewWillDisappear:animated];
}
//#endif


#pragma mark  View - Rotate

// 回転の許可　ここでは許可、禁止の判定だけする
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
    if (IS_PAD) {
        return YES;
    }else{
        // 回転禁止でも、正面は常に許可しておくこと。
        return  (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

// ユーザインタフェースの回転の最後の半分が始まる前にこの処理が呼ばれる　＜＜このタイミングで配置転換すると見栄え良い＞＞
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
													   duration:(NSTimeInterval)duration
{
	[self viewDesign];
}

//#ifdef AzPAD
// 回転した後に呼び出される
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//	if ([Mpopover isPopoverVisible]) {
//		// Popoverの位置を調整する　＜＜UIPopoverController の矢印が画面回転時にターゲットから外れてはならない＞＞
//		if (MindexPathEdit) { 
//			[self.tableView scrollToRowAtIndexPath:MindexPathEdit 
//								  atScrollPosition:UITableViewScrollPositionMiddle animated:NO]; // YESだと次の座標取得までにアニメーションが終了せずに反映されない
//			CGRect rc = [self.tableView rectForRowAtIndexPath:MindexPathEdit];
//			rc.origin.x = rc.size.width - 40;	rc.size.width = 10;
//			rc.origin.y += 10;	rc.size.height -= 20;
//			[Mpopover presentPopoverFromRect:rc  inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionRight  animated:YES]; //表示開始
//		} 
//		else {
//			// 回転後のアンカー位置が再現不可なので閉じる
//			[Mpopover dismissPopoverAnimated:YES];
//		}
//	}
}
//#endif


//#pragma mark  View - Unload - dealloc
//
//- (void)unloadRelease	// dealloc, viewDidUnload から呼び出される
//{
//	//【Tips】loadViewでautorelease＆addSubviewしたオブジェクトは全てself.viewと同時に解放されるので、ここでは解放前の停止処理だけする。
//	NSLog(@"--- unloadRelease --- E4shopTVC");
//	//【Tips】デリゲートなどで参照される可能性のあるデータなどは破棄してはいけない。
//	// 他オブジェクトからの参照無く、viewWillAppearにて生成されるので破棄可能
//	RaE4shops = nil;
//}
//
//- (void)dealloc    // 生成とは逆順に解放するのが好ましい
//{
//	[self unloadRelease];
//    if (IS_PAD) {
//        MindexPathEdit = nil;
//    }else{
//        RzSearchText = nil;
//        MindexPathActionDelete = nil;
//    }
//  //  [super dealloc];
//}
//
//// メモリ不足時に呼び出されるので不要メモリを解放する。 ただし、カレント画面は呼ばない。
//- (void)viewDidUnload 
//{
//	//NSLog(@"--- viewDidUnload ---"); 
//	// メモリ不足時、裏側にある場合に呼び出される。addSubviewされたOBJは、self.viewと同時に解放される
//	[self unloadRelease];
//	[super viewDidUnload];
//	// この後に loadView ⇒ viewDidLoad ⇒ viewWillAppear がコールされる
//}


#pragma mark - UISearchBar

// 検索バーへの文字入力の都度、呼び出される
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{
	// Requery
	[self requeryMe4shops:searchText];
	//[1.1.2]
	RzSearchText = [searchText copy];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	searchBar.text = @"";
	RzSearchText = nil;
	[searchBar resignFirstResponder]; // キーボードを非表示にする
}


#pragma mark - TableView lifecicle

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1; // 固定
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return RaE4shops.count + 1; // (+1)Add
}

/*
 // セルの高さを指示する
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if ([Me4shops count] <= indexPath.row) {
		return 30; // Add Record
	}
	return 44; // デフォルト：44ピクセル
}*/

#ifdef xxxxxxxxFREE_AD_PAD
// TableView セクションフッタを応答
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section 
{
	if (section==0) return @"\n\n\n\n\n\n\n\n\n\n\n\n\n\n";	// 大型AdMobスペースのための下部余白
	return nil;
}
#endif

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *zCellNode = @"CellNode";
	static NSString *zCellAdd = @"CellAdd";
    UITableViewCell *cell = nil;

	// 末尾([Me4shops count])はAdd行
	if (indexPath.row < RaE4shops.count) 
	{
		cell = [tableView dequeueReusableCellWithIdentifier:zCellNode];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] 
					 initWithStyle:UITableViewCellStyleValue1
					 reuseIdentifier:zCellNode];

            if (IS_PAD) {
                cell.textLabel.font = [UIFont systemFontOfSize:20];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
            }else{
                cell.textLabel.font = [UIFont systemFontOfSize:18];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
            }
			//cell.textLabel.textAlignment = NSTextAlignmentLeft;
			cell.textLabel.textColor = [UIColor blackColor];
			
			//cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
			cell.detailTextLabel.textColor = [UIColor blackColor];

			if (self.Pe3edit == nil) {
				cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton; // ディスクロージャボタン
				cell.showsReorderControl = NO; // MOVE
			}
		}
		
		E4shop *e4obj = RaE4shops[indexPath.row];
		
		if ((e4obj.zName).length <= 0) 
			cell.textLabel.text = NSLocalizedString(@"(Untitled)", nil);
		else
			cell.textLabel.text = e4obj.zName;
	} 
	else {
		// Add ボタンセル
		cell = [tableView dequeueReusableCellWithIdentifier:zCellAdd];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault      // Default型
										   reuseIdentifier:zCellAdd];
		}
        if (IS_PAD) {
            cell.textLabel.font = [UIFont systemFontOfSize:20];
        }else{
            cell.textLabel.font = [UIFont systemFontOfSize:14];
        }
		cell.textLabel.textAlignment = NSTextAlignmentCenter; // 中央寄せ
		cell.textLabel.textColor = [UIColor grayColor];
		cell.imageView.image = [UIImage imageNamed:@"Icon32-GreenPlus.png"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	// > ディスクロージャマーク
		cell.showsReorderControl = NO; // MOVE
		cell.textLabel.text = NSLocalizedString(@"Add Shop",nil);
	}
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// 末尾([Me4shops count])はAdd行
	if (indexPath.row < RaE4shops.count) return UITableViewCellEditingStyleDelete;
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 非選択状態に戻す
	
	// didSelect時のScrollView位置を記録する（viewWillAppearにて再現するため）
	McontentOffsetDidSelect = tableView.contentOffset;

	// 末尾([Me4shops count])はAdd行
	if (indexPath.row < RaE4shops.count) {
		if (self.Pe3edit) { // 選択モード
			self.Pe3edit.e4shop = RaE4shops[indexPath.row];
			if (sourceE4shop != self.Pe3edit.e4shop) {
				AppDelegate *apd = (AppDelegate *)[UIApplication sharedApplication].delegate;
				apd.entityModified = YES;	//変更あり
			}
			[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
		}
		else if (self.editing) {
			[self e4shopDatail:indexPath];
		} else {
			// E3records へ
			E3recordTVC *tvc = [[E3recordTVC alloc] init];
			E4shop *e4obj = RaE4shops[indexPath.row];
#ifdef AzDEBUGxxxxxxxxxxx
			tvc.title = [NSString stringWithFormat:@"E3 %@", e4obj.zName];
#else
			tvc.title =  e4obj.zName;
#endif
			tvc.Re0root = self.Re0root;
			//tvc.Pe1card = nil;  
			tvc.Pe4shop = e4obj;  // e4obj以下の全E3表示モード
			tvc.Pe5category = nil;
			[self.navigationController pushViewController:tvc animated:YES];
		}
	}
	else {
		// Add Plan
		[self e4shopDatail:nil]; //Add mode
	}
}

// ディスクロージャボタンが押されたときの処理
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self e4shopDatail:indexPath];
}

#pragma mark  TableView - Editting

// TableView Editモードの表示
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
    // この後、self.editing = YES になっている。
	// [self.tableView reloadData]だとアニメ効果が消される。　(OS 3.0 Function)を使って解決した。
//	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)]; // [0]セクションから1個
//	[self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade]; // (OS 3.0 Function)
}

// TableView Editモード処理
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
											forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		// 削除コマンド警告　==>> (void)actionSheet にて処理
		//MindexPathActionDelete = indexPath;
		MindexPathActionDelete = [indexPath copy];
//		// 削除コマンド警告
//		UIActionSheet *action = [[UIActionSheet alloc] 
//						 initWithTitle:NSLocalizedString(@"DELETE Shop", nil)
//						 delegate:self 
//						 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
//						 destructiveButtonTitle:NSLocalizedString(@"DELETE Shop button", nil)
//						 otherButtonTitles:nil];
//		action.tag = ACTIONSEET_TAG_DELETE_SHOP;
//		UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//		if (orientation == UIInterfaceOrientationPortrait
//			OR orientation == UIInterfaceOrientationPortraitUpsideDown){
//			// タテ：ToolBar表示
//			[action showFromToolbar:self.navigationController.toolbar]; // ToolBarがある場合
//		} else {
//			// ヨコ：ToolBar非表示（TabBarも無い）　＜＜ToolBar無しでshowFromToolbarするとFreeze＞＞
//			[action showInView:self.view]; //windowから出すと回転対応しない
//		}
        
        [AZAlert target:self
             actionRect:[tableView rectForRowAtIndexPath:indexPath]
                  title:NSLocalizedString(@"DELETE Shop", nil)
                message:nil
                b1title:NSLocalizedString(@"DELETE Shop button", nil)
                b1style:UIAlertActionStyleDestructive
               b1action:^(UIAlertAction * _Nullable action) {
                   //========== E4 削除実行 ==========
                   E4shop *e4objDelete = RaE4shops[MindexPathActionDelete.row];
                   
                   // E3は、削除せずに E4-E3 リンクを断つだけ
                   // E4-E3 リンクは、以下のE4削除すれば全てnilされる
                   // E4shop 削除
                   [RaE4shops removeObjectAtIndex:MindexPathActionDelete.row];
                   [self.Re0root.managedObjectContext deleteObject:e4objDelete];
                   // SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する
                   [MocFunctions commit];
                   [self.tableView reloadData];
               }
                b2title:NSLocalizedString(@"Cancel", nil)
                b2style:UIAlertActionStyleCancel
               b2action:nil];

	}
}

// Editモード時の行Edit可否　　 YESを返した行は、左にスペースが入って右寄りになる
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < RaE4shops.count) return YES;
	return NO;  // 最終行のAdd行は、右寄せさせない
}

/**** 行移動なしである。
// Editモード時の行移動の可否　　＜＜最終行のAdd専用行を移動禁止にしている＞＞
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// 末尾([Me4shops count])はAdd行
	if (indexPath.row < [Me4shops count]) return YES;
	return NO;  // 最終行のAdd行は移動禁止
}

// Editモード時の行移動「先」を返す　　＜＜最終行のAdd専用行への移動ならば1つ前の行を返している＞＞
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)oldPath 
															toProposedIndexPath:(NSIndexPath *)newPath {
    NSIndexPath *target = newPath;
	// 末尾([Me4shops count])はAdd行
	// セクション０限定仕様
	if ([Me4shops count] < 0) {
		return newPath;
	}
	else if ([Me4shops count] <= newPath.row) {
		// 末尾ならば末尾-1行目を返す
        target = [NSIndexPath indexPathForRow:[Me4shops count]-1 inSection:0];
	}
    return target;
}

// Editモード時の行移動処理　　＜＜CoreDataにつきArrayのように削除＆挿入ではダメ。ソート属性(row)を書き換えることにより並べ替えている＞＞
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)oldPath 
												  toIndexPath:(NSIndexPath *)newPath {
	// CoreDataは順序を保持しないため 属性"ascend"を昇順ソート表示している
	// この 属性"ascend"の値を行異動後に更新するための処理

	// Re4shop 更新 ==>> なんと、managedObjectContextも更新される。 ただし、削除や挿入は反映されない！！！
	E4shop *e4obj = [Me4shops objectAtIndex:oldPath.row]; //[MfetchE1card objectAtIndexPath:oldPath];

	[Me4shops removeObjectAtIndex:oldPath.row];
	[Me4shops insertObject:e4obj atIndex:newPath.row];
	
	NSInteger start = oldPath.row;
	NSInteger end = newPath.row;
	if (end < start) {
		start = newPath.row;
		end = oldPath.row;
	}
	for (NSInteger i = start; i <= end; i++) {
		e4obj = [Me4shops objectAtIndex:i];
		e4obj.nRow = [NSNumber numberWithInteger:i];
	}
	
	// SAVE　＜＜万一システム障害で落ちてもデータが残るようにコマメに保存する方針＞＞
	[MocFunctions commit];
}
*/


//#ifdef AzPAD
//#pragma mark - <UIPopoverControllerDelegate>
//- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
//{	// Popoverの外部をタップして閉じる前に通知
//	AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//	if (apd.entityModified) {	// 追加または変更あり
//		alertBox(NSLocalizedString(@"Cancel or Save",nil), NSLocalizedString(@"Cancel or Save msg",nil), NSLocalizedString(@"Roger",nil));
//		return NO; // Popover外部タッチで閉じるのを禁止 ＜＜追加MOCオブジェクトをＣａｎｃｅｌ時に削除する必要があるため＞＞
//	} else {	// 追加や変更なし
//		return YES;	// Popover外部タッチで閉じるのを許可
//	}
//}
//#endif


@end

