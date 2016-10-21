//
//  UserModel.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/14.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol UserModel <NSObject>

@end

@interface UserModel : JSONModel

@property (copy, nonatomic) NSString *userId;

@property (copy, nonatomic) NSString *userName;

@property (copy, nonatomic) NSString *userEMName;

@property (copy, nonatomic) NSString *userGroupId;

@property (copy, nonatomic) NSString <Ignore>*userIcon;

@property (copy, nonatomic) NSString <Ignore>*userAddress;

@property (copy, nonatomic) NSString <Ignore>*userViewNum;
@end
