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
#import "HandyFoundation.h"
#import "NSTimer+Blocks.h"

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
    self.title = NSLocalizedString(@"Nearby", @"附近站点");
    self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"Bus Name, Pinyin Abbrivation", @"路线名或首字母缩写");
    self.searchDisplayController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchDisplayController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchDisplayController.searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:115./255. green:123./255. blue:143./255. alpha:1];
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.purpose = NSLocalizedString(@"\"Nearby\" feature needs your location to discover nearby bus stops.", @"“附近站点”功能需要使用您的当前位置来发现附近的公交站点。");
        self.manager.delegate = self;
        self.manager.distanceFilter = 100.0; // Update if user moves more than 100m.
        self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    if (!([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
        NSString *msg;
        BOOL shouldShowAlert = YES;
        if (![CLLocationManager locationServicesEnabled]) {
            msg = NSLocalizedString(@"Location Service is not available. Maybe Location Services is turned off on your device.", @"定位服务不可用。可能是您没有打开定位服务。");
        }
        else {
            switch([CLLocationManager authorizationStatus]){
                case kCLAuthorizationStatusAuthorized: {
                    shouldShowAlert = NO;
                    break;
                }
                case kCLAuthorizationStatusDenied: {
                    msg = NSLocalizedString(@"You are not allow app to access your location info. If you want to change your settings, please open \"Settings\" app, navigate to \"Privacy\" - \"Location Service\" and allow app to access your location info.", @"您没有允许程序访问您的定位信息。如果你要修改定位授权，请打开“设置” - “隐私” - “位置”，并允许“无锡公交查询”访问您的定位信息。") ;
                    break;
                }
                case kCLAuthorizationStatusRestricted:{
                    msg = NSLocalizedString(@"Parental Control denied the app to access your location info.", @"家长控制设置不允许本程序使用定位信息。");
                    break;
                }
                case kCLAuthorizationStatusNotDetermined: {
                    shouldShowAlert = NO;
                    break;
                }
            }
        }
        if (shouldShowAlert) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"提示") message:msg completionBlock:^(NSUInteger buttonIndex) {
            } cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil];
            [alert show];
            return;
        }
        else {
            [self.manager startUpdatingLocation];
        }
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map_icon"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        if ([self.nearbyStations count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"附近没有任何公交车站。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        };
        StationMapViewController *stationVC = [[StationMapViewController alloc] initWithNibName:@"StationMapViewController" bundle:nil];
        stationVC.stations = self.nearbyStations;
        stationVC.title = self.title;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:stationVC];
        nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.navigationController presentModalViewController:nav animated:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [NSTimer scheduledTimerWithTimeInterval:1 block:^{
                [self.manager startUpdatingLocation];
        } repeats:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [NSTimer scheduledTimerWithTimeInterval:5 block:^{
        [self.manager stopUpdatingLocation];
    } repeats:NO];
    [super viewWillDisappear:animated];
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
    NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:newLocation.timestamp];
    if (delta > (5 * 60)) {
        return;
    }
    [self.manager stopUpdatingLocation];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.nearbyStations = [[BusDataSource shared] nearbyStationsForCoordinate:newLocation.coordinate inRadius:500];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            if ([self.nearbyStations count] == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"提示") message:@"No bus stops nearby." completionBlock:^(NSUInteger buttonIndex) {
                } cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil];
                [alert show];
            }
        });
    });
}

@end
