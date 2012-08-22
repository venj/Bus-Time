//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//

/**
 * 专门用来存储临时变量.
 */
@interface NSObject (AssociatedObjects)


/** Strongly associates an object with the reciever.
 
 The associated value is retained as if it were a property
 synthesized with `nonatomic` and `retain`.
 
 Using retained association is strongly recommended for most
 Objective-C object derivative of NSObject, particularly
 when it is subject to being externally released or is in an
 `NSAutoreleasePool`.
 
 @param value Any object.
 @param key A unique key string.
 */
- (void)associateValue:(id)value withKey:(const char *)key;

/** Associates a copy of an object with the reciever.
 
 The associated value is copied as if it were a property
 synthesized with `nonatomic` and `copy`.
 
 Using copied association is recommended for a block or
 temporarily-allocated Objective-C instances like NSString.
 
 @param value Any object, pointer, or value.
 @param key A unique key string.
 */
- (void)associateCopyOfValue:(id)value withKey:(const char *)key;

/** Weakly associates an object with the reciever.
 
 A weak association will cause the pointer to be set to zero
 or nil upon the disappearance of what it references;
 in other words, the associated object is not kept alive.
 
 @param value Any object.
 @param key A unique key string.
 */
- (void)associateWeakOfValue:(id)value withKey:(const char *)key;

/** Weakly associates an object with the reciever.
 
 A weak association will cause the pointer to be set to zero
 or nil upon the disappearance of what it references;
 in other words, the associated object is not kept alive.
 
 @param key A unique key string.
 @return The value associated with the key, or `nil` if not found.
 */
- (id)associatedValueForKey:(const char *)key;


-(void)removeAssociatedValueForKey:(const char *)key;


@end
