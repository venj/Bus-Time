//
//  Favorite.h
//  Bus Time
//
//  Created by venj on 12-12-21.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UserItem : NSObject <MKAnnotation>
@property (nonatomic, strong) NSString *segmentID;
@property (nonatomic, strong) NSString *segmentName;
@property (nonatomic, strong) NSNumber *lineID;
@property (nonatomic, strong) NSNumber *stationSequence;
@property (nonatomic, strong) NSString *stationID;
@property (nonatomic, strong) NSString *stationName;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) CGFloat updateDate;
- (id)initWithDictionary:(NSDictionary *)dataDict;
// MKAnnotation
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;
// If you want to use the real coordinate for calculation, use this one, not `- coordinate`.
- (CLLocationCoordinate2D)realCoordinate;
@end
