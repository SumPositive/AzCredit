//
//  UpdateVC.m
//  PayNote
//
//  Created by 松山正和 on 2017/07/17.
//
//

#import "UpdateVC.h"
#import "FileCsv.h"
#import <StoreKit/StoreKit.h>



@interface UpdateVC () <SKStoreProductViewControllerDelegate>
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
    // Upload to iCloud
    [DataManager.singleton iCloudUpload];
}

- (IBAction)appStoreButtonTap:(UIButton *)button
{
    [self showSKStoreProductViewControllerWithProductID:NEW_APP_ID];
}

- (IBAction)closeButtonTap:(UIButton *)button
{
    button.enabled = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

// アプリ内AppStore画面を表示するメソッド  (SKStoreKit.framework)
- (void)showSKStoreProductViewControllerWithProductID:(NSString*)productID {
    SKStoreProductViewController *productViewController = [[SKStoreProductViewController alloc] init];
    productViewController.delegate = self;
    
    [self presentViewController:productViewController animated:YES completion:^() {
        
        NSDictionary *parameters = @{SKStoreProductParameterITunesItemIdentifier:productID};
        [productViewController loadProductWithParameters:parameters
                                         completionBlock:^(BOOL result, NSError *error)
         {
             if (!result) {
                 // エラーのときの処理
                 [AZAlert target:nil
                           title:NSLocalizedString(@"AppStore Not Open",nil)
                         message:error.localizedDescription
                         b1title:@"OK"
                         b1style:UIAlertActionStyleDefault
                        b1action:^(UIAlertAction * _Nullable action) {
                            //[productViewController dismissViewControllerAnimated:YES completion:nil];
                        }];
             }
         }];
    }];
}

#pragma mark - <SKStoreProductViewControllerDelegate>
// キャンセルボタンが押されたときの処理
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}








@end
