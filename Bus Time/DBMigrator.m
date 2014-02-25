//
//  DBMigrator.m
//  Bus Time
//
//  Created by venj on 13-1-24.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import "DBMigrator.h"

@implementation DBMigrator

+ (void)copyOrMigrate {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *userDBPath = [self userDataBasePath];
    BOOL dbExists = [manager fileExistsAtPath:userDBPath];
    if (!dbExists) { // Fresh install no need to migrate
        [manager copyItemAtPath:[self bundleDataBasePath] toPath:userDBPath error:nil];
    }
    else {
        if ([self userDataBaseNeedsMigrate]) {
            [self migrate];
        }
    }
}

+ (void)migrate {
    NSArray *upFiles = [self migrateUpFiles];
    FMDatabase *db = [self userDatabase];
    for (NSString *p in upFiles) {
        NSString *content = [[NSString alloc] initWithContentsOfFile:p encoding:NSUTF8StringEncoding error:nil];
        NSArray *sqls = [content split:@"\n"];
        for (NSString *s in sqls) {
            NSString *sql = [s strip];
            if ([sql length] == 0) {
                continue;
            }
            [db executeUpdate:[sql strip]];
        }
    }
    [db close];
    [self updateMigrationVersion];
}

#pragma mark - Helper

+ (NSArray *)migrateUpFiles {
    NSArray *migrationFiles = [self migrationFiles];
    NSIndexSet *set = [migrationFiles indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([(NSString *)obj rangeOfString:@"_up.migration"].location == NSNotFound)
            return NO;
        else
            return YES;
    }];
    NSArray *upFiles, *sortedUpFiles;
    sortedUpFiles = upFiles = [migrationFiles objectsAtIndexes:set];
    if ([upFiles count] > 1) {
        sortedUpFiles = [upFiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *fileName1 = [obj1 baseName];
            NSString *fileName2 = [obj2 baseName];
            NSInteger version1 = [(NSString *)[[fileName1 split:@"_"] objectAtIndex:0] integerValue];
            NSInteger version2 = [(NSString *)[[fileName2 split:@"_"] objectAtIndex:0] integerValue];
            if (version1 < version2) {
                return NSOrderedAscending;
            }
            else if (version1 == version2) {
                return NSOrderedSame;
            }
            else {
                return NSOrderedDescending;
            }
        }];
    }
    
    return sortedUpFiles;
}

+ (NSArray *)migrationFiles {
    NSArray *migrationFiles = [[NSBundle mainBundle] pathsForResourcesOfType:@"migration" inDirectory:nil];
    return migrationFiles;
}

+ (NSUInteger)migrationCount {
    NSArray *migrationsFiles = [self migrationFiles];
    NSUInteger numberOfMigrationsFiles = [migrationsFiles count];
    NSUInteger migrationCount = numberOfMigrationsFiles / 2;
    return migrationCount;
}

+ (NSString *)userDataBasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = paths[0];
    NSString *dbPath = [docDirectory stringByAppendingPathComponent:@"userdata.db"];
    return dbPath;
}

+ (NSString *)bundleDataBasePath {
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"userdata" ofType:@"db"];
    return dbPath;
}

+ (FMDatabase *)userDatabase {
    NSString *dbPath = [self userDataBasePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        return nil;
    }
    return db;
}

+ (BOOL)userDataBaseNeedsMigrate {
    // Fetch userDB migration version number.
    NSString *userDBPath = [self userDataBasePath];
    FMDatabase *userDB = [FMDatabase databaseWithPath:userDBPath];
    if (![userDB open]) {
        return NO;
    }
    FMResultSet *s = [userDB executeQuery:@"SELECT * FROM migrations LIMIT 1"];
    NSInteger migrationVersion = 0;
    if ([s next]) {
        migrationVersion = [s intForColumn:@"version"];
    }
    [userDB close];
    // Calc current migrations and compare.
    NSUInteger migrationCount = [self migrationCount];
    if (migrationVersion < migrationCount) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (void)updateMigrationVersion {
    FMDatabase *userDB = [self userDatabase];
    NSUInteger currentMigtationVersion = [self migrationCount];
    [userDB executeUpdateWithFormat:@"UPDATE 'migrations' SET 'version'=%u", currentMigtationVersion];
    [userDB close];
}

@end
