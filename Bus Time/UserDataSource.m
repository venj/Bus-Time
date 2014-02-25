//
//  History.m
//  Bus Time
//
//  Created by venj on 12-12-21.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import "UserDataSource.h"
#import "Favorite.h"
#import "History.h"
#import <FMDB/FMDatabase.h>
#import "BusStation.h"
#import "BusRoute.h"
#import "DBMigrator.h"

@implementation UserDataSource
static UserDataSource *__shared = nil;

+ (void)initialize {
    [DBMigrator copyOrMigrate];
}

+ (id)shared{
    if(__shared == nil){
        __shared = [[self alloc] init];
    }
    
    return __shared;
}

- (void)sharedClean{
    if (__shared) {
        __shared = nil;
    }
}

#pragma mark - User Database Query

- (NSArray *)favorites {
    FMDatabase *db = [self userDatabase];
    FMResultSet *s = [db executeQuery:@"SELECT * FROM favorites ORDER BY `updated_at` DESC"];
    NSMutableArray *favs = [[NSMutableArray alloc] initWithCapacity:0];
    while ([s next]) {
        NSDictionary *dict;
        dict = @{
            @"segment_id": [s stringForColumn:@"segment_id"],
            @"segment_name": [s stringForColumn:@"segment_name"],
            @"line_id": @([s intForColumn:@"line_id"]),
            @"station_sequence": @([s intForColumn:@"station_sequence"]),
            @"station_id": [s stringForColumn:@"station_id"],
            @"station_name": [s stringForColumn:@"station_name"],
            @"latitude": [s stringForColumn:@"latitude"],
            @"longitude": [s stringForColumn:@"longitude"],
            @"updated_at": @([s doubleForColumn:@"updated_at"])
        };
        [favs addObject:[[Favorite alloc] initWithDictionary:dict]];
    }
    
    [db close];
    return favs;
}

- (NSArray *)histories {
    FMDatabase *db = [self userDatabase];
    FMResultSet *s = [db executeQuery:@"SELECT * FROM histories ORDER BY `updated_at` DESC"];
    NSMutableArray *hists = [[NSMutableArray alloc] initWithCapacity:0];
    while ([s next]) {
        NSDictionary *dict;
            dict = @{
            @"segment_id": [s stringForColumn:@"segment_id"],
            @"segment_name": [s stringForColumn:@"segment_name"],
            @"line_id": [s stringForColumn:@"line_id"],
            @"station_sequence": @([s intForColumn:@"station_sequence"]),
            @"station_id": [s stringForColumn:@"station_id"],
            @"station_name": [s stringForColumn:@"station_name"],
            @"latitude": [s stringForColumn:@"latitude"],
            @"longitude": [s stringForColumn:@"longitude"],
            @"updated_at": @([s doubleForColumn:@"updated_at"])
        };
        [hists addObject:[[History alloc] initWithDictionary:dict]];
    }
    
    [db close];
    return hists;
}

- (BOOL)addOrUpdateHistoryWithObject:(id)object {
    if ([object isKindOfClass:[UserItem class]]) {
        return [self addOrUpdateHistoryWithUserItem:(UserItem *)object];
    }
    else {
        return [self addOrUpdateHistoryWithStation:(BusStation *)object];
    }
}

- (BOOL)addOrUpdateHistoryWithUserItem:(UserItem *)userItem {
    FMDatabase *db = [self userDatabase];
    FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM 'histories' WHERE `segment_id`='%@' AND `station_id`='%@'", userItem.segmentID, userItem.stationID]];
    NSInteger count = 0;
    if ([s next]) {
        count = [s intForColumnIndex:0];
    }
    NSString *queryString;
    BOOL result;
    NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
    if (count == 0) {
        queryString = @"INSERT INTO 'histories' ('updated_at', 'segment_id', 'segment_name', 'line_id', 'station_sequence', 'station_id', 'latitude', 'longitude', 'station_name') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        result = [db executeUpdate:queryString withArgumentsInArray:@[@(ts), userItem.segmentID, userItem.segmentName, userItem.lineID, userItem.stationSequence, userItem.stationID, @(userItem.location.coordinate.latitude), @(userItem.location.coordinate.longitude), userItem.stationName]];
    }
    else {
        queryString = @"UPDATE 'histories' SET `updated_at`=? WHERE `segment_id`=? AND `station_id`=?";
        result = [db executeUpdate:queryString withArgumentsInArray:@[@(ts), userItem.segmentID, userItem.stationID]];
    }
    
    [db close];
    return result;
}

- (BOOL)addOrUpdateHistoryWithStation:(BusStation *)station {
    FMDatabase *db = [self userDatabase];
    BusRoute *route = station.busRoute;
    FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM 'histories' WHERE `segment_id`='%@' AND `station_id`='%@'", route.segmentID, station.stationID]];
    NSInteger count = 0;
    if ([s next]) {
        count = [s intForColumnIndex:0];
    }
    NSString *queryString;
    BOOL result;
    NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
    if (count == 0) {
        queryString = @"INSERT INTO 'histories' ('updated_at', 'segment_id', 'segment_name', 'line_id', 'station_sequence', 'station_id', 'latitude', 'longitude', 'station_name') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        result = [db executeUpdate:queryString withArgumentsInArray:@[@(ts), route.segmentID, route.segmentName, route.lineID, station.stationSequence, station.stationID, @(station.location.coordinate.latitude), @(station.location.coordinate.longitude), station.stationName]];
    }
    else {
        queryString = @"UPDATE 'histories' SET `updated_at`=? WHERE `segment_id`=? AND `station_id`=?";
        result = [db executeUpdate:queryString withArgumentsInArray:@[@(ts), route.segmentID, station.stationID]];
    }
    
    [db close];
    return result;
}

- (BOOL)addOrUpdateFavoriteWithObject:(id)object {
    if ([object isKindOfClass:[UserItem class]]) {
        return [self addOrUpdateFavoriteWithUserItem:(UserItem *)object];
    }
    else {
        return [self addOrUpdateFavoriteWithStation:(BusStation *)object];
    }
}

- (BOOL)addOrUpdateFavoriteWithUserItem:(UserItem *)userItem {
    FMDatabase *db = [self userDatabase];
    FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM 'favorites' WHERE `segment_id`='%@' AND `station_id`='%@'", userItem.segmentID, userItem.stationID]];
    NSInteger count = 0;
    if ([s next]) {
        count = [s intForColumnIndex:0];
    }
    NSString *queryString;
    BOOL result;
    NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
    if (count == 0) {
        queryString = @"INSERT INTO 'favorites' ('updated_at', 'segment_id', 'segment_name', 'line_id', 'station_sequence', 'station_id', 'latitude', 'longitude', 'station_name') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        result = [db executeUpdate:queryString withArgumentsInArray:@[@(ts), userItem.segmentID, userItem.segmentName, userItem.lineID, userItem.stationSequence, userItem.stationID, @(userItem.location.coordinate.latitude), @(userItem.location.coordinate.longitude), userItem.stationName]];
    }
    else {
        queryString = @"UPDATE 'favorites' SET 'updated_at'=? WHERE `segment_id`=? AND `station_id`=?";
        result = [db executeUpdate:queryString withArgumentsInArray:@[@(ts), userItem.segmentID, userItem.stationID]];
    }
    
    [db close];
    return result;
}

- (BOOL)addOrUpdateFavoriteWithStation:(BusStation *)station {
    FMDatabase *db = [self userDatabase];
    BusRoute *route = station.busRoute;
    FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM 'favorites' WHERE `segment_id`='%@' AND `station_id`='%@'", route.segmentID, station.stationID]];
    NSInteger count = 0;
    if ([s next]) {
        count = [s intForColumnIndex:0];
    }
    NSString *queryString;
    BOOL result;
    NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
    if (count == 0) {
        queryString = @"INSERT INTO 'favorites' ('updated_at', 'segment_id', 'segment_name', 'line_id', 'station_sequence', 'station_id', 'latitude', 'longitude', 'station_name') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        result = [db executeUpdate:queryString withArgumentsInArray:@[@(ts), route.segmentID, route.segmentName, route.lineID, station.stationSequence, station.stationID, @(station.location.coordinate.latitude), @(station.location.coordinate.longitude), station.stationName]];
    }
    else {
        queryString = @"UPDATE 'favorites' SET `updated_at`=? WHERE `segment_id`=? AND `station_id`=?";
        result = [db executeUpdate:queryString withArgumentsInArray:@[@(ts), route.segmentID, station.stationID]];
    }
    
    [db close];
    return result;
}

- (BOOL)isFavoritedObject:(id)object {
    if ([object isKindOfClass:[UserItem class]]) {
        return [self isFavoritedUserItem:(UserItem *)object];
    }
    else {
        return [self isFavoritedStation:(BusStation *)object];
    }
}

- (BOOL)isFavoritedUserItem:(UserItem *)userItem {
    FMDatabase *db = [self userDatabase];
    NSString *queryString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM 'favorites' WHERE `segment_id`='%@' AND `station_id`='%@'", userItem.segmentID, userItem.stationID];
    FMResultSet *s = [db executeQuery:queryString];
    NSInteger count = 0;
    if ([s next]) {
        count = [s intForColumnIndex:0];
    }
    
    [db close];
    return (count == 0) ? NO : YES;
}

- (BOOL)isFavoritedStation:(BusStation *)station {
    FMDatabase *db = [self userDatabase];
    NSString *queryString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM 'favorites' WHERE `segment_id`='%@' AND `station_id`='%@'", station.busRoute.segmentID, station.stationID];
    FMResultSet *s = [db executeQuery:queryString];
    NSInteger count = 0;
    if ([s next]) {
        count = [s intForColumnIndex:0];
    }
    
    [db close];
    return (count == 0) ? NO : YES;
}

- (BOOL)isHistoryStation:(BusStation *)station {
    FMDatabase *db = [self userDatabase];
    NSString *queryString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM 'histories' WHERE `segment_id`='%@' AND `station_id`='%@'", station.busRoute.segmentID, station.stationID];
    FMResultSet *s = [db executeQuery:queryString];
    NSInteger count = 0;
    if ([s next]) {
        count = [s intForColumnIndex:0];
    }
    
    [db close];
    return (count == 0) ? NO : YES;
}

- (BOOL)removeHistoryWithStation:(BusStation *)station {
    FMDatabase *db = [self userDatabase];
    NSString *queryString = @"DELETE FROM 'histories' WHERE `segment_id`=? AND `station_id`=?";
    BOOL result = [db executeUpdate:queryString withArgumentsInArray:@[station.busRoute.segmentID, station.stationID]];
    
    [db close];
    return result;
}

- (BOOL)removeFavoriteWithStation:(BusStation *)station {
    FMDatabase *db = [self userDatabase];
    NSString *queryString = @"DELETE FROM 'favorites' WHERE `segment_id`=? AND `station_id`=?";
    BOOL result = [db executeUpdate:queryString withArgumentsInArray:@[station.busRoute.segmentID, station.stationID]];
    
    [db close];
    return result;
}

- (BOOL)removeHistoryWithUserItem:(UserItem *)userItem {
    FMDatabase *db = [self userDatabase];
    NSString *queryString = @"DELETE FROM 'histories' WHERE `segment_id`=? AND `station_id`=?";
    BOOL result = [db executeUpdate:queryString withArgumentsInArray:@[userItem.segmentID, userItem.stationID]];
    
    [db close];
    return result;
}

- (BOOL)removeHistoryWithObject:(id)object {
    if ([object isKindOfClass:[UserItem class]]) {
        return [self removeHistoryWithUserItem:(UserItem *)object];
    }
    else {
        return [self removeHistoryWithStation:(BusStation *)object];
    }
}

- (BOOL)removeFavoriteWithUserItem:(UserItem *)userItem {
    FMDatabase *db = [self userDatabase];
    NSString *queryString = @"DELETE FROM 'favorites' WHERE `segment_id`=? AND `station_id`=?";
    BOOL result = [db executeUpdate:queryString withArgumentsInArray:@[userItem.segmentID, userItem.stationID]];
    
    [db close];
    return result;
}

- (BOOL)removeFavoriteWithObject:(id)object {
    if ([object isKindOfClass:[UserItem class]]) {
        return [self removeFavoriteWithUserItem:(UserItem *)object];
    }
    else {
        return [self removeFavoriteWithStation:(BusStation *)object];
    }
}

- (NSArray *)stationNameHistories {
    FMDatabase *db = [self userDatabase];
    FMResultSet *s = [db executeQuery:@"SELECT * FROM 'station_histories' ORDER BY `updated_at` DESC"];
    NSMutableArray *snHistory = [[NSMutableArray alloc] initWithCapacity:0];
    while ([s next]) {
        NSString *name = [s stringForColumn:@"station_name"];
        [snHistory addObject:name];
    }
    
    [db close];
    return snHistory;
}

- (BOOL)addOrUpdateStationName:(NSString *)stationName {
    FMDatabase *db = [self userDatabase];
    FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM 'station_histories' WHERE `station_name`='%@'", stationName]];
    NSInteger count = 0;
    if ([s next]) {
        count = [s intForColumnIndex:0];
    }
    NSString *queryString;
    BOOL result;
    NSTimeInterval ts = [[NSDate date] timeIntervalSince1970];
    if (count == 0) {
        queryString = @"INSERT INTO 'station_histories' ('updated_at', 'station_name') VALUES (?, ?)";
        result = [db executeUpdate:queryString withArgumentsInArray:@[@(ts), stationName]];
    }
    else {
        queryString = @"UPDATE 'station_histories' SET `updated_at`=? WHERE `station_name`=?";
        result = [db executeUpdate:queryString withArgumentsInArray:@[@(ts), stationName]];
    }
    
    [db close];
    return result;
}

- (BOOL)removeStationHistoryWithStationName:(NSString *)stationName {
    FMDatabase *db = [self userDatabase];
    NSString *queryString = @"DELETE FROM 'station_histories' WHERE `station_name`=?";
    BOOL result = [db executeUpdate:queryString withArgumentsInArray:@[stationName]];    
    [db close];
    return result;
}

#pragma mark - Helper Method

- (FMDatabase *)userDatabase {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = paths[0];
    NSString *dbPath = [docDirectory stringByAppendingPathComponent:@"userdata.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        return nil;
    }
    return db;
}

@end
