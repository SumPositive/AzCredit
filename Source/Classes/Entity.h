//
//  Entity.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
// *************************************************************************
// エンティティを追加したとき、以下の対応も忘れずに！！！
//		EntityRelation.m - (void)allReset リスト前に削除する処理
//		FileCsv.m - I/O
// *************************************************************************
//
#import <Foundation/Foundation.h>

#define AzDataModelVersion	4	//[0.4]


//---------------------------------------------------------------------------------------E0
@interface E0root : NSManagedObject {	// applicationDidFinishLaunchingにて1個だけ生成
}
@property (nonatomic, retain) NSSet				*e7paids;		// E0 <-->> E7
@property (nonatomic, retain) NSSet				*e7unpaids;		// E0 <-->> E7
@end

//---------------------------------------------------------------------------------------E8
@interface E8bank : NSManagedObject {	// [0.3]New
}
@property (nonatomic, retain) NSNumber   *nRow;
@property (nonatomic, retain) NSString   *zName;
@property (nonatomic, retain) NSString	 *zNote;
@property (nonatomic, retain) NSSet		 *e1cards;		// E8 <-->> E1
@end

//---------------------------------------------------------------------------------------E1
@interface E1card : NSManagedObject {
}
@property (nonatomic, retain) NSNumber	*nBonus1;		// ボーナス月1
@property (nonatomic, retain) NSNumber	*nBonus2;		// ボーナス月2 
@property (nonatomic, retain) NSNumber	*nClosingDay;	// 締日 1〜28,29=末日,    0=Debit(利用日⇒支払日)	
@property (nonatomic, retain) NSNumber	*nPayDay;		// 支払日 1〜28,29=末日,  Debit(0〜99)日後支払
@property (nonatomic, retain) NSNumber	*nPayMonth;		// 支払月 (0)当月　(1)翌月　(2)翌々月
@property (nonatomic, retain) NSNumber	*nRow;
@property (nonatomic, retain) NSString	*zName;
@property (nonatomic, retain) NSString	*zNote;
@property (nonatomic, retain) NSSet		*e2paids;		// E1 <-->> E2
@property (nonatomic, retain) NSSet		*e2unpaids;		// E1 <-->> E2
@property (nonatomic, retain) NSSet		*e3records;		// E1 <-->> E3
@property (nonatomic, retain) E8bank	*e8bank;		// E1 <<--> E8	[0.3]
@end

// coalesce these into one @interface E1card (CoreDataGeneratedAccessors) section
@interface E1card (CoreDataGeneratedAccessors)
	- (void)addChildsObject:(NSManagedObject *)value;
	- (void)removeChildsObject:(NSManagedObject *)value;
	- (void)addChilds:(NSSet *)value;
	- (void)removeChilds:(NSSet *)value;
@end

//---------------------------------------------------------------------------------------E7
@interface E7payment : NSManagedObject {
}
@property (nonatomic, retain) NSNumber	 *nYearMMDD;	// 支払日 (1〜31)
@property (nonatomic, retain) NSDecimalNumber	 *sumAmount;	// e2invoices.@sum.nAmount
@property (nonatomic, retain) NSNumber   *sumNoCheck;	// e2invoices.@sum.nNoCheck
@property (nonatomic, retain) NSSet		 *e2invoices;	// E7 <-->> E2
@property (nonatomic, retain) E0root	 *e0paid;		// E7 <<--> E0
@property (nonatomic, retain) E0root	 *e0unpaid;		// E7 <<--> E0
@end

//---------------------------------------------------------------------------------------E2
@interface E2invoice : NSManagedObject {
}
@property (nonatomic, retain) NSNumber	*nYearMMDD;		// 支払日 (1〜31)
@property (nonatomic, retain) NSDecimalNumber	*sumAmount;		// e6parts.@sum.nAmount
@property (nonatomic, retain) NSNumber	*sumNoCheck;	// e6parts.@sum.nNoCheck
@property (nonatomic, retain) E1card	*e1paid;		// E2 <<--> E1
@property (nonatomic, retain) E1card	*e1unpaid;		// E2 <<--> E1
@property (nonatomic, retain) NSSet		*e6parts;		// E2 <-->> E6
@property (nonatomic, retain) E7payment	*e7payment;		// E2 <<--> E7
@end

@interface E2invoice (CoreDataGeneratedAccessors)
	- (void)addChildsObject:(NSManagedObject *)value;
	- (void)removeChildsObject:(NSManagedObject *)value;
	- (void)addChilds:(NSSet *)value;
	- (void)removeChilds:(NSSet *)value;
@end

//---------------------------------------------------------------------------------------E4
@interface E4shop : NSManagedObject {
}
@property (nonatomic, retain) NSDecimalNumber	*sortAmount;
@property (nonatomic, retain) NSNumber	*sortCount;
@property (nonatomic, retain) NSDate	*sortDate;
@property (nonatomic, retain) NSString  *sortName;
@property (nonatomic, retain) NSString  *zName;
@property (nonatomic, retain) NSString	*zNote;
@property (nonatomic, retain) NSSet		*e3records;		// E4 <-->> E3
@end

//---------------------------------------------------------------------------------------E5
@interface E5category : NSManagedObject {
}
@property (nonatomic, retain) NSDecimalNumber	*sortAmount;
@property (nonatomic, retain) NSNumber	*sortCount;
@property (nonatomic, retain) NSDate	*sortDate;
@property (nonatomic, retain) NSString  *sortName;
@property (nonatomic, retain) NSString  *zName;
@property (nonatomic, retain) NSString	*zNote;
@property (nonatomic, retain) NSSet		*e3records;		// E5 <-->> E3
@end

//---------------------------------------------------------------------------------------E3
@interface E3record : NSManagedObject {
}
@property (nonatomic, retain) NSDate	 *dateUse;		// NSDateは、UTC(+0000)協定時刻で記録 ⇒ 表示でタイムゾーン変換する
@property (nonatomic, retain) NSDecimalNumber   *nAmount;
@property (nonatomic, retain) NSNumber   *nAnnual;		// Float 年利
@property (nonatomic, retain) NSNumber   *nPayType;		// (1)一括　(2〜99)分割　　(101)ボーナス1回 (201)支払日指定
@property (nonatomic, retain) NSNumber   *nRepeat;		//[0.4] (0)なし　(1)1ヶ月後　(2)2ヶ月後　(12)1年後
@property (nonatomic, retain) NSNumber   *sumNoCheck;	// e6parts @sum nNoCheck
@property (nonatomic, retain) NSString   *zName;
@property (nonatomic, retain) NSString	 *zNote;
@property (nonatomic, retain) E1card	 *e1card;		// E3 <<--> E1
@property (nonatomic, retain) E4shop	 *e4shop;		// E3 <<--> E4
@property (nonatomic, retain) E5category *e5category;	// E3 <<--> E5
@property (nonatomic, retain) NSSet		 *e6parts;		// E3 <-->> E6
@end

//---------------------------------------------------------------------------------------E6
@interface E6part : NSManagedObject {
}
@property (nonatomic, retain) NSDecimalNumber	 *nAmount;		// 金額（元金）
@property (nonatomic, retain) NSDecimalNumber	 *nInterest;	// 利息金額
@property (nonatomic, retain) NSNumber   *nNoCheck;
@property (nonatomic, retain) NSNumber	 *nPartNo;		// 分割回（1〜99）
@property (nonatomic, retain) E2invoice	 *e2invoice;	// E6 <<--> E2
@property (nonatomic, retain) E3record	 *e3record;		// E6 <<--> E3
@end

// END
