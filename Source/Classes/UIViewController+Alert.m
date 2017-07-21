//
//  UIViewController+Alert.m
//  Common
//
//  Created by matsuyama on 2017/07/18.
//  Copyright © 2017年 jmas. All rights reserved.
//

#import "UIViewController+Alert.h"

#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"
#import "UIAlertController+Blocks.h"



@implementation UIViewController (Alert)

- (instancetype)aleartTitle:(NSString*)title
            message:(NSString*)message
            b1title:(NSString*)b1title
            b1style:(UIAlertActionStyle)b1style
           b1action:(AlertActionBlock)b1action
{
//    [self aleartTitle: title
//              message: message
//              b1title: b1title
//              b1style: b1style
//             b1action: b1action
//              b2title: nil  b2style: UIAlertActionStyleDefault  b2action: nil
//              b3title: nil  b3style: UIAlertActionStyleDefault  b3action: nil
//              b4title: nil  b4style: UIAlertActionStyleDefault  b4action: nil
//              b5title: nil  b5style: UIAlertActionStyleDefault  b5action: nil
//     ];

    UIAlertController *alertController
    = [UIAlertController alertControllerWithTitle: title
                                          message: message
                                   preferredStyle: UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle: b1title
                                                        style: b1style
                                                      handler: b1action ]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

- (instancetype)aleartTitle:(NSString*)title
            message:(NSString*)message
            b1title:(NSString*)b1title
            b1style:(UIAlertActionStyle)b1style
           b1action:(AlertActionBlock)b1action
            b2title:(NSString*)b2title
            b2style:(UIAlertActionStyle)b2style
           b2action:(AlertActionBlock)b2action
{
//    [self aleartTitle: title
//              message: message
//              b1title: b1title
//              b1style: b1style
//             b1action: b1action
//              b2title: b2title
//              b2style: b2style
//             b2action: b2action
//              b3title: nil  b3style: UIAlertActionStyleDefault  b3action: nil
//              b4title: nil  b4style: UIAlertActionStyleDefault  b4action: nil
//              b5title: nil  b5style: UIAlertActionStyleDefault  b5action: nil
//     ];

    UIAlertController *alertController
    = [UIAlertController alertControllerWithTitle: title
                                          message: message
                                   preferredStyle: UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle: b1title
                                                        style: b1style
                                                      handler: b1action ]];
    
    [alertController addAction:[UIAlertAction actionWithTitle: b2title
                                                        style: b2style
                                                      handler: b2action ]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

//- (void)aleartTitle:(NSString*)title
//            message:(NSString*)message
//            b1title:(NSString*)b1title
//            b1style:(UIAlertActionStyle)b1style
//           b1action:(void (^ __nullable)())b1action
//            b2title:(NSString*)b2title
//            b2style:(UIAlertActionStyle)b2style
//           b2action:(void (^ __nullable)())b2action
//            b3title:(NSString*)b3title
//            b3style:(UIAlertActionStyle)b3style
//           b3action:(void (^ __nullable)())b3action
//{
//    [self aleartTitle: title
//              message: message
//              b1title: b1title
//              b1style: b1style
//             b1action: b1action
//              b2title: b2title
//              b2style: b2style
//             b2action: b2action
//              b3title: b3title
//              b3style: b3style
//             b3action: b3action
//              b4title: nil  b4style: UIAlertActionStyleDefault  b4action: nil
//              b5title: nil  b5style: UIAlertActionStyleDefault  b5action: nil
//     ];
//}
//
//- (void)aleartTitle:(NSString*)title
//            message:(NSString*)message
//            b1title:(NSString*)b1title
//            b1style:(UIAlertActionStyle)b1style
//           b1action:(void (^ __nullable)())b1action
//            b2title:(NSString*)b2title
//            b2style:(UIAlertActionStyle)b2style
//           b2action:(void (^ __nullable)())b2action
//            b3title:(NSString*)b3title
//            b3style:(UIAlertActionStyle)b3style
//           b3action:(void (^ __nullable)())b3action
//            b4title:(NSString*)b4title
//            b4style:(UIAlertActionStyle)b4style
//           b4action:(void (^ __nullable)())b4action
//{
//    [self aleartTitle: title
//              message: message
//              b1title: b1title
//              b1style: b1style
//             b1action: b1action
//              b2title: b2title
//              b2style: b2style
//             b2action: b2action
//              b3title: b3title
//              b3style: b3style
//             b3action: b3action
//              b4title: b4title
//              b4style: b4style
//             b4action: b4action
//              b5title: nil  b5style: UIAlertActionStyleDefault  b5action: nil
//     ];
//}
//
//- (void)aleartTitle:(NSString*)title
//            message:(NSString*)message
//            b1title:(NSString*)b1title
//            b1style:(UIAlertActionStyle)b1style
//           b1action:(AlertActionBlock)b1action
//            b2title:(NSString*)b2title
//            b2style:(UIAlertActionStyle)b2style
//           b2action:(AlertActionBlock)b2action
//            b3title:(NSString*)b3title
//            b3style:(UIAlertActionStyle)b3style
//           b3action:(AlertActionBlock)b3action
//            b4title:(NSString*)b4title
//            b4style:(UIAlertActionStyle)b4style
//           b4action:(AlertActionBlock)b4action
//            b5title:(NSString*)b5title
//            b5style:(UIAlertActionStyle)b5style
//           b5action:(AlertActionBlock)b5action
//{
//    
//    
//    UIAlertController *alertController
//    = [UIAlertController alertControllerWithTitle: title
//                                          message: message
//                                   preferredStyle: UIAlertControllerStyleAlert];
//    
//    [alertController addAction:[UIAlertAction actionWithTitle: b1title
//                                                        style: b1style
//                                                      handler: b1action ]];
//
//    if (b2title) {
//        [alertController addAction:[UIAlertAction actionWithTitle: b2title
//                                                            style: b2style
//                                                          handler: b2action ]];
//    }
//
//    if (b3title) {
//        [alertController addAction:[UIAlertAction actionWithTitle: b3title
//                                                            style: b3style
//                                                          handler: b3action ]];
//    }
//    
//    if (b4title) {
//        [alertController addAction:[UIAlertAction actionWithTitle: b4title
//                                                            style: b4style
//                                                          handler: b4action ]];
//    }
//    
//    if (b5title) {
//        [alertController addAction:[UIAlertAction actionWithTitle: b5title
//                                                            style: b5style
//                                                          handler: b5action ]];
//    }
//    
//    [self presentViewController:alertController animated:YES completion:nil];
//}


@end
