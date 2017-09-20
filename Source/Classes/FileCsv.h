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
//@private
	//----------------------------------------------------------------viewDidLoadでnil, dealloc時にrelese
	//----------------------------------------------------------------autoreleaseにつきdealloc時のrelese不要
	//----------------------------------------------------------------Owner移管につきdealloc時のrelese不要
	//----------------------------------------------------------------assign
}

// クラスメソッド（グローバル関数）
+ (NSString *)zSave: (E0root *)Pe0root toTempFileName:(NSString *)PzFname;
+ (BOOL)getMaCsv: (NSFileHandle *)fileHandle;
+ (NSString *)zLoad: (E0root *)Pe0root fromTempFileName:(NSString *)PzFname;

@end
