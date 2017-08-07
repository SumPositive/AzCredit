//
//  DataManager.h
//  PayNote
//
//  Created by 松山正和 on 2017/07/22.
//
//

#import <Foundation/Foundation.h>
#import "Global.h"
#import "AppDelegate.h"
#import "Entity.h"
#import "MocFunctions.h"

#import "SVProgressHUD.h"
#import "AZAlert.h"


#define UKVS_UPLOAD_DATE        @"UKVS_UPLOAD_DATE"


@interface DataManager : NSObject

+ (DataManager*)singleton;

// iCloud
- (void)iCloudUpload;
- (void)iCloudDownloadAlert;
- (void)iCloudDownload;


@end