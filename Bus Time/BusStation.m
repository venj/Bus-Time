//
//  BusStation.m
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "BusStation.h"
#import "CharToPinyin.h"
#import "MarsHelper.h"

@interface BusStation ()
@property (nonatomic, assign) CLLocationCoordinate2D marsCoordinate;
@end

@implementation BusStation

- (id)initWithDictionary:(NSDictionary *)stationDict {
    if ((self = [super init])) {
        _stationNumber = [stationDict objectForKey:@"station_num"];
        _stationType = [stationDict objectForKey:@"station_type"];
        _stationName = [stationDict objectForKey:@"station_name"];
        _stationNamePY = [[CharToPinyin shared] abbreviation:_stationName];
        _stationID = [stationDict objectForKey:@"station_id"];
        _stationSMSID = [stationDict objectForKey:@"station_smsid"];
        _location = [[CLLocation alloc] initWithLatitude:[[stationDict objectForKey:@"latitude"] doubleValue] longitude:[[stationDict objectForKey:@"longitude"] doubleValue]];
        _busRoute = [stationDict objectForKey:@"bus_route"];
        _marsCoordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    }
    
    return self;
}

- (CLLocationCoordinate2D)realCoordinate {
    return [self.location coordinate];
}

- (CLLocationCoordinate2D)coordinate {
    // Add calibration for Wuxi.
    if (self.marsCoordinate.latitude == 0.0 && self.marsCoordinate.longitude == 0.0) {
        self.marsCoordinate = [MarsHelper convertToEarthCoordinateWithMarsCoordinate:self.location.coordinate];
    }
    return self.marsCoordinate;
}

@end
