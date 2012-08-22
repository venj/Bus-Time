//
//  HandyFoundation.h
//  Handy Foundation
//
//  Created by 朱 文杰 on 12-2-21.
//  Copyright (c) 2012年 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    HFSplitRuleWhole = 0,
    HFSplitRuleAny
} HFSplitRule;

@interface NSArray (HandyFoundation)
- (NSUInteger) size;
- (NSUInteger) length;
- (id)firstObject;
@end

@interface NSString (HandyFoundation)
- (NSString *)toUpper;
- (NSString *)toLower;
- (NSString *)upCase;
- (NSString *)downCase;
- (NSString *)capitalize;
- (NSUInteger)size;
- (NSUInteger)count;
- (NSArray *)split:(NSString *)separator;
- (NSArray *)split:(NSString *)separator rule:(HFSplitRule)rule;

- (NSString *)baseName;
- (NSString *)baseNameWithoutExtension;
- (NSString *)dirName;
- (NSString *)charStringAtIndex:(NSUInteger)index;
- (BOOL)isBlank;
- (NSString *)strip;
- (NSString *)lstrip;
- (NSString *)rstrip;

@end

@interface NSMutableString (HandyFoundation)

@end