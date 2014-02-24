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
#import "AppDelegate.h"

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
    self.title = NSLocalizedString(@"Buses", @"公交路线");
    self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"Bus Name, Pinyin Abbrivation", @"路线名或首字母缩写");
    self.searchDisplayController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchDisplayController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchDisplayController.searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:115./255. green:123./255. blue:143./255. alpha:1];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && self.shouldShowMenuIcon == YES) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"menu_icon"] style:UIBarButtonItemStyleBordered handler:^(id sender) {
            [[AppDelegate shared] showLeftMenu];
        }];
    }
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
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
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
    NSArray *busRoutes;
    if (tableView == self.searchDisplayController.searchResultsTableView)
        busRoutes = self.filterBuses;
    else
        busRoutes = self.allBuses;
    StationListViewController *stationListViewController = [[StationListViewController alloc] initWithNibName:@"StationListViewController" bundle:nil];
    stationListViewController.busRoute = [busRoutes objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:stationListViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSArray *busRoutes;
    if (tableView == self.searchDisplayController.searchResultsTableView)
        busRoutes = self.filterBuses;
    else
        busRoutes = self.allBuses;
    BusRoute *route = [busRoutes objectAtIndex:indexPath.row];
    NSDictionary *infoDict = [[BusDataSource shared] routeInfoForBusRoute:route];
    NSString *title, *message;
    if (infoDict == nil || [[infoDict objectForKey:@"line_info"] isEqualToString:@""]) {
        title = NSLocalizedString(@"Info", @"提示");
        message = [NSString stringWithFormat:NSLocalizedString(@"Service hours for bus: %@ is not available.", @"公交%@的运营时间不可用。"), route.segmentName];
    }
    else {
        title = [NSString stringWithFormat:NSLocalizedString(@"Service hours for %@", @"公交%@运营时间"), [infoDict objectForKey:@"line_name"]];
        message = [infoDict objectForKey:@"line_info"];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil];
    [alert show];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSIndexSet *resultSet = [self.allBuses indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSString *busName = [(BusRoute *)obj segmentName];
        NSString *busNamePY = [(BusRoute *)obj segmentNamePY];
        NSRange result = [busName rangeOfString:[searchText strip]];
        if (result.location == NSNotFound) {
            result = [busNamePY rangeOfString:[searchText strip]];
            return (result.location == NSNotFound) ? NO : YES;
        }
        else {
            return YES;
        }
    }];
    
    self.filterBuses = [self.allBuses objectsAtIndexes:resultSet];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

@end
