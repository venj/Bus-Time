//
//  NSString+HFExtension.h
//  Handy Foundation
//
//  Created by venj on 13-2-19.
//  Copyright (c) 2013年 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

/** This catagory provides some method aliases and extension to existing method set for NSString class. */

/**
 @enum HFSplitRule
 String seperate rules.
 */
enum {
    /** Whole string as seperator */
    HFSplitRuleWhole = 0,
    /** Any charater in string as seperator */
    HFSplitRuleAny
};
typedef int HFSplitRule;

@interface NSString (HFExtension)
/** @name Method Aliases */

/** Method alias for method `uppercaseString`.
 */
- (NSString *)toUpper;

/** Method alias for method `lowercaseString`.
 */
- (NSString *)toLower;

/** Method alias for method `uppercaseString`.
 */
- (NSString *)upCase;

/** Method alias for method `lowercaseString`.
 */
- (NSString *)downCase;

/** Method alias for method `capitalizedString`.
 */
- (NSString *)capitalize;

/** Method alias for method `length`.
 */
- (NSUInteger)size;

/** Method alias for method `length`.
 */
- (NSUInteger)count;

/** @name Convinent Methods */

/** This method is used to seperate a string into parts by some seperator characters.
 
 @param separator A string of separators. **ALL** the charactors in the string will be used as a separator.
 @return An array of NSString objects.
 
 This method is a convinient method for split:rule: which use HFSplitRuleAny for parameter rule.
 */
- (NSArray *)split:(NSString *)separator;

/** This method is used to seperate a string into parts by seperator characters or a fixed string as seperator.
 
 @param separator A string of separators or a separator string, depending on the value passed to parameter rule.
 @param rule The rule to decide whether the seperator string is used as a whole or independent charators in the string will be used as seperator(s) to split the original string.
 @return An array of NSString objects.
 
 - When `HFSplitRuleWhole` is passed, the separetor will be used as the separator as a whole.
 - When `HFSplitRuleAny` is passed, **ALL** the charactors in the string will be used as a separator.
 */
- (NSArray *)split:(NSString *)separator rule:(HFSplitRule)rule;

/** Method alias for `lastPathComponent`.
 
 This is also a convenient method for baseNameWithExtension: when `YES` is passed to parameter `ext`.
 */
- (NSString *)baseName;

/** Return the last path component with or without the file extension.
 
 @param ext A `BOOL` value which decide whether show the file extension or not.
 */
- (NSString *)baseNameWithExtension:(BOOL)ext;

/** Return the containing directory for a specific path. */
- (NSString *)dirName;

/** Return the character at the index of a string.
 
 If `index` is beyond the range of the string, `nil` will be returned.
 
 @param index The index inside a string.
 @return A string containing the characer at the specific `index`, or return `nil`.
 */
- (NSString *)charStringAtIndex:(NSUInteger)index;

/** This method is used to found out whether the string only contains blank characers or nothing(a blank string).
 
 Since `nil` is not a `NSString` instance, this method can not be used to judge whether a string object is `nil`.
 */
- (BOOL)isBlank;

/** Get rid of blank characters at the beginning and the end of a string object. */
- (NSString *)strip;

/** Get rid of blank characters at the beginning of a string object. */
- (NSString *)lstrip;

/** Get rid of blank characters at the end of a string object. */
- (NSString *)rstrip;

@end
