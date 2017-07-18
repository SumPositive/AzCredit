//
//  UpdateVC.m
//  PayNote
//
//  Created by 松山正和 on 2017/07/17.
//
//

#import "UpdateVC.h"
#import "FileCsv.h"



@interface UpdateVC ()
{
    IBOutlet UIButton*   cloudSaveButton;
    IBOutlet UIButton*   appStoreButton;
    IBOutlet UIButton*   closeButton;
    
}
@end

@implementation UpdateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Action


#define UPLOAD_FILENAME         @"AzCredit1_999.csv"
#define NEW_APP_ID              @"432458298"            // 新しい「クレメモ」1.2.x


- (IBAction)cloudSaveButtonTap:(UIButton *)button
{
    button.enabled = NO;
    
    
    // CSV make ---> Document file
    NSString* zErr = [FileCsv zSave:self.Re0root toLocalFileName:UPLOAD_FILENAME];
    if (zErr) {
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:NSLocalizedString(@"Upload Fail",nil)
//                              message:zErr
//                              delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//        [alert show];
        
        [self aleartTitle:NSLocalizedString(@"Upload Fail",nil)
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
        
        return;
    }

    // iCloud Drive
    NSURL* url = [fm URLForUbiquityContainerIdentifier:nil];
    NSURL* fileUrl = [url URLByAppendingPathComponent:@"AzCreditData"];
    NSLog(@"fileUrl: %@", fileUrl);
    // WRITE
    @try {
        if ([csvString writeToURL:fileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
            AzLOG(@"writeToURL: OK");
        }else{
            AzLOG(@"writeToURL: NG");
        }
        // OK
        
        
    } @catch (NSException *exception) {
        AzLOG(@"writeToURL: @catch: %@", exception);
        
    } @finally {
        AzLOG(@"writeToURL: @finally");
        button.enabled = YES;
    }
}

- (IBAction)appStoreButtonTap:(UIButton *)button
{
    button.enabled = NO;
    NSString* urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", NEW_APP_ID];
    NSURL* url= [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)closeButtonTap:(UIButton *)button
{
    button.enabled = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}







@end
