//
//  EntityRelation.m
//  AzCredit
//
//  Created by 松山 和正 on 10/03/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SFHFKeychainUtils.h"
#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"


@implementation MocFunctions

static NSManagedObjectContext *scMoc = nil;

+ (void)setMoc:(NSManagedObjectContext *)moc
{
	assert(moc);
	scMoc = moc;
}	

+ (id)insertAutoEntity:(NSString *)zEntityName	// autorelease
{
	assert(scMoc);
	// Newが含まれているが、自動解放インスタンスが生成される。
	// 即commitされる。つまり、rollbackやcommitの対象外である。
	return [NSEntityDescription insertNewObjectForEntityForName:zEntityName inManagedObjectContext:scMoc];
	// ここで生成されたEntityは、rollBack では削除されない。　Cancel時には、deleteEntityが必要。
}	

+ (void)deleteEntity:(NSManagedObject *)entity
{
	@synchronized(scMoc)
	{
		if (entity) {
			[scMoc deleteObject:entity];	// 即commitされる。つまり、rollbackやcommitの対象外である。
		}
	}
}	

+ (BOOL)commit
{
	assert(scMoc);
	@synchronized(scMoc)
	{
		// SAVE
		NSError *err = nil;
		if (![scMoc  save:&err]) {
			NSLog(@"*** MOC commit error ***\n%@\n%@\n***\n", err, [err userInfo]);
			//exit(-1);  // Fail
			alertBox(NSLocalizedString(@"MOC CommitErr",nil),
					 NSLocalizedString(@"MOC CommitErrMsg",nil),
					 NSLocalizedString(@"Roger",nil));
			return NO;
		}
	}
	return YES;
}


+ (void)rollBack
{
	assert(scMoc);
	@synchronized(scMoc)
	{
		// ROLLBACK
		[scMoc rollback]; // 前回のSAVE以降を取り消す
	}
}

+ (NSArray *)select:(NSString *)zEntity
			  limit:(NSInteger)iLimit
			 offset:(NSInteger)iOffset
			  where:(NSPredicate *)predicate
			   sort:(NSArray *)arSort 
{
	assert(scMoc);
	NSFetchRequest *req = nil;
	@try {
		req = [[NSFetchRequest alloc] init];
		
		// select
		NSEntityDescription *entity = [NSEntityDescription entityForName:zEntity 
												  inManagedObjectContext:scMoc];
		[req setEntity:entity];
		
		// limit	抽出件数制限
		if (0 < iLimit) {
			[req setFetchLimit:iLimit];
		}
		
		// offset
		if (iOffset != 0) {
			[req setFetchOffset:iOffset];
		}
		
		// where
		if (predicate) {
			[req setPredicate:predicate];
		}
		
		// order by
		if (arSort) {
			[req setSortDescriptors:arSort];
		}

		NSError *error = nil;
		NSArray *arFetch = [scMoc executeFetchRequest:req error:&error];
		[req release], req = nil;
		if (error) {
			AzLOG(@"select: Error %@, %@", error, [error userInfo]);
			return nil;
		}
		return arFetch; // autorelease
	}
	@catch (NSException *errEx) {
		NSLog(@"select @catch:NSException: %@ : %@", [errEx name], [errEx reason]);
	}
	@finally {
		[req release], req = nil;
	}
	return nil;
}

+ (void)allReset
{
	assert(scMoc);
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSError *error;
	NSEntityDescription *entity;
	NSArray *arFetch;

	// E6削除　＜＜ E2,E3 より先に削除する
	entity = [NSEntityDescription entityForName:@"E6part" inManagedObjectContext:scMoc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [scMoc executeFetchRequest:fetchRequest error:&error]; // autorelease
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
		[scMoc deleteObject:e6]; // 削除
	}
	
	// E2削除
	entity = [NSEntityDescription entityForName:@"E2invoice" inManagedObjectContext:scMoc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [scMoc executeFetchRequest:fetchRequest error:&error]; // autorelease
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
		[scMoc deleteObject:e2]; // 削除
	}
	
	// E3削除
	entity = [NSEntityDescription entityForName:@"E3record" inManagedObjectContext:scMoc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [scMoc executeFetchRequest:fetchRequest error:&error]; // autorelease
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
		[scMoc deleteObject:e3]; // 削除
	}
	
	// E1削除　＜＜ E2,E3 から参照されているので、それらの後に削除すること
	entity = [NSEntityDescription entityForName:@"E1card" inManagedObjectContext:scMoc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [scMoc executeFetchRequest:fetchRequest error:&error]; // autorelease
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
		[scMoc deleteObject:e1]; // 削除
	}
	
	// E4削除
	entity = [NSEntityDescription entityForName:@"E4shop" inManagedObjectContext:scMoc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [scMoc executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		[fetchRequest release];
		AzLOG(@"allReset E4 Error: %@, %@", error, [error userInfo]);
		return;
	}
	for (E4shop *e4 in arFetch) {
		[scMoc deleteObject:e4]; // 削除
	}
	
	// E5削除
	entity = [NSEntityDescription entityForName:@"E5category" inManagedObjectContext:scMoc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [scMoc executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		[fetchRequest release];
		AzLOG(@"allReset E5 Error: %@, %@", error, [error userInfo]);
		return;
	}
	for (E5category *e5 in arFetch) {
		[scMoc deleteObject:e5]; // 削除
	}
	
	// E8削除
	entity = [NSEntityDescription entityForName:@"E8bank" inManagedObjectContext:scMoc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [scMoc executeFetchRequest:fetchRequest error:&error]; // autorelease
	if (error) {
		[fetchRequest release];
		AzLOG(@"allReset E4 Error: %@, %@", error, [error userInfo]);
		return;
	}
	for (E8bank *e8 in arFetch) {
		[scMoc deleteObject:e8]; // 削除
	}

	// E7削除
	entity = [NSEntityDescription entityForName:@"E7payment" inManagedObjectContext:scMoc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [scMoc executeFetchRequest:fetchRequest error:&error]; // autorelease
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
		[scMoc deleteObject:e7]; // 削除
	}
	
#if AzDEBUG
	// E0root
	entity = [NSEntityDescription entityForName:@"E0root" inManagedObjectContext:scMoc];
	[fetchRequest setEntity:entity];
	error = nil;
	arFetch = [scMoc executeFetchRequest:fetchRequest error:&error]; // autorelease
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


// E0（固有ノード）を取得する。無ければ生成する。
+ (E0root *)e0root
{
	assert(scMoc);
	E0root *e0root = nil;

	NSArray *arFetch = [MocFunctions select:@"E0root" 
										limit:1
									   offset:0
										where:nil
										 sort:nil];
	
	if (arFetch==nil || [arFetch count]<1) 
	{
		// 無いので新規追加する
		e0root = [NSEntityDescription insertNewObjectForEntityForName:@"E0root" inManagedObjectContext:scMoc];
		//[0.4] ログインパスをクリアする
		AzLOG(@"New Login pass Clear");
		// 新規や再インストールされた場合、保存したパスワードを削除して自動ログインさせる
		NSError *error; // nilを渡すと異常終了するので注意
		[SFHFKeychainUtils deleteItemForUsername:GD_KEY_LOGINPASS
								  andServiceName:GD_PRODUCTNAME 
										   error:&error]; 
		
		//[1.0.0]初期E1cardを追加する
		//(0)デビット支払
		E1card *e1 = [NSEntityDescription insertNewObjectForEntityForName:@"E1card" inManagedObjectContext:scMoc];
		e1.nRow = [NSNumber numberWithInt:0];
		e1.zName = NSLocalizedString(@"Sample Debit",nil);
		e1.zNote = NSLocalizedString(@"Sample Debit　note",nil);
		e1.nClosingDay = [NSNumber numberWithInt:0];	// 締日 1〜28,29=末日,    0=Debit(利用日⇒支払日)	
		e1.nPayMonth = [NSNumber numberWithInt:0];		// 支払月 (0)当月　(1)翌月　(2)翌々月
		e1.nPayDay = [NSNumber numberWithInt:0];			// 支払日 1〜28,29=末日,  Debit(0〜99)日後支払
		//(1)クレジット支払
		e1 = [NSEntityDescription insertNewObjectForEntityForName:@"E1card" inManagedObjectContext:scMoc];
		e1.nRow = [NSNumber numberWithInt:1];
		e1.zName = NSLocalizedString(@"Sample Credit",nil);
		e1.zNote = NSLocalizedString(@"Sample Credit　note",nil);
		e1.nClosingDay = [NSNumber numberWithInt:20];
		e1.nPayMonth = [NSNumber numberWithInt:1];
		e1.nPayDay = [NSNumber numberWithInt:20];
		//(2)家賃支払
		e1 = [NSEntityDescription insertNewObjectForEntityForName:@"E1card" inManagedObjectContext:scMoc];
		e1.nRow = [NSNumber numberWithInt:2];
		e1.zName = NSLocalizedString(@"Sample Rent",nil);
		e1.zNote = NSLocalizedString(@"Sample Rent　note",nil);
		e1.nClosingDay = [NSNumber numberWithInt:0];	// デビットと同じ条件、家賃支払日を利用日にする
		e1.nPayMonth = [NSNumber numberWithInt:0];
		e1.nPayDay = [NSNumber numberWithInt:0];
		// SAVE
		[self commit];
	}
	else {
		// あり
		e0root = [arFetch objectAtIndex:0]; // 未払い計を表示するためTopMenuTVCへ渡す
	}
	if (e0root == nil) {
		AzLOG(@"LOGIC ERR: E0root Nothing");
		exit(-1);  // Fail
	}
	return e0root;
}

// カード(Pe1card)と利用日(PtUse)から支払日を求める
//static NSInteger MiYearMMDDpayment( E1card *Pe1card, NSDate *PtUse )
+ (NSInteger)yearMMDDpaymentE1card:(E1card *)Pe1card  forUseDate:(NSDate*)PtUse
{
	if (Pe1card==nil || PtUse==nil) return 0;
	
	NSInteger iClosingDay = [Pe1card.nClosingDay integerValue];
	NSInteger iPayMonth = [Pe1card.nPayMonth integerValue]; // 支払月（0=当月、1=翌月、2=翌々月）
	NSInteger iPayDay = [Pe1card.nPayDay integerValue];
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *compUse = [cal components:unitFlags fromDate:PtUse]; // 利用日
	
	if (iClosingDay<=0) { // Debit 当日締
		if (iPayDay<=0) {
			return GiYearMMDD( PtUse );  // 当日払
		} else {
			// PtUse の iPayDay 日後払
			compUse.day += iPayDay;
			return GiYearMMDD( [cal dateFromComponents:compUse] );
		}
	}
	
	// 支払日
	NSInteger iYearMMDD = compUse.year * 10000 + compUse.month * 100 + iPayDay;
	// 利用日が締日以降ならば翌月（支払月+1）になる
	if (iClosingDay <= 28 && iClosingDay < compUse.day) {
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
	
	@synchronized(scMoc)
	{
		// 締め支払が変更された場合、Paid分は不変、Unpaid分を全て変更する
		for (E3record *e3 in e1obj.e3records) {
			// カード(e1obj)と利用日(e3.dateUse)から支払日を求める
			NSInteger iYearMMDD = [self yearMMDDpaymentE1card:e1obj forUseDate:e3.dateUse];  //MiYearMMDDpayment(e1obj, e3.dateUse);
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
					assert(e2old);
					assert(e2old.e1unpaid);
					// e1obj配下にあるiYearMMDDのE2を取得する（無ければE7まで生成）
					E2invoice *e2new = [MocFunctions e2invoice:e1obj inYearMMDD:iYearMMDD];
					if (e2new==nil OR e2new.e7payment.e0paid) {
						AzLOG(@"LOGIC ERR: e1update: e2new NG");
						[muE6 release];
						return;
					}
					if (e2new != e2old) {
						// E2 old -->> new リンク変更
						e6.e2invoice = e2new;
						// E6の所属が変わったので親となるE2,E7を再集計する
						[MocFunctions e2e7update:e2new];		//e6増
						[MocFunctions e2e7update:e2old];		//e6減
					}
				}
				// if (e6.e2invoice.e1unpaid)
				// 次のE6のため
				if (0 < [e1obj.nPayDay integerValue]) {	// <=0:Debitならば同じ利用日
					iYearMMDD = GiAddYearMMDD(iYearMMDD, 0, +1, 0);	// 翌月へ
				}
			} // e6
			[muE6 release];
		} // e3
	}
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
		[MocFunctions e3delete:e3];
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
	//NSManagedObjectContext *moc = e1card.managedObjectContext;
	assert(scMoc);

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
	E2invoice *e2new = [NSEntityDescription insertNewObjectForEntityForName:@"E2invoice" inManagedObjectContext:scMoc];
	e2new.nYearMMDD = [NSNumber numberWithLong:iYearMMDD]; // 支払日 ＜＜締月日と違う＞＞
	e2new.e1paid = nil;
	e2new.e1unpaid = e1card;	// E2 <<--> E1 未払い
	
	//e2new.sumAmount = [NSDecimalNumber zero];
	//e2new.sumNoCheck = [NSNumber numberWithInt:0];
	//e2new.e6parts = [NSSet set];
	
	 // E7 Unpaid 検索
	E0root *e0root = [MocFunctions e0root];
	if (e0root == nil) return NO;
	for (E7payment *e7 in e0root.e7unpaids) {
		if ([e7.nYearMMDD integerValue] == iYearMMDD) {
			e2new.e7payment = e7;
			return e2new; // 決定
		}
	}
	// E7なし、E7 Unpaid 追加
	E7payment *e7new = [NSEntityDescription insertNewObjectForEntityForName:@"E7payment" inManagedObjectContext:scMoc];
	e7new.nYearMMDD = [NSNumber numberWithLong:iYearMMDD]; // 支払日
	e7new.e0paid = nil;
	e7new.e0unpaid = e0root;
	//
	e2new.e7payment = e7new;
	return e2new;
}

//[1.0.0] e2配下(E6,E3)に変化ありe2,e7再集計する
+ (void)e2e7update:(E2invoice *)e2
{
	E7payment *e7 = e2.e7payment;
	// E2
	if (0 < [e2.e6parts count]) { // E2 sum
		e2.sumAmount = [e2 valueForKeyPath:@"e6parts.@sum.nAmount"];
		e2.sumNoCheck = [e2 valueForKeyPath:@"e6parts.@sum.nNoCheck"];
	} else {
		// E2配下のE6なし
		//[0.4]E2削除せずに配下E6なし状態で残す。 E8＞E2>E3にてE3からE2に戻るときにe2が無ければ落ちるため。
		//     尚、空のE2は、いずれ再利用されるか、破棄される。
		e2.sumAmount = [NSDecimalNumber zero];				
		e2.sumNoCheck = [NSNumber numberWithInt:0];
	}
	// E7
	if (0 < [e7.e2invoices count]) { // E7 sum
		e7.sumAmount = [e7 valueForKeyPath:@"e2invoices.@sum.sumAmount"];
		e7.sumNoCheck = [e7 valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
	} else {
		// E7配下のE2なし
		e7.e0paid = nil;
		e7.e0unpaid = nil;
		[e2.managedObjectContext deleteObject:e7];	// E7削除
	}
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
		if (e2) {
			// E2配下から切り離す（まだここではE6削除しない）
			e6.e2invoice = nil; // 切断してからE2,E7を再集計
			// E6の所属が変わったので親となるE2,E7を再集計する
			[MocFunctions e2e7update:e2];		//e6減
		}
		// E6 削除
		e6.e2invoice = nil;
		e6.e3record = nil;	// E6 <<--> E3 リンク削除：これが無いと "LOGIC ERROR: E6 Delete NG" が出る
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
// iFirstYearMMDD = 最初の支払日(分割の場合、これと翌月以降になる)   =0:カードの締支払条件から自動決定する
+ (BOOL)e3makeE6:(E3record *)e3obj inFirstYearMMDD:(NSInteger)iFirstYearMMDD
{
	if (e3obj == nil) return NO;
	if (e3obj.e1card == nil) return YES; // クイック追加時、カード(未定)許可のため　
										 // クイック追加時、＜この時点で配下のE6は無い。また、E6が追加された後に.e1card==nilになることは無い＞

	// 締め支払条件に変化があったか調べる
	NSInteger iYearMMDD = iFirstYearMMDD; // 支払日
	if (iFirstYearMMDD < AzMIN_YearMMDD) {
		// カード(e3obj.e1card)と利用日(e3obj.dateUse)から支払日を求める
		iYearMMDD = [self yearMMDDpaymentE1card:e3obj.e1card forUseDate:e3obj.dateUse];  //MiYearMMDDpayment(e3obj.e1card, e3obj.dateUse);
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
		NSDecimalNumber *decAmount = [NSDecimalNumber zero];
		for (E6part *e6 in e3obj.e6parts) {
			decAmount = [decAmount decimalNumberByAdding:e6.nAmount]; // 和
			if ([e6.nPartNo integerValue] == 1) {
				if (iYearMMDD != [e6.e2invoice.nYearMMDD integerValue] && [e6.nNoCheck integerValue]==1) {
					// 第1回目の支払日が変化した && 未チェックであること[0.4]チェック済みならば変更しないため
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

		if (!bE6remake && [decAmount compare:e3obj.nAmount] != NSOrderedSame)
		{	// 金額が変わった
			bE6remake = YES; // 旧E6削除してから新E6生成する。　E6のチェックは解除される
		}
	}
	
	//NSManagedObjectContext *moc = e3obj.managedObjectContext;
	assert(scMoc);

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
		E0root *e0root = [MocFunctions e0root];
		if (e0root == nil) return NO;
		
		//------------------------------------------------------------E6 削除
		// e3obj.e6parts 配下が削除されても配列位置がズレないようにコピー配列を用いる
		//NSArray *arrayE6 = [NSArray arrayWithArray:[e3obj.e6parts allObjects]]; 
		NSArray *arrayE6 = [[NSArray alloc] initWithArray:[e3obj.e6parts allObjects]]; 
		for (E6part *e6 in arrayE6) {
			// E6 削除
			E2invoice *e2 = e6.e2invoice; // 後のsumのため親E2を保存
			e6.e3record = nil;  // E6 <<--> E3 リンク削除：これが無いと "LOGIC ERROR: E6 Delete NG" が出る
			e6.e2invoice = nil; // E6 <<--> E2 リンク削除：切断してからE2,E7を再集計
			// E6の所属が変わったので親となるE2,E7を再集計する
			[MocFunctions e2e7update:e2];		//e6減
			// E6削除
			[scMoc deleteObject:e6];
		}
		[arrayE6 release];
		
		//------------------------------------------------------------E6 新規追加
		
		// E6追加　　E2,E7が無ければ追加する
		NSInteger iPayType = [e3obj.nPayType integerValue];
		if (1 <= iPayType && iPayType < 100) 
		{
			NSDecimalNumber *decAmountOne;	// 1回分
			NSDecimalNumber *decAmountRest;	// 余り（最終回に配分する） ＜＜[1.0.1]以前は1回目に配分していた＞＞

			if (iPayType <= 1) { // 一括払い
				decAmountOne = e3obj.nAmount;
				decAmountRest = [NSDecimalNumber zero];
			}
			else {	// 2回以上分割
				NSDecimalNumber *decAmountZan = e3obj.nAmount;
				NSDecimalNumber *decPayType = [NSDecimalNumber decimalNumberWithDecimal:[e3obj.nPayType decimalValue]];
				//[0.4] Decimal対応  behavior
				// 通貨型に合った丸め位置を取得
				NSUInteger iRoundingScale = 2;
				if ([[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier] isEqualToString:@"ja_JP"]) { // 言語 + 国、地域
					iRoundingScale = 0;
				}
				// 分割(÷)のための丸め（常に切り捨て）
				NSDecimalNumberHandler *behavior = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundDown		// ここでは切り捨て
																								  scale:iRoundingScale	// 丸めた後の桁数
																					   raiseOnExactness:YES				// 精度
																						raiseOnOverflow:YES				// オーバーフロー
																					   raiseOnUnderflow:YES				// アンダーフロー
																					raiseOnDivideByZero:YES ];			// アンダーフロー
				// 金額 ÷ 分割回数　　(÷)切り捨て
				decAmountOne = [decAmountZan decimalNumberByDividingBy:decPayType withBehavior:behavior];
				[behavior release];
				// 以後、デフォルト丸め
				NSDecimalNumber *decTotal = [decAmountOne decimalNumberByMultiplyingBy:decPayType]; // デフォルト丸め
				// 誤差を1回目に配賦するため
				decAmountRest = [decAmountZan decimalNumberBySubtracting:decTotal];
			}
			
			// 分割1〜99回まで対応
			for (NSInteger iPartNo = 1; iPartNo <= iPayType; iPartNo++) {
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
						e6obj = [NSEntityDescription insertNewObjectForEntityForName:@"E6part" inManagedObjectContext:scMoc];
						e6obj.e2invoice = e2obj;	// E6-E2 リンク
						e6obj.e3record = e3obj; // E6-E3 リンク
						// 属性
						e6obj.nPartNo = [NSNumber numberWithInteger:iPartNo];
						e6obj.nNoCheck = [NSNumber numberWithInteger:1];
						if (iPayType <= iPartNo) {
							e6obj.nAmount = [decAmountOne decimalNumberByAdding:decAmountRest]; //最終回 decAmountOne + decAmountRest
						} else {
							e6obj.nAmount = decAmountOne;
						}
						break;
					}
				}
				if (e6obj == nil) {
					// 既存E2なし：追加する
					e2obj = [NSEntityDescription insertNewObjectForEntityForName:@"E2invoice" inManagedObjectContext:scMoc];
					e2obj.nYearMMDD = [NSNumber numberWithInteger:iYearMMDD];
					e2obj.e1paid = nil;  // 必ず一方は nil になる
					e2obj.e1unpaid = e3obj.e1card;  // E2-E1 リンク
					// E6追加
					e6obj = [NSEntityDescription insertNewObjectForEntityForName:@"E6part" inManagedObjectContext:scMoc];
					e6obj.e2invoice = e2obj;	// E6-E2 リンク　　これのより e2obj.e6parts にも加えられる。
					e6obj.e3record = e3obj; // E6-E3 リンク
					// 属性
					e6obj.nPartNo = [NSNumber numberWithInteger:iPartNo];
					e6obj.nNoCheck = [NSNumber numberWithInteger:1];
					if (iPayType <= iPartNo) {
						e6obj.nAmount = [decAmountOne decimalNumberByAdding:decAmountRest]; //最終回 decAmountOne + decAmountRest
					} else {
						e6obj.nAmount = decAmountOne;
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
						E7payment *e7obj = [NSEntityDescription insertNewObjectForEntityForName:@"E7payment" inManagedObjectContext:scMoc];
						e7obj.nYearMMDD = [NSNumber numberWithLong:iYearMMDD]; // 支払日 ＜＜締月日と違う＞＞
						e7obj.e0paid = nil;
						e7obj.e0unpaid = e0root;	// E7 <<--> E0 未払い
						e2obj.e7payment = e7obj; // E2 <<--> E7
					}
					// E1は変わらないのでsum不要
					// E6の所属が変わったので親となるE2,E7を再集計する
					[MocFunctions e2e7update:e2obj];		//e6増
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


// E3の複製を生成する  ＜＜メソッド名に copy が含まれるとAnlyzer警告が出る。 alloc,newが無いから＞＞
+ (E3record *)replicateE3record:(E3record *)e3source
{
	E3record *e3new = [NSEntityDescription insertNewObjectForEntityForName:@"E3record"
													inManagedObjectContext:e3source.managedObjectContext];
	// Copy	＜＜属性が増減すれば修正すること＞＞
	e3new.nAmount		= e3source.nAmount;		//[0.3]金額もそのままコピーする。　 [NSNumber numberWithInt:0];
	e3new.nAnnual		= e3source.nAnnual;
	e3new.nPayType		= e3source.nPayType;
	e3new.nRepeat		= e3source.nRepeat;		//[0.4]
	e3new.zName			= e3source.zName;
	e3new.zNote			= e3source.zNote;
	e3new.e1card		= e3source.e1card;
	e3new.e4shop		= e3source.e4shop;
	e3new.e5category	= e3source.e5category;
	// Initial
	e3new.dateUse		= [NSDate date];
	e3new.sumNoCheck	= [NSNumber numberWithInt:1];
	e3new.e6parts		= nil;
	//
	return e3new; //autorelese
}


// E3配下のE6.nNoCheck を 0,1 切り替えする。 E6.PAIDならば不変。
+ (void)e3check:(BOOL)bCheckOn inE3obj:(E3record *)e3obj inAlert:(BOOL)bAlert
{
	for (E6part *e6 in e3obj.e6parts) {
		// E6 Check
		[MocFunctions e6check:bCheckOn inE6obj:e6 inAlert:NO];
	}
}

// E2の Paid と Unpaid を切り替える
// bE6noCheckNext = YES: E6未チェック分を翌月以降に移動する
// [0.4]nRepeat対応
+ (void)e2paid:(E2invoice *)e2obj inE6payNextMonth:(BOOL)bE6payNextMonth
{
	NSManagedObjectContext *moc = e2obj.managedObjectContext;
	E7payment *e7old = e2obj.e7payment;
	
	if (e2obj.e1unpaid) {
		// 配下のE6が無ければE2削除する
		//if ([e2obj.e6parts count]<=0) {
		//	[self e2delete:e2obj];
		//	return;
		//}
		// 配下のE6に未チェックがあるか調べる
		//NSLog(@"***e2paid: e2obj.e6parts=(%d)=%@\n", [e2obj.e6parts count], e2obj.e6parts);
		for (E6part *e6 in e2obj.e6parts) {
			if (0 < [e6.nNoCheck intValue]) {
				if (bE6payNextMonth) {	// e6 (Unpaid) の支払日を翌月へ移す
					[MocFunctions e6payNextMonth:e6];
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
		
		// [0.4]nRepeat対応　＜＜E2,E7をPAID移行完了してからRepeat処理すること。さもなくば落ちる＞＞
		for (E6part *e6 in e2obj.e6parts) {
			E3record *e3 = e6.e3record;
			if (e3 && 0 < [e3.nRepeat integerValue]) 
			{	// E3配下をコピーして利用日を nRepeat ヶ月後にする
				E3record *e3add = [self replicateE3record:e3];	//autorelease
				// 利用日を nRepeat ヶ月後の同日にする  ＜28日以上ならば各月末にする＞
				// 元の日を求める
				NSCalendar *cal = [NSCalendar currentCalendar];
				unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
				| NSHourCalendarUnit | NSMinuteCalendarUnit;
				NSDateComponents *comp = [cal components:unitFlags fromDate:e3.dateUse];
				if (28 <= comp.day) {
					// 28日以降ならば月末にするため　翌月の前日
					comp.month += ([e3.nRepeat integerValue] + 1);	// ＋月数の翌月
					comp.day = -1;	// 前日 ⇒ 末日になる
				} else {
					comp.month += [e3.nRepeat integerValue];		// ＋月数
				}
				e3add.dateUse = [cal dateFromComponents:comp];
				// E3配下リンク等の更新処理			  inFirstYearMMDD:0=カードの締支払条件から支払日を決定する
				if ([MocFunctions e3saved:e3add inFirstYearMMDD:0]==NO) break; // ERROR
				//
				e3.nRepeat = [NSNumber numberWithInteger:0]; // 繰り返しを取り消しておく
			}
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
	
	// 移動先となる E2 を探す
	E2invoice *e2new = nil;
	for (e2new in e1card.e2paids) { // E2支払済 から探す
		if ([e2new.nYearMMDD integerValue] == iYearMMDD) {  // 支払日
			// ありましたが支払済なので、さらに翌月を探す　＜＜新規の場合だけ＞＞
			//iYearMMDD = GiAddYearMMDD(iYearMMDD, 0, +1, 0); // 翌月へ
			AzLOG(@"LOGIC ERR: E6の移動先がPAIDになっている"); //　ここを通ることは無いハズ
			return;
		}
	}
	e6obj.e2invoice = nil;
	for (e2new in e1card.e2unpaids) { // E2未払い から探す
		if ([e2new.nYearMMDD integerValue] == iYearMMDD) {  // 支払日
			// E2発見！E6リンク
			e6obj.e2invoice = e2new;	// E6-E2 リンク
			break;
		}
	}
	if (e6obj.e2invoice == nil) {
		// 既存E2なし：追加する
		e2new = [NSEntityDescription insertNewObjectForEntityForName:@"E2invoice" inManagedObjectContext:moc];
		e2new.nYearMMDD = [NSNumber numberWithInteger:iYearMMDD];
		e2new.e1paid = nil;  // 必ず一方は nil になる
		e2new.e1unpaid = e1card;  // E2-E1 リンク
		// E6リンク
		e6obj.e2invoice = e2new;	// E6-E2 リンク　　これのより e2obj.e6parts にも加えられる。
	}
	if (e2new && e2new != e2old) {
		if (e2new.e1paid) {  // PAIDでここを通ることは無いハズ！
			AzLOG(@"LOGIC ERROR: E2 NG PAID");
			return;
		}
		if (e2new.e7payment == nil) {
			// E7がリンクされていないので探してリンクする
			for (E7payment *e7obj in e0root.e7unpaids) {
				if ([e7obj.nYearMMDD integerValue] == iYearMMDD) {
					e2new.e7payment = e7obj; // E2 <<--> E7
					break;
				}
			}
		}
		if (e2new.e7payment == nil) { // 探したが、E7が無いので追加する
			E7payment *e7obj = [NSEntityDescription insertNewObjectForEntityForName:@"E7payment" inManagedObjectContext:moc];
			e7obj.nYearMMDD = [NSNumber numberWithLong:iYearMMDD]; // 支払日 ＜＜締月日と違う＞＞
			e7obj.e0paid = nil;
			e7obj.e0unpaid = e0root;	// E7 <<--> E0 未払い
			e2new.e7payment = e7obj; // E2 <<--> E7
		}
		// E1は変わらないのでsum不要
		// E6の所属が変わったので親となるE2,E7を再集計する
		[MocFunctions e2e7update:e2new];		//e6増
		[MocFunctions e2e7update:e2old];		//e6減
	}
}

// E7の Paid と Unpaid を切り替える
// bE6noCheckNext = YES: E6未チェック分を翌月以降に移動する
// [0.4]nRepeat対応
+ (void)e7paid:(E7payment *)e7obj inE6payNextMonth:(BOOL)bE6payNextMonth
{
	NSArray *aE2 = [[NSArray alloc] initWithArray:[e7obj.e2invoices allObjects]];
	// e2paid:内で配下が無くなったe7objが削除される可能性があるためコピーを使用する。
	for (E2invoice *e2 in aE2) 
	{	// 配下E2の Paid と Unpaid を切り替える
		[MocFunctions e2paid:e2 inE6payNextMonth:bE6payNextMonth];
	}
	[aE2 release];
}

// [0.4]
// iFirstYearMMDD = 最初の支払日(分割の場合、これと翌月以降になる)   =0:カードの締支払条件から自動決定する  <0:支払日のみ変更時
+ (BOOL)e3saved:(E3record *)e3node inFirstYearMMDD:(NSInteger)iFirstYearMMDD
{
	// クイック追加時、＜この時点で配下のE6は無い。また、E6が追加された後に.e1card==nilになることは無い＞
	if (e3node.e1card && 0<=iFirstYearMMDD)  // クイック追加時、カード未定(.e1card==nil)許可のため　
	{	// 配下のE6を生成または更新する			E2が PiFirstYearMMDD 
		if ([MocFunctions e3makeE6:e3node inFirstYearMMDD:iFirstYearMMDD]==NO) return NO;
	}
	
	e3node.sumNoCheck = [e3node valueForKeyPath:@"e6parts.@sum.nNoCheck"];
	
	if (e3node.e4shop) {
		E4shop *e4node = e3node.e4shop;
		e4node.sortDate = [NSDate date]; // [e4node valueForKeyPath:@"e3records.@max.dateUse"];
		e4node.sortAmount = [e4node valueForKeyPath:@"e3records.@sum.nAmount"];
		e4node.sortCount = [e4node valueForKeyPath:@"e3records.@count"];
	}
	
	if (e3node.e5category) {
		E5category *e5node = e3node.e5category;
		e5node.sortDate = [NSDate date]; // [e5node valueForKeyPath:@"e3records.@max.dateUse"];
		e5node.sortAmount = [e5node valueForKeyPath:@"e3records.@sum.nAmount"];
		e5node.sortCount = [e5node valueForKeyPath:@"e3records.@count"];
	}
	
	return YES;
}


// E7E2クリーンアップ：配下のE6が無くなったE2を削除し、さらに配下のE2が無くなったE7も削除する。
// TopMenu:viewDidAppear にて呼び出している。
+ (void)e7e2clean
{
	E0root *e0root = [MocFunctions e0root];
	BOOL bSave = NO;
	//NSManagedObjectContext *moc = e0root.managedObjectContext;

	NSArray *aE7 = [[NSArray alloc] initWithArray:[e0root.e7unpaids allObjects]]; // Unpaid側だけ処理する
	for (E7payment *e7 in aE7) // aE7一時配列要素は削除しないので reverseObjectEnumerator は不要 
	{
		NSArray *aE2 = [[NSArray alloc] initWithArray:[e7.e2invoices allObjects]];
		for (E2invoice *e2 in aE2) // aE2一時配列要素は削除しないので reverseObjectEnumerator は不要 
		{
			if (e2.e6parts==nil OR [e2.e6parts count]<=0) {
				e2.e1paid = nil;
				e2.e1unpaid = nil;
				e2.e7payment = nil;
				[scMoc deleteObject:e2]; // moc要素削除
				e2 = nil;
				bSave = YES;
			}
		}
		[aE2 release];
		
		if (e7.e2invoices==nil OR [e7.e2invoices count]<=0) {
			e7.e0paid = nil;
			e7.e0unpaid = nil;
			[scMoc deleteObject:e7]; // moc要素削除
			e7 = nil;
			bSave = YES;
		}
	}
	[aE7 release];

	if (bSave) [MocFunctions commit]; // 保存
}



@end
