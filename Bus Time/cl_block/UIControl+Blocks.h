//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//

/** 使用方法
 
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [btn addEventHandler:^(id sender) {
        //xxxx
    } forControlEvents:UIControlEventTouchUpInside];
 
 */
@interface UIControl (Blocks)

- (void)addEventHandler:(void(^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents;

- (void)removeEventHandlersForControlEvents:(UIControlEvents)controlEvents;

- (BOOL)hasEventHandlersForControlEvents:(UIControlEvents)controlEvents;

@end
