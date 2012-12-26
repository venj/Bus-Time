//
//  AppDelegate.h
//  Bus Time
//
//  Created by venj on 12-12-19.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BusListViewController, QueryResultViewController, LeftMenuViewController, SettingsViewController,
    FavoritesViewController, PPRevealSideViewController, NearbyStationsViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) PPRevealSideViewController *revealController;
@property (strong, nonatomic) LeftMenuViewController *leftMenuViewController;
@property (nonatomic, strong) FavoritesViewController *favoritesViewController;
@property (strong, nonatomic) UINavigationController *favoritesNavController;
@property (strong, nonatomic) BusListViewController *busListController;
@property (strong, nonatomic) UINavigationController *busListNavController;
@property (strong, nonatomic) NearbyStationsViewController *nearbyStationsViewController;
@property (strong, nonatomic) UINavigationController *nearbyStationsNavController;
@property (strong, nonatomic) SettingsViewController *settingsViewController;
@property (strong, nonatomic) UINavigationController *settingsNavController;
@property (nonatomic, strong) QueryResultViewController *queryResultController;
+ (AppDelegate *)shared;
- (NSArray *)menuViewControllers;

- (void)showLeftMenu;
- (void)hideMenu;
- (void)preloadMenus;
- (void)popViewControllerAtIndex:(NSUInteger)index;
@end
