/*                                                                                                                                                                                                                                        
* CharToPinyin - A Chinese pinyin library for Objective-C
*
* Copyright (c) 2012 venj <ersaclarke@gmail.com>
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*
* In case your copy of CharToPinyin does not include a copy of the license, you may find it online at 
* http://www.gnu.org/copyleft/gpl.html
*
* This library is based on SunriseSpell - A Chinese pinyin library,
* Copyright (C) 2004 mic  <mic4free@hotmail.com>, licensed under GPL v.2
*
*/

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
- (NSString *)translate:(NSString *)chsString withSpaceString:(NSString *)spaceString options:(CPSpellOptions)options;
- (NSString *)abbreviation:(NSString *)chsString;
@end
