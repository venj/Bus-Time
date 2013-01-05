//
//  NearbyStation.m
//  Bus Time
//
//  Created by venj on 13-1-5.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import "NearbyStation.h"
#import "BusDataSource.h"

@implementation NearbyStation

- (id)initWithBusStation:(BusStation *)busStation {
    if ((self = [super init])) {
        self.segmentID = busStation.busRoute.segmentID;
        self.segmentName = busStation.busRoute.segmentName;
        _segmentNamePY = busStation.busRoute.segmentNamePY;
        self.lineID = busStation.busRoute.lineID;
        self.stationSequence = busStation.stationSequence;
        self.stationID = busStation.stationID;
        self.stationName = busStation.stationName;
        _stationNamePY = busStation.stationNamePY;
        self.location = busStation.location;
        self.updateDate = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (id)lookupStationSequence {
    self.stationSequence = [[BusDataSource shared] stationSequenceForSegmentID:self.segmentID andStationID:self.stationID];
    return self;
}
@end
