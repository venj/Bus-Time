//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//

#import "UIView+Blocks.h"
#import "NSObject+AssociatedObjects.h"

static char *kViewTouchDownBlockKey = "kUIViewTouchDownBlock";
static char *kViewTouchMoveBlockKey = "kUIViewTouchMoveBlock";
static char *kViewTouchUpBlockKey = "kUIViewTouchUpBlock";

@implementation UIView (Blocks)

- (void)whenTouchesBegan:(void(^)(NSSet* set, UIEvent* event))block{
    self.userInteractionEnabled = YES;
    if (!block)
        block = nil;
    [self associateCopyOfValue:block withKey:kViewTouchDownBlockKey];
}

- (void)whenTouchesMoved:(void(^)(NSSet* set, UIEvent* event))block{
    self.userInteractionEnabled = YES;
    if (!block)
        block = nil;
    [self associateCopyOfValue:block withKey:kViewTouchMoveBlockKey];
}

- (void)whenTouchesEnded:(void(^)(NSSet* set, UIEvent* event))block{
    self.userInteractionEnabled = YES;
    if (!block)
        block = nil;
    [self associateCopyOfValue:block withKey:kViewTouchUpBlockKey];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    void(^block)(NSSet* set, UIEvent* event) = [self associatedValueForKey:kViewTouchDownBlockKey];
    if (block)
        block(touches, event);

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    void(^block)(NSSet* set, UIEvent* event) = [self associatedValueForKey:kViewTouchMoveBlockKey];
    if (block)
        block(touches, event);

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    void(^block)(NSSet* set, UIEvent* event) = [self associatedValueForKey:kViewTouchUpBlockKey];
    if (block)
        block(touches, event);

}



@end
