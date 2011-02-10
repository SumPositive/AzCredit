//
//  SampleTVC.h
//  AzPacking
//
//  Created by 松山 和正 on 10/01/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLDownload.h"


@interface SampleTVC : UITableViewController <URLDownloadDeleagte, UIActionSheetDelegate> {
	NSManagedObjectContext *PmanagedObjectContext;
	NSInteger PiSelectedRow;  //Downloadの新規追加される行になる
}

@property (nonatomic, retain) NSManagedObjectContext *PmanagedObjectContext;
@property NSInteger PiSelectedRow;

@end
