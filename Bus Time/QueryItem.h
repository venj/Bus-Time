//
//  QueryItem.h
//  Bus Time
//
//  Created by venj on 13-7-17.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "BusStation.h"

@interface QueryItem : NSObject <MKAnnotation>

@property (nonatomic, strong) BusStation *station;
@property (nonatomic, copy) NSString *busSerial;
@property (nonatomic, copy) NSString *timeString;
@property (nonatomic, assign) NSInteger *stationNumber;
// MKAnnotation
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;

// Initializer
- (id)initWithDictionary:(NSDictionary *)stationDict userStation:(BusStation *)userStation allStations:(NSArray *)stations showCurrent:(BOOL)shouldShowCurrent;
// If you want to use the real coordinate for calculation, use this one, not `- coordinate`.
- (CLLocationCoordinate2D)realCoordinate;
@end
