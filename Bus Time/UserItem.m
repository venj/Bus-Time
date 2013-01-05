//
//  Favorite.m
//  Bus Time
//
//  Created by venj on 12-12-21.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import "UserItem.h"

@implementation UserItem
- (id)initWithDictionary:(NSDictionary *)dataDict {
    if ((self = [super init])) {
        _segmentID = [dataDict objectForKey:@"segment_id"];
        _segmentName = [dataDict objectForKey:@"segment_name"];
        _lineID = [dataDict objectForKey:@"line_id"];
        _stationSequence = [dataDict objectForKey:@"station_sequence"];
        _stationID = [dataDict objectForKey:@"station_id"];
        _stationName = [dataDict objectForKey:@"station_name"];
        _location = [[CLLocation alloc] initWithLatitude:[[dataDict objectForKey:@"latitude"] doubleValue] longitude:[[dataDict objectForKey:@"longitude"] doubleValue]];
        _updateDate = [[dataDict objectForKey:@"updated_at"] doubleValue];
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
