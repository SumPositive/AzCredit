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
    // Upload to iCloud
    [DataManager.singleton iCloudUpload];
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
