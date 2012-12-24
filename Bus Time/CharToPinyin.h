//
//  CharToPinyin.h
//  Bus Time
//
//  Created by venj on 12-12-24.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum 
{
    CPSpellOptionsNone = 0,
    CPSpellOptionsFirstLetterOnly = 1,								// 只转换拼音首字母，默认转换全部
    CPSpellOptionsTranslateUnknowWordToInterrogation = 1 << 1,		// 转换未知汉字为问号，默认不转换
    CPSpellOptionsEnableUnicodeLetter = 1 << 2,						// 保留非字母、非数字字符，默认不保留
    CPSpellOptionsFirstLetterUpper = 1 << 4,						// 首字母大写，默认小写
} CPSpellOptions;

@interface CharToPinyin : NSObject
+ (id)shared;
- (void)sharedClean;
- (NSString *)translate:(NSString *)chsString withSpaceString:(NSString *)spaceString options:(CPSpellOptions)options;
- (NSString *)abbreviation:(NSString *)chsString;
@end
