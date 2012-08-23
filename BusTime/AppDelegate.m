//
//  AppDelegate.m
//  BusTime
//
//  Created by 朱 文杰 on 12-8-20.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "MBProgressHUD.h"

@interface AppDelegate () <MBProgressHUDDelegate>

@end

@implementation AppDelegate

+ (AppDelegate *)shared {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.window.rootViewController = navControl;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - MBProgressHUD Helper and Delegate

- (void)showHUDLoadingInView:(UIView *)view withMessage:(NSString *)message {
    if (self.hud) {
        [self.hud hide:YES];
        [self.hud removeFromSuperview];
        self.hud = nil;
    }
    self.hud = [[MBProgressHUD alloc] initWithView:view];
	[view addSubview:self.hud];
	
    self.hud.delegate = self;
    self.hud.labelText = message;
	[self.hud show:YES];
}

- (void)showHUDInView:(UIView *)view withMessage:(NSString *)message isWarning:(BOOL)warningOrDone {
    if (self.hud) {
        [self.hud hide:YES];
        [self.hud removeFromSuperview];
        self.hud = nil;
    }
    self.hud = [[MBProgressHUD alloc] initWithView:view];
    self.hud.mode = MBProgressHUDModeCustomView;
    if (warningOrDone) {
        self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"32x-Exclamationmark"]];
    }
    else {
        self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
    }
	[view addSubview:self.hud];
	
    self.hud.delegate = self;
    self.hud.labelText = message;
	[self.hud show:YES];
    [self.hud hide:YES afterDelay:2];
}

- (void)hideHUD {
    [self.hud hide:YES];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    if (hud) {
        [hud removeFromSuperview];
        hud = nil;
    }
}

- (void)hideHUDWithMessage:(NSString *)message {
    if (self.hud) {
        self.hud.labelText = message;
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"32x-Exclamationmark"]];
        [self.hud hide:YES afterDelay:2];
    }
}

@end
