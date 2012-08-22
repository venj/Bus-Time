//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//

#import "NSTimer+Blocks.h"

@interface NSTimer (BlocksPrivate)
+ (void)_executeBlockFromTimer:(NSTimer *)aTimer;
@end

@implementation NSTimer (Blocks)

+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats
{
    id ret = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(_executeBlockFromTimer:) userInfo:[inBlock copy] repeats:inRepeats];

    return ret;
}

+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats
{
    id ret = [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(_executeBlockFromTimer:) userInfo:[inBlock copy] repeats:inRepeats];

    return ret;
}

+(void)_executeBlockFromTimer:(NSTimer *)inTimer;
{
    if([inTimer userInfo])
    {
        void (^block)() = (void (^)())[inTimer userInfo];
        block();
    }
}
@end