//
//  StationListViewController.m
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "StationListViewController.h"
#import "BusStation.h"
#import "BusRoute.h"
#import "BusDataSource.h"
#import "QueryResultViewController.h"
#import "AppDelegate.h"
#import <ODRefreshControl/ODRefreshControl.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import <XMLReader/XMLReader.h>
#import "StationMapViewController.h"
#import "UserDataSource.h"
#import "QueryItem.h"

@interface StationListViewController ()
@property (nonatomic, strong) NSArray *stations;
@property (nonatomic, strong) NSArray *filterStations;
@end

@implementation StationListViewController

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
    self.title = self.busRoute.segmentName;
    self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"Bus Name, Pinyin Abbrivation", @"路线名或首字母缩写");
    self.searchDisplayController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchDisplayController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchDisplayController.searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:115./255. green:123./255. blue:143./255. alpha:1];
    
    self.stations = [[BusDataSource shared] stationsForBusRoute:self.busRoute];
    StationListViewController *blockSelf = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map_icon"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Please choose your action", @"选择您要执行的操作")];
        [sheet addButtonWithTitle:NSLocalizedString(@"All stops", @"所有公交站") handler:^{
            StationMapViewController *stationVC = [[StationMapViewController alloc] initWithNibName:@"StationMapViewController" bundle:nil];
            stationVC.stations = blockSelf.stations;
            stationVC.title = self.title;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:stationVC];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            }
            else {
                nav.modalPresentationStyle = UIModalPresentationPageSheet;
                nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            }
            [self.navigationController presentModalViewController:nav animated:YES];
        }];
        [sheet addButtonWithTitle:NSLocalizedString(@"Buses on the way", @"在途的公交车") handler:^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            BusStation *station = [self.stations lastObject];
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://218.90.160.85:10086/BusTravelGuideWebService/bustravelguide.asmx"]];
            __block ASIHTTPRequest *request_b = request;
            NSString *postBodyString = [NSString stringWithFormat:
                                        @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                        "  <soap:Body>\n"
                                        "    <getBusALStationInfoCommon xmlns=\"http://tempuri.org/\">\n"
                                        "      <routeid>%@</routeid>\n"
                                        "      <segmentid>%@</segmentid>\n"
                                        "      <stationseq>%@</stationseq>\n"
                                        "      <fdisMsg></fdisMsg>\n"
                                        "    </getBusALStationInfoCommon>\n"
                                        "  </soap:Body>\n"
                                        "</soap:Envelope>\n", station.busRoute.lineID, station.busRoute.segmentID, station.stationSequence];
            NSData *postData = [postBodyString dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *headersDict = [[NSMutableDictionary alloc] init];
            [headersDict setObject:@([postData length]) forKey:@"Content-Length"];
            [headersDict setObject:@"text/xml" forKey:@"Content-Type"];
            [headersDict setObject:@"http://tempuri.org/getBusALStationInfoCommon" forKey:@"soapActionString"];
            [request setPostBody:[[NSMutableData alloc] initWithData:postData]];
            [request setRequestMethod:@"POST"];
            [request setRequestHeaders:headersDict];
            //网络请求开始
            [request setStartedBlock:^{}];
            //网络请求成功
            [request setCompletionBlock:^{
                [hud hide:YES];
                NSString *responseString = [request_b responseString];
                NSError *error;
                NSDictionary *result = [XMLReader dictionaryForXMLString:responseString error:&error];
                NSString *infoString = (NSString *)[result valueForKeyPath:@"soap:Envelope.soap:Body.getBusALStationInfoCommonResponse.fdisMsg.text"];
                if (infoString != nil) {
                    [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"Info", @"提示") message:infoString cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil handler:NULL];
                }
                else {
                    id infoArray = [result valueForKeyPath:@"soap:Envelope.soap:Body.getBusALStationInfoCommonResponse.getBusALStationInfoCommonResult.diffgr:diffgram.NewDataSet.Table1"];
                    NSArray *results;
                    if ([infoArray isKindOfClass:[NSDictionary class]]) {
                        results = @[infoArray];
                    }
                    else {
                        results = infoArray;
                    }
                    NSMutableArray *queryItems = [NSMutableArray array];
                    for (NSDictionary *infoDict in infoArray) {
                        QueryItem *item = [[QueryItem alloc] initWithDictionary:infoDict userStation:station allStations:self.stations showCurrent:NO];
                        [queryItems addObject:item];
                    }
                    StationMapViewController *stationVC = [[StationMapViewController alloc] initWithNibName:@"StationMapViewController" bundle:nil];
                    stationVC.stations = queryItems;
                    stationVC.title = @"Buses on the road";
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:stationVC];
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                        nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    }
                    else {
                        nav.modalPresentationStyle = UIModalPresentationPageSheet;
                        nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                    }
                    [self.navigationController presentModalViewController:nav animated:YES];
                }
            }];
            //网络请求失败
            [request setFailedBlock:^{
                [hud hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"提示") message:NSLocalizedString(@"Network error, please retry later.", @"网络连接失败，请重试。") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil];
                [alert show];
            }];
            [request startAsynchronous];
        }];
        [sheet setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"取消") handler:NULL];
        [sheet showInView:self.view];
    }];
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
        return [self.filterStations count];
    }
    else {
        return [self.stations count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StationListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    BusStation *station;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        station = [self.filterStations objectAtIndex:indexPath.row];
    }
    else {
        station = [self.stations objectAtIndex:indexPath.row];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:@"%@. %@", station.stationSequence, station.stationName];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BusStation *station;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        station = [self.filterStations objectAtIndex:indexPath.row];
    }
    else {
        station = [self.stations objectAtIndex:indexPath.row];
    }
    [[UserDataSource shared] addOrUpdateHistoryWithStation:station];
    QueryResultViewController *queryController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        queryController = [[QueryResultViewController alloc] initWithStyle:UITableViewStyleGrouped];
        queryController.title = [NSString stringWithFormat:@"%@, %@", station.busRoute.segmentName, station.stationName];
        queryController.station = station;
        queryController.userItem = nil;
        [self.navigationController pushViewController:queryController animated:YES];
    }
    else {
        queryController = [[AppDelegate shared] queryResultController];
        queryController.title = [NSString stringWithFormat:@"%@, %@", station.busRoute.segmentName, station.stationName];
        queryController.station = station;
        queryController.userItem = nil;
        [queryController loadResult];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSIndexSet *resultSet = [self.stations indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSString *stationName = [(BusStation *)obj stationName];
        NSString *stationNamePY = [(BusStation *)obj stationNamePY];
        NSRange result = [stationName rangeOfString:[searchText strip]];
        if (result.location == NSNotFound) {
            result = [stationNamePY rangeOfString:[searchText strip]];
            return (result.location == NSNotFound) ? NO : YES;
        }
        else {
            return YES;
        }
    }];
    
    self.filterStations = [self.stations objectsAtIndexes:resultSet];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

@end
