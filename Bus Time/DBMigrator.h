//
//  DBMigrator.h
//  Bus Time
//
//  Created by venj on 13-1-24.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DBMigrator : NSObject
+ (void)copyOrMigrate;
@end
