//
//  FileCsv.m
//  AzCredit
//
//  Created by 松山 和正 on 10/03/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "EntityRelation.h"
#import "FileCsv.h"


@implementation FileCsv

static NSData *MdLF;
static NSData *MdCR;
static NSMutableString *MzCsvStr;
static NSMutableArray	*MaCsv; // getMaCsv()
static unsigned long MulStart;
static unsigned long MulEnd;
static long	MlCsvLine;

// string ⇒ csv : 文字列中にあるCSV予約文字を取り除くか置き換えてCSV保存できるようにする
static NSString *strToCsv( NSString *inStr ) {
	if (inStr && [inStr length]) {
		// 文字列中にある["]ダブルクォーテーションを[']シングルに置き換えてCSV保存できるようにする
		return [inStr stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];  // ["]-->>[']
	}
	return @"";
}

// csv ⇒ string : CSVから取得した文字列の前後にある["]ダブルクォーテーションを取り除く（無ければ何もしない）
static NSString *csvToStr( NSString *inCsv ) {
	if ([inCsv length]) {
		// 文字列中にある["]ダブルクォーテーションを[]空文字に置き換える
		return [inCsv stringByReplacingOccurrencesOfString:@"\"" withString:@""];  // ["]-->>[]
	}
	return @"";
}


+ (NSString *)zSave: (E0root *)Pe0root toLocalFileName:(NSString *)PzFname
{
	NSAutoreleasePool *autoPool = [[NSAutoreleasePool alloc] init];	// [0.3]autorelease独自解放のため

	NSString *zErrMsg = NSLocalizedString(@"File write error",nil);
	NSString *home_dir = NSHomeDirectory();
	NSString *doc_dir = [home_dir stringByAppendingPathComponent:@"Documents"];
	NSString *csvPath = [doc_dir stringByAppendingPathComponent:PzFname]; //GD_CSVFILENAME]; // ローカルファイル名

	NSManagedObjectContext *context = Pe0root.managedObjectContext;
	NSEntityDescription *entity;
	NSError *error = nil;
	
	// 	@finally にて release する。
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// E1,E8 Sort
	NSSortDescriptor *key1 = [[NSSortDescriptor alloc] initWithKey:@"nRow" ascending:YES];
	NSArray *sortRow = [[NSArray alloc] initWithObjects:key1, nil];  [key1 release];
	// E4,E5 Sort
	NSSortDescriptor *key2 = [[NSSortDescriptor alloc] initWithKey:@"sortDate" ascending:NO];
	NSArray *sortDate = [[NSArray alloc] initWithObjects:key2, nil];  [key2 release];
	
	// 出力ファイルをCREATE
	[[NSFileManager defaultManager] createFileAtPath:csvPath contents:nil attributes:nil];
	// 出力ファイルをOPEN
	NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:csvPath];
	@try {
		NSStringEncoding enc = NSUTF8StringEncoding; //(NSStringEncoding)[NSString availableStringEncodings];
		NSString *str;

		//----------------------------------------------------------------------------Header
		str = GD_PRODUCTNAME  @",CSV,UTF-8,Copyright,(C)2000-2010,Azukid,,,\n";
		[output writeData:[str dataUsingEncoding:enc allowLossyConversion:YES]];

		//----------------------------------------------------------------------------Structure
		
		//----------------------------------------------------------------------------[Begin]
		str = @"Begin,,,,,,,,\n";
		[output writeData:[str dataUsingEncoding:enc allowLossyConversion:YES]];
		
	
		//----------------------------------------------------------------------------[Shop] E4shop
		entity = [NSEntityDescription entityForName:@"E4shop" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDate]; // Sorting
		error = nil;
		NSArray *e4shops = [Pe0root.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (error) {
			AzLOG(@"Error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		
		for (E4shop *e4node in e4shops) {
			//--------------------------------------E4 (nRow昇順)
			if (e4node.zName != nil) {	// nilやブランクはSAVE時に拒否して存在しないハズだが念のために除外する
				// トリム（両端のスペース除去）　＜＜Load時に zNameで検索するから厳密にする＞＞
				NSString *zName = [e4node.zName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				if (0 < [zName length]) {
					if (e4node.zNote == nil) e4node.zNote = @"";
					// E4,zName,zNote,sortDate,sortCount,sortAmount,sortName,
					//str = [NSString stringWithFormat:@"Shop,\"%@\",\"%@\",%@,%ld,%ld,\"%@\",\n",   autoreleseを減らすため
					str = [[NSString alloc] initWithFormat:@"Shop,\"%@\",\"%@\",%@,%ld,%ld,\"%@\",\n", 
						   strToCsv(zName), 
						   strToCsv(e4node.zNote), 
						   [e4node.sortDate description], 
						   (long)[e4node.sortCount integerValue], 
						   (long)[e4node.sortAmount integerValue], 
						   strToCsv(e4node.sortName)];
					[output writeData:[str dataUsingEncoding:enc allowLossyConversion:YES]];
					[str release];
				}
			}
		}
		
		//----------------------------------------------------------------------------[Cat] E5category
		entity = [NSEntityDescription entityForName:@"E5category" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDate]; // Sorting
		error = nil;
		NSArray *e5categorys = [Pe0root.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (error) {
			AzLOG(@"Error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		
		for (E5category *e5node in e5categorys) {
			//--------------------------------------E5 (nRow昇順)
			if (e5node.zName != nil) {	// nilやブランクはSAVE時に拒否して存在しないハズだが念のために除外する
				// トリム（両端のスペース除去）　＜＜Load時に zNameで検索するから厳密にする＞＞
				NSString *zName = [e5node.zName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				if (0 < [zName length]) {
					// E5,zName,zNote,sortDate,sortCount,sortAmount,sortName,
					str = [[NSString alloc] initWithFormat:@"Cat,\"%@\",\"%@\",%@,%ld,%ld,\"%@\",\n", 
						   strToCsv(zName), 
						   strToCsv(e5node.zNote), 
						   [e5node.sortDate description], 
						   (long)[e5node.sortCount integerValue], 
						   (long)[e5node.sortAmount integerValue], 
						   strToCsv(e5node.sortName)];
					[output writeData:[str dataUsingEncoding:enc allowLossyConversion:YES]];
					[str release];
				}
			}
		}
		
		//----------------------------------------------------------------------------[Bank] E8bank
		entity = [NSEntityDescription entityForName:@"E8bank" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortRow]; // Sorting
		error = nil;
		NSArray *e8banks = [Pe0root.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (error) {
			AzLOG(@"Error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		
		for (E8bank *e8node in e8banks) {
			//--------------------------------------E8 (nRow昇順)
			if (e8node.zName != nil) {	// nilやブランクはSAVE時に拒否して存在しないハズだが念のために除外する
				// トリム（両端のスペース除去）　＜＜Load時に zNameで検索するから厳密にする＞＞
				NSString *zName = [e8node.zName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				if (0 < [zName length]) {
					if (e8node.zNote == nil) e8node.zNote = @"";
					// E8,zName,zNote,
					str = [[NSString alloc] initWithFormat:@"Bank,\"%@\",\"%@\",\n", 
						   strToCsv(zName), 
						   strToCsv(e8node.zNote)];
					[output writeData:[str dataUsingEncoding:enc allowLossyConversion:YES]];
					[str release];
				}
			}
		}
		
		//----------------------------------------------------------------------------[Card] E1card
		entity = [NSEntityDescription entityForName:@"E1card" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortRow]; // Sorting
		error = nil;
		NSArray *e1cards = [Pe0root.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (error) {
			AzLOG(@"Error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		
		for (E1card *e1node in e1cards) {
			//--------------------------------------E1 (nRow昇順)
			// E1,zName,nClosingDay,nPayMonth,nPayDay,nBonus1,nBonus2,zNote,zBank,
			str = [[NSString alloc] initWithFormat:@"Card,\"%@\",%d,%d,%d,%d,%d,\"%@\",\"%@\",\n", 
				   strToCsv(e1node.zName), 
				   [e1node.nClosingDay intValue], 
				   [e1node.nPayMonth intValue], 
				   [e1node.nPayDay intValue], 
				   [e1node.nBonus1 intValue], 
				   [e1node.nBonus2 intValue],
				   strToCsv(e1node.zNote),
				   strToCsv(e1node.e8bank.zName)];
			[output writeData:[str dataUsingEncoding:enc allowLossyConversion:YES]];
			[str release];
			
			//----------------------------------------------------------E1-->>E3 [Rec]
			for (E3record *e3node in e1node.e3records) {
				//--------------------------------------E3
				if (e3node.zName == nil) e3node.zName = @"";
				if (e3node.zNote == nil) e3node.zNote = @"";
				NSString *zShop = @"";
				if (e3node.e4shop && e3node.e4shop.zName) zShop = e3node.e4shop.zName;
				NSString *zCategory = @"";
				if (e3node.e5category && e3node.e5category.zName) zCategory = e3node.e5category.zName;
				// E3,dateUse,nAmount,nPayType,nAnnual,zShop,zCategory,zName,zNote,
				//str = [NSString stringWithFormat:@"Rec,%@,%ld,%d,%f,\"%@\",\"%@\",\"%@\",\"%@\",\n", 
				str = [[NSString alloc] initWithFormat:@"Rec,%@,%ld,%d,%f,\"%@\",\"%@\",\"%@\",\"%@\",\n", 
					   [e3node.dateUse description], 
					   (long)[e3node.nAmount integerValue], 
					   [e3node.nPayType intValue], 
					   [e3node.nAnnual floatValue], 
					   strToCsv(zShop), 
					   strToCsv(zCategory),
					   strToCsv(e3node.zName),
					   strToCsv(e3node.zNote)];
				[output writeData:[str dataUsingEncoding:enc allowLossyConversion:YES]];
				[str release]; // autorelease使用せず！
				
				//----------------------------------------------------------E3-->>E6 [Pay]
				for (E6part *e6node in e3node.e6parts) {
					//--------------------------------------E6
					NSInteger iYearMMDD = [e6node.e2invoice.nYearMMDD integerValue];
					
					NSString *zPaid = @""; // Unpaid
					if (e6node.e2invoice.e7payment.e0paid) zPaid = @"Paid"; // 1文字"P"だけでも有効
					
					NSString *zCheck = @"ck"; // 1文字でも入っておれば「Check済」扱い
					if (0 < [e6node.nNoCheck intValue]) zCheck = @""; // 未Check
					
					// E6,iYearMMDD,zPaid,lAmount,fInterest,bChecked,
					str = [[NSString alloc] initWithFormat:@"Pay,%ld,%@,%ld,%ld,%@,\n", 
						   iYearMMDD, 
						   zPaid, 
						   [e6node.nAmount longValue], 
						   [e6node.nInterest longValue], 
						   zCheck];
					[output writeData:[str dataUsingEncoding:enc allowLossyConversion:YES]];
					[str release]; // autorelease使用せず！
				}
			}
		}
		
	
		//----------------------------------------------------------------------------[End]
		str = @"End,,,,,,,,\n";
		[output writeData:[str dataUsingEncoding:enc allowLossyConversion:YES]];
		// Compleat !!
		zErrMsg = nil; // OK
	}
	@catch (NSException *errEx) {
		NSString *name = [errEx name];
		AzLOG(@"Err: %@ : %@\n", name, [errEx reason]);
		if ([name isEqualToString:NSRangeException])
			NSLog(@"Exception was caught successfully.\n");
		else
			[errEx raise];
	}
	@finally {
		// CLOSE
		[output closeFile];
		// release
		[fetchRequest release];
		[sortRow release];
		[sortDate release];
		[autoPool release];
	}
	return zErrMsg;
}

+ (BOOL)getMaCsv: (NSFileHandle *)fileHandle
{
	NSData *dDQ = [@"\"" dataUsingEncoding:NSUTF8StringEncoding]; // ["]ダブルクォーテーション
	NSData *one;
	BOOL bDQSection = NO;
	// 1行を切り出す
	MlCsvLine++;
	while (one = [fileHandle readDataOfLength:1]) { 
		if ([one length] <= 0) {
			AzLOG(@"Break1");
			break;	// ファイル終端
		}
		// ["]文字列区間にあるCRやLFは無視するための処理
		if ([one isEqualToData:dDQ]) bDQSection = !bDQSection; // ["]区間判定　トグルになる
		// 文字列区間でないところに、CRやLFがあれば行末と判断する
		if (!bDQSection && ([one isEqualToData:MdLF] || [one isEqualToData:MdCR])) break; // 行末
	}
	
	MulEnd = [fileHandle offsetInFile]; // [LF]または[CR]の次の位置を示す
	if (MulEnd <= MulStart) {
		AzLOG(@"Break2");
		return NO;	// ファイル終端
	}
	if ([one length] <= 0) MulEnd++; // ファイル末尾対策  ＜＜これが無いと "End"の[d]が欠ける＞＞
	
	// [CRLF] [LFCR] 対応のため、次の1バイトを調べてCRまたはLFならば終端を1バイト進める
	one = [fileHandle readDataOfLength:1]; // 次の1バイトを先取りしておく 「次の読み込みの開始位置をセットする」ために使用
	
	// 最初に見つかった[CR]または[LF]の直前までを切り出して文字列にする
	[fileHandle seekToFileOffset:MulStart];

	NSData *data = [fileHandle readDataOfLength:(MulEnd - MulStart - 1)];  // 1行分読み込み
	NSString *csvStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[MzCsvStr setString:csvStr];
	[MzCsvStr appendString:@",,,,,,,,,,"]; // 最大項目数以上追加しておく
	[csvStr release];	// 行毎に生成＆破棄
	AzLOG(@"%@", MzCsvStr);
	[MaCsv setArray:[MzCsvStr componentsSeparatedByString:@","]];
	
	//NSString *csvSplit = [csvStr stringByAppendingString:@",,,,,,,,,,"]; // 最大項目数以上追加しておく
	//[csvStr release];	// 行毎に生成＆破棄
	//AzLOG(@"%@", csvSplit);
	// さらに、切り出した文字列をCSV区切りで配列に切り出す
	//NSArray *csvArray = [csvSplit componentsSeparatedByString:@","];
	//[MaCsv setArray:[csvSplit componentsSeparatedByString:@","]];
	
	AzLOG(@"%ld(%@,%@,%@)", MlCsvLine, [MaCsv objectAtIndex:0], [MaCsv objectAtIndex:1], [MaCsv objectAtIndex:2]);
	
	// 次の読み込みの開始位置をセットする
	// 次の1バイトが[CR]または[LF]ならば、さらに1バイト進める
	if ([one isEqualToData:MdLF] || [one isEqualToData:MdCR]) MulEnd++; // 終端を1バイト進める
	
	// 次の開始位置をセット
	MulStart = MulEnd;
	[fileHandle seekToFileOffset:MulStart];
	
	return YES;
}

+ (NSString *)zLoad: (E0root *)Pe0root fromLocalFileName:(NSString *)PzFname
{
	NSAutoreleasePool *autoPool = [[NSAutoreleasePool alloc] init];	// [0.3]autorelease独自解放のため

	NSString *home_dir = NSHomeDirectory();
	NSString *doc_dir = [home_dir stringByAppendingPathComponent:@"Documents"];
	NSString *csvPath = [doc_dir stringByAppendingPathComponent:PzFname];  //GD_CSVFILENAME];		
	
	long	lE1nRow = 0;
	
	E1card		*ActE1card = nil;
	E3record	*ActE3record = nil;
	NSInteger	iPrevE6YearMMDD = 0;
	NSInteger	iE1nPayMonth = 0;
	NSInteger	iE6partNo = 0;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];  // @finallyにてrelease
	[dateFormatter setTimeStyle:NSDateFormatterFullStyle];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
	
	NSManagedObjectContext *context = Pe0root.managedObjectContext;
	NSError *err = nil;
	NSString *zErrMsg = nil;
	MulStart = 0;
	MulEnd = 0;
	MlCsvLine = 0;
	MaCsv = [[NSMutableArray alloc] init];  // @finallyにてrelease
	MzCsvStr = [[NSMutableString alloc] init];  // @finallyにてrelease
	
	unsigned char uChar[1];
	uChar[0] = 0x0a; // LF(0x0a)
	MdLF = [[NSData alloc] initWithBytes:uChar length:1];  // @finallyにてrelease
	uChar[0] = 0x0d; // CR(0x0d)
	MdCR = [[NSData alloc] initWithBytes:uChar length:1];  // @finallyにてrelease
	// input OPEN
	NSFileHandle *csvHandle = [NSFileHandle fileHandleForReadingAtPath:csvPath];
	@try {
		// 全データをクリアする　＜ E0root だけが残る＞
		[EntityRelation allReset];
		// ここではSAVEしない。CSV読み込み成功時にSAVEする

		while (1) {
			// "AzCredit,CSV,UTF-8,Copyright,(C)2000-2010,Azukid,,,\n";
			if (![self getMaCsv:csvHandle]) { // EOF
				@throw NSLocalizedString(@"Err CsvHeaderNG",nil);
			}
			if ([[MaCsv objectAtIndex:0] isEqualToString:GD_PRODUCTNAME]
			 && [[MaCsv objectAtIndex:1] isEqualToString:@"CSV"]) {
				break; // OK
			} 
		}
		
		while ( [self getMaCsv:csvHandle] ) 
		{
			//--------------------------------------------------------------------------------[Shop] E4
			if ([[MaCsv objectAtIndex:0] isEqualToString:@"Shop"]) 
			{	// Shop,zName,zNote,sortDate,sortCount,sortAmount,sortName,
				// トリム（両端のスペース除去）　＜＜Load時に zNameで検索するから厳密にする＞＞
				NSString *zName = [csvToStr([MaCsv objectAtIndex:1]) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				if (![zName isEqualToString:@""])
				{ // zNameが有効
					E4shop *e4node = [NSEntityDescription insertNewObjectForEntityForName:@"E4shop" inManagedObjectContext:context];
					e4node.zName = zName; // csvToStr()後にトリム済み
					e4node.zNote = csvToStr([MaCsv objectAtIndex:2]);
					e4node.sortDate = [dateFormatter dateFromString:[MaCsv objectAtIndex:3]];
					e4node.sortCount = [NSNumber numberWithInteger:[[MaCsv objectAtIndex:4] integerValue]];
					e4node.sortAmount = [NSNumber numberWithInteger:[[MaCsv objectAtIndex:5] integerValue]];
					e4node.sortName = csvToStr([MaCsv objectAtIndex:6]);
				}
			} 
			//--------------------------------------------------------------------------------[Cat] E5
			else if ([[MaCsv objectAtIndex:0] isEqualToString:@"Cat"]) 
			{	// Cat,zName,zNote,sortDate,sortCount,sortAmount,sortName,
				NSString *zName = [csvToStr([MaCsv objectAtIndex:1]) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				if (![zName isEqualToString:@""]) 
				{ // zNameが有効
					E5category *e5node = [NSEntityDescription insertNewObjectForEntityForName:@"E5category" inManagedObjectContext:context];
					e5node.zName = zName;
					e5node.zNote = csvToStr([MaCsv objectAtIndex:2]);
					e5node.sortDate = [dateFormatter dateFromString:[MaCsv objectAtIndex:3]];
					e5node.sortCount = [NSNumber numberWithInteger:[[MaCsv objectAtIndex:4] integerValue]];
					e5node.sortAmount = [NSNumber numberWithInteger:[[MaCsv objectAtIndex:5] integerValue]];
					e5node.sortName = csvToStr([MaCsv objectAtIndex:6]);
				}
			} 
			//--------------------------------------------------------------------------------[Bank] E8
			else if ([[MaCsv objectAtIndex:0] isEqualToString:@"Bank"]) 
			{	// Bank,zName,zNote,
				NSString *zName = [csvToStr([MaCsv objectAtIndex:1]) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				if (![zName isEqualToString:@""]) 
				{ // zNameが有効
					E8bank *e8node = [NSEntityDescription insertNewObjectForEntityForName:@"E8bank" inManagedObjectContext:context];
					e8node.zName = zName;
					e8node.zNote = csvToStr([MaCsv objectAtIndex:2]);
				}
			} 
			//--------------------------------------------------------------------------------[Card] E1
			else if ([[MaCsv objectAtIndex:0] isEqualToString:@"Card"]) 
			{	// E1,zName,nClosingDay,nPayMonth,nPayDay,nBonus1,nBonus2,zNote,zBank,
				ActE1card = nil;
				// トリム（両端のスペース除去）　＜＜Load時に zNameで検索するから厳密にする＞＞
				NSString *zName = [csvToStr([MaCsv objectAtIndex:1]) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				if (![zName isEqualToString:@""])
				{ // zNameが有効
					// Add E1
					E1card *e1node = [NSEntityDescription insertNewObjectForEntityForName:@"E1card" inManagedObjectContext:context];
					ActE1card = e1node; // E3のため
					iE1nPayMonth = [[MaCsv objectAtIndex:3] integerValue]; // 支払日から締め日を求めるのに使用
					e1node.nRow = [NSNumber numberWithLong:(lE1nRow++)]; // 代入してからインクリメント
					e1node.zName = zName;
					e1node.nClosingDay = [NSNumber numberWithInteger:[[MaCsv objectAtIndex:2] integerValue]];
					e1node.nPayMonth = [NSNumber numberWithInteger:iE1nPayMonth];
					e1node.nPayDay = [NSNumber numberWithInteger:[[MaCsv objectAtIndex:4] integerValue]];
					e1node.nBonus1 = [NSNumber numberWithInteger:[[MaCsv objectAtIndex:5] integerValue]];
					e1node.nBonus2 = [NSNumber numberWithInteger:[[MaCsv objectAtIndex:6] integerValue]];
					e1node.zNote = csvToStr([MaCsv objectAtIndex:7]);
					NSString *zBank = [csvToStr([MaCsv objectAtIndex:8]) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
					// E8Bank
					if (![zBank isEqualToString:@""]) {
						// 検索して、あればリンク、無ければ追加してリンク
						NSFetchRequest *request = [[NSFetchRequest alloc] init];
						[request setEntity:[NSEntityDescription entityForName:@"E8bank" inManagedObjectContext:context]];
						[request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", @"zName", zBank]];
						// コンテキストにリクエストを送る
						NSArray* aRes = [context executeFetchRequest:request error:&err];
						[request release];
						if (0 < [aRes count]) {
							// Find & Link
							e1node.e8bank = [aRes objectAtIndex:0];
						} else {
							// ＜＜手作業でCSV作成や変更された場合、先にLoadされていなくても対応するため＞＞
							E8bank *e8node = [NSEntityDescription insertNewObjectForEntityForName:@"E8bank" inManagedObjectContext:context];
							e8node.zName = zBank;
							//e8node.zNote = nil;
							// Add & Link
							e1node.e8bank = e8node;
						}
					}
				}
			} 
			//--------------------------------------------------------------------------------[Rec] E3
			else if ([[MaCsv objectAtIndex:0] isEqualToString:@"Rec"] && ActE1card) 
			{ // E3,dateUse,nAmount,nPayType,nAnnual,zShop,zCategory,zName,zNote,
				ActE3record = nil;
				NSDate *dateUse = [dateFormatter dateFromString:[MaCsv objectAtIndex:1]];
				// AzLOG(@"(2)'%@'  (3)'%@'", [MaCsv objectAtIndex:2], [MaCsv objectAtIndex:3]);
				NSInteger lAmount = [[MaCsv objectAtIndex:2] integerValue];  // longValueだとFreeze
				NSInteger lPayType = [[MaCsv objectAtIndex:3] integerValue];	// NSString に longValue は無い
				NSInteger lAnnual = [[MaCsv objectAtIndex:4] integerValue];
				NSString *zShop = [csvToStr([MaCsv objectAtIndex:5]) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				NSString *zCategory = [csvToStr([MaCsv objectAtIndex:6]) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				// CHECK
				if (lAmount <= 0 OR 99999999 < lAmount) {
					@throw NSLocalizedString(@"STOP E3nAmountNG",nil);
				}
				if (lPayType < 1 OR 102 < lPayType) {
					@throw NSLocalizedString(@"STOP E3nPayTypeNG",nil);
				}

				E3record *e3node = [NSEntityDescription insertNewObjectForEntityForName:@"E3record" inManagedObjectContext:context];
				e3node.e1card = ActE1card;
				e3node.dateUse = dateUse;
				e3node.nAmount = [NSNumber numberWithLong:lAmount];
				e3node.nPayType = [NSNumber numberWithLong:lPayType];
				e3node.nAnnual = [NSNumber numberWithLong:lAnnual];
				// E4shop
				if (![zShop isEqualToString:@""]) {
					// 検索して、あればリンク、無ければ追加してリンク
					NSFetchRequest *request = [[NSFetchRequest alloc] init];
					[request setEntity:[NSEntityDescription entityForName:@"E4shop" inManagedObjectContext:context]];
					[request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", @"zName", zShop]];
					// コンテキストにリクエストを送る
					NSArray* aRes = [context executeFetchRequest:request error:&err];
					[request release];
					if (0 < [aRes count]) {
						// Find & Link
						e3node.e4shop = [aRes objectAtIndex:0];
					} else {
						// ＜＜手作業でCSV作成や変更された場合、先にLoadされていなくても対応するため＞＞
						E4shop *e4node = [NSEntityDescription insertNewObjectForEntityForName:@"E4shop" inManagedObjectContext:context];
						e4node.zName = zShop;
						e4node.sortName = zShop;
						e4node.sortDate = e3node.dateUse;
						e4node.sortAmount = e3node.nAmount;
						e4node.sortCount = [NSNumber numberWithInteger:1];
						// Add & Link
						e3node.e4shop = e4node;
					}
				}
				// E5category 
				if (![zCategory isEqualToString:@""]) {
					// 検索して、あればリンク、無ければ追加してリンク
					NSFetchRequest *request = [[NSFetchRequest alloc] init];
					[request setEntity:[NSEntityDescription entityForName:@"E5category" inManagedObjectContext:context]];
					[request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", @"zName", zCategory]];
					// コンテキストにリクエストを送る
					NSArray* aRes = [context executeFetchRequest:request error:&err];
					[request release];
					if (0 < [aRes count]) {
						// Find & Link
						e3node.e5category = [aRes objectAtIndex:0];
					} else {
						// ＜＜手作業でCSV作成や変更された場合、先にLoadされていなくても対応するため＞＞
						E5category *e5node = [NSEntityDescription insertNewObjectForEntityForName:@"E5category" inManagedObjectContext:context];
						e5node.zName = zCategory;
						e5node.sortName = zCategory;
						e5node.sortDate = e3node.dateUse;
						e5node.sortAmount = e3node.nAmount;
						e5node.sortCount = [NSNumber numberWithInteger:1];
						// Add & Link
						e3node.e5category = e5node;
					}
				}
				e3node.zName = csvToStr([MaCsv objectAtIndex:7]);
				e3node.zNote = csvToStr([MaCsv objectAtIndex:8]);
				ActE3record = e3node; // E6のため
				iPrevE6YearMMDD = 0;
				iE6partNo = 1;
			}
			//--------------------------------------------------------------------------------[Pay] E6
			else if ([[MaCsv objectAtIndex:0] isEqualToString:@"Pay"] && ActE3record) 
			{ // E6,iYearMMDD,zPaid,lAmount,fInterest,bChecked,
				NSInteger iYearMMDD = [[MaCsv objectAtIndex:1] integerValue]; // 支払日
				if (iYearMMDD < AzMIN_YearMMDD OR AzMAX_YearMMDD < iYearMMDD) {
					@throw NSLocalizedString(@"STOP E6iYearMMDDNG",nil);
				}
				else if (iYearMMDD/100 <= iPrevE6YearMMDD/100) {
					@throw NSLocalizedString(@"STOP E6lYearMM-NG",nil);
				}
				iPrevE6YearMMDD = iYearMMDD;
				
				NSString *zPaid = [[MaCsv objectAtIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				BOOL bPaid = YES;
				if ([zPaid isEqualToString:@""]) bPaid = NO;
				
				NSInteger iAmount = [[MaCsv objectAtIndex:3] integerValue];
				if (iAmount < 1 OR 99999999 < iAmount) {
					@throw NSLocalizedString(@"STOP E6iAmountNG",nil);
				}

				float fInterest = [[MaCsv objectAtIndex:4] floatValue];
				if (fInterest < 0 OR 90 < fInterest) {
					@throw NSLocalizedString(@"STOP E6fInterestNG",nil);
				}
				
				NSString *zCheck = [[MaCsv objectAtIndex:5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				NSInteger iNoCheck = 0;
				if ([zCheck isEqualToString:@""]) iNoCheck = 1;
				
				// Add E6
				E6part *e6node = [NSEntityDescription insertNewObjectForEntityForName:@"E6part" inManagedObjectContext:context];
				e6node.nPartNo = [NSNumber numberWithInteger:(iE6partNo++)]; // 代入してからインクリメント
				e6node.nAmount = [NSNumber numberWithInteger:iAmount];
				e6node.nInterest =  [NSNumber numberWithFloat:fInterest];
				e6node.nNoCheck = [NSNumber numberWithInteger:iNoCheck];
				e6node.e3record = ActE3record;
				// E3 sum
				ActE3record.sumNoCheck = [ActE3record valueForKeyPath:@"e6parts.@sum.nNoCheck"];
				
				// E2invoice 該当あればリンク、無ければ追加してリンク
				NSSet *e2nodes;
				if (bPaid) {
					e2nodes = ActE1card.e2paids;
				} else {
					e2nodes = ActE1card.e2unpaids;
				}
				for (E2invoice *e2node in e2nodes) {
					if ([e2node.nYearMMDD integerValue] == iYearMMDD) {
						e6node.e2invoice = e2node;
						break;
					}
				}
				if (e6node.e2invoice == nil) {
					// Add & Link
					E2invoice *e2node = [NSEntityDescription insertNewObjectForEntityForName:@"E2invoice" inManagedObjectContext:context];
					e2node.nYearMMDD = [NSNumber numberWithLong:iYearMMDD];
					if (bPaid) {
						e2node.e1paid = ActE1card;
						e2node.e1unpaid = nil; 
					} else {
						e2node.e1paid = nil;
						e2node.e1unpaid = ActE1card;
					}
					//e2node.e7payment = 以下のE7処理にてセット 
					// Add & Link
					e6node.e2invoice = e2node;
				}

				// E7payment 該当あればリンク、無ければ追加してリンク
				NSSet *e7nodes;
				if (bPaid) {
					e7nodes = Pe0root.e7paids;
				} else {
					e7nodes = Pe0root.e7unpaids;
				}
				for (E7payment *e7node in e7nodes) {
					if ([e7node.nYearMMDD integerValue] == iYearMMDD) { // 支払日
						e6node.e2invoice.e7payment = e7node;
						break;
					}
				}
				if (e6node.e2invoice.e7payment == nil) {
					// Add & Link
					E7payment *e7node = [NSEntityDescription insertNewObjectForEntityForName:@"E7payment" inManagedObjectContext:context];
					e7node.nYearMMDD = [NSNumber numberWithLong:iYearMMDD]; // 支払日
					if (bPaid) {
						e7node.e0paid = Pe0root;
						e7node.e0unpaid = nil;
					} else {
						e7node.e0paid = nil;
						e7node.e0unpaid = Pe0root;
					}
					//e2node.e7payment = 以下のE7処理にてセット 
					// Add & Link
					e6node.e2invoice.e7payment = e7node;
				}
			}
		} // End of while ( [self getMaCsv:csvHandle] ) 

		//--------------------------------------------------------------------------sum
		// E2 sum値　集計
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:@"E2invoice" inManagedObjectContext:context]];
		NSArray* aE2nodes = [context executeFetchRequest:request error:&err];
		[request release];
		for (E2invoice *e2node in aE2nodes) {
			e2node.sumAmount = [e2node valueForKeyPath:@"e6parts.@sum.nAmount"];
			e2node.sumNoCheck = [e2node valueForKeyPath:@"e6parts.@sum.nNoCheck"];
		}
		// E7 sum値　集計
		for (E7payment *e7node in Pe0root.e7paids) {
			e7node.sumAmount = [e7node valueForKeyPath:@"e2invoices.@sum.sumAmount"];
			e7node.sumNoCheck = [e7node valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
		}
		for (E7payment *e7node in Pe0root.e7unpaids) {
			e7node.sumAmount = [e7node valueForKeyPath:@"e2invoices.@sum.sumAmount"];
			e7node.sumNoCheck = [e7node valueForKeyPath:@"e2invoices.@sum.sumNoCheck"];
		}
		// E4 sort値　集計
		request = [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:@"E4shop" inManagedObjectContext:context]];
		NSArray* aE4nodes = [context executeFetchRequest:request error:&err];
		[request release];
		for (E4shop *e4 in aE4nodes) {
			e4.sortDate =	[e4 valueForKeyPath:@"e3records.@max.dateUse"];
			e4.sortAmount = [e4 valueForKeyPath:@"e3records.@sum.nAmount"];
			e4.sortCount =	[e4 valueForKeyPath:@"e3records.@count"];
		}
		// E5 sort値　集計
		request = [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:@"E5category" inManagedObjectContext:context]];
		NSArray* aE5nodes = [context executeFetchRequest:request error:&err];
		[request release];
		for (E5category *e5 in aE5nodes) {
			e5.sortDate =	[e5 valueForKeyPath:@"e3records.@max.dateUse"];
			e5.sortAmount = [e5 valueForKeyPath:@"e3records.@sum.nAmount"];
			e5.sortCount =	[e5 valueForKeyPath:@"e3records.@count"];
		}
		//
		// E8bank 事前集計は無い、リスト表示時に集計している
		//
		//--------------------------------------------------------------------------SAVE
		if (![context save:&err]) {
			NSLog(@"Unresolved error %@, %@", err, [err userInfo]);
			@throw NSLocalizedString(@"Err CoreData",nil);
		}
		// Compleat !!
		zErrMsg = nil; // OK
	}
	@catch (NSException *errEx) {
		if (!zErrMsg) zErrMsg = NSLocalizedString(@"File read error", @"CSV読み込み失敗");
		NSString *name = [errEx name];
		AzLOG(@"◆ %@ : %@\n", name, [errEx reason]);
		if ([name isEqualToString:NSRangeException]) {
			AzLOG(@"Exception was caught successfully.\n");
		} else {
			[errEx raise];
		}
	}
	@catch (NSString *errMsg) {
		zErrMsg = [NSString stringWithFormat:@"FileCsv (%ld) %@", MlCsvLine, errMsg];
	}
	@finally {
		// CLOSE
        [csvHandle closeFile];
		// release
		[MaCsv release];
		[MdCR release];
		[MdLF release];
		[MzCsvStr release];
		[dateFormatter release];
		[autoPool release];
	}	
	return zErrMsg;
}

@end
