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
#import "ASIFormDataRequest.h"

@interface StationListViewController ()
@property (nonatomic, strong) NSArray *stations;
@property (nonatomic, strong) ASIFormDataRequest *request;
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
    self.stations = [[BusDataSource shared] stationsForBusRoute:self.busRoute];
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
    return [self.stations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StationListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    BusStation *station = [self.stations objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:@"%@. %@", station.stationNumber, station.stationName];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self loadResultWithStation:[self.stations objectAtIndex:indexPath.row]];
}

- (void)loadResultWithStation:(BusStation *)station {
    if (self.request) {
        [self.request clearDelegatesAndCancel];
    }
    self.request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://218.90.160.85:10086/BusTravelGuideWebService/bustravelguide.asmx"]];
    __block ASIHTTPRequest *request_b = self.request;
    NSString *postBodyString = [NSString stringWithFormat:
                                @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.""org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                "  <soap:Body>\n"
                                "    <getBusALStationInfoCommon xmlns=\"http://tempuri.org/\">\n"
                                "      <routeid>%@</routeid>\n"
                                "      <segmentid>%@</segmentid>\n"
                                "      <stationseq>%@</stationseq>\n"
                                "      <fdisMsg></fdisMsg>\n"
                                "    </getBusALStationInfoCommon>\n"
                                "  </soap:Body>\n"
                                "</soap:Envelope>\n", station.busRoute.lineID, station.busRoute.segmentID, station.stationNumber];
    NSData *postData = [postBodyString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *headersDict = [[NSMutableDictionary alloc] init];
    [headersDict setObject:@([postData length]) forKey:@"Content-Length"];
    [headersDict setObject:@"application/soap+xml; charset=utf-8" forKey:@"Content-Type"];
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
        NSLog(@"%@", responseString);
#endif  
    }];
    //网络请求失败
    [self.request setFailedBlock:^{
        NSLog(@"Failed!!!");
    }];
    [self.request startAsynchronous];
}

@end
