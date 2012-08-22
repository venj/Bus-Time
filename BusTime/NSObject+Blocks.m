//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//
#import "NSObject+Blocks.h"
#import <objc/runtime.h>


@implementation NSObject (Blocks)

static NSMutableDictionary* NSObjectBlockTimers = nil;

- (NSString*) performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
	if (!NSObjectBlockTimers) {
		NSObjectBlockTimers = [[NSMutableDictionary alloc] init];
	}
	
	CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
	NSString *identifier = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
	CFRelease(uuid);
	
	dispatch_queue_t queue = dispatch_get_main_queue();
	dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
													 queue);
	
	dispatch_source_set_timer(timer,
							  dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC),
							  DISPATCH_TIME_FOREVER, 0);
	
	dispatch_source_set_event_handler(timer, ^{
		block();
		dispatch_source_cancel(timer);
		dispatch_release(timer);
		[NSObjectBlockTimers removeObjectForKey:identifier];
	});
	
	dispatch_resume(timer);
	[NSObjectBlockTimers setObject:[NSValue valueWithPointer:timer] forKey:identifier];
	return identifier;
}

- (void) cancelPerformBlockWithIdentifier:(NSString*)identifier
{
	id obj = [NSObjectBlockTimers objectForKey:identifier];
	dispatch_source_t timer = [obj pointerValue];
	dispatch_source_cancel(timer);
	dispatch_release(timer);
	[NSObjectBlockTimers removeObjectForKey:identifier];
}

- (void) cancelPerformAllBlocks
{
	[NSObjectBlockTimers enumerateKeysAndObjectsUsingBlock:^(id identifier, id obj, BOOL *stop) {
		dispatch_source_t timer = [obj pointerValue];
		dispatch_source_cancel(timer);
		dispatch_release(timer);
		[NSObjectBlockTimers removeObjectForKey:identifier];
	}];
}

+ (void) swizzleSelector:(SEL)oldSel withSelector:(SEL)newSel {
    Method oldMethod = class_getInstanceMethod(self, oldSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    Class c = [self class];
    
    if(class_addMethod(c, oldSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, newSel, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
    else
        method_exchangeImplementations(oldMethod, newMethod);
}
@end