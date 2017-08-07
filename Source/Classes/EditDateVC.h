//
//  EditDateVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E3record;
@class CalcView;

@interface EditDateVC : UIViewController

@property (nonatomic, assign)	  id		delegate;
@property (nonatomic, assign) NSInteger	PiMinYearMMDD;
@property (nonatomic, assign) NSInteger	PiMaxYearMMDD;

- (instancetype)initWithE3:(E3record*)e3 orE6:(E6part*)e6; // NS_DESIGNATED_INITIALIZER;

@end
