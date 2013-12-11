//
//  AppDelegate.h
//  Bus Time
//
//  Created by venj on 12-12-19.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BusListViewController, QueryResultViewController, LeftMenuViewController, SettingsViewController,
    FavoritesViewController, PPRevealSideViewController, NearbyStationsViewController, HistoryViewController,
    NewsListViewController, StationSearchViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) PPRevealSideViewController *revealController;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (strong, nonatomic) LeftMenuViewController *leftMenuViewController;
@property (nonatomic, strong) FavoritesViewController *favoritesViewController;
@property (strong, nonatomic) UINavigationController *favoritesNavController;
@property (nonatomic, strong) HistoryViewController *historiesViewController;
@property (strong, nonatomic) UINavigationController *historiesNavController;
@property (strong, nonatomic) BusListViewController *busListController;
@property (strong, nonatomic) UINavigationController *busListNavController;
@property (strong, nonatomic) StationSearchViewController *stationSearchController;
@property (strong, nonatomic) UINavigationController *stationSearchNavController;
@property (strong, nonatomic) NearbyStationsViewController *nearbyStationsViewController;
@property (strong, nonatomic) UINavigationController *nearbyStationsNavController;
@property (strong, nonatomic) NewsListViewController *newsListViewController;
@property (strong, nonatomic) UINavigationController *newsNavViewController;
@property (strong, nonatomic) SettingsViewController *settingsViewController;
@property (strong, nonatomic) UINavigationController *settingsNavController;
@property (nonatomic, strong) QueryResultViewController *queryResultController;
+ (AppDelegate *)shared;
- (NSArray *)menuViewControllers;

- (void)showLeftMenu;
- (void)showBusList;
- (void)hideMenu;
- (void)preloadMenus;
- (void)popViewControllerAtIndex:(NSUInteger)index;

- (NSUInteger)deviceSystemMajorVersion;
- (void)checkAppVersion;
@end
