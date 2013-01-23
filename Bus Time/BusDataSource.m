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
#import "NearbyStation.h"
#import "CharToPinyin.h"

@implementation BusDataSource
static BusDataSource *__shared = nil;

#pragma mark - Class Helper Methods
+ (NSString *)busDataBaseVersion {
    NSString *newUpdateDate;
    NSString *newDBPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"wuxitraffic.db"];
    FMDatabase *newDB = [FMDatabase databaseWithPath:newDBPath];
    if (![newDB open]) {
        return NO;
    }
    FMResultSet *t = [newDB executeQuery:@"SELECT * FROM db_config LIMIT 1"];
    if ([t next]) {
        newUpdateDate = [t stringForColumn:@"value"];
    }
    [newDB close];
    return [[newUpdateDate componentsSeparatedByString:@" "] objectAtIndex:0];
}

+ (BOOL)busDataBaseNeedsUpdate {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *oldDBPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"wuxitraffic.db"];
    BOOL dbExists = [manager fileExistsAtPath:oldDBPath];
    if (!dbExists) {
        return YES;
    }
    
    FMDatabase *oldDB = [FMDatabase databaseWithPath:oldDBPath];
    if (![oldDB open]) {
        return NO;
    }
    FMResultSet *s = [oldDB executeQuery:@"SELECT * FROM db_config LIMIT 1"];
    NSString *oldUpdateDate, *newUpdateDate;
    if ([s next]) {
        oldUpdateDate = [s stringForColumn:@"value"];
    }
    [oldDB close];
    
    NSString *newDBPath = [[NSBundle mainBundle] pathForResource:@"wuxitraffic" ofType:@"db"];
    FMDatabase *newDB = [FMDatabase databaseWithPath:newDBPath];
    if (![newDB open]) {
        return NO;
    }
    FMResultSet *t = [newDB executeQuery:@"SELECT * FROM db_config LIMIT 1"];
    if ([t next]) {
        newUpdateDate = [t stringForColumn:@"value"];
    }
    [newDB close];
    
    if ([oldUpdateDate isEqualToString:newUpdateDate]) {
        return NO;
    }
    return YES;
}

+ (void)updateBusDataBase {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dbPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"wuxitraffic.db"];
    if ([self busDataBaseNeedsUpdate]) {
        [manager removeItemAtPath:dbPath error:nil];
        [manager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"wuxitraffic" ofType:@"db"] toPath:dbPath error:nil];
    }
    [self addSkipBackupAttributeToItemAtPath:dbPath];
}

#pragma mark - Object life cycle

+ (void)initialize {
    [self updateBusDataBase];
}

+ (id)shared{
    if(__shared == nil){
        __shared = [[self alloc] init];
    }
    [__shared busRoutes];
    return __shared;
}

- (void)sharedClean{
    if (__shared) {
        __shared = nil;
    }
}

#pragma mark - Bus Route Database Query

- (NSArray *)busRoutes {
    FMDatabase *db = [self busDatabase];
    FMResultSet *s = [db executeQuery:@"SELECT * FROM bus_segment"];
    NSMutableArray *busRoutes = [[NSMutableArray alloc] initWithCapacity:200];
    while ([s next]) {
        NSDictionary *busDict;
        busDict = @{
            @"line_id":@([s intForColumn:@"line_id"]),
            @"segment_id":[s stringForColumn:@"segment_id"],
            @"segment_name":[s stringForColumn:@"segment_name"],
        };
        BusRoute *route = [[BusRoute alloc] initWithDictionary:busDict];
        [busRoutes addObject:route];
    }
    [busRoutes sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(BusRoute *)obj1 lineID] compare:[(BusRoute *)obj2 lineID]];
    }];
    
    [db close];
    return busRoutes;
}

- (BusRoute *)routeForSegmentID:(NSString *)segmentID {
    FMDatabase *db = [self busDatabase];
    FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM bus_segment WHERE segment_id=%@", segmentID]];
    BusRoute *route;
    if ([s next]) {
        NSDictionary *busDict;
        busDict = @{
            @"line_id":@([s intForColumn:@"line_id"]),
            @"segment_id":[s stringForColumn:@"segment_id"],
            @"segment_name":[s stringForColumn:@"segment_name"]
        };
        route = [[BusRoute alloc] initWithDictionary:busDict];
    }
    
    [db close];
    return route;
}

- (NSArray *)stationsForBusRoute:(BusRoute *)busRoute {
    FMDatabase *db = [self busDatabase];
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
    
    [db close];
    return stations;
}

// Radius in meters. 1 km = 0.009 degree (latitude/longitude)
- (NSArray *)nearbyStationsForCoordinate:(CLLocationCoordinate2D)coordinate inRadius:(double)radius {
    double lat, lng, maxLat, minLat, maxLng, minLng;
    double delta = (radius / 1000.0) * 0.009;
    lat = coordinate.latitude; lng = coordinate.longitude;
    maxLat = lat + delta; minLat = lat - delta; maxLng = lng + delta; minLng = lng - delta;
    
    FMDatabase *db = [self busDatabase];
    NSMutableArray *nearbyStations = [[NSMutableArray alloc] initWithCapacity:0];
    FMResultSet *s = [db executeQuery:
                      [NSString stringWithFormat:@"SELECT s.*,i.station_name,i.jd_str,i.wd_str FROM bus_station s left join bus_stationinfo i on s.station_id=i.station_id where wd_str<%f and wd_str>%f and jd_str<%f and jd_str>%f", maxLat, minLat, maxLng, minLng]
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
            @"bus_route": [self routeForSegmentID:[s stringForColumn:@"segment_id"]]
        };
        BusStation *station = [[BusStation alloc] initWithDictionary:stationDict];
        NearbyStation *nearbyStation = [[NearbyStation alloc] initWithBusStation:station];
        [nearbyStations addObject:nearbyStation];
    }
    [nearbyStations sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(NearbyStation *)obj1 lineID] compare:[(NearbyStation *)obj2 lineID] ];
    }];
    
    [db close];
    return nearbyStations;
}

- (NSDictionary *)routeInfoForBusRoute:(BusRoute *)busRoute {
    FMDatabase *db = [self busDatabase];
    FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM 'bus_line' WHERE `line_id`=%@", busRoute.lineID]];
    NSDictionary *infoDict;
    if ([s next]) {
        infoDict = @{
            @"line_id": [s stringForColumn:@"line_id"],
            @"line_name": [s stringForColumn:@"line_name"],
            @"line_info": [s stringForColumn:@"line_info"]
        };
    }
    [db close];
    return infoDict;
}

- (NSNumber *)stationSequenceForSegmentID:(NSString *)segmentID andStationID:(NSString *)stationID {
    NSArray *stations = [self stationsForBusRoute:[self routeForSegmentID:segmentID]];
    NSNumber *stationSequence;
    for (BusStation *s in stations) {
        if ([stationID isEqualToString:s.stationID]) {
            stationSequence = s.stationSequence;
            break;
        }
    }
    return stationSequence;
}

- (NSArray *)stationDictWithKeyword:(NSString *)keyword {
    FMDatabase *db = [self busDatabase];
    NSMutableString *kw = [keyword mutableCopy];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"[^\\w]" options:NSRegularExpressionCaseInsensitive error:nil];
    [regex replaceMatchesInString:kw options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, [kw length]) withTemplate:@""];
    NSString *queryString = [NSString stringWithFormat:@"SELECT DISTINCT `station_name` FROM `bus_stationinfo` WHERE `station_name` LIKE '%%%@%%' ORDER BY `station_name`", kw];
    
    FMResultSet *s = [db executeQuery:queryString];
    NSMutableArray *stations = [[NSMutableArray alloc] init];
    while ([s next]) {
        [stations addObject:[s stringForColumn:@"station_name"]];
    }
    return stations;
}

#pragma mark - Helper methods

- (FMDatabase *)busDatabase {
    NSString *dbPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"wuxitraffic.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        return nil;
    }
    return db;
}

- (FMDatabase *)userDatabase {
    NSString *dbPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"userdata.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        return nil;
    }
    return db;
}

#pragma mark - File Attribute
+ (BOOL)haveSkipBackupAttributeForItemAtPath:(NSString *)filePath {
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:filePath];
    NSError *error = nil;
    id result;
    BOOL success = [URL getResourceValue: &result forKey: NSURLIsExcludedFromBackupKey error:&error];
    if(!success){
#if DEBUG
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
#endif
    }
    return [result boolValue];
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePath {
    if ([self haveSkipBackupAttributeForItemAtPath:filePath]) {
        return YES;
    }
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:filePath];
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error:&error];
    if(!success){
#if DEBUG
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
#endif
    }
    return success;
}

@end
