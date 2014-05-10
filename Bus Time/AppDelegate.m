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
#import <PPRevealSideViewController/PPRevealSideViewController.h>
#import "LeftMenuViewController.h"
#import "SettingsViewController.h"
#import "NearbyStationsViewController.h"
#import "StationSearchViewController.h"
#import "HistoryViewController.h"
#import "NewsListViewController.h"
#import "BusDataSource.h"
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import "VCNavigationBar.h"
#import <FlurrySDK/Flurry.h>

#define kBTIsDeviceRegistered @"BTIsDeviceRegistered"
// 版本升级
#define DoNotNotifyVersion @"kDoNotNotifyVersion"
// GuideToNewApp
#define DoNotGuideToNewApp @"kDoNotGuideToNewApp"

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
    [Flurry setCrashReportingEnabled:NO];
    [Flurry startSession:@"79N9NDKJSP5TPHHRJ4WW"];
    //your code
    // Register push notification
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![[defaults valueForKey:kBTIsDeviceRegistered] boolValue]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
        });
    }
	application.applicationIconBadgeNumber = 0;
    
    [self checkAppVersion];
    [self checkDBVersion];
    [self loadUI];
    [self showGuideAlert];
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)loadUI {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self loadRevealVC];
    }
    else {
        [self loadTabBarVC];
    }
}
/*
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id uuid = [defaults objectForKey:@"deviceUuid"];
    if (uuid)
        deviceUuid = (NSString *)uuid;
    else {
        CFStringRef cfUuid = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
        deviceUuid = (__bridge NSString *)cfUuid;
        CFRelease(cfUuid);
        [defaults setObject:deviceUuid forKey:@"deviceUuid"];
        [defaults synchronize];
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
    self.req = [[ASIHTTPRequest alloc] initWithURL:url];
    //TODO: Do more to process the success action.
    [self.req setCompletionBlock:^{
        [defaults setObject:@(YES) forKey:kBTIsDeviceRegistered];
    }];
    [self.req setFailedBlock:^{
        // Just fail it.
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
*/
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
        self.busListNavController.tabBarItem.title = NSLocalizedString(@"Buses_tab", @"公交");
        self.busListNavController.tabBarItem.image = [UIImage imageNamed:@"tab_bus"];
        self.favoritesNavController.tabBarItem.title = NSLocalizedString(@"Favorites_tab", @"收藏");
        self.favoritesNavController.tabBarItem.image = [UIImage imageNamed:@"tab_star"];
        self.historiesNavController.tabBarItem.title = NSLocalizedString(@"History_tab", @"历史");
        self.historiesNavController.tabBarItem.image = [UIImage imageNamed:@"tab_history"];
        self.stationSearchNavController.tabBarItem.title = NSLocalizedString(@"Search_tab", @"搜索");
        self.stationSearchNavController.tabBarItem.image = [UIImage imageNamed:@"tab_search"];
        self.nearbyStationsNavController.tabBarItem.title = NSLocalizedString(@"Nearby_tab", @"附近");
        self.nearbyStationsNavController.tabBarItem.image = [UIImage imageNamed:@"tab_position"];
        self.newsNavViewController.tabBarItem.title = NSLocalizedString(@"News_tab", @"提示");
        self.newsNavViewController.tabBarItem.image = [UIImage imageNamed:@"tab_info"];
        self.settingsNavController.tabBarItem.title = NSLocalizedString(@"Settings", @"设置");
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

#pragma mark - Helper
- (NSUInteger)deviceSystemMajorVersion {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

# pragma mark - Check App Version

- (void)checkAppVersion {
    ASIHTTPRequest *versionRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@version.txt", SERVER_ADDRESS]]];
    ASIHTTPRequest *request_b = versionRequest;
    __weak AppDelegate *weakSelf = self;
    //网络请求成功
    [versionRequest setCompletionBlock:^{
        NSString *versionString = [[request_b responseString] strip];
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\d+\\.\\d+(\\.\\d+)?" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches = [regex matchesInString:versionString options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, versionString.length)];
        if ([matches count] < 1) {
            return;
        }
        if ([self isVersion:versionString newerThanOtherVersionNumber:[self currentVersion]] && ![[[NSUserDefaults standardUserDefaults] objectForKey:DoNotNotifyVersion] isEqualToString:versionString]) {
            UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:NSLocalizedString(@"App Update", @"发现新版本") message:[NSString stringWithFormat:NSLocalizedString(@"You are using \"Wuxi Bus v%@\".\n\"Wuxi Bus v%@\" is already available.\nDo you want to update?", @"您正在使用“BusTime v%@”。\n“BusTime v%@”已经发布。\n是否升级？"), [weakSelf currentVersion], versionString]];
            [alert bk_setCancelButtonWithTitle:NSLocalizedString(@"Later", @"以后再说") handler:NULL];
            [alert bk_addButtonWithTitle:NSLocalizedString(@"Update Now", @"立刻升级") handler:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/wuxi-bus/id588921563?mt=8"]];
            }];
            [alert bk_addButtonWithTitle:NSLocalizedString(@"Never", @"不再提示") handler:^{
                [[NSUserDefaults standardUserDefaults] setObject:versionString forKey:DoNotNotifyVersion]; //不再提示
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
            [alert show];
        }
    }];
    //TODO: Add already latest app version alert if issued from settings.
    [versionRequest startAsynchronous];
}

- (void)showGuideAlert {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:DoNotGuideToNewApp]) {
        UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:NSLocalizedString(@"Note", @"注意") message:NSLocalizedString(@"This unofficial Wuxi Bus app will be phase out, you can still use it, but it will be more unreliable. Please switch to an official app.", @"正如你所知，这个非官方的无锡公交查询程序将退休了。虽然你可以继续使用，但是它将变得不那么可靠了。你可以下载官方的公交查询程序。")];
        [alert bk_addButtonWithTitle:NSLocalizedString(@"More Info About Deprecation", @"了解退休原因") handler:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://sukiapps.com/bustime/faq.html#deprecation"]];
        }];
        [alert bk_addButtonWithTitle:NSLocalizedString(@"Get \"WuxiBus Portable\"", @"下载“掌上公交(无锡公交出品)”") handler:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/wu-xi-zhang-shang-gong-jiao/id741884913?mt=8"]];
        }];
        [alert bk_addButtonWithTitle:NSLocalizedString(@"Get \"Wireless Wuxi Bus\"", @"下载“智慧无锡公交(无锡广电出品)”") handler:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/zhi-hui-wu-xi-gong-jiao/id578525485?mt=8"]];
        }];
        [alert bk_addButtonWithTitle:NSLocalizedString(@"Never", @"不再提示") handler:^{
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DoNotGuideToNewApp]; //不再提示
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
        [alert bk_setCancelButtonWithTitle:NSLocalizedString(@"Later", @"以后再说") handler:NULL];
        [alert show];
    }
}

- (NSString *)currentVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (BOOL)isVersion:(NSString *)currentVersionNumber newerThanOtherVersionNumber:(NSString *)otherVersionNumber {
    NSArray *versionParts = [otherVersionNumber componentsSeparatedByString:@"."];
    
    NSArray *currentVersionParts = [currentVersionNumber componentsSeparatedByString:@"."];
    
    if ([versionParts count] == 2)
        versionParts = [versionParts arrayByAddingObject:@"0"];
    if ([currentVersionParts count] == 2)
        currentVersionParts = [currentVersionParts arrayByAddingObject:@"0"];
    
    for (NSInteger i = 0; i < 3; i++) {
        NSInteger a = [[currentVersionParts objectAtIndex:i] integerValue];
        NSInteger b = [[versionParts objectAtIndex:i] integerValue];
        if (a > b)
            return YES;
        else if (a == b)
            continue;
        else
            return NO;
    }
    return NO;
}

#pragma mark - Check DB Version 

// Check and download
//TODO: Merge with same method in settings???
- (void)checkDBVersion {
    ASIHTTPRequest *versionRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@db/version.txt", SERVER_ADDRESS]]];
    __weak ASIHTTPRequest *request_b = versionRequest;
    __weak AppDelegate *weakSelf = self;
    //网络请求成功
    [versionRequest setCompletionBlock:^{
        NSString *versionString = [(NSString *)[request_b responseString] strip];
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\d{4}-\\d{1,2}-\\d{1,2}" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches = [regex matchesInString:versionString options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, versionString.length)];
        if ([matches count] < 1) {
            return;
        }
        if (![versionString isEqualToString:[BusDataSource busDataBaseVersion]]) {
            UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:NSLocalizedString(@"Database Update", @"数据库更新") message:[NSString stringWithFormat:NSLocalizedString(@"New bus database(%@) found, do you want to update?", @"公交车数据库(%@)已经发布。是否开始下载？"), versionString]];
            [alert bk_setCancelButtonWithTitle:NSLocalizedString(@"Later", @"以后再说") handler:NULL];
            [alert bk_addButtonWithTitle:NSLocalizedString(@"Update Now", @"立刻升级") handler:^{
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    [weakSelf popViewControllerAtIndex:6];
                }
                else {
                    [weakSelf.tabBarController setSelectedIndex:6];
                }
                [weakSelf.settingsViewController downloadDatabaseFile];
            }];
            [alert show];
        }
    }];
    [versionRequest startAsynchronous];
}

@end
