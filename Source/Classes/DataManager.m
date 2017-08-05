//
//  DataManager.m
//  PayNote
//
//  Created by 松山正和 on 2017/07/22.
//
//

#import "DataManager.h"
#import "FileCsv.h"


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
    // iCloud Drive 実験
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* url = [fm URLForUbiquityContainerIdentifier:ICLOUD_CONTAINER];
    NSURL* fileUrl = [url URLByAppendingPathComponent:ICLOUD_FILENAME];
    AzLOG(@"fileUrl: %@", fileUrl);
    return fileUrl;
}

// 保存
- (void)iCloudUpload
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Saveing",nil)];
    
    
    E0root *e0node = [MocFunctions e0root];
    // E0配下をファイルへ書き出す
    NSString* zErr = [FileCsv zSave:e0node toLocalFileName:ICLOUD_FILENAME];
    if (zErr) {
        [SVProgressHUD dismiss];
        [AZAlert target:nil
                  title:NSLocalizedString(@"iCloud Upload Fail",nil)
                message:NSLocalizedString(@"iCloud Upload NoData",nil)
                b1title:@"OK"
                b1style:UIAlertActionStyleDefault
               b1action:nil];
        return;
    }
    
    // /Documentのパスの取得
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // ファイル名の作成
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:ICLOUD_FILENAME];
    NSError *error = nil;
    // ファイルを読み出して文字列化する
    NSString *csvString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        [SVProgressHUD dismiss];
        AzLOG(@"stringWithContentsOfFile: NG : %@", error.localizedDescription);
        [AZAlert target:nil
                  title:NSLocalizedString(@"iCloud Upload Fail",nil)
                message:NSLocalizedString(@"iCloud Upload NoData",nil)
                b1title:@"OK"
                b1style:UIAlertActionStyleDefault
               b1action:nil];
        return;
    }
    
    // WRITE
    @try {
        NSError *error = nil;
        // 文字列化したものをiCloudへ書き込む
        if ([csvString writeToURL:[self iCloudFileUrl]
                       atomically:YES
                         encoding:NSUTF8StringEncoding
                            error:&error]) {
            
            AzLOG(@"writeToURL: OK");
            [AZAlert target:nil
                      title:NSLocalizedString(@"iCloud Upload Success",nil)
                    message:nil
                    b1title:@"OK"
                    b1style:UIAlertActionStyleDefault
                   b1action:nil];
        }else{
            AzLOG(@"writeToURL: NG : %@", error.localizedDescription);
            [AZAlert target:nil
                      title:NSLocalizedString(@"iCloud Upload Fail",nil)
                    message:NSLocalizedString(@"iCloud Upload NoData",nil)
                    b1title:@"OK"
                    b1style:UIAlertActionStyleDefault
                   b1action:nil];
        }
        // OK
        
        
    } @catch (NSException *exception) {
        AzLOG(@"writeToURL: @catch: %@", exception);
        [AZAlert target:nil
                  title:NSLocalizedString(@"iCloud Upload Fail",nil)
                message:nil
                b1title:@"OK"
                b1style:UIAlertActionStyleDefault
               b1action:nil];
        
    } @finally {
        AzLOG(@"writeToURL: @finally");
        [SVProgressHUD dismiss];
    }
}

UIAlertController* alertController = nil;
// 読み込む
- (void)iCloudDownload
{
    [AZAlert target:nil
              title:NSLocalizedString(@"iCloud Download WARN", nil)
            message:nil
            b1title:NSLocalizedString(@"iCloud Download", nil)
            b1style:UIAlertActionStyleDestructive
           b1action:^(UIAlertAction * _Nullable action) {
               // Download to iCloud

               //[SVProgressHUD showWithStatus:NSLocalizedString(@"Loading",nil)];
               // CoreDataがメインスレッドで動くのでプログラス処理が止まる。
               // なので、応急措置としてアラートトースト表示して待たせる。
               alertController = [AZAlert target:nil
                                           title:NSLocalizedString(@"Loading", nil)
                                         message:NSLocalizedString(@"Weiting", nil)
                                      completion:^{
                                          // メインスレッド
                                          [self iCloudDownloadTask];
                                      }];
           }
            b2title:NSLocalizedString(@"Cancel", nil)
            b2style:UIAlertActionStyleCancel
           b2action:nil];
}

- (void)iCloudDownloadTask
{
    // READ
    @try {
        NSString* csvString = [NSString stringWithContentsOfURL:[self iCloudFileUrl]
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
        AzLOG(@"iCloudDownloadTask: csvString: %@", csvString);
        if (csvString.length < 10) {
            //[SVProgressHUD dismiss];
            [alertController dismissViewControllerAnimated:NO completion:nil]; alertController = nil;
            [AZAlert target:nil
                      title:NSLocalizedString(@"iCloud Download Fail",nil)
                    message:NSLocalizedString(@"iCloud Download NoData",nil)
                    b1title:@"OK"
                    b1style:UIAlertActionStyleDefault
                   b1action:nil];
            return;
        }
        // ファイルへ書き込む
        // /Documentのパスの取得
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        // ファイル名の作成
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:ICLOUD_FILENAME];
        NSError *error = nil;
        [csvString writeToFile:filePath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:&error];
        if (error) {
            //[SVProgressHUD dismiss];
            [alertController dismissViewControllerAnimated:NO completion:nil]; alertController = nil;
            [AZAlert target:nil
                      title:NSLocalizedString(@"iCloud Download Fail",nil)
                    message:NSLocalizedString(@"iCloud Download NoData",nil)
                    b1title:@"OK"
                    b1style:UIAlertActionStyleDefault
                   b1action:nil];
            return;
        }
        
        E0root *e0node = [MocFunctions e0root];
        // CSVファイルを読み込んでクレメモ情報を更新する
        NSString* zErr = [FileCsv zLoad:e0node fromLocalFileName:ICLOUD_FILENAME];
        //[SVProgressHUD dismiss];
        [alertController dismissViewControllerAnimated:NO completion:nil]; alertController = nil;
        if (zErr) {
            AzLOG(@"FileCsv zLoad: %@", zErr);
            [AZAlert target:nil
                      title:NSLocalizedString(@"iCloud Download Fail",nil)
                    message:NSLocalizedString(@"iCloud Download NoData",nil)
                    b1title:@"OK"
                    b1style:UIAlertActionStyleDefault
                   b1action:nil];
            return;
        }
        [AZAlert target:nil
                  title:NSLocalizedString(@"iCloud Download Success",nil)
                message:nil
                b1title:@"OK"
                b1style:UIAlertActionStyleDefault
               b1action:nil];
        
    } @catch (NSException *exception) {
        AzLOG(@"iCloudDownloadTask: @catch: %@", exception);
        //[SVProgressHUD dismiss];
        [alertController dismissViewControllerAnimated:NO completion:nil]; alertController = nil;
        [AZAlert target:nil
                  title:NSLocalizedString(@"iCloud Download Fail",nil)
                message:NSLocalizedString(@"iCloud Download NoData",nil)
                b1title:@"OK"
                b1style:UIAlertActionStyleDefault
               b1action:nil];

    } @finally {
        AzLOG(@"iCloudDownloadTask: @finally");
        //[SVProgressHUD dismiss];
        [alertController dismissViewControllerAnimated:NO completion:nil]; alertController = nil;
    }
}

@end
