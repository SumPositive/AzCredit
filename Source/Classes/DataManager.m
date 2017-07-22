//
//  DataManager.m
//  PayNote
//
//  Created by 松山正和 on 2017/07/22.
//
//

#import "DataManager.h"
#import "FileCsv.h"


#define UPLOAD_FILENAME         @"PayNote_1.data"
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

// iCloud
- (void)iCloudUpload
{
    [SVProgressHUD show];

    E0root *e0node = [MocFunctions e0root];
    // CSV make ---> Document file
    NSString* zErr = [FileCsv zSave:e0node toLocalFileName:UPLOAD_FILENAME];
    if (zErr) {
        [SVProgressHUD dismiss];
        [AZAlert target:nil
                  title:NSLocalizedString(@"Upload Fail NoData",nil)
                message:zErr
                b1title:@"OK"
                b1style:UIAlertActionStyleDefault
               b1action:nil];
        return;
    }
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
    // Document file ---> NSString
    // /Documentのパスの取得
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // ファイル名の作成
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:UPLOAD_FILENAME];
    NSError *error = nil;
    NSString *csvString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        [SVProgressHUD dismiss];
        [AZAlert target:nil
                  title:NSLocalizedString(@"Upload Fail",nil)
                message:zErr
                b1title:@"OK"
                b1style:UIAlertActionStyleDefault
               b1action:nil];
        return;
    }
    
    // iCloud Drive
    NSURL* url = [fm URLForUbiquityContainerIdentifier:nil];
    NSURL* fileUrl = [url URLByAppendingPathComponent:@"AzCreditData"];
    NSLog(@"fileUrl: %@", fileUrl);
    // WRITE
    @try {
        NSError *error = nil;
        if ([csvString writeToURL:fileUrl atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
            AzLOG(@"writeToURL: OK");
            [AZAlert target:nil
                      title:NSLocalizedString(@"Upload OK",nil)
                    message:nil
                    b1title:@"OK"
                    b1style:UIAlertActionStyleDefault
                   b1action:nil];
        }else{
            AzLOG(@"writeToURL: NG : %@", error.localizedDescription);
            [AZAlert target:nil
                      title:NSLocalizedString(@"Upload Fail",nil)
                    message:error.localizedDescription
                    b1title:@"OK"
                    b1style:UIAlertActionStyleDefault
                   b1action:nil];
        }
        // OK
        
        
    } @catch (NSException *exception) {
        AzLOG(@"writeToURL: @catch: %@", exception);
        [AZAlert target:nil
                  title:NSLocalizedString(@"Upload Fail",nil)
                message:nil
                b1title:@"OK"
                b1style:UIAlertActionStyleDefault
               b1action:nil];
        
    } @finally {
        AzLOG(@"writeToURL: @finally");
        [SVProgressHUD dismiss];
    }
}



@end
