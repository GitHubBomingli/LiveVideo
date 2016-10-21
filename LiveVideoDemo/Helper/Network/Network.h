//
//  Network.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/14.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Network : NSObject

- (void)networkWithAction:(NSString *)action params:(NSDictionary *)params success:(void(^)(NSDictionary *data))success failure:(void(^)(NSDictionary *data))failure view:(UIView *)view;

@end
