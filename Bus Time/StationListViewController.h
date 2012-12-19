//
//  StationListViewController.h
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BusRoute;
@interface StationListViewController : UITableViewController
@property (nonatomic, strong) BusRoute *busRoute;
@end
