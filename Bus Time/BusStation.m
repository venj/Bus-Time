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
        _stationNamePY = [_stationName pinyinAbbreviation];
        _stationID = [stationDict objectForKey:@"station_id"];
        _stationSMSID = [stationDict objectForKey:@"station_smsid"];
        _location = [[CLLocation alloc] initWithLatitude:[[stationDict objectForKey:@"latitude"] doubleValue] longitude:[[stationDict objectForKey:@"longitude"] doubleValue]];
        _busRoute = [stationDict objectForKey:@"bus_route"];
    }
    
    return self;
}

- (CLLocationCoordinate2D)realCoordinate {
    return [self.location coordinate];
}
- (CLLocationCoordinate2D)coordinate {
    // Add calibration for Wuxi.
    return CLLocationCoordinate2DMake(self.location.coordinate.latitude - 0.001906, self.location.coordinate.longitude + 0.004633);
}

@end
