//
//  BusStation.m
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "BusStation.h"

@implementation BusStation

- (id)initWithDictionary:(NSDictionary *)stationDict {
    if ((self = [super init])) {
        _stationNumber = [stationDict objectForKey:@"station_num"];
        _stationType = [stationDict objectForKey:@"station_type"];
        _stationName = [stationDict objectForKey:@"station_name"];
        _stationID = [stationDict objectForKey:@"station_id"];
        _stationSMSID = [stationDict objectForKey:@"station_smsid"];
        _latitude = [stationDict objectForKey:@"wd_str"];
        _longitude = [stationDict objectForKey:@"jd_str"];
        _busRoute = [stationDict objectForKey:@"bus_route"];
    }
    
    return self;
}
@end
