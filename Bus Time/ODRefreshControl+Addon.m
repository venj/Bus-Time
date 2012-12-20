//
//  ODRefreshControl+Addon.m
//  Bus Time
//
//  Created by venj on 12-12-20.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import "ODRefreshControl+Addon.h"

@implementation ODRefreshControl (Addon)
- (BOOL)isRefreshing {
    return [self refreshing];
}
@end
