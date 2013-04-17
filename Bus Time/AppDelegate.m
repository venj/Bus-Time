//
//  AppDelegate.m
//  Bus Time
//
//  Created by venj on 12-12-19.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "FavoritesViewController.h"
#import "BusListViewController.h"
#import "QueryResultViewController.h"
#import "PPRevealSideViewController.h"
#import "LeftMenuViewController.h"
#import "SettingsViewController.h"
#import "NearbyStationsViewController.h"
#import "StationSearchViewController.h"
#import "HistoryViewController.h"
#import "NewsListViewController.h"
#import "BusDataSource.h"
#import "ASIHTTPRequest.h"
#import "VCNavigationBar.h"

@interface AppDelegate () <UISplitViewControllerDelegate, PPRevealSideViewControllerDelegate, UITabBarControllerDelegate>
@property (nonatomic, strong) UISplitViewController *splitViewController;
@property (nonatomic, strong) NSMutableArray *menuViewControllers;
@property (nonatomic, strong) ASIHTTPRequest *req;
@end

@implementation AppDelegate

+ (AppDelegate *)shared {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Register push notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
	application.applicationIconBadgeNumber = 0;
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self loadRevealVC];
    }
    else {
        [self loadTabBarVC];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
#if !TARGET_IPHONE_SIMULATOR
	// Get Bundle Info for Remote Registration (handy if you have more than one app)
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = (rntypes & UIRemoteNotificationTypeBadge) ? @"enabled" : @"disabled";
	NSString *pushAlert = (rntypes & UIRemoteNotificationTypeAlert) ? @"enabled" : @"disabled";
	NSString *pushSound = (rntypes & UIRemoteNotificationTypeSound) ? @"enabled" : @"disabled";
	
	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid;
	if ([dev respondsToSelector:@selector(uniqueIdentifier)])
		deviceUuid = [dev uniqueIdentifier];
	else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		id uuid = [defaults objectForKey:@"deviceUuid"];
		if (uuid)
			deviceUuid = (NSString *)uuid;
		else {
			CFStringRef cfUuid = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
			deviceUuid = (__bridge_transfer NSString *)cfUuid;
			CFRelease(cfUuid);
			[defaults setObject:deviceUuid forKey:@"deviceUuid"];
		}
	}
	NSString *deviceName = dev.name;
	NSString *deviceModel = dev.model;
	NSString *deviceSystemVersion = dev.systemVersion;
	
	// Prepare the Device Token for Registration (remove spaces and < >)
	NSString *deviceToken = [[[[devToken description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
	NSString *host = @"apns.sukiapps.com";
	NSString *urlString = [NSString stringWithFormat:@"/apns.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@", @"register", appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound];
    
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    __block AppDelegate *blockSelf = self;
    self.req = [[ASIHTTPRequest alloc] initWithURL:url];
    //TODO: Do more to process the success action.
    [self.req setCompletionBlock:^{
        NSData *returnData = [blockSelf.req responseData];
        NSLog(@"Register URL: %@", url);
        NSLog(@"Return Data: %@", returnData);
    }];
    [self.req setFailedBlock:^{
        // Just fail it.
        //NSLog(@"Register request failed with error %d: %@", blockSelf.req.responseStatusCode, [[blockSelf.req error] description]);
    }];
    [self.req startAsynchronous];
#endif
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#if !TARGET_IPHONE_SIMULATOR
	NSLog(@"Error in registration. Error: %@", error);
#endif
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
#if !TARGET_IPHONE_SIMULATOR
	//NSLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
	NSString *sound = [apsInfo objectForKey:@"sound"];
    SystemSoundID mBeep;
    NSString* path = [[NSBundle mainBundle] pathForResource:sound ofType:@""];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL* url = [NSURL fileURLWithPath:path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &mBeep);
        AudioServicesPlaySystemSound(mBeep);
        AudioServicesDisposeSystemSoundID(mBeep);
    }
    
	NSString *badge = [apsInfo objectForKey:@"badge"];
	application.applicationIconBadgeNumber = [badge integerValue];
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Clean up app badge anyway.
    application.applicationIconBadgeNumber = 0;
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

#pragma mark - Load The Main UI

- (NSArray *)loadCommonVC {
    // BusList
    self.busListController = [[BusListViewController alloc] initWithNibName:@"BusListViewController" bundle:nil];
    self.busListController.allBuses = [[BusDataSource shared] busRoutes];
    self.busListController.shouldShowMenuIcon = YES;
    self.busListNavController = [[UINavigationController alloc] initWithNavigationBarClass:[VCNavigationBar class] toolbarClass:nil];
    [self.busListNavController addChildViewController:self.busListController];
    // FavList
    self.favoritesViewController = [[FavoritesViewController alloc] initWithStyle:UITableViewStylePlain];
    self.favoritesNavController = [[UINavigationController alloc] initWithNavigationBarClass:[VCNavigationBar class] toolbarClass:nil];
    [self.favoritesNavController addChildViewController:self.favoritesViewController];
    // HistoryList
    self.historiesViewController = [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
    self.historiesNavController = [[UINavigationController alloc] initWithNavigationBarClass:[VCNavigationBar class] toolbarClass:nil];
    [self.historiesNavController addChildViewController:self.historiesViewController];
    // Station Search
    self.stationSearchController = [[StationSearchViewController alloc] initWithNibName:@"StationSearchViewController" bundle:nil];
    self.stationSearchNavController = [[UINavigationController alloc] initWithNavigationBarClass:[VCNavigationBar class] toolbarClass:nil];
    [self.stationSearchNavController addChildViewController:self.stationSearchController];
    // Nearby stations
    self.nearbyStationsViewController = [[NearbyStationsViewController alloc] initWithNibName:@"NearbyStationsViewController" bundle:nil];
    self.nearbyStationsNavController = [[UINavigationController alloc] initWithNavigationBarClass:[VCNavigationBar class] toolbarClass:nil];
    [self.nearbyStationsNavController addChildViewController:self.nearbyStationsViewController];
    // Nav news
    self.newsListViewController = [[NewsListViewController alloc] initWithStyle:UITableViewStylePlain];
    self.newsNavViewController = [[UINavigationController alloc] initWithNavigationBarClass:[VCNavigationBar class] toolbarClass:nil];
    [self.newsNavViewController addChildViewController:self.newsListViewController];
    // Settings
    self.settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.settingsNavController = [[UINavigationController alloc] initWithNavigationBarClass:[VCNavigationBar class] toolbarClass:nil];
    [self.settingsNavController addChildViewController:self.settingsViewController];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.busListNavController.title = NSLocalizedString(@"Buses", @"公交查询");
        self.busListNavController.tabBarItem.image = [UIImage imageNamed:@"tab_bus"];
        self.favoritesNavController.title = NSLocalizedString(@"Favorites", @"收藏夹");
        self.favoritesNavController.tabBarItem.image = [UIImage imageNamed:@"tab_star"];
        self.historiesNavController.title = NSLocalizedString(@"History", @"查询历史");
        self.historiesNavController.tabBarItem.image = [UIImage imageNamed:@"tab_history"];
        self.stationSearchController.title = NSLocalizedString(@"Search", @"站名搜索");
        self.stationSearchNavController.tabBarItem.image = [UIImage imageNamed:@"tab_search"];
        self.nearbyStationsNavController.title = NSLocalizedString(@"Nearby", @"附近站点");
        self.nearbyStationsNavController.tabBarItem.image = [UIImage imageNamed:@"tab_position"];
        self.newsNavViewController.title = NSLocalizedString(@"News", @"出行提示");
        self.newsNavViewController.tabBarItem.image = [UIImage imageNamed:@"tab_info"];
        self.settingsNavController.title = NSLocalizedString(@"Settings", @"设置");
        self.settingsNavController.tabBarItem.image = [UIImage imageNamed:@"tab_gear"];
    }
    
    return @[self.historiesNavController, self.favoritesNavController, self.busListNavController, self.stationSearchNavController,
             self.nearbyStationsNavController, self.newsNavViewController, self.settingsNavController];
}

- (void)loadRevealVC {
    // LeftMenu
    self.leftMenuViewController = [[LeftMenuViewController alloc] initWithStyle:UITableViewStylePlain];
    
    if (!self.menuViewControllers) {
        self.menuViewControllers = [[NSMutableArray alloc] initWithArray:[self loadCommonVC]];
    }
    
    self.revealController = [[PPRevealSideViewController alloc] initWithRootViewController:self.historiesNavController];
    [self.revealController setDirectionsToShowBounce:PPRevealSideDirectionLeft];
    self.revealController.panInteractionsWhenClosed = PPRevealSideInteractionNavigationBar | PPRevealSideInteractionContentView;
    self.revealController.delegate = self;
    self.window.rootViewController = self.revealController;
}

- (void)loadTabBarVC {
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [self loadCommonVC];
    self.tabBarController.delegate = self;
    self.splitViewController = [[UISplitViewController alloc] init];
    self.queryResultController = [[QueryResultViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.queryResultController.title = NSLocalizedString(@"No result yet", @"暂未查询");
    UINavigationController *queryNavControl = [[UINavigationController alloc] initWithRootViewController:self.queryResultController];
    self.splitViewController.viewControllers = @[self.tabBarController, queryNavControl];
    self.splitViewController.delegate = self;
    self.window.rootViewController = self.splitViewController;
}

- (void)preloadMenus {
    [self.revealController preloadViewController:self.leftMenuViewController forSide:PPRevealSideDirectionLeft];
}

- (void)showLeftMenu {
    [self.revealController pushViewController:self.leftMenuViewController onDirection:PPRevealSideDirectionLeft animated:YES];
    [self.leftMenuViewController.tableView reloadData];
}

- (void)showBusList {
    [self.tabBarController setSelectedViewController:self.busListNavController];
}

- (void)hideMenu {
    [self.revealController popViewControllerAnimated:YES];
}

- (void)popViewControllerAtIndex:(NSUInteger)index {
    UIViewController *targetVC = [self.menuViewControllers objectAtIndex:index];
    if (self.revealController.rootViewController == targetVC) {
        [self.revealController popViewControllerAnimated:YES];
    }
    else {
        [self.revealController popViewControllerWithNewCenterController:targetVC animated:YES];
    }
}

#pragma mark - UISplitViewController
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

#pragma mark - PPRevealSideViewControllerDelegate
- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didPopToController:(UIViewController *)centerController {
    [self.leftMenuViewController.tableView reloadData];
}

@end
