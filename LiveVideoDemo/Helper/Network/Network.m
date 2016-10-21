//
//  Network.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/14.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "Network.h"
#import <AFNetworking.h>

@implementation Network
{
    MBProgressHUD *hud;
}

- (void)networkWithAction:(NSString *)action params:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSDictionary *))failure view:(UIView *)view {
    if (view) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.animationType = MBProgressHUDModeAnnularDeterminate;
        hud.removeFromSuperViewOnHide = YES;
    }
    
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 50;
    NSString *url = [NSString stringWithFormat:@"http://123.56.11.95:8082/%@.json",action];
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [hud hide:YES];
        NSDictionary *result = [NSDictionary dictionaryWithDictionary:responseObject];
        if ([result[@"status"] intValue] == 1) {
            success(result);
        } else {
            failure(result);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud hide:YES];
        NSDictionary *dic = @{@"status":@"500"};
        failure(dic);
    }];
}

@end
