//
//  AppDelegate.h
//  BusTime
//
//  Created by 朱 文杰 on 12-8-20.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController, MBProgressHUD;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) MBProgressHUD *hud;

+ (AppDelegate *)shared;
- (void)showHUDLoadingInView:(UIView *)view withMessage:(NSString *)message;
- (void)showHUDInView:(UIView *)view withMessage:(NSString *)message isWarning:(BOOL)warningOrDone;
- (void)hudWasHidden:(MBProgressHUD *)hud;
- (void)hideHUD;
- (void)hideHUDWithMessage:(NSString *)message;
@end
