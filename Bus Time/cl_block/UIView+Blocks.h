//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//


/** 使用方法

    [self whenTouchesBegan:^(NSSet *set, UIEvent *event) {
        // xxxx
    }];
 */
@interface UIView (Blocks)

// - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
- (void)whenTouchesBegan:(void(^)(NSSet* set, UIEvent* event))block;

// - (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
- (void)whenTouchesMoved:(void(^)(NSSet* set, UIEvent* event))block;

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
- (void)whenTouchesEnded:(void(^)(NSSet* set, UIEvent* event))block;

@end
