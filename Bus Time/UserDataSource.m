//
//  History.m
//  Bus Time
//
//  Created by venj on 12-12-21.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import "UserDataSource.h"
#import "Favorite.h"

@implementation UserDataSource
static UserDataSource *__shared = nil;

+ (void)initialize {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dbPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"userdata.db"];
    BOOL dbExists = [manager fileExistsAtPath:dbPath];
    if (!dbExists) {
        [manager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"userdata" ofType:@"db"] toPath:dbPath error:nil];
    }
}

+ (id)shared{
    if(__shared == nil){
        __shared = [[self alloc] init];
    }
    
    return __shared;
}

- (void)sharedClean{
    if (__shared) {
        __shared = nil;
    }
}

#pragma mark - Data source

- (NSArray *)favorites {
    return @[];
}


@end
