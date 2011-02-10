//
//  Entity.m
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Entity.h"


//---------------------------------------------------------------------------------------E0
@implementation E0root
@dynamic e7paids;
@dynamic e7unpaids;
@end

//---------------------------------------------------------------------------------------E8 [0.3]New
@implementation E8bank
@dynamic nRow;
@dynamic zName;
@dynamic zNote;
@dynamic e1cards;
@end

//---------------------------------------------------------------------------------------E1 
@implementation E1card
@dynamic nBonus1;
@dynamic nBonus2;
@dynamic nClosingDay;
@dynamic nPayDay;
@dynamic nPayMonth;
@dynamic nRow;
@dynamic zName;
@dynamic zNote;
@dynamic e2paids;
@dynamic e2unpaids;
@dynamic e3records;
@dynamic e8bank;
@end

//---------------------------------------------------------------------------------------E7
@implementation E7payment
@dynamic nYearMMDD;
@dynamic sumAmount;
@dynamic sumNoCheck;
@dynamic e2invoices;	// E7 <-->> E2
@dynamic e0paid;		// E7 <<--> E0
@dynamic e0unpaid;		// E7 <<--> E0
@end

//---------------------------------------------------------------------------------------E2 
@implementation E2invoice
@dynamic nYearMMDD;
@dynamic sumAmount;
@dynamic sumNoCheck;
@dynamic e1paid;
@dynamic e1unpaid;
@dynamic e6parts;
@dynamic e7payment;
@end

//---------------------------------------------------------------------------------------E4shop
@implementation E4shop
@dynamic sortAmount;
@dynamic sortCount;
@dynamic sortDate;
@dynamic sortName;
@dynamic zName;
@dynamic zNote;
@dynamic e3records;
@end

//---------------------------------------------------------------------------------------E5category
@implementation E5category
@dynamic sortAmount;
@dynamic sortCount;
@dynamic sortDate;
@dynamic sortName;
@dynamic zName;
@dynamic zNote;
@dynamic e3records;
@end

//---------------------------------------------------------------------------------------E3
@implementation E3record
@dynamic dateUse;
@dynamic nAmount;
@dynamic nAnnual;
@dynamic nPayType;
@dynamic nReservType;
@dynamic sumNoCheck;
@dynamic zName;
@dynamic zNote;
@dynamic e1card;
@dynamic e4shop;
@dynamic e5category;
@dynamic e6parts;
@end

//---------------------------------------------------------------------------------------E6
@implementation E6part
@dynamic nAmount;
@dynamic nInterest;	// 利息金額
@dynamic nNoCheck;
@dynamic nPartNo;
@dynamic e2invoice;		// E6 <<--> E2
@dynamic e3record;		// E6 <<--> E3
@end

// END