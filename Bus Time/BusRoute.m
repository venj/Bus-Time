//
//  BusRoute.m
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "BusRoute.h"
#import "BusDataSource.h"

@implementation BusRoute

- (id)initWithDictionary:(NSDictionary *)busDict {
    if ((self = [super init])) {
        _lineID = [busDict objectForKey:@"line_id"];
        _segmentID = [busDict objectForKey:@"segment_id"];
        _segmentName = [busDict objectForKey:@"segment_name"];
    }
    
    return self;
}

- (NSArray *)stations {
    BusDataSource *source = [BusDataSource shared];
    _stations = [source stationsForBusRoute:self];
    return _stations;
}

@end
