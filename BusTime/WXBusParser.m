//
//  WXBusParser.m
//  BusTime
//
//  Created by 朱 文杰 on 12-8-23.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "WXBusParser.h"
#import "TFHpple.h"
#import "Common.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "HandyFoundation.h"

@interface WXBusParser ()
@property (strong, nonatomic) TFHpple *htmlDoc;
@property (strong, nonatomic) NSUserDefaults *defaults;
@end

@implementation WXBusParser
- (id)initWithData:(NSData *)htmlData {
    if ((self = [super init])) {
        _defaults = [NSUserDefaults standardUserDefaults];
        _htmlDoc = [[TFHpple alloc] initWithHTMLData:htmlData];
#if TARGET_IS_DEBUG
        //NSLog(@"%@", [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding]);
#endif
        _busRoutes = [[NSArray alloc] init];
        _directionRoutes = [[NSArray alloc] init];
        _stations = [[NSArray alloc] init];
        _formDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)parse {
    // 公交路线
    NSMutableArray *busRoutes = [[NSMutableArray alloc] init];
    NSArray *elements = [self.htmlDoc searchWithXPathQuery:@"//select"];
    for (TFHppleElement *element in [[elements objectAtIndex:0] children]) {
        [busRoutes addObject:@{kBusName: [[element firstChild] content], kBusID: [element objectForKey:@"value"]}];
    }
    self.busRoutes = busRoutes;
    
    // 方向选择
    NSMutableArray *directionRoutes = [[NSMutableArray alloc] init];
    NSArray *subElements = [[elements objectAtIndex:1] children];
    if ([subElements count] == 0) {
        self.directionRoutes = nil;
    }
    else {
        for (TFHppleElement *element in subElements) {
            [directionRoutes addObject:@{kBusName: [[element firstChild] content], kBusID: [element objectForKey:@"value"]}];
        }
        self.directionRoutes = directionRoutes;
    }
    
    // 站点信息
    NSMutableArray *stations = [[NSMutableArray alloc] init];
    NSArray *tables = [self.htmlDoc searchWithXPathQuery:@"//table[@class='table_inside']"];
    TFHppleElement *table = [tables objectAtIndex:1];
    if ([[[[table children] objectAtIndex:0] children] count] == 0) {
        // 无站点信息
        self.stations = nil;
    }
    else {
        // 加载站点信息
        elements = [self.htmlDoc searchWithXPathQuery:@"//table[@class='table_inside']/tr/td/table"];
        for (NSInteger i = 2; i < [elements count]; i++) {
            NSMutableDictionary *station = [[NSMutableDictionary alloc] init];
            NSArray *children = [[[[[elements objectAtIndex:i] children] objectAtIndex:0] firstChild] children]; // <input> etc.
            for (TFHppleElement *e in children) {
                if ([[e tagName] isEqualToString:@"input"] && [[e objectForKey:@"type"] isEqualToString:@"hidden"] && [e objectForKey:@"value"]) {
                    [station setObject:[e objectForKey:@"value"] forKey:[e objectForKey:@"name"]];
                }
            }
            for (TFHppleElement *e in [[[[elements objectAtIndex:i] children] objectAtIndex:1] children]) {
                if ([[e tagName] isEqualToString:@"td"]) {
                    for (TFHppleElement *c in [e children]) {
                        if ([[c tagName] isEqualToString:@"span"]) {
                            [station setObject:[[c firstChild] content] forKey:kStationName];
                        }
                    }
                }
            }
            [stations addObject:station];
        }
        self.stations = stations;
    }

    // 公交状态
    elements = [self.htmlDoc searchWithXPathQuery:@"//table[@class='table_inside']/tr/td/span/font"];
    
    NSString *message = [[[elements objectAtIndex:0] firstChild] content];
    if ([message length] > 0) {
        self.nextBuses = message;
    }
    else {
        elements = [self.htmlDoc searchWithXPathQuery:@"//table[@class='table_inside']//div/table/tr"];
        if ([elements count] == 0) {
            self.nextBuses = nil;
        }
        else {
            NSMutableArray *nextBuses = [[NSMutableArray alloc] initWithCapacity:1];
            for (NSInteger i = 1; i < [elements count]; i++) {
                TFHppleElement *element = [elements objectAtIndex:i];
                NSArray *children = [element children];
                NSMutableArray *bus = [[NSMutableArray alloc] initWithCapacity:3];
                for (TFHppleElement *child in children) {
                    NSString *text = [[[child firstChild] content] strip];
                    if ([text length] > 0) {
                        [bus addObject:text];
                    }
                }
                [nextBuses addObject:bus];
            }
            self.nextBuses = nextBuses;
        }
    }
    
    // 表单字典
    NSMutableDictionary *formDict = [[NSMutableDictionary alloc] init];
    NSArray *formElements = [self.htmlDoc searchWithXPathQuery:@"//input"];
    for (TFHppleElement *element in formElements) {
        if ([element objectForKey:@"value"] == nil) {
            continue;
        }
        else {
            [formDict setObject:[element objectForKey:@"value"] forKey:[element objectForKey:@"name"]];
        }
    }
    self.formDict = formDict;
    //[self updateViewState:[self.formDict objectForKey:@"__VIEWSTATE"]];
}
/*
- (void)updateViewState:(NSString *)viewState {
    if (viewState != nil && [self.directionRoutes count] == 0) {
        NSMutableDictionary *formDict = [[self.defaults objectForKey:kBusFormPartitialStorage] mutableCopy];
        [formDict setObject:viewState forKey:@"__VIEWSTATE"];
        NSLog(@"%@", viewState);
        [self.defaults setObject:formDict forKey:kBusFormPartitialStorage];
        [self.defaults synchronize];
    }
}
*/
@end
