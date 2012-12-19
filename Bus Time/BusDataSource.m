//
//  BusDataSource.m
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "BusDataSource.h"
#import "FMDatabase.h"
#import "BusStation.h"
#import "BusRoute.h"

@implementation BusDataSource
static BusDataSource* __shared = nil;

+ (id)shared{
    if(__shared == nil){
        __shared = [[self alloc] init];
    }
    [__shared loadBusRoutes];
    return __shared;
}

- (void)sharedClean{
    if (__shared) {
        __shared = nil;
    }
}

- (void)loadBusRoutes {
    NSString *dbPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"wuxitraffic.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        return;
    }
    FMResultSet *s = [db executeQuery:@"SELECT * FROM bus_segment"];
    self.busList = [[NSMutableArray alloc] initWithCapacity:200];
    while ([s next]) {
        NSDictionary *busDict;
        busDict = @{
            @"line_id":@([s intForColumn:@"line_id"]),
            @"segment_id":[s stringForColumn:@"segment_id"],
            @"segment_name":[s stringForColumn:@"segment_name"],
        };
        BusRoute *route = [[BusRoute alloc] initWithDictionary:busDict];
        [self.busList addObject:route];
    }
    [self.busList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(BusRoute *)obj1 lineID] compare:[(BusRoute *)obj2 lineID]];
    }];
    
    [db close];
}

- (NSArray *)stationsForBusRoute:(BusRoute *)busRoute {
    NSString *dbPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"wuxitraffic.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        return nil;
    }
    NSMutableArray *stations = [[NSMutableArray alloc] initWithCapacity:10];
    FMResultSet *s = [db executeQuery:
                      [NSString stringWithFormat:@"SELECT s.*,i.station_name,i.jd_str,i.wd_str FROM bus_station s left join bus_stationinfo i on s.station_id=i.station_id where segment_id='%@' and line_id='%@'", busRoute.segmentID, busRoute.lineID]
                      ];
    while ([s next]) {
        NSDictionary *stationDict;
        stationDict = @{
            @"station_num":@([s intForColumn:@"station_num"]),
            @"station_type":[s stringForColumn:@"station_type"],
            @"station_name":[s stringForColumn:@"station_name"],
            @"station_id":[s stringForColumn:@"station_id"],
            @"station_smsid":[s stringForColumn:@"station_smsid"],
            @"latitude":[s stringForColumn:@"wd_str"],
            @"longitude":[s stringForColumn:@"jd_str"],
            @"bus_route":busRoute
        };
        BusStation *station = [[BusStation alloc] initWithDictionary:stationDict];
        [stations addObject:station];
    }
    [stations sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(BusStation *)obj1 stationNumber] compare:[(BusStation *)obj2 stationNumber] ];
    }];
    for (NSInteger i = 0; i < [stations count]; i++) {
        BusStation *station = [stations objectAtIndex:i];
        station.stationSequence = @(i+1);
    }
    
    return stations;
}


@end
