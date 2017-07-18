//
//  UIViewController+Alert.h
//  Common
//
//  Created by matsuyama on 2017/07/18.
//  Copyright © 2017年 jmas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Alert)


- (void)aleartTitle:(NSString*_Nonnull)title
            message:(NSString*_Nonnull)message
            b1title:(NSString*_Nonnull)b1title
            b1style:(UIAlertActionStyle)b1style
           b1action:(void (^ __nullable)(UIAlertAction*_Nullable action))b1action;

- (void)aleartTitle:(NSString*_Nonnull)title
            message:(NSString*_Nonnull)message
            b1title:(NSString*_Nonnull)b1title
            b1style:(UIAlertActionStyle)b1style
           b1action:(void (^ __nullable)(UIAlertAction*_Nullable action))b1action
            b2title:(NSString*_Nonnull)b2title
            b2style:(UIAlertActionStyle)b2style
           b2action:(void (^ __nullable)(UIAlertAction*_Nullable action))b2action;

- (void)aleartTitle:(NSString*_Nonnull)title
            message:(NSString*_Nonnull)message
            b1title:(NSString*_Nonnull)b1title
            b1style:(UIAlertActionStyle)b1style
           b1action:(void (^ __nullable)(UIAlertAction*_Nullable action))b1action
            b2title:(NSString*_Nullable)b2title
            b2style:(UIAlertActionStyle)b2style
           b2action:(void (^ __nullable)(UIAlertAction*_Nullable action))b2action
            b3title:(NSString*_Nullable)b3title
            b3style:(UIAlertActionStyle)b3style
           b3action:(void (^ __nullable)(UIAlertAction*_Nullable action))b3action;

- (void)aleartTitle:(NSString*_Nonnull)title
            message:(NSString*_Nonnull)message
            b1title:(NSString*_Nonnull)b1title
            b1style:(UIAlertActionStyle)b1style
           b1action:(void (^ __nullable)(UIAlertAction*_Nullable action))b1action
            b2title:(NSString*_Nullable)b2title
            b2style:(UIAlertActionStyle)b2style
           b2action:(void (^ __nullable)(UIAlertAction*_Nullable action))b2action
            b3title:(NSString*_Nullable)b3title
            b3style:(UIAlertActionStyle)b3style
           b3action:(void (^ __nullable)(UIAlertAction*_Nullable action))b3action
            b4title:(NSString*_Nullable)b4title
            b4style:(UIAlertActionStyle)b4style
           b4action:(void (^ __nullable)(UIAlertAction*_Nullable action))b4action;

- (void)aleartTitle:(NSString*_Nonnull)title
            message:(NSString*_Nonnull)message
            b1title:(NSString*_Nonnull)b1title
            b1style:(UIAlertActionStyle)b1style
           b1action:(void (^ __nullable)(UIAlertAction*_Nullable action))b1action
            b2title:(NSString*_Nullable)b2title
            b2style:(UIAlertActionStyle)b2style
           b2action:(void (^ __nullable)(UIAlertAction*_Nullable action))b2action
            b3title:(NSString*_Nullable)b3title
            b3style:(UIAlertActionStyle)b3style
           b3action:(void (^ __nullable)(UIAlertAction*_Nullable action))b3action
            b4title:(NSString*_Nullable)b4title
            b4style:(UIAlertActionStyle)b4style
           b4action:(void (^ __nullable)(UIAlertAction*_Nullable action))b4action
            b5title:(NSString*_Nullable)b5title
            b5style:(UIAlertActionStyle)b5style
           b5action:(void (^ __nullable)(UIAlertAction*_Nullable action))b5action;

@end
