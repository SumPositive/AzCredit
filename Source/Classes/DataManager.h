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

// E0配下をDATAへ書き出す
- (void)coreExport:(void(^)(BOOL success, NSData* exportData))completion;
// NSDataを読み込んでE0配下を更新する
- (void)coreImportData:(NSData*)importData completion:(void(^)(BOOL success))completion;

// iCloud
- (void)iCloudUpload:(void(^)(BOOL success))completion;
- (void)iCloudDownloadAlert;
//- (void)iCloudDownload:(void(^)(BOOL success))completion;


@end
