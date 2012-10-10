//
//  WXBusParser.h
//  BusTime
//
//  Created by 朱 文杰 on 12-8-23.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXBusParser : NSObject
@property (strong, nonatomic) NSArray *busRoutes;
@property (strong, nonatomic) NSArray *directionRoutes;
@property (strong, nonatomic) NSArray *stations;
@property (strong, nonatomic) id nextBuses;
@property (strong, nonatomic) NSMutableDictionary *formDict;
@property (assign, nonatomic) BOOL needCapcha;
//@property (strong, nonatomic) UIImage *capcha;
//@property (strong, nonatomic) NSString *capcha;
- (id)initWithData:(NSData *)htmlData;
- (void)parse;
@end
