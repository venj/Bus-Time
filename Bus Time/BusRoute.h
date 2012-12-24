//
//  BusRoute.h
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusRoute : NSObject
@property (nonatomic, strong) NSString *segmentName;
@property (nonatomic, strong) NSString *segmentNamePY;
@property (nonatomic, strong) NSString *segmentID;
@property (nonatomic, strong) NSNumber *lineID;
@property (nonatomic, strong) NSArray *stations;
@property (nonatomic, strong) NSString *serviceInfo;
- (id)initWithDictionary:(NSDictionary *)busDict;
@end
