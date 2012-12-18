//
//  BusListViewController.m
//  BusTime
//
//  Created by venj on 12-10-10.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "BusListViewController.h"
#import "BusDataSource.h"
#import "BusStation.h"
#import "StationListViewController.h"
#import "SettingsViewController.h"

@interface BusListViewController () <UISearchDisplayDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSArray *filterBuses;
@end

@implementation BusListViewController

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
    BusDataSource *source = [BusDataSource shared];
    self.allBuses = source.busList;
    
    self.title = @"公交线路";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain handler:^(id sender) {
        SettingsViewController *settingsControl = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        UINavigationController *settingsNavControl = [[UINavigationController alloc] initWithRootViewController:settingsControl];
        settingsNavControl.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.navigationController presentModalViewController:settingsNavControl animated:YES];
    }];
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filterBuses count];
    }
    else {
        return [self.allBuses count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BusListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    // Configure the cell...
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [(BusRoute *)[self.filterBuses objectAtIndex:indexPath.row] segmentName];
    }
    else {
        cell.textLabel.text = [(BusRoute *)[self.allBuses objectAtIndex:indexPath.row] segmentName];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StationListViewController *stationListViewController = [[StationListViewController alloc] initWithNibName:@"StationListViewController" bundle:nil];
    stationListViewController.busRoute = [self.allBuses objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:stationListViewController animated:YES];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSIndexSet *resultSet = [self.allBuses indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSString *busName = [(BusRoute *)obj segmentName];
        NSRange result = [busName rangeOfString:[searchText strip]];
        return (result.location == NSNotFound) ? NO : YES;
    }];
    
    self.filterBuses = [self.allBuses objectsAtIndexes:resultSet];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

@end