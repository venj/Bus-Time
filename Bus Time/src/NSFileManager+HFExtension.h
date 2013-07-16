//
//  NSFileManager+HFExtension.h
//  Handy Foundation
//
//  Created by venj on 13-2-25.
//  Copyright (c) 2013年 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

/** This catagory for `NSFileManager` provides some convinent methods for commonly used user directories. */

@interface NSFileManager (HFExtension)

/** @name Convinent methods */

/**
 This method return an `NSURL` object representing user's *Documents* directory.
 
 - On OS X, the directory usually is: `/Users/YOUR_NAME/Documents/`
 - On iOS and Simulator, the directory is the *Documents* directory inside the app sandbox.
 */
- (NSURL *)userDocumentDirectory;

/**
 This method return an `NSURL` object representing user's *Library* directory.
 
 - On OS X, the directory usually is: `/Users/YOUR_NAME/Library/`
 - On iOS and Simulator, the directory is the *Library* directory inside the app sandbox.
 */
- (NSURL *)userLibraryDirectory;

/**
 This method return an `NSURL` object representing user's *Caches* directory.
 
 - On OS X, the directory usually is: `/Users/YOUR_NAME/Library/Caches/`
 - On iOS and Simulator, the directory is the *Caches* directory inside *Library* directory.
 
 @see userLibraryDirectory
 */
- (NSURL *)userCacheDirectory;

@end
