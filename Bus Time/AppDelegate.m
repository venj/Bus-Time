//
//  AppDelegate.m
//  Bus Time
//
//  Created by venj on 12-12-19.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import "AppDelegate.h"
#import "FavoritesViewController.h"
#import "BusListViewController.h"
#import "QueryResultViewController.h"
#import "PPRevealSideViewController.h"
#import "LeftMenuViewController.h"
#import "SettingsViewController.h"
#import "NearbyStationsViewController.h"
#import "HistoryViewController.h"
#import "NewsListViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate, PPRevealSideViewControllerDelegate, UITabBarControllerDelegate>
@property (nonatomic, strong) UISplitViewController *splitViewController;
@property (nonatomic, strong) NSMutableArray *menuViewControllers;
@end

@implementation AppDelegate

+ (AppDelegate *)shared {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
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

- (NSArray *)loadCommonVC {
    // BusList
    self.busListController = [[BusListViewController alloc] initWithNibName:@"BusListViewController" bundle:nil];
    self.busListNavController = [[UINavigationController alloc] initWithRootViewController:self.busListController];
    // FavList
    self.favoritesViewController = [[FavoritesViewController alloc] initWithStyle:UITableViewStylePlain];
    self.favoritesNavController = [[UINavigationController alloc] initWithRootViewController:self.favoritesViewController];
    // HistoryList
    self.historiesViewController = [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
    self.historiesNavController = [[UINavigationController alloc] initWithRootViewController:self.historiesViewController];
    // Nearby stations
    self.nearbyStationsViewController = [[NearbyStationsViewController alloc] initWithNibName:@"NearbyStationsViewController" bundle:nil];
    self.nearbyStationsNavController = [[UINavigationController alloc] initWithRootViewController:self.nearbyStationsViewController];
    // Nav news
    self.newsListViewController = [[NewsListViewController alloc] initWithStyle:UITableViewStylePlain];
    self.newsNavViewController = [[UINavigationController alloc] initWithRootViewController:self.newsListViewController];
    // Settings
    self.settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.settingsNavController = [[UINavigationController alloc] initWithRootViewController:self.settingsViewController];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.busListNavController.title = NSLocalizedString(@"Buses", @"公交查询");
        self.busListNavController.tabBarItem.image = [UIImage imageNamed:@"tab_search"];
        self.favoritesNavController.title = NSLocalizedString(@"Favorites", @"收藏夹");
        self.favoritesNavController.tabBarItem.image = [UIImage imageNamed:@"tab_star"];
        self.historiesNavController.title = NSLocalizedString(@"History", @"查询历史");
        self.historiesNavController.tabBarItem.image = [UIImage imageNamed:@"tab_history"];
        self.nearbyStationsNavController.title = NSLocalizedString(@"Nearby", @"附近站点");
        self.nearbyStationsNavController.tabBarItem.image = [UIImage imageNamed:@"tab_position"];
        self.newsNavViewController.title = NSLocalizedString(@"News", @"出行提示");
        self.newsNavViewController.tabBarItem.image = [UIImage imageNamed:@"tab_info"];
        self.settingsNavController.title = NSLocalizedString(@"Settings", @"设置");
        self.settingsNavController.tabBarItem.image = [UIImage imageNamed:@"tab_gear"];
    }
    
    return @[self.historiesNavController, self.favoritesNavController, self.busListNavController, self.nearbyStationsNavController, self.newsNavViewController, self.settingsNavController];
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

#pragma mark - PPRevealSideViewControllerDelegate
- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didPopToController:(UIViewController *)centerController {
    [self.leftMenuViewController.tableView reloadData];
}

@end
