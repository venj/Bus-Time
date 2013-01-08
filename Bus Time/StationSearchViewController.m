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

@interface StationSearchViewController ()
@property (nonatomic, strong) NSArray *stations;
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
    self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"Bus Name, Pinyin Abbrivation", @"路线名或首字母缩写");
    self.searchDisplayController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchDisplayController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchDisplayController.searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:115./255. green:123./255. blue:143./255. alpha:1];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"] style:UIBarButtonItemStyleBordered handler:^(id sender) {
            [[AppDelegate shared] showLeftMenu];
        }];
    }
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
    return [self.stations count];
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
    BusStation *station = [self.stations objectAtIndex:indexPath.row];
    cell.textLabel.text = station.stationName;
    
    return cell;
}

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - SearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.filteredStations = [[BusDataSource shared] stationsForText:searchText];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

@end
