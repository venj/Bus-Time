//
//  StationSearchViewController.m
//  Bus Time
//
//  Created by venj on 13-1-8.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import "StationSearchViewController.h"
#import "BusStation.h"
#import "BusRoute.h"
#import "BusDataSource.h"
#import "AppDelegate.h"
#import "UIBarButtonItem+Blocks.h"
#import "UIAlertView+Blocks.h"
#import "CharToPinyin.h"
#import "HandyFoundation.h"
#import "UserDataSource.h"
#import "BusListViewController.h"

@interface StationSearchViewController ()
@property (nonatomic, strong) NSArray *stationHistories;
@property (nonatomic, strong) NSArray *filteredStations;
@end

@implementation StationSearchViewController

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
    self.title = NSLocalizedString(@"Search", @"站名搜索");
    self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"Please enter bus stop name", @"请输入站名");
    self.searchDisplayController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchDisplayController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchDisplayController.searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:115./255. green:123./255. blue:143./255. alpha:1];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"] style:UIBarButtonItemStyleBordered handler:^(id sender) {
            [[AppDelegate shared] showLeftMenu];
        }];
    }
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.stationHistories = [[UserDataSource shared] stationNameHistories];
    [self.tableView reloadData];
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredStations count];
    }
    return [self.stationHistories count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    return NSLocalizedString(@"Search History", @"搜索历史");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StationSearchHistoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSString *station = [self.filteredStations objectAtIndex:indexPath.row];
        cell.textLabel.text = station;
    }
    else {
        NSString *station = [self.stationHistories objectAtIndex:indexPath.row];
        cell.textLabel.text = station;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *stationName = cell.textLabel.text;
        [[UserDataSource shared] removeStationHistoryWithStationName:stationName];
        self.stationHistories = [[UserDataSource shared] stationNameHistories];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        if ([self.stationHistories count] == 0) {
            [self changeEditingStatusAnimated:YES];
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *stationName = cell.textLabel.text;
    NSArray *busList = [[BusDataSource shared] busRoutesWithStationName:stationName];
    if ([busList count] > 0) {
        [[UserDataSource shared] addOrUpdateStationName:stationName];
        BusListViewController *busListViewController = [[BusListViewController alloc] initWithNibName:@"BusListViewController" bundle:nil];
        busListViewController.allBuses = busList;
        busListViewController.shouldShowMenuIcon = NO;
        [self.navigationController pushViewController:busListViewController animated:YES];
    }
    else {
        [self.searchDisplayController.searchBar resignFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"提示") message:NSLocalizedString(@"Bus lines pass the bus stop is not included in the system yet.", @"途径该站的公交线路暂未被系统收录。")  delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil];
        [alert show];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchDisplayController.searchBar resignFirstResponder];
}

#pragma mark - SearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.filteredStations = [[BusDataSource shared] stationNamesWithKeyword:searchText];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchDisplayController.searchResultsTableView reloadData];
        });
    });
}

#pragma mark - Search

- (void)changeEditingStatusAnimated:(BOOL)animated {
    if ([self.tableView isEditing]) {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Edit", @"编辑");
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;
        [self.tableView setEditing:NO animated:animated];
    }
    else {
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done", @"完成");
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
        [self.tableView setEditing:YES animated:animated];
    }
}

@end
