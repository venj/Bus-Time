//
//  BusDataSource.h
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class BusRoute;
@interface BusDataSource : NSObject
+ (id)shared;
- (void)sharedClean;

+ (NSString *)busDataBaseVersion;
+ (BOOL)updateDatabaseFileWithFileAtPath:(NSString *)updatedDatabaseFilePath;
- (NSArray *)busRoutes;
- (NSArray *)busRoutesWithStationName:(NSString *)stationName;
- (BusRoute *)routeForSegmentID:(NSString *)segmentID;
- (NSArray *)stationsForBusRoute:(BusRoute *)busRoute;
- (NSArray *)nearbyStationsForCoordinate:(CLLocationCoordinate2D)coordinate inRadius:(double)radius;
- (NSDictionary *)routeInfoForBusRoute:(BusRoute *)busRoute;
- (NSNumber *)stationSequenceForSegmentID:(NSString *)segmentID andStationID:(NSString *)stationID;
- (NSArray *)stationNamesWithKeyword:(NSString *)keyword;
@end
