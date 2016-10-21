//
//  MyConfig.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/8.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "MyConfig.h"

#define kIsLogin @"isLogin"

@interface MyConfig()

@property (nonatomic, strong) NSUserDefaults *defaults;

@end
@implementation MyConfig

+ (MyConfig *)shared {
    static dispatch_once_t predicate = 0;
    static MyConfig *object = nil;
    dispatch_once(&predicate, ^{ object = [[self class] new]; });
    
    return object;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.defaults = [NSUserDefaults standardUserDefaults];
        // 当前设备系统版本
        self.osVersion = [[[UIDevice currentDevice]systemVersion]floatValue];
    }
    return self;
}

- (void)setIsLogin:(BOOL)isLogin {
    [self.defaults setBool:isLogin forKey:kIsLogin];
    [self.defaults synchronize];
}

- (BOOL)isLogin {
    return [self.defaults boolForKey:kIsLogin];
}

- (void)setUserName:(NSString *)userName {
    [self.defaults setValue:userName forKey:@"userName"];
    [self.defaults synchronize];
}

- (NSString *)userName {
    return [self.defaults valueForKey:@"userName"];
}

- (void)setUserPassword:(NSString *)userPassword {
    [self.defaults setValue:userPassword forKey:@"userPassword"];
    [self.defaults synchronize];
}

- (NSString *)userPassword {
    return [self.defaults valueForKey:@"userPassword"];
}

- (void)setUserId:(NSString *)userId {
    [self.defaults setValue:userId forKey:@"userId"];
    [self.defaults synchronize];
}

- (NSString *)userId {
    return [self.defaults valueForKey:@"userId"];
}

- (void)setUserEMName:(NSString *)userEMName {
    [self.defaults setValue:userEMName forKey:@"userEMName"];
    [self.defaults synchronize];
}

- (NSString *)userEMName {
    return [self.defaults valueForKey:@"userEMName"];
}

- (void)setUserGroupId:(NSString *)userGroupId {
    [self.defaults setValue:userGroupId forKey:@"userGroupId"];
    [self.defaults synchronize];
}

- (NSString *)userGroupId {
    return [self.defaults valueForKey:@"userGroupId"];
}

- (void)setUserIsLiveing:(NSString *)userIsLiveing {
    [self.defaults setValue:userIsLiveing forKey:@"userIsLiveing"];
    [self.defaults synchronize];
}

- (NSString *)userIsLiveing {
    return [self.defaults valueForKey:@"userIsLiveing"];
}

- (void)clearLogin {
    self.isLogin = NO;
    self.userName = @"";
    self.userPassword = @"";
    self.userId = @"";
    self.userEMName = @"";
    self.userGroupId = @"";
    self.userIsLiveing = @"";
}



@end
