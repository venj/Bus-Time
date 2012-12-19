//
//  AppDelegate.h
//  Bus Time
//
//  Created by venj on 12-12-19.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BusListViewController, QueryResultViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BusListViewController *busListController;
@property (nonatomic, strong) QueryResultViewController *queryResultController;
+ (AppDelegate *)shared;
@end
