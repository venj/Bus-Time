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
#import "AppDelegate.h"

@interface NearbyStationsViewController () <CLLocationManagerDelegate>
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"] style:UIBarButtonItemStyleBordered handler:^(id sender) {
        [[AppDelegate shared] showLeftMenu];
    }];
    UIViewController *blockSelf = self;
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位服务不可用" message:@"定位服务不可用。可能是因为您的设备不支持定位；或您没有打开定位服务；或您没有允许程序使用定位服务。" completionBlock:^(NSUInteger buttonIndex) {
            blockSelf.title = @"附近的公交站(定位服务不可用)";
        } cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else {
        self.title = @"附近的公交站";
        if (!self.manager) {
            self.manager = [[CLLocationManager alloc] init];
            self.manager.delegate = self;
            self.manager.distanceFilter = 50.0; // Update if user moves more than 50m.
            [self.manager startMonitoringSignificantLocationChanges];
        }
    }
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"%f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

@end
