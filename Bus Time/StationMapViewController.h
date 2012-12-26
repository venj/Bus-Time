//
//  StationMapViewController.h
//  Bus Time
//
//  Created by venj on 12-12-26.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKMapView;
@interface StationMapViewController : UIViewController
@property (nonatomic, strong) NSArray *stations;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@end
