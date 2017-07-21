//
//  AZAlert.h
//  UIAlertController+WRAPPER
//
//  Copyright 2017 Azukid
//  Created by 松山正和 on 2017/07/19.
//
//

#import <UIKit/UIKit.h>


//typedef void(^AZAlertAction)(UIAlertAction * _Nullable action);


@interface AZAlert : NSObject

/*
 3ボタン・アラート
 */
+ (void)target:(UIViewController*_Nullable)target
         title:(NSString*_Nullable)title
       message:(NSString*_Nullable)message
       b1title:(NSString*_Nonnull)b1title
       b1style:(UIAlertActionStyle)b1style
      b1action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b1action
       b2title:(NSString*_Nullable)b2title
       b2style:(UIAlertActionStyle)b2style
      b2action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b2action
       b3title:(NSString*_Nullable)b3title
       b3style:(UIAlertActionStyle)b3style
      b3action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b3action;

/*
 2ボタン・アラート
 */
+ (void)target:(UIViewController*_Nullable)target
         title:(NSString*_Nullable)title
       message:(NSString*_Nullable)message
       b1title:(NSString*_Nonnull)b1title
       b1style:(UIAlertActionStyle)b1style
      b1action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b1action
       b2title:(NSString*_Nullable)b2title
       b2style:(UIAlertActionStyle)b2style
      b2action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b2action;

/*
 1ボタン・アラート
 */
+ (void)target:(UIViewController*_Nullable)target
         title:(NSString*_Nullable)title
       message:(NSString*_Nullable)message
       b1title:(NSString*_Nonnull)b1title
       b1style:(UIAlertActionStyle)b1style
      b1action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b1action;

/*
 0ボタン・トースト
 */
+ (void)target:(UIViewController*_Nullable)target
         title:(NSString*_Nullable)title
       message:(NSString*_Nullable)message
      interval:(NSTimeInterval)interval;

/*
 5ボタン・アクションシート
 */
+ (void)target:(UIViewController*_Nullable)target
    actionRect:(CGRect)rect
         title:(NSString*_Nullable)title
       message:(NSString*_Nullable)message
       b1title:(NSString*_Nonnull)b1title
       b1style:(UIAlertActionStyle)b1style
      b1action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b1action
       b2title:(NSString*_Nullable)b2title
       b2style:(UIAlertActionStyle)b2style
      b2action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b2action
       b3title:(NSString*_Nullable)b3title
       b3style:(UIAlertActionStyle)b3style
      b3action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b3action
       b4title:(NSString*_Nullable)b4title
       b4style:(UIAlertActionStyle)b4style
      b4action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b4action
       b5title:(NSString*_Nullable)b5title
       b5style:(UIAlertActionStyle)b5style
      b5action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b5action;

/*
 4ボタン・アクションシート
 */
+ (void)target:(UIViewController*_Nullable)target
    actionRect:(CGRect)rect
         title:(NSString*_Nullable)title
       message:(NSString*_Nullable)message
       b1title:(NSString*_Nonnull)b1title
       b1style:(UIAlertActionStyle)b1style
      b1action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b1action
       b2title:(NSString*_Nullable)b2title
       b2style:(UIAlertActionStyle)b2style
      b2action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b2action
       b3title:(NSString*_Nullable)b3title
       b3style:(UIAlertActionStyle)b3style
      b3action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b3action
       b4title:(NSString*_Nullable)b4title
       b4style:(UIAlertActionStyle)b4style
      b4action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b4action;

/*
 3ボタン・アクションシート
 */
+ (void)target:(UIViewController*_Nullable)target
    actionRect:(CGRect)rect
         title:(NSString*_Nullable)title
       message:(NSString*_Nullable)message
       b1title:(NSString*_Nonnull)b1title
       b1style:(UIAlertActionStyle)b1style
      b1action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b1action
       b2title:(NSString*_Nullable)b2title
       b2style:(UIAlertActionStyle)b2style
      b2action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b2action
       b3title:(NSString*_Nullable)b3title
       b3style:(UIAlertActionStyle)b3style
      b3action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b3action;

/*
 2ボタン・アクションシート
 */
+ (void)target:(UIViewController*_Nullable)target
    actionRect:(CGRect)rect
         title:(NSString*_Nullable)title
       message:(NSString*_Nullable)message
       b1title:(NSString*_Nonnull)b1title
       b1style:(UIAlertActionStyle)b1style
      b1action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b1action
       b2title:(NSString*_Nullable)b2title
       b2style:(UIAlertActionStyle)b2style
      b2action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b2action;

/*
 1ボタン・アクションシート
 */
+ (void)target:(UIViewController*_Nullable)target
    actionRect:(CGRect)rect
         title:(NSString*_Nullable)title
       message:(NSString*_Nullable)message
       b1title:(NSString*_Nonnull)b1title
       b1style:(UIAlertActionStyle)b1style
      b1action:(void (^ _Nullable)(UIAlertAction*_Nullable action))b1action;

@end
