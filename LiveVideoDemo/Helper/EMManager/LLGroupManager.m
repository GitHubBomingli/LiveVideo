//
//  LLGroupManager.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/10.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "LLGroupManager.h"


@implementation LLGroupManager

- (EMGroup *)createGroupWithName:(NSString *)name invitees:(NSArray *)invitees {
    EMError *error = nil;
    EMGroupOptions *setting = [[EMGroupOptions alloc] init];
    setting.maxUsersCount = 500;
    setting.style = EMGroupStylePublicOpenJoin;// 创建不同类型的群组，这里需要才传入不同的类型
    EMGroup *group = [[EMClient sharedClient].groupManager createGroupWithSubject:name description:@"直播群组" invitees:invitees message:@"邀请您加入群组" setting:setting error:&error];
    if(!error){
        NSLog(@"创建成功 -- %@",group);
    }
    return group;
}

- (BOOL)joinGroupWith:(NSString *)groupId {
    EMError *error = nil;
    [[EMClient sharedClient].groupManager joinPublicGroup:groupId error:&error];
    if (!error) {
        NSLog(@"加入群组成功");
        return YES;
    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"加入群组失败" message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
        return NO;
    }
}

- (BOOL)leaveGroupWith:(NSString *)groupId {
    EMError *error = nil;
    [[EMClient sharedClient].groupManager leaveGroup:groupId error:&error];
    if (!error) {
        NSLog(@"退出群组成功");
        return YES;
    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"退出群组失败" message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
        return NO;
    }
}

- (BOOL)destroyGroupWith:(NSString *)groupId {
    EMError *error = nil;
    [[EMClient sharedClient].groupManager destroyGroup:groupId error:&error];
    if (!error) {
        NSLog(@"解散成功");
        return YES;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"解散群组失败" message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
}

- (BOOL)getPublicGroups {
    EMError *error = nil;
    EMCursorResult *result = [[EMClient sharedClient].groupManager getPublicGroupsFromServerWithCursor:nil pageSize:50 error:&error];
    if (!error) {
        NSLog(@"获取成功 -- %@",result);
        return YES;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"获取群组失败" message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
}


@end
