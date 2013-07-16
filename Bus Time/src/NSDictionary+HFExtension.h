//
//  NSDictionary+HFExtension.h
//  Handy Foundation
//
//  Created by venj on 13-2-19.
//  Copyright (c) 2013年 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

/** This catagory for `NSDictionary` provide some convinent methods for dictionary manipulation. */

@interface NSDictionary (HFExtension)

/** HTTP request related */

/**
 This method returns a request string which could be used for send HTTP request.
 
 @see requestData
 */
- (NSString *)requestString;

/**
 This method returns a request data which could be used for send HTTP request. The request data is just the `NSData` representation for requestString.
 
 @see requestString
 */
- (NSData *)requestData;
@end
