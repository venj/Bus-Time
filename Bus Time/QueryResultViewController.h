//
//  QueryResultViewController.h
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BusStation, UserItem;
@interface QueryResultViewController : UITableViewController
@property (nonatomic, strong) BusStation *station;
@property (nonatomic, strong) UserItem *userItem;
@property (nonatomic, strong) id refControl;
- (void)loadResult;
@end
