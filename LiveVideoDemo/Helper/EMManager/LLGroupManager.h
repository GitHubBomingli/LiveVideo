//
//  LLGroupManager.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/10.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EMClient.h"

@interface LLGroupManager : NSObject

/**
 *  创建一个群组
 *
 *  @param name     群组名
 *  @param invitees 邀请人
 */
- (EMGroup *)createGroupWithName:(NSString *)name invitees:(NSArray *)invitees;

- (BOOL)joinGroupWith:(NSString *)groupId;

- (BOOL)leaveGroupWith:(NSString *)groupId;

- (BOOL)destroyGroupWith:(NSString *)groupId;

- (BOOL)getPublicGroups;

@end
