//
//  NearbyStation.h
//  Bus Time
//
//  Created by venj on 13-1-5.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import "UserItem.h"
#import "BusStation.h"

@interface NearbyStation : UserItem
@property (nonatomic, strong) NSString *segmentNamePY;
@property (nonatomic, strong) NSString *stationNamePY;
- (id)initWithBusStation:(BusStation *)busStation;
- (id)lookupStationSequence;
@end
