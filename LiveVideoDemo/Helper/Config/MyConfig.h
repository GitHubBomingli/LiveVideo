//
//  MyConfig.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/8.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MyConfig : NSObject

/**
 *  当前设备系统版本
 */
@property (nonatomic, assign) float osVersion;

/**
 *  是否登录
 */
@property(nonatomic) BOOL isLogin;

@property (copy, nonatomic) NSString *userName;

@property (copy, nonatomic) NSString *userPassword;

@property (copy, nonatomic) NSString *userId;

@property (copy, nonatomic) NSString *userEMName;

@property (copy, nonatomic) NSString *userGroupId;

@property (copy, nonatomic) NSString *userIsLiveing;


+ (MyConfig *)shared;

- (void)clearLogin;

@end
