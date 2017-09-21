//
//  DataManager.m
//  PayNote
//
//  Created by 松山正和 on 2017/07/22.
//
//

#import "DataManager.h"
#import "FileCsv.h"
#import "TopMenuTVC.h"


#define ICLOUD_CONTAINER        @"iCloud.com.azukid.PayNote"
#define ICLOUD_FILENAME         @"PayNote_1.data"
#define NEW_APP_ID              @"432458298"            // 新しい「クレメモ」1.2.x


@interface DataManager ()

@end

@implementation DataManager

static DataManager* _singleton = nil;

+ (DataManager*)singleton
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [DataManager new];
    });
    return _singleton;
}


#pragma mark - Public methods

// iCloud Drive

- (NSURL*)iCloudFileUrl
{
    // iCloud Drive
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* url = [fm URLForUbiquityContainerIdentifier:ICLOUD_CONTAINER]; //ICLOUD_CONTAINER
    NSURL* fileUrl = [url URLByAppendingPathComponent:ICLOUD_FILENAME];
    AzLOG(@"fileUrl: %@", fileUrl);
    if (fileUrl == nil) {
        [AZAlert target:nil
                  title:NSLocalizedString(@"iCloud nil",nil)
                message:nil
                b1title:@"OK"
                b1style:UIAlertActionStyleDefault
               b1action:nil];
    }
    return fileUrl;
}

// E0配下をNSDataへ書き出す
- (void)coreExport:(void(^)(BOOL success, NSData* exportData))completion
{
    assert([NSThread isMainThread]);

    E0root *e0node = [MocFunctions e0root];
    NSString* zErr = [FileCsv zSave:e0node toTempFileName:ICLOUD_FILENAME];
    if (zErr) {
        // NG
        completion(NO,nil);
        return;
    }
    // 一時ファイルパス
    NSString *csvPath = [NSTemporaryDirectory() stringByAppendingPathComponent:ICLOUD_FILENAME];
    //
    NSData* exportData = [NSData dataWithContentsOfFile:csvPath];
    // OK
    completion(YES, exportData);
}

// NSDataを読み込んでE0配下を更新する
- (void)coreImportData:(NSData*)importData completion:(void(^)(BOOL success))completion
{
    // 一時ファイルパス
    NSString *csvPath = [NSTemporaryDirectory() stringByAppendingPathComponent:ICLOUD_FILENAME];
    // ファイルへ書き込む
    NSError *error = nil;
    [importData writeToFile:csvPath options:NSDataWritingAtomic error:&error];
    if (error) {
        completion(NO);
        return;
    }

    if ([NSThread isMainThread]) {
        E0root *e0node = [MocFunctions e0root];
        NSString* zErr = [FileCsv zLoad:e0node fromTempFileName:ICLOUD_FILENAME];
        if (zErr) {
            completion(NO);
        } else {
            completion(YES);
        }
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            E0root *e0node = [MocFunctions e0root];
            NSString* zErr = [FileCsv zLoad:e0node fromTempFileName:ICLOUD_FILENAME];
            if (zErr) {
                completion(NO);
            } else {
                completion(YES);
            }
        });
    }
}

// 保存
- (void)iCloudUpload:(void(^)(BOOL success))completion
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Saveing",nil)];
    
    [self coreExport:^(BOOL success, NSData *exportData) {
        if (success) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                
                NSError *error = nil;
                [exportData writeToURL:[self iCloudFileUrl] options:NSDataWritingAtomic error:&error];
                
                [SVProgressHUD dismiss];
                if (error) {
                    AzLOG(@"writeToURL: NG : %@", error.localizedDescription);
                    completion(NO);
                } else {
                    AzLOG(@"writeToURL: OK");
                    completion(YES);
                }
            });
        }
        else {
            [SVProgressHUD dismiss];
            completion(NO);
        }
    }];
}

UIAlertController* alertController = nil;
// 読み込む
- (void)iCloudDownloadAlert
{
    [AZAlert target:nil
              title:NSLocalizedString(@"iCloud Download WARN", nil)
            message:nil
            b1title:NSLocalizedString(@"iCloud Download", nil)
            b1style:UIAlertActionStyleDestructive
           b1action:^(UIAlertAction * _Nullable action) {
               // Download to iCloud
               [self iCloudDownload:^(BOOL success) {
                   if (success) {
                       [AZAlert target:nil
                                 title:NSLocalizedString(@"iCloud Download Success",nil)
                               message:nil
                               b1title:@"OK"
                               b1style:UIAlertActionStyleDefault
                              b1action:nil];
                       //
                       if (IS_PAD) {
                           // TopMenuTVCにある 「未払合計額」を再描画するための処理
                           AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                           UINavigationController* naviLeft = [apd.mainSplit.viewControllers objectAtIndex:0];    //[0]Left
                           TopMenuTVC* tvc = (TopMenuTVC *)[naviLeft.viewControllers objectAtIndex:0]; //<<<.topViewControllerではダメ>>>
                           if ([tvc respondsToSelector:@selector(refreshTopMenuTVC)]) {    // メソッドの存在を確認する
                               [tvc refreshTopMenuTVC]; // 「未払合計額」再描画を呼び出す
                           }
                       }
                   }
                   else {
                       [AZAlert target:nil
                                 title:NSLocalizedString(@"iCloud Download Fail",nil)
                               message:NSLocalizedString(@"iCloud Download NoData",nil)
                               b1title:@"OK"
                               b1style:UIAlertActionStyleDefault
                              b1action:nil];
                   }
               }];
           }
            b2title:NSLocalizedString(@"Cancel", nil)
            b2style:UIAlertActionStyleCancel
           b2action:nil];
}

- (void)iCloudDownload:(void(^)(BOOL success))completion
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading",nil)];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSData* importData = [NSData dataWithContentsOfURL:[self iCloudFileUrl]];
        if (importData) {
            //dispatch_sync(dispatch_get_main_queue(), ^{
                [self coreImportData:importData completion:^(BOOL success) {
                    [SVProgressHUD dismiss];
                    if (success) {
                        completion(YES);
                    }else{
                        completion(NO);
                    }
                }];
            //});
        }else{
            [SVProgressHUD dismiss];
            completion(NO);
        }
    });
}


@end
