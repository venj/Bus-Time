//
//  AppDelegate.m
//  Bus Time
//
//  Created by venj on 12-12-19.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import "AppDelegate.h"
#import "BusListViewController.h"
#import "QueryResultViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>
@property (nonatomic, strong) UISplitViewController *splitViewController;
@end

@implementation AppDelegate

+ (AppDelegate *)shared {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (void)initialize {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dbPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"wuxitraffic.db"];
    BOOL dbExists = [manager fileExistsAtPath:dbPath];
    if (!dbExists) {
        [manager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"wuxitraffic" ofType:@"db"] toPath:dbPath error:nil];
    }
    [self addSkipBackupAttributeToItemAtPath:dbPath];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.busListController = [[BusListViewController alloc] initWithNibName:@"BusListViewController" bundle:nil];
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:self.busListController];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.window.rootViewController = navControl;
    }
    else {
        self.splitViewController = [[UISplitViewController alloc] init];
        self.queryResultController = [[QueryResultViewController alloc] initWithNibName:@"QueryResultViewController" bundle:nil];
        self.queryResultController.title = @"暂未查询";
        UINavigationController *queryNavControl = [[UINavigationController alloc] initWithRootViewController:self.queryResultController];
        self.splitViewController.viewControllers = @[navControl, queryNavControl];
        self.splitViewController.delegate = self;
        self.window.rootViewController = self.splitViewController;
    }
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

#pragma mark - UISplitViewController
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

#pragma mark - File Attribute
+ (BOOL)haveSkipBackupAttributeForItemAtPath:(NSString *)filePath {
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:filePath];
    NSError *error = nil;
    id result;
    BOOL success = [URL getResourceValue: &result forKey: NSURLIsExcludedFromBackupKey error:&error];
    if(!success){
#if DEBUG
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
#endif
    }
    return [result boolValue];
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePath {
    if ([self haveSkipBackupAttributeForItemAtPath:filePath]) {
        return YES;
    }
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:filePath];
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error:&error];
    if(!success){
#if TARGET_IS_TEST_DATA
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
#endif
    }
    return success;
}

@end