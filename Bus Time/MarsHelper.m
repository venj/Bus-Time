//
//  MarsHelper.m
//  Bus Time
//
//  Created by venj on 13-9-9.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import "MarsHelper.h"
#import <FMDB/FMDatabase.h>

@implementation MarsHelper
+ (CLLocationCoordinate2D)convertToEarthCoordinateWithMarsCoordinate:(CLLocationCoordinate2D)marsCoord {
    int tenLat = 0;
    int tenLng = 0;
    tenLat = (int)(marsCoord.latitude * 10);
    tenLng = (int)(marsCoord.longitude * 10);
    
    NSString *gpsDBPath = [[NSBundle mainBundle] pathForResource:@"gps" ofType:@"db"];
    FMDatabase *db = [FMDatabase databaseWithPath:gpsDBPath];
    [db open];
    FMResultSet *t = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM gpsT WHERE lat=%d AND log=%d", tenLat, tenLng]];
    
    int offLat = 0, offLng = 0;
    if ([t next]) {
        offLat = [t intForColumn:@"offLat"];
        offLng = [t intForColumn:@"offLog"];
    }
    
    [db close];
    
    return CLLocationCoordinate2DMake(marsCoord.latitude + offLat * 0.0001, marsCoord.longitude + offLng * 0.0001);
}
@end
