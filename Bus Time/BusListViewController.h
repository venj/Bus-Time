//
//  BusListViewController.h
//  BusTime
//
//  Created by venj on 12-10-10.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusListViewController : UITableViewController
@property (nonatomic, strong) NSArray *allBuses;
@property (nonatomic, assign) BOOL shouldShowMenuIcon;
@end
