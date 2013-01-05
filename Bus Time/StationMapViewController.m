//
//  StationMapViewController.m
//  Bus Time
//
//  Created by venj on 12-12-26.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import "StationMapViewController.h"
#import "NearbyStation.h"
#import <MapKit/MapKit.h>
#import "UIBarButtonItem+Blocks.h"

@interface StationMapViewController () <MKMapViewDelegate>

@end

@implementation StationMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone handler:^(id sender) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:115./255. green:123./255. blue:143./255. alpha:1];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.075);
    id<MKAnnotation> s = [self.stations objectAtIndex:[self.stations count] / 4];
    MKCoordinateRegion visibleRegion = MKCoordinateRegionMake(s.coordinate, span);
    [self.mapView setRegion:visibleRegion animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    return YES;
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.mapView removeAnnotations:self.stations];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    if ([mapView.annotations count] <= 1) {
        [mapView addAnnotations:self.stations];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if ([self.mapView.annotations count] <= 1) {
        [self.mapView addAnnotations:self.stations];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return [mapView viewForAnnotation:mapView.userLocation];
    }
    NSString *AnnotationIdentifier = @"StationPin";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        //pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        if ([annotation isKindOfClass:[BusStation class]]) {
            BusStation *station = (BusStation *)annotation;
            station.title = [NSString stringWithFormat:@"%@. %@", station.stationSequence, station.stationName];
            station.subtitle = station.busRoute.segmentName;
        }
        else if ([annotation isKindOfClass:[NearbyStation class]]) {
            NearbyStation *station = (NearbyStation *)annotation;
            station.title = [NSString stringWithFormat:@"%@. %@", station.stationSequence, station.stationName];
            station.subtitle = station.segmentName;
        }
    }
    return pinView;
}
/*
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    id<MKAnnotation> annotation = view.annotation;
    if ([annotation isKindOfClass:[NearbyStation class]]) {
        NearbyStation *station = (NearbyStation *)annotation;
        [station lookupStationSequence];
        station.title = [NSString stringWithFormat:@"%@. %@", station.stationSequence, station.stationName];
        station.subtitle = station.segmentName;
    }
}*/

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
}

@end
