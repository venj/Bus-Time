//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Blocks)
/**
 * 开启一个Block
 * 
 * @param block delay
 * @returns UUID identifier
 */
- (NSString*) performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

/**
 * 根据UUID证书取消Block
 * 
 * @param UUID identifier
 */
- (void) cancelPerformBlockWithIdentifier:(NSString*)identifier;

/**
 * 取消注册的所有Block
 */
- (void) cancelPerformAllBlocks;

/**
 * 交换Selector
 * 
 * @param SEL SEL
 */
+ (void) swizzleSelector:(SEL)oldSel withSelector:(SEL)newSel;



@end
