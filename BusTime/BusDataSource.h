//
//  BusDataSource.h
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BusRoute;
@interface BusDataSource : NSObject
+ (id)shared;
- (void)sharedClean;

- (NSArray *)stationsForBusRoute:(BusRoute *)busRoute;

@property (nonatomic, strong) NSMutableArray *busList;
@end
