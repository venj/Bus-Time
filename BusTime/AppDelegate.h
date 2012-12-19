//
//  AppDelegate.h
//  BusTime
//
//  Created by 朱 文杰 on 12-8-20.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BusListViewController, QueryResultViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BusListViewController *busListController;
@property (nonatomic, strong) QueryResultViewController *queryResultController;
+ (AppDelegate *)shared;
@end
