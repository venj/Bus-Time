//
//  BusStation.h
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "BusRoute.h"

@interface BusStation : NSObject <MKAnnotation>
@property (nonatomic, strong) NSNumber *stationNumber;
@property (nonatomic, strong) NSNumber *stationSequence;
@property (nonatomic, strong) NSString *stationType;
@property (nonatomic, strong) NSString *stationName;
@property (nonatomic, strong) NSString *stationNamePY;
@property (nonatomic, strong) NSString *stationID;
@property (nonatomic, strong) NSString *stationSMSID;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) BusRoute *busRoute;
// MKAnnotation
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;

// Initializer
- (id)initWithDictionary:(NSDictionary *)stationDict;
// If you want to use the real coordinate for calculation, use this one, not `- coordinate`.
- (CLLocationCoordinate2D)realCoordinate;
@end
