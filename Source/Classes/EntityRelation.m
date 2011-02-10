//
//  EntityRelation.m
//  AzCredit
//
//  Created by 松山 和正 on 10/03/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "EntityRelation.h"


@implementation EntityRelation
//@synthesize Re0root;

//- (void)dealloc {
//	[Re0root release];
//    [super dealloc];
//}


+ (void)commit
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	// SAVE
	NSError *err = nil;
	if (![appDelegate.managedObjectContext  save:&err]) {
		NSLog(@"MOC commit error %@, %@", err, [err userInfo]);
		//exit(-1);  // Fail
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MOC CommitErr",nil)
														message:NSLocalizedString(@"MOC CommitErrMsg",nil)
													   delegate:nil 
												cancelButtonTitle:nil 
												otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		return;
	}
}


+ (void)rollBack
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	// ROLLBACK
	[appDelegate.managedObjectContext rollback]; // 前回のSAVE以降を取り消す
}

+ (void)allReset
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *moc = appDelegate.managedObjectContext;

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSError *error;
	NSEntityDescription *entity;
	NSArray *arFetch;

	// E6削除　＜＜ E2,E3 より先に削除する
	entity = [NSEntityDescription entityForName:@"E6part" inManagedObjectContext:moc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [moc executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		[fetchRequest release];
		AzLOG(@"allReset E6 Error: %@, %@", error, [error userInfo]);
		return;
	}
	for (E6part *e6 in arFetch) {
#if AzDEBUG
		//if (!e6.e3record) AzLOG(@"allReset: E6.e3link Nothing");
		//if (!e6.e2invoice) AzLOG(@"allReset: E6.e2link Nothing");
		assert(e6.e3record);
		assert(e6.e2invoice);
#endif
		[moc deleteObject:e6]; // 削除
	}
	
	// E2削除
	entity = [NSEntityDescription entityForName:@"E2invoice" inManagedObjectContext:moc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [moc executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		[fetchRequest release];
		AzLOG(@"allReset E2 Error: %@, %@", error, [error userInfo]);
		return;
	}
	for (E2invoice *e2 in arFetch) {
#if AzDEBUG
		//if (!e2.e1paid && !e2.e1unpaid) AzLOG(@"allReset: E2.e1link Nothing");
		//if (!e2.e7payment) AzLOG(@"allReset: E2.e7link Nothing");
		assert(e2.e1paid OR e2.e1unpaid);
		assert(e2.e7payment);
#endif
		[moc deleteObject:e2]; // 削除
	}
	
	// E3削除
	entity = [NSEntityDescription entityForName:@"E3record" inManagedObjectContext:moc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [moc executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		[fetchRequest release];
		AzLOG(@"allReset E3 Error: %@, %@", error, [error userInfo]);
		return;
	}
	for (E3record *e3 in arFetch) {
#if AzDEBUG
		//if (!e3.e1card) AzLOG(@"allReset: E3.e1link Nothing");
		assert(e3.e1card);
#endif
		[moc deleteObject:e3]; // 削除
	}
	
	// E1削除　＜＜ E2,E3 から参照されているので、それらの後に削除すること
	entity = [NSEntityDescription entityForName:@"E1card" inManagedObjectContext:moc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [moc executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		[fetchRequest release];
		AzLOG(@"allReset E1 Error: %@, %@", error, [error userInfo]);
		return;
	}
	for (E1card *e1 in arFetch) {
#if AzDEBUG
		// E2を先に削除しているから、逆に残っていたらバグ
		//if (0 < [e1.e2paids count]) AzLOG(@"allReset: E1.e2paids NoClear");
		//if (0 < [e1.e2unpaids count]) AzLOG(@"allReset: E1.e2unpaids NoClear");
		assert([e1.e2paids count]==0);
		assert([e1.e2unpaids count]==0);
#endif
		[moc deleteObject:e1]; // 削除
	}
	
	// E4削除
	entity = [NSEntityDescription entityForName:@"E4shop" inManagedObjectContext:moc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [moc executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		[fetchRequest release];
		AzLOG(@"allReset E4 Error: %@, %@", error, [error userInfo]);
		return;
	}
	for (E4shop *e4 in arFetch) {
		[moc deleteObject:e4]; // 削除
	}
	
	// E5削除
	entity = [NSEntityDescription entityForName:@"E5category" inManagedObjectContext:moc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [moc executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		[fetchRequest release];
		AzLOG(@"allReset E5 Error: %@, %@", error, [error userInfo]);
		return;
	}
	for (E5category *e5 in arFetch) {
		[moc deleteObject:e5]; // 削除
	}
	
	// E8削除
	entity = [NSEntityDescription entityForName:@"E8bank" inManagedObjectContext:moc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [moc executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		[fetchRequest release];
		AzLOG(@"allReset E4 Error: %@, %@", error, [error userInfo]);
		return;
	}
	for (E8bank *e8 in arFetch) {
		[moc deleteObject:e8]; // 削除
	}

	// E7削除
	entity = [NSEntityDescription entityForName:@"E7payment" inManagedObjectContext:moc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [moc executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		[fetchRequest release];
		AzLOG(@"allReset E7 Error: %@, %@", error, [error userInfo]);
		return;
	}
	for (E7payment *e7 in arFetch) {
#if AzDEBUG
		//if (!e7.e0paid && !e7.e0unpaid) AzLOG(@"allReset: E7.e0link Nothing");
		assert(e7.e0paid OR e7.e0unpaid);
#endif
		[moc deleteObject:e7]; // 削除
	}
	
#if AzDEBUG
	// E0root
	entity = [NSEntityDescription entityForName:@"E0root" inManagedObjectContext:moc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [moc executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		[fetchRequest release];
		AzLOG(@"allReset E0 Error: %@, %@", error, [error userInfo]);
		return;
	}
	if ([arFetch count] == 1) {
		E0root *e0 = [arFetch objectAtIndex:0]; // 未払い計を表示するためTopMenuTVCへ渡す
		if (0 < [e0.e7paids count]) AzLOG(@"allReset: E0.e7paids NoClear");
		if (0 < [e0.e7unpaids count]) AzLOG(@"allReset: E0.e7unpaids NoClear");
	} else {
		[fetchRequest release];
		AzLOG(@"LOGIC ERR: E0root Nothing");
		assert(NO);
	}
#endif

	[fetchRequest release];
}


// E0（固有ノード）を取得する
+ (E0root *)e0root
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	E0root *e0root = nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"E0root" 
											  inManagedObjectContext:appDelegate.managedObjectContext];
	//上記の最初の self.managedObjectContextメソッド呼び出しにてCoreData初期化される
	[fetchRequest setEntity:entity];
	// Fitch
	NSError *error = nil;
	NSArray *arFetch = [appDelegate.managedObjectContext
						executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		[fetchRequest release];
		AzLOG(@"Error: %@, %@", error, [error userInfo]);
		return nil;
	}
	[fetchRequest release];
	if ([arFetch count] == 1) {
		e0root = [arFetch objectAtIndex:0]; // 未払い計を表示するためTopMenuTVCへ渡す
	}
	if (e0root == nil) {
		AzLOG(@"LOGIC ERR: E0root Nothing");
	}
	return e0root;
	
}

// E1card DELETE  ＜＜PAIDも全て削除する＞＞  ＜＜注意！呼び出し側で E1.nRow の更新を行うこと＞＞
+ (void)e1delete:(E1card *)e1obj
{
	if (e1obj==nil) return;
	NSManagedObjectContext *moc = e1obj.managedObjectContext;
	//------------------------------------------------------- E1配下E3
	NSArray *aE3s = [[NSArray alloc] initWithArray:[e1obj.e3records allObjects]]; // 削除必須パターン
	for (E3record *e3 in aE3s)
	{
		// E3以下削除　　関連するE6,E2,さらに配下のE2が無くなったE7も削除される
		[EntityRelation e3delete:e3];
	}
	[aE3s release];
	
	// E1削除
	[moc deleteObject:e1obj]; // 削除
	// この後、呼び出し元にて、削除行以下の E1.nRow 更新が必要！
}

// e1card配下で支払日がiYearMMDDであるE2を検索または無ければ追加して返す
+ (E2invoice *)e2invoice:(E1card *)e1card inYearMMDD:(NSInteger)iYearMMDD
{
	if (iYearMMDD < AzMIN_YearMMDD OR AzMAX_YearMMDD < iYearMMDD) return nil;
	if (e1card==nil) return nil;
	NSManagedObjectContext *moc = e1card.managedObjectContext;

	for (E2invoice *e2 in e1card.e2paids) {
		if ([e2.nYearMMDD integerValue] == iYearMMDD) {
			return e2; // PAIDにあり
		}
	}
	for (E2invoice *e2 in e1card.e2unpaids) {
		if ([e2.nYearMMDD integerValue] == iYearMMDD) {
			return e2; // UNpaidにあり
		}
	}

	// E2なし、E2追加　　　以下、E2配下のE6は無いのでE2,E7のsum更新は不要
	E2invoice *e2new = [NSEntityDescription insertNewObjectForEntityForName:@"E2invoice" inManagedObjectContext:moc];
	e2new.nYearMMDD = [NSNumber numberWithLong:iYearMMDD]; // 支払日 ＜＜締月日と違う＞＞
	e2new.e1paid = nil;
	e2new.e1unpaid = e1card;	// E2 <<--> E1 未払い

	// E7 Unpaid 検索
	E0root *e0root = [EntityRelation e0root];
	if (e0root == nil) return NO;
	for (E7payment *e7 in e0root.e7unpaids) {
		if ([e7.nYearMMDD integerValue] == iYearMMDD) {
			e2new.e7payment = e7;
			return e2new; // 決定
		}
	}
	// E7なし、E7 Unpaid 追加
	E7payment *e7new = [NSEntityDescription insertNewObjectForEntityForName:@"E7payment" inManagedObjectContext:moc];
	e7new.nYearMMDD = [NSNumber numberWithLong:iYearMMDD]; // 支払日
	e7new.e0paid = nil;
	e7new.e0unpaid = e0root;
	//
	e2new.e7payment = e7new;
	return e2new;
}

// e2objを削除する。ただし、配下のE6が無い場合、あれば中止。
+ (void)e2delete:(E2invoice *)e2obj
{
	if (e2obj==nil) return;
	if (0 < [e2obj.e6parts count]) {
		AzLOG(@"LOGIC ERROR: e2delete: 配下あり");
		return;		// E2配下、あるので中止
	}
	
	NSManagedObjectContext *moc = e2obj.managedObjectContext;
	E7payment *e7obj = e2obj.e7payment; // E7保持
	// E2削除
	e2obj.e1paid = nil;
	e2obj.e1unpaid = nil;
	e2obj.e7payment = nil;
	[moc deleteObject:e2obj]; // 削除
	e2obj = nil;
	// E7
	if (0 < [e7obj.e2invoices count]) {
		// E2が減ったので E7 sum
		e7obj.sumAmount = [e7obj valueForKeyPath:@"e2invoices.@sum.sumAmount"];
		e7obj.sumNoCheck = [e7obj valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
	} else {
		// E2削除した結果、e7obj配下が無くなったので削除する
		e7obj.e0paid = nil;
		e7obj.e0unpaid = nil;
		[moc deleteObject:e7obj]; // 削除
		e7obj = nil;
	}
}

// カード(Pe1card)と利用日(PtUse)から支払日を求める
static NSInteger MiYearMMDDpayment( E1card *Pe1card, NSDate *PtUse )
{
	NSInteger iClosingDay = [Pe1card.nClosingDay integerValue];
	NSInteger iPayMonth = [Pe1card.nPayMonth integerValue]; // 支払月（0=当月、1=翌月、2=翌々月）
	NSInteger iPayDay = [Pe1card.nPayDay integerValue];

	if (iClosingDay<=0 OR iPayMonth<0 OR iPayDay<=0) {
		// Debit
		return GiYearMMDD( PtUse );  // Debut: 支払日＝利用日
	}
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *compUse = [cal components:unitFlags fromDate:PtUse]; // 利用日
	// 支払日
	NSInteger iYearMMDD = [compUse year] * 10000 + [compUse month] * 100 + iPayDay;
	// 利用日が締日以降ならば翌月（支払月+1）になる
	if (iClosingDay <= 28 && iClosingDay < [compUse day]) {
		// 当月の締め切りを過ぎているので（支払月+1）
		iPayMonth++;
	}
	//[compUse release]; autorelease
	// 支払月へ移動
	iYearMMDD = GiAddYearMMDD(iYearMMDD, 0, iPayMonth, 0);	// これが支払日である
	return iYearMMDD;
}


// E1card UPDATE　締め支払条件の変更に対応  ＜＜PAID済の E6,E2,E7 は変更しない＞＞
+ (void)e1update:(E1card *)e1obj
{
	if (e1obj==nil) return;
	//NSManagedObjectContext *moc = e1obj.managedObjectContext;

	// 締め支払が変更された場合、Paid分は不変、Unpaid分を全て変更する
	for (E3record *e3 in e1obj.e3records) {
		// カード(e1obj)と利用日(e3.dateUse)から支払日を求める
		NSInteger iYearMMDD = MiYearMMDDpayment(e1obj, e3.dateUse);
		// E3配下のE6を取得
		//NSMutableArray *muE6 = [NSMutableArray arrayWithArray:[e3.e6parts allObjects]];
		NSMutableArray *muE6 = [[NSMutableArray alloc] initWithArray:[e3.e6parts allObjects]];
		if (1 < [muE6 count]) {
			// 2分割以上あるのでソートする
			NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"nPartNo" ascending:YES];
			NSArray *sortArray = [[NSArray alloc] initWithObjects:sort1,nil];
			[muE6 sortUsingDescriptors:sortArray];
			[sortArray release];
			[sort1 release];
		}
		for (E6part *e6 in muE6) {
			if (e6.e2invoice.e1unpaid) { // Unpaidならば変更
				if ([e6.e2invoice.e7payment.nYearMMDD integerValue] == iYearMMDD) break; // 変更なし
				// 支払日が iYearMMDD に変更された
				// E2.unpaid にあるか
				E2invoice *e2old = e6.e2invoice; // 移動元のE2 sum のため
#ifdef AzDEBUG
				//if (e2old==nil) AzLOG(@"LOGIC ERR: e1update: e2old nil");
				//if (e2old.e1unpaid==nil) AzLOG(@"LOGIC ERR: e1update: e2old.e1unpaid nil");
				assert(e2old);
				assert(e2old.e1unpaid);
#endif
				// e1obj配下にあるiYearMMDDのE2を取得する（無ければE7まで生成）
				E2invoice *e2new = [EntityRelation e2invoice:e1obj inYearMMDD:iYearMMDD];
				if (e2new==nil OR e2new.e7payment.e0paid) {
					AzLOG(@"LOGIC ERR: e1update: e2new NG");
					[muE6 release];
					return;
				}
				// E2 old -->> new リンク変更
				e6.e2invoice = e2new;
				// E2 new sum
				e2new.sumAmount = [e2new valueForKeyPath:@"e6parts.@sum.nAmount"];
				e2new.sumNoCheck = [e2new valueForKeyPath:@"e6parts.@sum.nNoCheck"];
				// E7 new sum
				E7payment *e7new = e2new.e7payment;
				e7new.sumAmount = [e7new valueForKeyPath:@"e2invoices.@sum.sumAmount"];
				e7new.sumNoCheck = [e7new valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
				// E2,E7 old sum
				if (0 < [e2old.e6parts count]) {
					// E2 old sum
					e2old.sumAmount = [e2old valueForKeyPath:@"e6parts.@sum.nAmount"];
					e2old.sumNoCheck = [e2old valueForKeyPath:@"e6parts.@sum.nNoCheck"];
					// E7 new sum
					E7payment *e7old = e2old.e7payment;
					e7old.sumAmount = [e7old valueForKeyPath:@"e2invoices.@sum.sumAmount"];
					e7old.sumNoCheck = [e7old valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
				} else {
					// e2old 配下が無くなったので削除する
					[EntityRelation e2delete:e2old]; // E2削除＆E7sumまたは配下が無くなればE7削除
				}
			} // if (e6.e2invoice.e1unpaid)
			// 次のE6のため
			if (0 < [e1obj.nPayDay integerValue]) {	// <=0:Debitならば同じ利用日
				iYearMMDD = GiAddYearMMDD(iYearMMDD, 0, +1, 0);	// 翌月へ
			}
		} // e6
		[muE6 release];
	} // e3
}

// E3record DELETE  ＜＜PAIDも全て削除する＞＞
+ (void)e3delete:(E3record *)e3obj
{
	if (e3obj==nil) return;
	
	NSManagedObjectContext *moc = e3obj.managedObjectContext;
	// E3 以下削除
	// e3obj.e6parts 配下が削除されても配列位置がズレないようにコピー配列を用いる
	//NSArray *arrayE6 = [NSArray arrayWithArray:[e3obj.e6parts allObjects]];  できるだけautoreleaseを使わないようにする
	NSArray *arrayE6 = [[NSArray alloc] initWithArray:[e3obj.e6parts allObjects]];
	for (E6part *e6 in arrayE6) {
		E2invoice *e2 = e6.e2invoice;
		E7payment *e7 = nil;
		if (e2) {
			e7 = e2.e7payment; // 次でe2が削除される場合があるので先にe7保持する
			/***************************************************[0.3]ここではE2削除しない。
			 E8からE1別E2一覧表示するときの処理が難しくなるので削除しないことにした。
			 配下のE6が無くなったE2さらにE7は、e7e2clean により適時削除するようにした。
			 **************************************************************
			 if ([e2.e6parts count] <= 1) {
				// E2配下のE6が自身だけなのでE2を削除する
				e2.e1paid = nil;
				e2.e1unpaid = nil;
				e2.e7payment = nil;
				[moc deleteObject:e2];
				e2 = nil;
			 } else {
				// E2配下から切り離す（まだここではE6削除しない）
				e6.e2invoice = nil; // 切断してからsum
				// E2 sum
				e2.sumAmount = [e2 valueForKeyPath:@"e6parts.@sum.nAmount"];
				e2.sumNoCheck = [e2 valueForKeyPath:@"e6parts.@sum.nNoCheck"];
			 }
			 ***************************************************/
			// E2配下から切り離す（まだここではE6削除しない）
			e6.e2invoice = nil; // 切断してからsum
			// E2 sum
			e2.sumAmount = [e2 valueForKeyPath:@"e6parts.@sum.nAmount"];
			e2.sumNoCheck = [e2 valueForKeyPath:@"e6parts.@sum.nNoCheck"];

			if (e7) {
				// E6 が属する E7 配下のE2数を調べる
				if ([e7.e2invoices count] <= 0) {
					// E7配下のE2が先の削除により無くなったのでE7削除する
					e7.e0paid = nil;
					e7.e0unpaid = nil;
					[moc deleteObject:e7];
					e7 = nil; // 次の集計をスルーするため
				}
				else {	// E7 sum  [0.3]
					e7.sumAmount = [e7 valueForKeyPath:@"e2invoices.@sum.sumAmount"];
					e7.sumNoCheck = [e7 valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
				}
			}
		}
		// E6 削除
		e6.e2invoice = nil;
		e6.e3record = nil;
		[moc deleteObject:e6];
		e6 = nil;
	}
	[arrayE6 release];
	
	// E3 削除
	E4shop *e4 = e3obj.e4shop;
	E5category *e5 = e3obj.e5category;
	e3obj.e1card = nil;
	e3obj.e4shop = nil;
	e3obj.e5category = nil;
	[moc deleteObject:e3obj];
	e3obj = nil;
	// e4 sum
	e4.sortAmount = [e4 valueForKeyPath:@"e3records.@sum.nAmount"];
	e4.sortCount =  [e4 valueForKeyPath:@"e3records.@count"];
	// e5 sum
	e5.sortAmount = [e5 valueForKeyPath:@"e3records.@sum.nAmount"];
	e5.sortCount =  [e5 valueForKeyPath:@"e3records.@count"];
}

// E3配下のE6(unpaid)をE1,E3の支払条件に合わせて再生成する
// E6に1つでもPAIDがあれば拒否returnする
+ (BOOL)e3makeE6:(E3record *)e3obj inFirstYearMMDD:(NSInteger)iFirstYearMMDD
{
	if (e3obj == nil) return NO;
	if (e3obj.e1card == nil) return YES; // クイック追加時、カード(未定)許可のため　
										 // クイック追加時、＜この時点で配下のE6は無い。また、E6が追加された後に.e1card==nilになることは無い＞
	// 締め支払条件に変化があったか調べる
	NSInteger iYearMMDD = iFirstYearMMDD; // 支払日
	if (iFirstYearMMDD < AzMIN_YearMMDD) {
		// カード(e3obj.e1card)と利用日(e3obj.dateUse)から支払日を求める
		iYearMMDD = MiYearMMDDpayment(e3obj.e1card, e3obj.dateUse);
	}
	
	//------------------------------------------------- 旧E6の第1回目の支払日と比較して異なれば再生する
	BOOL bE6remake = NO; // E6,E2,E7に関わる変化なし、再生成しない。 E6のチェック状態が保存される
	NSInteger iPayType = [e3obj.nPayType integerValue];
	if (99 < iPayType) iPayType -= 100; // Bonus対応
	if (iPayType != [e3obj.e6parts count]) {
		// 分割回数が変化した
		bE6remake = YES; // 旧E6削除してから新E6生成する。　E6のチェックは解除される
	}
	else {
		NSInteger iAmount = 0;
		for (E6part *e6 in e3obj.e6parts) {
			iAmount += [e6.nAmount integerValue];
			if ([e6.nPartNo integerValue] == 1) {
				if (iYearMMDD != [e6.e2invoice.nYearMMDD integerValue]) {
					// 第1回目の支払日が変化した
					bE6remake = YES; // 旧E6削除してから新E6生成する。　E6のチェックは解除される
					break;
				}
				if (e6.e2invoice.e1unpaid != e3obj.e1card) {
					// カードが変わった
					bE6remake = YES; // 旧E6削除してから新E6生成する。　E6のチェックは解除される
					break;
				}
			}
		}
		if (!bE6remake && iAmount != [e3obj.nAmount integerValue]) {
			// 金額が変わった
			bE6remake = YES; // 旧E6削除してから新E6生成する。　E6のチェックは解除される
		}
	}
	
	NSManagedObjectContext *moc = e3obj.managedObjectContext;

	if (bE6remake) {
		//------------------------------------------------------------E6 PAIDあれば拒否
		for (E6part *e6 in e3obj.e6parts) {
			if (e6.e2invoice.e1paid OR e6.e2invoice.e7payment.e0paid) {
				// PAIDあり、処理拒否
				if (e6.e2invoice.e1unpaid OR e6.e2invoice.e7payment.e0unpaid) {
					AzLOG(@"LOGIC ERR: E2,E7のpaid/unpaidが不一致");
				}
				return NO; 
			}
		}
		//-------------------------------------------------e0root（固有ノード）を取得する　E7追加に必要となる
		E0root *e0root = [EntityRelation e0root];
		if (e0root == nil) return NO;
		
		//------------------------------------------------------------E6 削除
		// e3obj.e6parts 配下が削除されても配列位置がズレないようにコピー配列を用いる
		//NSArray *arrayE6 = [NSArray arrayWithArray:[e3obj.e6parts allObjects]]; 
		NSArray *arrayE6 = [[NSArray alloc] initWithArray:[e3obj.e6parts allObjects]]; 
		for (E6part *e6 in arrayE6) {
			// E6 削除
			E2invoice *e2 = e6.e2invoice; // 後のsumのため親E2を保存
			E7payment *e7 = e2.e7payment;
			e6.e2invoice = nil; // E6 <<--> E2 リンク削除：これが無いと後のsumで残骸が集計されてしまう。
			e6.e3record = nil;  // E6 <<--> E3 リンク削除：これが無いと "LOGIC ERROR: E6 Delete NG" が出る
			[moc deleteObject:e6];	// E6削除
			// E2
			if (0 < [e2.e6parts count]) { // E2 sum
				e2.sumAmount = [e2 valueForKeyPath:@"e6parts.@sum.nAmount"];
				e2.sumNoCheck = [e2 valueForKeyPath:@"e6parts.@sum.nNoCheck"];
			} else {
				// E2配下のE6なし
				e2.e1paid = nil;
				e2.e1unpaid = nil;
				e2.e7payment = nil;
				[moc deleteObject:e2];	// E2削除
			}
			// E7
			if (0 < [e7.e2invoices count]) { // E7 sum
				e7.sumAmount = [e7 valueForKeyPath:@"e2invoices.@sum.sumAmount"];
				e7.sumNoCheck = [e7 valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
			} else {
				// E7配下のE2なし
				e7.e0paid = nil;
				e7.e0unpaid = nil;
				[moc deleteObject:e7];	// E7削除
			}
		}
		[arrayE6 release];
		
		//------------------------------------------------------------E6 新規追加
		
		// E6追加　　E2,E7が無ければ追加する
		NSInteger iPayType = [e3obj.nPayType integerValue];
		if (iPayType < 100) {
			NSInteger iAmountZan = [e3obj.nAmount integerValue];
			NSInteger iAmountOne = iAmountZan / iPayType;
			NSInteger iAmountFirst = iAmountZan - (iAmountOne * iPayType);  // 初回に加える誤差金額
			// 分割1〜99回まで対応
			for (NSInteger iPartNo = 1 ; iPartNo <= [e3obj.nPayType integerValue] ; iPartNo++) {
				// 既存E2レコードを探す　　＜＜Pe3select.e2invoiceは、新規追加時は nil であるから＞＞
				E2invoice *e2obj = nil;
				E6part *e6obj = nil;
				for (e2obj in e3obj.e1card.e2paids) { // E2支払済 から探す
					if ([e2obj.nYearMMDD integerValue] == iYearMMDD) {  // 支払日
						// ありましたが支払済なので、次を探す　＜＜新規の場合だけ＞＞
						if (0 < [e3obj.e1card.nPayDay integerValue]) {	// <=0:Debit
							iYearMMDD = GiAddYearMMDD(iYearMMDD, 0, +1, 0); // 通常:翌月へ
						} else {
							iYearMMDD = GiAddYearMMDD(iYearMMDD, 0, 0, +1); // Debit:翌日へ
						}
					}
				}
				for (e2obj in e3obj.e1card.e2unpaids) { // E2未払い から探す
					if ([e2obj.nYearMMDD integerValue] == iYearMMDD) {  // 支払日
						// E2発見！E6追加
						e6obj = [NSEntityDescription insertNewObjectForEntityForName:@"E6part" inManagedObjectContext:moc];
						e6obj.e2invoice = e2obj;	// E6-E2 リンク
						e6obj.e3record = e3obj; // E6-E3 リンク
						// 属性
						e6obj.nPartNo = [NSNumber numberWithInteger:iPartNo];
						e6obj.nNoCheck = [NSNumber numberWithInteger:1];
						if (iPartNo==1) {
							e6obj.nAmount = [NSNumber numberWithLong:iAmountOne + iAmountFirst];
						} else {
							e6obj.nAmount = [NSNumber numberWithLong:iAmountOne];
						}
						break;
					}
				}
				if (e6obj == nil) {
					// 既存E2なし：追加する
					e2obj = [NSEntityDescription insertNewObjectForEntityForName:@"E2invoice" inManagedObjectContext:moc];
					e2obj.nYearMMDD = [NSNumber numberWithInteger:iYearMMDD];
					e2obj.e1paid = nil;  // 必ず一方は nil になる
					e2obj.e1unpaid = e3obj.e1card;  // E2-E1 リンク
					// E6追加
					e6obj = [NSEntityDescription insertNewObjectForEntityForName:@"E6part" inManagedObjectContext:moc];
					e6obj.e2invoice = e2obj;	// E6-E2 リンク　　これのより e2obj.e6parts にも加えられる。
					e6obj.e3record = e3obj; // E6-E3 リンク
					// 属性
					e6obj.nPartNo = [NSNumber numberWithInteger:iPartNo];
					e6obj.nNoCheck = [NSNumber numberWithInteger:1];
					if (iPartNo==1) {
						e6obj.nAmount = [NSNumber numberWithLong:iAmountOne + iAmountFirst];
					} else {
						e6obj.nAmount = [NSNumber numberWithLong:iAmountOne];
					}
				}
				if (e2obj) {
					if (e2obj.e1paid) {  // PAIDでここを通ることは無いハズ！
						AzLOG(@"LOGIC ERROR: E2 NG PAID");
						return NO;
					}
					if (e2obj.e7payment == nil) {
						// E7がリンクされていないので探してリンクする
						for (E7payment *e7obj in e0root.e7unpaids) {
							if ([e7obj.nYearMMDD integerValue] == iYearMMDD) {
								e2obj.e7payment = e7obj; // E2 <<--> E7
								break;
							}
						}
					}
					if (e2obj.e7payment == nil) { // 探したが、E7が無いので追加する
						E7payment *e7obj = [NSEntityDescription insertNewObjectForEntityForName:@"E7payment" inManagedObjectContext:moc];
						e7obj.nYearMMDD = [NSNumber numberWithLong:iYearMMDD]; // 支払日 ＜＜締月日と違う＞＞
						e7obj.e0paid = nil;
						e7obj.e0unpaid = e0root;	// E7 <<--> E0 未払い
						e2obj.e7payment = e7obj; // E2 <<--> E7
					}
					// E2 sum   E1は変わらないのでsum不要
					e2obj.sumAmount = [e2obj valueForKeyPath:@"e6parts.@sum.nAmount"];
					e2obj.sumNoCheck = [e2obj valueForKeyPath:@"e6parts.@sum.nNoCheck"];
					// E7 sum
					E7payment *e7obj = e2obj.e7payment;
					e7obj.sumAmount = [e7obj valueForKeyPath:@"e2invoices.@sum.sumAmount"];
					e7obj.sumNoCheck = [e7obj valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
				}
				// 次回（翌月）へ
				if (0 < [e3obj.e1card.nPayDay integerValue]) {	// <=0:Debitならば同じ利用日
					iYearMMDD = GiAddYearMMDD(iYearMMDD, 0, +1, 0); // 翌月へ
				}
			}
		}
		else {
			// ボーナス払い対応
			
		}
	} //ここまで、if (bE6remake == YES)
	
	return YES;
}

// E6.nNoCheck を 0,1 切り替えする。 E6.PAIDならば不変。
+ (void)e6check:(BOOL)bCheckOn inE6obj:(E6part *)e6obj inAlert:(BOOL)bAlert
{
	if (e6obj.e2invoice.e1paid) {
		// 支払済につきチェック変更できません
		if (bAlert) { // E3から一括処理されたときアラート表示しないため
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NotNoCheck",nil) 
															 message:NSLocalizedString(@"NotNoCheck msg",nil) 
															delegate:nil 
												   cancelButtonTitle:nil 
												   otherButtonTitles:@"OK", nil];
			[alert show];
			[alert release];
		}
		return;
	}

	if (bCheckOn) {
		e6obj.nNoCheck = [NSNumber numberWithInt:0]; // CheckON -->> .nNoCheck = 0
	} else {
		e6obj.nNoCheck = [NSNumber numberWithInt:1]; // CheckOFF -->> .nNoCheck = 1
	}
	// E3 sum
	e6obj.e3record.sumNoCheck = [e6obj.e3record valueForKeyPath:@"e6parts.@sum.nNoCheck"];
	// E2 sum
	e6obj.e2invoice.sumNoCheck = [e6obj.e2invoice valueForKeyPath:@"e6parts.@sum.nNoCheck"];
	// E7 sum
	e6obj.e2invoice.e7payment.sumNoCheck = [e6obj.e2invoice.e7payment valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
}

// E3配下のE6.nNoCheck を 0,1 切り替えする。 E6.PAIDならば不変。
+ (void)e3check:(BOOL)bCheckOn inE3obj:(E3record *)e3obj inAlert:(BOOL)bAlert
{
	for (E6part *e6 in e3obj.e6parts) {
		// E6 Check
		[EntityRelation e6check:bCheckOn inE6obj:e6 inAlert:NO];
	}
}

// E2の Paid と Unpaid を切り替える
// bE6noCheckNext = YES: E6未チェック分を翌月以降に移動する
+ (void)e2paid:(E2invoice *)e2obj inE6payNextMonth:(BOOL)bE6payNextMonth
{
	NSManagedObjectContext *moc = e2obj.managedObjectContext;
	E7payment *e7old = e2obj.e7payment;
	
	if (e2obj.e1unpaid) {
		// 配下のE6に未チェックがあるか調べる
		for (E6part *e6 in e2obj.e6parts) {
			if (0 < [e6.nNoCheck intValue]) {
				if (bE6payNextMonth) {
					// e6 (Unpaid) の支払日を翌月へ移す
					[EntityRelation e6payNextMonth:e6];
				} else {
					AzLOG(@"LOGIC ERR: e2paid: E6に未チェックあり");
					return; // 中断
				}
			}
		}
		
		// e2obj を Paid にする
		e2obj.e1paid = e2obj.e1unpaid;
		e2obj.e1unpaid = nil;
		// E7 も Paid に変更する
		// E7.e0paid を検索する
		E7payment *e7paid = nil;
		for (E7payment *e7 in e7old.e0unpaid.e7paids) {
			if ([e7.nYearMMDD isEqualToNumber:e7old.nYearMMDD]) {
				e7paid = e7; // 既存
				// このE2を e7paid へ移す
				e2obj.e7payment = e7paid;
				// E7 sum
				e7paid.sumAmount = [e7paid valueForKeyPath:@"e2invoices.@sum.sumAmount"];
				e7paid.sumNoCheck = [e7paid valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
				//
				if (0 < [e7old.e2invoices count]) {
					// E7 sum
					e7old.sumAmount = [e7old valueForKeyPath:@"e2invoices.@sum.sumAmount"];
					e7old.sumNoCheck = [e7old valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
				} else {
					// e7old 配下が無くなったので削除する
					e7old.e0paid = nil;
					e7old.e0unpaid = nil;
					[moc deleteObject:e7old]; // E7削除
					e7old = nil;
				}
				break;
			}
		}
		if (e7paid == nil && e7old) {
			// 既存の E7.paid が無い　　　　＜＜E7配下のE2は個(E1)別にPAIDになる場合があることに注意＞＞
			// E7 <-->> E2 を切って、E7.unpaid の配下を調べる。
			e2obj.e7payment = nil;
			if ([e7old.e2invoices count] <= 0) {
				// e7old 配下が無くなったので、e7oldをpaid に変えて流用する
				e7paid = e7old;
			} else {
				// e7old 配下(他カードのE2)があるので、新たに E7.paid を追加してリンクする
				e7paid = [NSEntityDescription insertNewObjectForEntityForName:@"E7payment"
													   inManagedObjectContext:moc];
				e7paid.nYearMMDD = e7old.nYearMMDD;
				// E7 sum
				e7old.sumAmount = [e7old valueForKeyPath:@"e2invoices.@sum.sumAmount"];
				e7old.sumNoCheck = [e7old valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
			}
			e7paid.e0paid = e7old.e0unpaid; // nil 代入の前に代入すること
			e7paid.e0unpaid = nil;
			e2obj.e7payment = e7paid;
			// E7 sum
			e7paid.sumAmount = [e7paid valueForKeyPath:@"e2invoices.@sum.sumAmount"];
			e7paid.sumNoCheck = [e7paid valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
		}
	}
	else if (e2obj.e1paid) {
		// e2obj を Unpaid にする
		e2obj.e1unpaid = e2obj.e1paid;
		e2obj.e1paid = nil;
		// E7 Paid >>> Unpaid  .e0unpaid を検索する
		E7payment *e7unpaid = nil;
		for (E7payment *e7 in e7old.e0paid.e7unpaids) {
			if ([e7.nYearMMDD isEqualToNumber:e7old.nYearMMDD]) {
				e7unpaid = e7; // 既存
				// このE2を e7unpaid へ移す
				e2obj.e7payment = e7unpaid;
				// E7 sum
				e7unpaid.sumAmount = [e7unpaid valueForKeyPath:@"e2invoices.@sum.sumAmount"];
				e7unpaid.sumNoCheck = [e7unpaid valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
				//
				if (0 < [e7old.e2invoices count]) {
					// E7 sum
					e7old.sumAmount = [e7old valueForKeyPath:@"e2invoices.@sum.sumAmount"];
					e7old.sumNoCheck = [e7old valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
				} else {
					// e7old 配下が無くなったので削除する
					e7old.e0paid = nil;
					e7old.e0unpaid = nil;
					[moc deleteObject:e7old]; // E7削除
					e7old = nil;
				}
				break;
			}
		}
		if (e7unpaid == nil && e7old) {
			// 既存の E7.unpaid が無い　　　　＜＜E7配下のE2は個(E1)別にPAIDになる場合があることに注意＞＞
			// E7 <-->> E2 を切って、E7.paid の配下を調べる。
			e2obj.e7payment = nil;
			if ([e7old.e2invoices count] <= 0) {
				// e7old 配下が無くなったので、e7oldをunpaid に変えて流用する
				e7unpaid = e7old;
			} else {
				// e7old 配下(他カードのE2)があるので、新たに E7.unpaid を追加してリンクする
				e7unpaid = [NSEntityDescription insertNewObjectForEntityForName:@"E7payment"
														 inManagedObjectContext:moc];
				e7unpaid.nYearMMDD = e7old.nYearMMDD;
				// E7 sum
				e7old.sumAmount = [e7old valueForKeyPath:@"e2invoices.@sum.sumAmount"];
				e7old.sumNoCheck = [e7old valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
			}
			e7unpaid.e0unpaid = e7old.e0paid; // nil 代入の前に代入すること
			e7unpaid.e0paid = nil;
			e2obj.e7payment = e7unpaid;
			// E7 sum
			e7unpaid.sumAmount = [e7unpaid valueForKeyPath:@"e2invoices.@sum.sumAmount"];
			e7unpaid.sumNoCheck = [e7unpaid valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
		}
	}
	else {
		// E2 NG
		
	}
}

// e6obj (Unpaid) の支払日を翌月へ移す
+ (void)e6payNextMonth:(E6part *)e6obj
{
	E0root	*e0root = e6obj.e2invoice.e7payment.e0unpaid; // 移動先のE7を探すために使用
	if (e0root == nil) {
		AzLOG(@"LOGIC ERR: e6payNextMonth: E6 Paid");
		return;
	}
	NSManagedObjectContext *moc = e6obj.managedObjectContext;
	E1card	*e1card = e6obj.e3record.e1card; // 移動先のE2を探すために使用
	E2invoice *e2old = e6obj.e2invoice;
	NSInteger iYearMMDD = [e2old.nYearMMDD integerValue];
	iYearMMDD = GiAddYearMMDD(iYearMMDD, 0, +1, 0); // 翌月へ

	e6obj.e2invoice = nil;
	
	// 移動先となる E2 を探す
	E2invoice *e2obj = nil;
	for (e2obj in e1card.e2paids) { // E2支払済 から探す
		if ([e2obj.nYearMMDD integerValue] == iYearMMDD) {  // 支払日
			// ありましたが支払済なので、さらに翌月を探す　＜＜新規の場合だけ＞＞
			//iYearMMDD = GiAddYearMMDD(iYearMMDD, 0, +1, 0); // 翌月へ
			AzLOG(@"LOGIC ERR: E6の移動先がPAIDになっている"); //　ここを通ることは無いハズ
			return;
		}
	}
	for (e2obj in e1card.e2unpaids) { // E2未払い から探す
		if ([e2obj.nYearMMDD integerValue] == iYearMMDD) {  // 支払日
			// E2発見！E6リンク
			e6obj.e2invoice = e2obj;	// E6-E2 リンク
			break;
		}
	}
	if (e6obj.e2invoice == nil) {
		// 既存E2なし：追加する
		e2obj = [NSEntityDescription insertNewObjectForEntityForName:@"E2invoice" inManagedObjectContext:moc];
		e2obj.nYearMMDD = [NSNumber numberWithInteger:iYearMMDD];
		e2obj.e1paid = nil;  // 必ず一方は nil になる
		e2obj.e1unpaid = e1card;  // E2-E1 リンク
		// E6リンク
		e6obj.e2invoice = e2obj;	// E6-E2 リンク　　これのより e2obj.e6parts にも加えられる。
	}
	if (e2obj) {
		if (e2obj.e1paid) {  // PAIDでここを通ることは無いハズ！
			AzLOG(@"LOGIC ERROR: E2 NG PAID");
			return;
		}
		if (e2obj.e7payment == nil) {
			// E7がリンクされていないので探してリンクする
			for (E7payment *e7obj in e0root.e7unpaids) {
				if ([e7obj.nYearMMDD integerValue] == iYearMMDD) {
					e2obj.e7payment = e7obj; // E2 <<--> E7
					break;
				}
			}
		}
		if (e2obj.e7payment == nil) { // 探したが、E7が無いので追加する
			E7payment *e7obj = [NSEntityDescription insertNewObjectForEntityForName:@"E7payment" inManagedObjectContext:moc];
			e7obj.nYearMMDD = [NSNumber numberWithLong:iYearMMDD]; // 支払日 ＜＜締月日と違う＞＞
			e7obj.e0paid = nil;
			e7obj.e0unpaid = e0root;	// E7 <<--> E0 未払い
			e2obj.e7payment = e7obj; // E2 <<--> E7
		}
		// E2 sum   E1は変わらないのでsum不要
		e2obj.sumAmount = [e2obj valueForKeyPath:@"e6parts.@sum.nAmount"];
		e2obj.sumNoCheck = [e2obj valueForKeyPath:@"e6parts.@sum.nNoCheck"];
		// E7 sum
		E7payment *e7obj = e2obj.e7payment;
		e7obj.sumAmount = [e7obj valueForKeyPath:@"e2invoices.@sum.sumAmount"];
		e7obj.sumNoCheck = [e7obj valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
	}
}

// E7の Paid と Unpaid を切り替える
// bE6noCheckNext = YES: E6未チェック分を翌月以降に移動する
+ (void)e7paid:(E7payment *)e7obj inE6payNextMonth:(BOOL)bE6payNextMonth
{
	//NSArray *aE2 = [NSArray arrayWithArray:[e7obj.e2invoices allObjects]];  autoreleseを減らすため
	NSArray *aE2 = [[NSArray alloc] initWithArray:[e7obj.e2invoices allObjects]];
	// e2paid:内で配下が無くなったe7objが削除される可能性があるためコピーを使用する。
	for (E2invoice *e2 in aE2) {
		// 配下E2の Paid と Unpaid を切り替える
		[EntityRelation e2paid:e2 inE6payNextMonth:bE6payNextMonth];
	}
	[aE2 release];
}


// E7E2クリーンアップ：配下のE6が無くなったE2を削除し、さらに配下のE2が無くなったE7も削除する。
+ (void)e7e2clean
{
	E0root *e0root = [EntityRelation e0root];
	BOOL bSave = NO;
	NSManagedObjectContext *moc = e0root.managedObjectContext;

	NSArray *aE7 = [[NSArray alloc] initWithArray:[e0root.e7unpaids allObjects]]; // Unpaid側だけ処理する
	for (E7payment *e7 in aE7) // aE7要素は削除しないので reverseObjectEnumerator は不要 
	{
		NSArray *aE2 = [[NSArray alloc] initWithArray:[e7.e2invoices allObjects]];
		for (E2invoice *e2 in aE2) // aE2要素は削除しないので reverseObjectEnumerator は不要 
		{
			if (e2.e6parts==nil OR [e2.e6parts count]<=0) {
				e2.e1paid = nil;
				e2.e1unpaid = nil;
				e2.e7payment = nil;
				[moc deleteObject:e2]; // 削除
				e2 = nil;
				bSave = YES;
			}
		}
		[aE2 release];
		
		if (e7.e2invoices==nil OR [e7.e2invoices count]<=0) {
			e7.e0paid = nil;
			e7.e0unpaid = nil;
			[moc deleteObject:e7];
			e7 = nil;
			bSave = YES;
		}
	}
	[aE7 release];

	if (bSave) [EntityRelation commit]; // 保存
}

@end
