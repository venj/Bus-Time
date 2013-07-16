//
//  NSDictionary+HFExtension.m
//  Handy Foundation
//
//  Created by venj on 13-2-19.
//  Copyright (c) 2013年 Home. All rights reserved.
//

#import "NSDictionary+HFExtension.h"
#import "NSArray+HFExtension.h"

@implementation NSDictionary (HFExtension)
- (NSString *)requestString {
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (id key in [self allKeys]) {
        if ([key isKindOfClass:[NSString class]]) {
            NSString *kv = [NSString stringWithFormat:@"%@=%@", key, [self objectForKey:key]];
            [tmpArray addObject:[kv stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        else {
            return nil;
        }
    }
    return [tmpArray join:@"&"];
}

- (NSData *)requestData {
    return [[self requestString] dataUsingEncoding:NSUTF8StringEncoding];
}
@end
