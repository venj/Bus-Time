//
//  NSString+HFExtension.m
//  Handy Foundation
//
//  Created by venj on 13-2-19.
//  Copyright (c) 2013年 Home. All rights reserved.
//

#import "NSString+HFExtension.h"
#import "NSArray+HFExtension.h"

@implementation NSString (HFExtension)
// Syntactic Sugar
- (NSString *)toUpper {
    return [self uppercaseString];
}

- (NSString *)toLower {
    return [self lowercaseString];
}

- (NSString *)upCase {
    return [self uppercaseString];
}

- (NSString *)downCase {
    return [self lowercaseString];
}

- (NSString *)capitalize {
    return [self capitalizedString];
}

- (NSUInteger)size {
    return [self length];
}

- (NSUInteger)count {
    return [self length];
}

- (NSArray *)split:(NSString *)separator {
    return [self split:separator rule:HFSplitRuleAny];
}

- (NSString *)baseName {
    return [self baseNameWithExtension:YES];
}

// Enhancement.
- (NSArray *)split:(NSString *)separator rule:(HFSplitRule)rule {
    switch (rule) {
        case HFSplitRuleWhole:
            return [self componentsSeparatedByString:separator];
        case HFSplitRuleAny:
        default: {
            NSCharacterSet *separators = [NSCharacterSet characterSetWithCharactersInString:separator];
            return [self componentsSeparatedByCharactersInSet:separators];
        }
    }
}

- (BOOL)isBlank {
    if ([self length] == 0) {
        return YES;
    }
    else {
        return [[self strip] length] == 0;
    }
}

- (NSString *)baseNameWithExtension:(BOOL)ext {
    NSString *baseName = [self lastPathComponent];
    if (ext) return baseName;
    
    if ([[self pathExtension] isEqualToString:@""])
        return baseName;
    else {
        NSString *ext = [self pathExtension];
        return [baseName substringToIndex:([baseName length] - [ext length] - 1)];
    }
}

- (NSString *)dirName {
    NSMutableArray *components = [[self pathComponents] mutableCopy];
    [components removeLastObject];
    NSString *dirName = [NSString pathWithComponents:components];
    return dirName;
}

- (NSString *)charStringAtIndex:(NSUInteger)index {
    if (index >= [self length]) return nil;
    return [self substringWithRange:NSMakeRange(index, 1)];
}

- (NSString *)strip {
    NSCharacterSet *whiteSpaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:whiteSpaces];
}

- (NSString *)lstrip {
    NSString *strippedString = [self strip];
    return [NSString stringWithFormat:@"%@%@", strippedString, [[self componentsSeparatedByString:strippedString] lastObject]];
}

- (NSString *)rstrip {
    NSString *strippedString = [self strip];
    return [NSString stringWithFormat:@"%@%@", [[self componentsSeparatedByString:strippedString] firstObject] , strippedString];
}

@end
