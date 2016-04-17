//
//  main.m
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
    @autoreleasepool {
  //int retVal = UIApplicationMain(argc, argv, nil, nil); ------ MainWindow.xlb を使う場合（標準）
		int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
    return retVal;
    }
}
