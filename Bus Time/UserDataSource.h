//
//  History.h
//  Bus Time
//
//  Created by venj on 12-12-21.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDataSource : NSObject
+ (id)shared;
- (void)sharedClean;
- (NSArray *)favorites;
@end
