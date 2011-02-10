//
//  FileCsv.h
//  AzCredit
//
//  Created by 松山 和正 on 10/03/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileCsv : NSObject {
	//--------------------------retain
	//--------------------------assign
	
// クラスメソッド（グローバル関数）につきインスタンス変数は使えない
//@private
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
/*	E0root		*Me0root;
	E2invoice	*Me2invoices;
	E3record	*Me3records;
	E6part		*Me6parts;
	E7payment	*Me7payments;
	
	NSData *MdLF;
	NSData *MdCR;
	NSMutableString *MzCsvStr;
	NSMutableArray	*MaCsv; // getMaCsv()

	//----------------------------------------------------------------autoreleaseにつきdealloc時のrelese不要
	//----------------------------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------------------------assign
	unsigned long MulStart;
	unsigned long MulEnd;
	long	MlCsvLine;
 */
}

// クラスメソッド（グローバル関数）
+ (NSString *)zSave: (E0root *)Pe0root toLocalFileName:(NSString *)PzFname;
+ (BOOL)getMaCsv: (NSFileHandle *)fileHandle;
+ (NSString *)zLoad: (E0root *)Pe0root fromLocalFileName:(NSString *)PzFname;

@end
