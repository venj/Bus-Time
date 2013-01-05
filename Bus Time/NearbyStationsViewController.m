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
#import "NearbyStation.h"
#import "UserDataSource.h"
#import "QueryResultViewController.h"

@interface NearbyStationsViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) NSArray *nearbyStations;
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
    /*
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map_icon"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        if ([blockSelf.nearbyStations count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"附近没有任何公交车站。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        };
        StationMapViewController *stationVC = [[StationMapViewController alloc] initWithNibName:@"StationMapViewController" bundle:nil];
        stationVC.stations = blockSelf.nearbyStations;
        stationVC.title = self.title;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:stationVC];
        nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.navigationController presentModalViewController:nav animated:YES];
    }];
     */
}

- (void)dealloc {
    [self.manager stopUpdatingLocation];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredStations count];
    }
    else {
        return [self.nearbyStations count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NearbyStationsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSArray *nearbyStations;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        nearbyStations = self.filteredStations;
    }
    else {
        nearbyStations = self.nearbyStations;
    }
    
    NearbyStation *station = [nearbyStations objectAtIndex:indexPath.row];
    cell.textLabel.text = station.segmentName;
    cell.detailTextLabel.text = station.stationName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *nearbyStations;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        nearbyStations = self.filteredStations;
    }
    else {
        nearbyStations = self.nearbyStations;
    }
    NearbyStation *nearbyStation = [nearbyStations objectAtIndex:indexPath.row];
    [nearbyStation lookupStationSequence];
    [[UserDataSource shared] addOrUpdateHistoryWithUserItem:nearbyStation];
    QueryResultViewController *queryController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        queryController = [[QueryResultViewController alloc] initWithStyle:UITableViewStyleGrouped];
        queryController.title = [NSString stringWithFormat:@"%@, %@", nearbyStation.segmentName, nearbyStation.stationName];
        queryController.station = nil;
        queryController.userItem = nearbyStation;
        [self.navigationController pushViewController:queryController animated:YES];
    }
    else {
        queryController = [[AppDelegate shared] queryResultController];
        queryController.title = [NSString stringWithFormat:@"%@, %@", nearbyStation.segmentName, nearbyStation.stationName];
        queryController.station = nil;
        queryController.userItem = nearbyStation;
        [queryController loadResult];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSIndexSet *resultSet = [self.nearbyStations indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSString *stationName = [(NearbyStation *)obj stationName];
        NSString *stationNamePY = [(NearbyStation *)obj stationNamePY];
        NSString *segmentName = [(NearbyStation *)obj segmentName];
        NSString *segmentNamePY = [(NearbyStation *)obj segmentNamePY];
        
        NSRange result1 = [stationName rangeOfString:[searchText strip]];
        NSRange result2 = [stationNamePY rangeOfString:[searchText strip]];
        NSRange result3 = [segmentName rangeOfString:[searchText strip]];
        NSRange result4 = [segmentNamePY rangeOfString:[searchText strip]];
        if (result1.location == NSNotFound && result2.location == NSNotFound && result3.location == NSNotFound && result4.location == NSNotFound) {
            return NO;
        }
        return YES;
    }];
    
    self.filteredStations = [self.nearbyStations objectsAtIndexes:resultSet];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.nearbyStations = [[BusDataSource shared] nearbyStationsForCoordinate:newLocation.coordinate inRadius:500];
    if ([self.nearbyStations count] == 0) {
        self.title = @"附近的公交站(附近无站点)";
    }
    else {
        self.title = @"附近的公交站";
    }
    [self.tableView reloadData];
}

@end
