//
//  EntityRelation.h
//  AzCredit
//
//  Created by 松山 和正 on 10/03/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MocFunctions : NSObject {
}


// クラスメソッド（グローバル関数）
+ (void)setMoc:(NSManagedObjectContext *)moc;
+ (id)insertAutoEntity:(NSString *)zEntityName;
+ (void)deleteEntity:(NSManagedObject *)entity;
+ (BOOL)commit;
+ (void)rollBack;
+ (NSArray *)select:(NSString *)zEntity
			  limit:(NSInteger)iLimit
			 offset:(NSInteger)iOffset
			  where:(NSPredicate *)predicate
			   sort:(NSArray *)arSort;

+ (void)allReset;

+ (E0root *)e0root;

+ (void)e1delete:(E1card *)e1obj;
+ (void)e1update:(E1card *)e1obj;

+ (E2invoice *)e2invoice:(E1card *)e1card inYearMMDD:(NSInteger)iYearMMDD;
+ (void)e2e7update:(E2invoice *)e2;
+ (void)e2delete:(E2invoice *)e2obj;
+ (void)e2paid:(E2invoice *)e2obj inE6payNextMonth:(BOOL)bE6payNextMonth;

+ (E3record *)replicateE3record:(E3record *)e3source;
+ (void)e3check:(BOOL)bCheckOn inE3obj:(E3record *)e3obj inAlert:(BOOL)bAlert;
+ (void)e3delete:(E3record *)e3obj;
+ (BOOL)e3makeE6:(E3record *)e3obj inFirstYearMMDD:(NSInteger)iFirstYearMMDD;
+ (BOOL)e3saved:(E3record *)e3node inFirstYearMMDD:(NSInteger)iFirstYearMMDD;

+ (void)e6check:(BOOL)bCheckOn inE6obj:(E6part *)e6obj inAlert:(BOOL)bAlert;
+ (void)e6payNextMonth:(E6part *)e6obj;

+ (void)e7paid:(E7payment *)e7obj inE6payNextMonth:(BOOL)bE6payNextMonth;
+ (void)e7e2clean;

@end
