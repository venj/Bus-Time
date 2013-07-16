//
//  NSArray+HFExtension.m
//  Handy Foundation
//
//  Created by venj on 13-2-19.
//  Copyright (c) 2013年 Home. All rights reserved.
//

#import "NSArray+HFExtension.h"

@implementation NSArray (HFExtension)

// Syntactic Sugar
- (NSUInteger) size {
    return [self count];
}

- (NSUInteger) length {
    return [self count];
}

- (id)firstObject {
    if ([self count] == 0) {
        return nil; //Return nil here.
    }
    return [self objectAtIndex:0];
}

- (NSString *)join:(NSString *)linkString {
    if ([self count] == 0) return nil;
    
    id firstObject = [self objectAtIndex:0];
    if (![firstObject isKindOfClass:[NSString class]])return nil;
    
    NSMutableString *tmp = [[NSMutableString alloc] init];
    [tmp appendString:firstObject];
    for (NSInteger i = 1; i < [self count]; i++) {
        id e = [self objectAtIndex:i];
        if (![e isKindOfClass:[NSString class]]) {
            return nil;
        }
        [tmp appendFormat:@"%@%@", linkString, e];
    }
    return tmp;
}

@end
