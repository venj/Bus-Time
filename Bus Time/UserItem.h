//
//  Favorite.h
//  Bus Time
//
//  Created by venj on 12-12-21.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserItem : NSObject
@property (nonatomic, strong) NSString *segmentID;
@property (nonatomic, strong) NSString *segmentName;
@property (nonatomic, strong) NSNumber *lineID;
@property (nonatomic, strong) NSNumber *stationSequence;
@property (nonatomic, strong) NSString *stationID;
@property (nonatomic, strong) NSString *stationName;
@property (nonatomic, assign) CGFloat updateDate;
- (id)initWithDictionary:(NSDictionary *)dataDict;
@end
