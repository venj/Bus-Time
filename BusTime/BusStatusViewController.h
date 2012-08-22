//
//  BusStatusViewController.h
//  BusTime
//
//  Created by 朱 文杰 on 12-8-20.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusStatusViewController : UITableViewController
@property (nonatomic, strong) NSString *currentStationName;
@property (nonatomic, strong) NSArray *nextBuses;
@end
