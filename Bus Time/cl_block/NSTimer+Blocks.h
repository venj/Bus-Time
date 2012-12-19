//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//

/** 使用方法
 [NSTimer scheduledTimerWithTimeInterval:0.1 block:^{
 // xxx
 } repeats:YES];
 */
@interface NSTimer (Blocks)

// https://github.com/jivadevoe/NSTimer-Blocks

+(NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;

+(NSTimer *)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats;

@end
