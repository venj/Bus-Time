//
//  NearbyStationsViewController.m
//  Bus Time
//
//  Created by venj on 12-12-26.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import "NearbyStationsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "UIAlertView+Blocks.h"
#import "UIBarButtonItem+Blocks.h"
#import "AppDelegate.h"
#import "BusDataSource.h"
#import "BusStation.h"
#import "StationMapViewController.h"

@interface NearbyStationsViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) NSArray *stations;
@property (nonatomic, strong) NSArray *filteredStations;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *manager;
@end

@implementation NearbyStationsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"] style:UIBarButtonItemStyleBordered handler:^(id sender) {
            [[AppDelegate shared] showLeftMenu];
        }];
    }
    self.title = @"附近的公交站";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:115./255. green:123./255. blue:143./255. alpha:1];
    NearbyStationsViewController *blockSelf = self;
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.purpose = @"“附近的站点”功能需要使用您的当前位置来发现附近的公交站点。";
        self.manager.delegate = self;
        self.manager.distanceFilter = 100.0; // Update if user moves more than 100m.
        self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [self.manager startUpdatingLocation];
    }
    if (!([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
        NSString *msg, *addon;
        BOOL shouldShowAlert = YES;
        if (![CLLocationManager locationServicesEnabled]) {
            msg = @"定位服务不可用。可能是因为您的设备不支持定位；或您没有打开定位服务；或您没有允许程序使用定位服务。";
            addon = @"定位不可用";
        }
        else {
            switch([CLLocationManager authorizationStatus]){
                case kCLAuthorizationStatusAuthorized: {
                    shouldShowAlert = NO;
                    break;
                }
                case kCLAuthorizationStatusDenied: {
                    msg = @"您没有允许程序访问您的定位信息。如果你要修改定位授权，请打开“设置” - “隐私” - “位置”，并允许“无锡公交查询”访问您的定位信息。";
                    addon = @"未允许定位";
                    break;
                }
                case kCLAuthorizationStatusRestricted:{
                    msg = @"家长控制设置不允许本设备使用定位信息。";
                    addon = @"家长控制";
                    break;
                }
                case kCLAuthorizationStatusNotDetermined: {
                    shouldShowAlert = NO;
                    break;
                }
            }
        }
        if (shouldShowAlert) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位服务不可用" message:msg completionBlock:^(NSUInteger buttonIndex) {
                blockSelf.title = [NSString stringWithFormat:@"附近的公交站(%@)", addon];
            } cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map_icon"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        if ([blockSelf.stations count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"附近没有任何公交车站。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        };
        StationMapViewController *stationVC = [[StationMapViewController alloc] initWithNibName:@"StationMapViewController" bundle:nil];
        stationVC.stations = blockSelf.stations;
        stationVC.title = self.title;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:stationVC];
        nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.navigationController presentModalViewController:nav animated:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.manager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.manager stopUpdatingLocation];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.stations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NearbyStationsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    BusStation *station = [self.stations objectAtIndex:indexPath.row];
    cell.textLabel.text = station.busRoute.segmentName;
    cell.detailTextLabel.text = station.stationName;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"%f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    self.stations = [[BusDataSource shared] nearbyStationsForCoordinate:newLocation.coordinate inRadius:500];
    [self.tableView reloadData];
}

@end
