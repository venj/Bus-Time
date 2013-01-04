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
        _updateDate = [[dataDict objectForKey:@"updated_at"] doubleValue];
    }
    return self;
}
@end
