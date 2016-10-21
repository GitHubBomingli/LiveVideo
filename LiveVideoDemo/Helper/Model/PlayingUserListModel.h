//
//  PlayingUserListModel.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/14.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "UserModel.h"

@interface PlayingUserListModel : JSONModel

@property (copy, nonatomic) NSString *status;

@property (strong , nonatomic) NSArray <UserModel>*users;

@end
