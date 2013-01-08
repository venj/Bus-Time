//
//  QueryResultViewController.m
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "QueryResultViewController.h"
#import "ASIHTTPRequest.h"
#import "XMLReader.h"
#import "BusStation.h"
#import "ODRefreshControl.h"
#import "ODRefreshControl+Addon.h"
#import "NSTimer+Blocks.h"
#import "UIAlertView+Blocks.h"
#import "BusInfoCell.h"
#import "StationMapViewController.h"
#import "UserDataSource.h"
#import "UserItem.h"
#import "HistoryViewController.h"
#import "FavoritesViewController.h"
#import "AppDelegate.h"
#import "UIBarButtonItem+Blocks.h"

@interface QueryResultViewController () <UIActionSheetDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) ASIHTTPRequest *request;
@property (nonatomic, strong) id resultArray;
@end

@implementation QueryResultViewController

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
    Class RefControl = NSClassFromString(@"UIRefreshControl");
    if ([RefControl class]) {
        self.refreshControl = [[RefControl alloc] init];
        self.refControl = self.refreshControl;
    }
    else {
        self.refControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    }
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:115./255. green:123./255. blue:143./255. alpha:1];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.navigationController.navigationBar addGestureRecognizer:doubleTap];
    [self.refControl addTarget:self action:@selector(loadResult) forControlEvents:UIControlEventValueChanged];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.tableView setContentOffset:CGPointMake(0, -44) animated:NO];
        [self.refControl beginRefreshing];
        [self loadResult];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction handler:^(id sender) {
        if (self.station == nil && self.userItem == nil) {
            return;
        }
        NSString *message;
        id object = (self.station == nil ? self.userItem : self.station);
        if ([[UserDataSource shared] isFavoritedObject:object])
            message = NSLocalizedString(@"Remove from Favorites", @"取消收藏");
        else
            message = NSLocalizedString(@"Add to Favorites", @"加入收藏");
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Please choose your action", @"选择您要执行的操作") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消") destructiveButtonTitle:nil otherButtonTitles:message, NSLocalizedString(@"Show on map", @"显示地图"), nil];
        [sheet showInView:self.tableView];
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

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([self.resultArray isKindOfClass:[NSDictionary class]]) {
        return 1;
    }
    return [self.resultArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"QueryResultCell";
    
    BusInfoCell *cell = (BusInfoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BusInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    NSDictionary *resultDict;
    if ([self.resultArray isKindOfClass:[NSDictionary class]]) {
        resultDict = self.resultArray;
    }
    else {
        resultDict = [self.resultArray objectAtIndex:indexPath.section];
    }
    cell.textLabel.text = [resultDict valueForKeyPath:@"stationname.text"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ stops away from here.", @"距离本站还有%@站"), [resultDict valueForKeyPath:@"stationnum.text"]];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    [cell.detailTextLabel setAdjustsFontSizeToFitWidth:YES];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *resultDict;
    if ([self.resultArray isKindOfClass:[NSDictionary class]]) {
        resultDict = self.resultArray;
    }
    else {
        resultDict = [self.resultArray objectAtIndex:section];
    }
    return [NSString stringWithFormat:NSLocalizedString(@"By %2$@, bus: %1$@ arrived at: ", @"公交%1$@次班车于%2$@到达："), [resultDict valueForKeyPath:@"busselfid.text"], [resultDict valueForKeyPath:@"actdatetime.text"]];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == [tableView numberOfSections] - 1) {
        return NSLocalizedString(@"Shake your device or pull down to refresh.", @"下拉页面或摇动设备刷新班车状态。");
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)loadResult {
    if (self.station == nil && self.userItem == nil) {
        [self.refControl endRefreshing];
        return;
    }
    if (self.station != nil) {
        [self loadResultWithStation:self.station];
        [[UserDataSource shared] addOrUpdateHistoryWithStation:self.station];
    }
    else if (self.userItem != nil) {
        [self loadResultWithUserItem:self.userItem];
        [[UserDataSource shared] addOrUpdateHistoryWithUserItem:self.userItem];
    }
    //TODO:为History增加下拉更新后，在这里调用。
}

- (void)loadResultWithStation:(BusStation *)station {
    [self loadResultWithLineID:station.busRoute.lineID segmentID:station.busRoute.segmentID stationSequance:station.stationSequence];
}

- (void)loadResultWithUserItem:(UserItem *)userItem {
    [self loadResultWithLineID:userItem.lineID segmentID:userItem.segmentID stationSequance:userItem.stationSequence];
}

- (void)loadResultWithLineID:(NSNumber *)lineID segmentID:(NSString *)segmentID stationSequance:(NSNumber *)stationSequence {
    if ([self.request inProgress]) {
        return;
    }
    self.request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://218.90.160.85:10086/BusTravelGuideWebService/bustravelguide.asmx"]];
    __block ASIHTTPRequest *request_b = self.request;
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
                                "</soap:Envelope>\n", lineID, segmentID, stationSequence];
    NSData *postData = [postBodyString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *headersDict = [[NSMutableDictionary alloc] init];
    [headersDict setObject:@([postData length]) forKey:@"Content-Length"];
    [headersDict setObject:@"text/xml" forKey:@"Content-Type"];
    [headersDict setObject:@"http://tempuri.org/getBusALStationInfoCommon" forKey:@"soapActionString"];
    
    [self.request setPostBody:[[NSMutableData alloc] initWithData:postData]];
    [self.request setRequestMethod:@"POST"];
    [self.request setRequestHeaders:headersDict];
    //网络请求开始
    [self.request setStartedBlock:^{}];
    //网络请求成功
    [self.request setCompletionBlock:^{
        NSString *responseString = [request_b responseString];
#if DEBUG
        //NSLog(@"%@", responseString);
#endif
        NSError *error;
        NSDictionary *result = [XMLReader dictionaryForXMLString:responseString error:&error];
        NSString *infoString = (NSString *)[result valueForKeyPath:@"soap:Envelope.soap:Body.getBusALStationInfoCommonResponse.fdisMsg.text"];
        if (infoString != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"提示") message:infoString completionBlock:^(NSUInteger buttonIndex) {
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    if ([infoString rangeOfString:@"结束营运"].location != NSNotFound) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
                else {
                    self.resultArray = nil;
                    [self.tableView reloadData];
                }
            } cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil];
            [alert show];
            [self.refControl endRefreshing];
        }
        else {
            NSArray *infoArray = (NSArray *)[result valueForKeyPath:@"soap:Envelope.soap:Body.getBusALStationInfoCommonResponse.getBusALStationInfoCommonResult.diffgr:diffgram.NewDataSet.Table1"];
            self.resultArray = infoArray;
            [self.tableView reloadData];
            [self.refControl endRefreshing];
        }
    }];
    //网络请求失败
    [self.request setFailedBlock:^{
        [self.refControl endRefreshing];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"提示") message:NSLocalizedString(@"Network error, please retry later.", @"网络连接失败，请重试。") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil];
        [alert show];
    }];
    [self.request startAsynchronous];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if(event.type == UIEventSubtypeMotionShake) {
        if (self.station == nil && self.userItem == nil) {
            return;
        }
        [self.tableView setContentOffset:CGPointMake(0, -44) animated:YES];
        [self.refControl beginRefreshing];
        [self loadResult];
    }
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        id object = (self.station == nil ? self.userItem : self.station);
        if ([[UserDataSource shared] isFavoritedObject:object]) {
            [[UserDataSource shared] removeFavoriteWithObject:object];
        }
        else {
            [[UserDataSource shared] addOrUpdateFavoriteWithObject:object];
        }
        //TODO:为Fav增加下拉更新后，在这里调用。
    }
    else if (buttonIndex == 1) {
        id<MKAnnotation> annotation = (self.station == nil) ? self.userItem : self.station;
        if (annotation == nil) {
            return;
        }
        StationMapViewController *stationVC = [[StationMapViewController alloc] initWithNibName:@"StationMapViewController" bundle:nil];
        stationVC.stations = @[annotation];
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
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (void)doubleTapped:(UITapGestureRecognizer *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
