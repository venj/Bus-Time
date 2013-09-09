//
//  MarsHelper.h
//  Bus Time
//
//  Created by venj on 13-9-9.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MarsHelper : NSObject
+ (CLLocationCoordinate2D)convertToEarthCoordinateWithMarsCoordinate:(CLLocationCoordinate2D)marsCoord;
@end
