//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//

#import "UIControl+Blocks.h"
#import "NSObject+AssociatedObjects.h"


static char *kControlHandlersKey = "kUIControlBlockHandlers";

#pragma mark Private

@interface UIControlBlockWrapper : NSObject <NSCopying>

- (id)initWithHandler:(void(^)(id sender))aHandler forControlEvents:(UIControlEvents)someControlEvents;
@property (nonatomic, copy) void(^handler)(id sender);
@property (nonatomic) UIControlEvents controlEvents;

@end

@implementation UIControlBlockWrapper

@synthesize handler, controlEvents;

- (id)initWithHandler:(void(^)(id sender))aHandler forControlEvents:(UIControlEvents)someControlEvents {
    if ((self = [super init])) {
        self.handler = aHandler;
        self.controlEvents = someControlEvents;

    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[UIControlBlockWrapper alloc] initWithHandler:self.handler forControlEvents:self.controlEvents];
}

- (void)invoke:(id)sender {
    void(^block)(id sender)  = self.handler;
    if (block)
        block(sender);
}

@end

#pragma mark Category

@implementation UIControl (Blocks)

- (void)addEventHandler:(void(^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents {
    NSMutableDictionary *events = [self associatedValueForKey:kControlHandlersKey];
    if (!events) {
        events = [NSMutableDictionary dictionary];
        [self associateValue:events withKey:kControlHandlersKey];
    }
    
    NSNumber *key = [NSNumber numberWithUnsignedInteger:controlEvents];
    NSMutableSet *handlers = [events objectForKey:key];
    if (!handlers) {
        handlers = [NSMutableSet set];
        [events setObject:handlers forKey:key];
    }
    
    UIControlBlockWrapper *target = [[UIControlBlockWrapper alloc] initWithHandler:handler forControlEvents:controlEvents];
    [handlers addObject:target];
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];

}

- (void)removeEventHandlersForControlEvents:(UIControlEvents)controlEvents {
    NSMutableDictionary *events = [self associatedValueForKey:kControlHandlersKey];
    if (!events) {
        events = [NSMutableDictionary dictionary];
        [self associateValue:events withKey:kControlHandlersKey];
    }
    
    NSNumber *key = [NSNumber numberWithUnsignedInteger:controlEvents];
    NSSet *handlers = [events objectForKey:key];

    if (!handlers)
        return;
    
    for (id sender in handlers) {
        [self removeTarget:sender action:NULL forControlEvents:controlEvents];
    }
    
    [events removeObjectForKey:key];
    [self removeAssociatedValueForKey:kControlHandlersKey];

}

- (BOOL)hasEventHandlersForControlEvents:(UIControlEvents)controlEvents {
    NSMutableDictionary *events = [self associatedValueForKey:kControlHandlersKey];
    if (!events) {
        events = [NSMutableDictionary dictionary];
        [self associateValue:events withKey:kControlHandlersKey];
    }
    
    NSNumber *key = [NSNumber numberWithUnsignedInteger:controlEvents];
    NSSet *handlers = [events objectForKey:key];
    
    if (!handlers)
        return NO;
    
    return handlers.count;
}

@end
