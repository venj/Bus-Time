//
//  BusStation.h
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusRoute.h"

@interface BusStation : NSObject
@property (nonatomic, strong) NSNumber *stationNumber;
@property (nonatomic, strong) NSNumber *stationSequence;
@property (nonatomic, strong) NSString *stationType;
@property (nonatomic, strong) NSString *stationName;
@property (nonatomic, strong) NSString *stationID;
@property (nonatomic, strong) NSString *stationSMSID;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, weak) BusRoute *busRoute;
- (id)initWithDictionary:(NSDictionary *)stationDict;
@end
