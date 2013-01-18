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
#import "CharToPinyin.h"
#import "HandyFoundation.h"

@interface StationSearchViewController () {
    NSArray *_stationDicts;
}
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [self.filteredStations objectAtIndex:indexPath.row];
        //NSDictionary *station = [self.filteredStations objectAtIndex:indexPath.row];
        //cell.textLabel.text = [station objectForKey:@"station_name"];
    }
    else {
        BusStation *station = [self.stations objectAtIndex:indexPath.row];
        cell.textLabel.text = station.stationName;
    }
    
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!_stationDicts) {
            _stationDicts = [[BusDataSource shared] stationDicts];
        }
        else if ([[[_stationDicts objectAtIndex:0] objectForKey:@"station_name_py"] isEqualToString:@""]) {
            for (NSInteger i = 0 ; i < [_stationDicts count]; i++) {
                NSMutableDictionary *dict = [_stationDicts objectAtIndex:i];
                NSString *n = [dict objectForKey:@"station_name"];
                NSString *py = [[CharToPinyin shared] abbreviation:n];
                [dict setObject:py forKey:@"station_name_py"];
            }
        }
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for (NSDictionary *d in _stationDicts) {
            NSString *n = [d objectForKey:@"station_name"];
            NSString *py = [d objectForKey:@"station_name_py"];
            NSString *s = [searchText strip];
            if ([n rangeOfString:s].location != NSNotFound || [py rangeOfString:s].location != NSNotFound) {
                if ([result indexOfObject:n] == NSNotFound) {
                    [result addObject:n];
                }
            }
        }
        [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 caseInsensitiveCompare:obj2];//[[obj1 objectForKey:@"station_name"] caseInsensitiveCompare:[obj2 objectForKey:@"station_name"]];
        }];
        self.filteredStations = result;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchDisplayController.searchResultsTableView reloadData];
        });
    });
    
}

@end
