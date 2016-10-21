//
//  MemberManager.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/9.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "MemberManager.h"
#import <FMDB.h>

@implementation MemberManager
{
    NSString *_fileName;
    
    FMDatabase *_db;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _fileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"/myMember.db"];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isFolder;
        BOOL isExist = [fm fileExistsAtPath:_fileName isDirectory:&isFolder];
        
        _db = [FMDatabase databaseWithPath:_fileName];
        
        [_db open];
        
        if (!isExist || isFolder) {
            // 创建表
            NSString *sql = @"create table if not exists members(name text, password text);";
            [_db executeUpdate:sql];
        }
    }
    return self;
}

- (NSInteger)insertMember:(MemberModel *)member {
    NSString *sql = @"Insert into members values(?,?)";
    
    NSArray *members = [self getMemberWhereName:member.name];
    if (members.count > 0) {
        return 2;
    }
    
    if ([_db executeUpdate:sql, member.name, member.password]) {
        NSLog(@"Insert OK");
        return 1;
    } else {
        return 0;
    }
}
- (NSArray *)getMembers {
    FMResultSet *resultSet = [_db executeQuery:@"Select * From members"];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    while ([resultSet next]) {
        
        NSString *name = [resultSet stringForColumn:@"name"];
        NSString *password = [resultSet stringForColumn:@"password"];
        
        
        MemberModel *model = [[MemberModel alloc] init];
        model.name = name;
        model.password = password;
        
        [result addObject:model];
    }
    [resultSet close];
    
    return result;
}

- (NSArray *)getMemberWhereName:(NSString *)name {
    NSString *sqlString = [NSString stringWithFormat:@"Select * From members Where name is '%@'",name];
    FMResultSet *resultSet = [_db executeQuery:sqlString];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    while ([resultSet next]) {
        
        NSString *name = [resultSet stringForColumn:@"name"];
        NSString *password = [resultSet stringForColumn:@"password"];
        
        
        MemberModel *model = [[MemberModel alloc] init];
        model.name = name;
        model.password = password;
        
        [result addObject:model];
    }
    [resultSet close];
    
    return result;
}


- (void)dealloc {
    [_db close];
}
@end
