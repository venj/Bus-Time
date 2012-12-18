//
//  StationListViewController.m
//  BusTime
//
//  Created by venj on 12-12-18.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//
#include <libxml/parser.h>
#include <libxml/xpath.h>
#import "StationListViewController.h"
#import "BusStation.h"
#import "BusRoute.h"
#import "BusDataSource.h"
#import "ASIFormDataRequest.h"
#import "XMLReader.h"
#import "QueryResultViewController.h"

//xmlXPathObjectPtr getnodeset (xmlDocPtr doc, xmlChar *xpath);

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
    [headersDict setObject:@"text/xml" forKey:@"Content-Type"];
    [headersDict setObject:@"http://tempuri.org/getBusALStationInfoCommon" forKey:@"soapActionString"];
    //__block StationListViewController *blockSelf = self;
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
        //[blockSelf parseXMLString:responseString];
        NSError *error;
        NSDictionary *result = [XMLReader dictionaryForXMLString:responseString error:&error];
        NSString *infoString = (NSString *)[result valueForKeyPath:@"soap:Envelope.soap:Body.getBusALStationInfoCommonResponse.fdisMsg.text"];
        if (infoString != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:infoString delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
        else {
            NSArray *infoArray = (NSArray *)[result valueForKeyPath:@"soap:Envelope.soap:Body.getBusALStationInfoCommonResponse.getBusALStationInfoCommonResult.diffgr:diffgram.NewDataSet.Table1"];
            
            QueryResultViewController *queryController = [[QueryResultViewController alloc] initWithNibName:@"QueryResultViewController" bundle:nil];
            queryController.title = [NSString stringWithFormat:@"%@, %@", station.busRoute.segmentName, station.stationName];
            queryController.resultArray = infoArray;
            [self.navigationController pushViewController:queryController animated:YES];
        }
        
    }];
    //网络请求失败
    [self.request setFailedBlock:^{
        NSLog(@"Failed!!!");
    }];
    [self.request startAsynchronous];
}
/*
xmlXPathObjectPtr getnodeset (xmlDocPtr doc, xmlChar *xpath) {
    xmlXPathContextPtr context;
    xmlXPathObjectPtr result;
	
    context = xmlXPathNewContext(doc);
    if (context == NULL) {
        printf("Error in xmlXPathNewContext\n");
        return NULL;
    }
    result = xmlXPathEvalExpression(xpath, context);
    xmlXPathFreeContext(context);
    if (result == NULL) {
        printf("Error in xmlXPathEvalExpression\n");
        return NULL;
    }
    if(xmlXPathNodeSetIsEmpty(result->nodesetval)){
        xmlXPathFreeObject(result);
		printf("No result\n");
        return NULL;
    }
    return result;
}

- (void)parseXMLString:(NSString *)xmlString {
    xmlDocPtr doc;
    xmlChar *xpath = (xmlChar*) "//fdisMsg";
    xmlNodeSetPtr nodeset;
    xmlXPathObjectPtr result;
    int i;
    xmlChar *keyword;
    
    const char *xmlStr = [xmlString cStringUsingEncoding:NSUTF8StringEncoding];
    doc = xmlParseMemory(xmlStr, [xmlString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    result = getnodeset (doc, xpath);
    if (result) {
        nodeset = result->nodesetval;
        for (i=0; i < nodeset->nodeNr; i++) {
            keyword = xmlNodeListGetString(doc, nodeset->nodeTab[i]->xmlChildrenNode, 1);
			NSLog(@"keyword: %s\n", keyword);
			xmlFree(keyword);
        }
        xmlXPathFreeObject (result);
    }
    xmlFreeDoc(doc);
    xmlCleanupParser();
}
*/
@end
