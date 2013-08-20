//
//  QueryItem.m
//  Bus Time
//
//  Created by venj on 13-7-17.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import "QueryItem.h"

@interface QueryItem ()
@property (nonatomic, assign) BOOL showCurrent;
@end

@implementation QueryItem

- (id)initWithDictionary:(NSDictionary *)stationDict userStation:(BusStation *)userStation allStations:(NSArray *)stations showCurrent:(BOOL)shouldShowCurrent {
    if ((self = [super init])) {
        NSInteger stationNumber = [[stationDict  valueForKeyPath:@"stationnum.text"] integerValue];
        NSString *stationName = [stationDict  valueForKeyPath:@"stationname.text"];
        _station = [stations objectAtIndex:([userStation.stationSequence integerValue] - stationNumber - 1)];
        NSAssert([[_station stationName] isEqualToString:stationName], @"Wrong station!!!");
        _stationNumber = stationNumber;
        _busSerial = [stationDict valueForKeyPath:@"busselfid.text"];
        _timeString = [stationDict valueForKeyPath:@"actdatetime.text"];
        _showCurrent = shouldShowCurrent;
    }
    
    return self;
}

- (NSString *)title {
    if (self.showCurrent)
        return self.station.stationName;
    else
        return [NSString stringWithFormat:@"%@. %@", self.station.stationSequence, self.station.stationName];
}

- (NSString *)subtitle {
    if (self.showCurrent)
        return [NSString stringWithFormat:NSLocalizedString(@"Bus #%1$@ was %2$d stops to your place at %3$@", @"%1$@次公交于%3$@到达，离您还有%2$d站"), self.busSerial, self.stationNumber, self.timeString];
    else
        return [NSString stringWithFormat:NSLocalizedString(@"Bus: %1$@ arrived here at %2$@", @"公交%1$@次班车于%2$@到达"), self.busSerial, self.timeString];
}

- (CLLocationCoordinate2D)realCoordinate {
    return [self.station.location coordinate];
}

- (CLLocationCoordinate2D)coordinate {
    // Add calibration for Wuxi.
    return CLLocationCoordinate2DMake(self.station.location.coordinate.latitude - 0.001906, self.station.location.coordinate.longitude + 0.004633);
}

@end
