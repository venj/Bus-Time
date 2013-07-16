//
//  NSFileManager+HFExtension.m
//  Handy Foundation
//
//  Created by venj on 13-2-25.
//  Copyright (c) 2013年 Home. All rights reserved.
//

#import "NSFileManager+HFExtension.h"

@implementation NSFileManager (HFExtension)

- (NSURL *)userDocumentDirectory {
    NSArray *directories = [self URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return [directories lastObject];
}

- (NSURL *)userLibraryDirectory {
    NSArray *directories = [self URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    return [directories lastObject];
}

- (NSURL *)userCacheDirectory {
    NSArray *directories = [self URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    return [directories lastObject];
}

@end
