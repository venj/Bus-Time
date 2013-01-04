//
//  History.h
//  Bus Time
//
//  Created by venj on 12-12-21.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BusStation, UserItem;
@interface UserDataSource : NSObject
+ (id)shared;
- (void)sharedClean;
- (NSArray *)favorites;
- (NSArray *)histories;
- (BOOL)addOrUpdateHistoryWithStation:(BusStation *)station;
- (BOOL)addOrUpdateHistoryWithUserItem:(UserItem *)userItem;
- (BOOL)addOrUpdateHistoryWithObject:(id)object;
- (BOOL)addOrUpdateFavoriteWithStation:(BusStation *)station;
- (BOOL)addOrUpdateFavoriteWithUserItem:(UserItem *)userItem;
- (BOOL)addOrUpdateFavoriteWithObject:(id)object;
- (BOOL)removeHistoryWithStation:(BusStation *)station;
- (BOOL)removeHistoryWithUserItem:(UserItem *)userItem;
- (BOOL)removeHistoryWithObject:(id)object;
- (BOOL)removeFavoriteWithStation:(BusStation *)station;
- (BOOL)removeFavoriteWithUserItem:(UserItem *)userItem;
- (BOOL)removeFavoriteWithObject:(id)object;
- (BOOL)isHistoryStation:(BusStation *)station;
- (BOOL)isFavoritedStation:(BusStation *)station;
- (BOOL)isFavoritedUserItem:(UserItem *)userItem;
- (BOOL)isFavoritedObject:(id)object;
@end
