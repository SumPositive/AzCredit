//
//  E1editBonusVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class E1card;

@interface E1editBonusVC : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) E1card		*Re1edit;

@end
