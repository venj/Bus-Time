//
//  NSArray+HFExtension.h
//  Handy Foundation
//
//  Created by venj on 13-2-19.
//  Copyright (c) 2013年 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

/** This catagory for `NSArray` provide some convinent methods for array manipulation. */

@interface NSArray (HFExtension)

/** @name Method aliases */

/**
 This method is an alias to `count` method. Returns total count of array elements.
 */
- (NSUInteger)size;

/**
 This method is an alias to `count` method. Returns total count of array elements.
 */
- (NSUInteger)length;

/**
 This is a convinent method for fetch the first object of the array.
 
 - If the array is empty, `nil` will be returned, just like the behavior of `lastObject` method.

 */
- (id)firstObject;

/** @name Convinent methods */
/**
 This method will connect all the array elements with a `linkString` into a long string.
 
 @param linkString The string to link the string parts.
 
 - If there is any object which is not an `NSString` or its subclass object, `nil` will be returned;
 - If the array is empty, `nil` will be returned.
 */
- (NSString *)join:(NSString *)linkString;
@end
