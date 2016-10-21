//
//  MemberManager.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/9.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemberModel.h"

@interface MemberManager : NSObject
/**
 *  插入一个用户
 *
 *  @param member 用户
 *
 *  @return 插入结果：0，失败；1，成功，2，已存在
 */
- (NSInteger)insertMember:(MemberModel *)member;
/**
 *  获取全部用户
 *
 *  @return 全部用户数组
 */
- (NSArray *)getMembers;
/**
 *  根据用户名获取用户
 *
 *  @param name 用户名
 *
 *  @return 用户数组
 */
- (NSArray *)getMemberWhereName:(NSString *)name;
@end
