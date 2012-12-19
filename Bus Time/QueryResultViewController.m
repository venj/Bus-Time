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
#import "NSTimer+Blocks.h"
#import "UIAlertView+Blocks.h"
#import "BusInfoCell.h"

@interface QueryResultViewController ()
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
    [self.refControl addTarget:self action:@selector(loadResult) forControlEvents:UIControlEventValueChanged];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self loadResult];
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"距离本站还有%@站", [resultDict valueForKeyPath:@"stationnum.text"]];
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
    return [NSString stringWithFormat:@"公交车于%@到达：", [resultDict valueForKeyPath:@"actdatetime.text"]];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)loadResult {
    if (self.request) {
        [self.request clearDelegatesAndCancel];
    }
    [self.refControl beginRefreshing];
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
                                "</soap:Envelope>\n", self.station.busRoute.lineID, self.station.busRoute.segmentID, self.station.stationSequence];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:infoString completionBlock:^(NSUInteger buttonIndex) {
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else {
                    self.resultArray = nil;
                    [self.tableView reloadData];
                }
            } cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [self.refControl endRefreshing];
        }
        else {
            NSArray *infoArray = (NSArray *)[result valueForKeyPath:@"soap:Envelope.soap:Body.getBusALStationInfoCommonResponse.getBusALStationInfoCommonResult.diffgr:diffgram.NewDataSet.Table1"];
            self.resultArray = infoArray;
            [self.refControl endRefreshing];
            [self.tableView reloadData];
        }
    }];
    //网络请求失败
    [self.request setFailedBlock:^{
        [self.refControl endRefreshing];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络请求出错，请重试。" completionBlock:^(NSUInteger buttonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        } cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }];
    [self.request startAsynchronous];
}

@end
