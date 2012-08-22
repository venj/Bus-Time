//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//

#import "UIBarButtonItem+Blocks.h"
#import "NSObject+AssociatedObjects.h"

static char *kBarButtonItemBlockKey = "kUIBarButtonItemBlock";

@interface UIBarButtonItem (BlocksPrivate)
- (void)_handleAction:(UIBarButtonItem *)sender;
@end

@implementation UIBarButtonItem (Blocks)

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem handler:(void(^)(id sender))action {
    self = [self initWithBarButtonSystemItem:systemItem target:self action:@selector(_handleAction:)];
    [self associateCopyOfValue:action withKey:kBarButtonItemBlockKey];
    return self;
}

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style handler:(void(^)(id sender))action {
    self = [self initWithImage:image style:style target:self action:@selector(_handleAction:)];
    [self associateCopyOfValue:action withKey:kBarButtonItemBlockKey];
    return self;
}

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style handler:(void(^)(id sender))action {
    self = [self initWithTitle:title style:style target:self action:@selector(_handleAction:)];
    [self associateCopyOfValue:action withKey:kBarButtonItemBlockKey];
    return self;
}

- (void)_handleAction:(UIBarButtonItem *)sender {
    void(^block)(id sender) = [self associatedValueForKey:kBarButtonItemBlockKey];
    if (block){
        block(self);
    }
    // 擦...ARC不支持自动release. [self removeAssociatedValueForKey:kBarButtonItemBlockKey];
    
    // 还是自己释放吧...
    //  [self.navigationItem.leftBarButtonItem removeAllAssociatedObjects]; 
    //  [self.navigationItem.rightBarButtonItem removeAllAssociatedObjects]; 

}

@end