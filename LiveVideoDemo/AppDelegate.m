//
//  AppDelegate.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/20.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "AppDelegate.h"

#import "MyConfig.h"
#import "LoginNavigationController.h"

#pragma mark - 第三方
#import "EMSDK.h"
#import <IQKeyboardManager.h>
#import "LLGroupManager.h"

@interface AppDelegate ()<EMClientDelegate,EMChatManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //AppKey:注册的AppKey，详细见下面注释。
    //apnsCertName:推送证书名（不需要加后缀），详细见下面注释。
    EMOptions *options = [EMOptions optionsWithAppkey:@"fuweihan00#livevideo"];
    options.apnsCertName = @"LiveVideo";
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    [[EaseSDKHelper shareHelper] hyphenateApplication:application
                        didFinishLaunchingWithOptions:launchOptions
                                               appkey:@"fuweihan00#livevideo"
                                         apnsCertName:@"LiveVideo"
                                          otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerSuccess:) name:NOTIFICATION_REGISTER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:NOTIFICATION_LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccess:) name:NOTIFICATION_LOGOUT object:nil];
    
    UIStoryboard *storyboard = nil;
    //如果未登录，则弹出登录界面
    if ([MyConfig shared].isLogin == NO) {
        storyboard = [UIStoryboard storyboardWithName:@"LoginNavigationController" bundle:[NSBundle mainBundle]];
        
    } else {
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = storyboard.instantiateInitialViewController;
    [self.window makeKeyAndVisible];
    
    IQKeyboardManager *keyBoardManager = [IQKeyboardManager sharedManager];
    
    keyBoardManager.enable = YES;
    keyBoardManager.shouldResignOnTouchOutside = YES;
    keyBoardManager.shouldToolbarUsesTextFieldTintColor = YES;
    keyBoardManager.enableAutoToolbar = YES;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[EMClient sharedClient] registerForRemoteNotificationsWithDeviceToken:deviceToken completion:^(EMError *aError) {
        if (aError) {
            NSLog(@"ERROE:  %@",aError);
        }
    }];
}

#pragma mark - 环信

- (void)emRegister {
    MyConfig *config = [MyConfig shared];
    NSString *emName = [NSString stringWithFormat:@"EMName%@",config.userId];
    EMError *error = [[EMClient sharedClient] registerWithUsername:emName password:@"111111"];
    if (error==nil) {
        NSLog(@"注册成功");
        config.userEMName = emName;
        Network *network = [[Network alloc] init];
        [network networkWithAction:@"uploadEMName" params:@{@"userId":config.userId,@"userEMName":emName} success:^(NSDictionary *data) {
            
        } failure:^(NSDictionary *data) {
            
        } view:nil];
        
        //创建群组
        LLGroupManager *groupManager = [[LLGroupManager alloc] init];
        EMGroup *group = [groupManager createGroupWithName:emName invitees:@[]];
        [network networkWithAction:@"uploadGroupId" params:@{@"userId":config.userId,@"userGroupId":group.groupId} success:^(NSDictionary *data) {
            
            config.userGroupId = group.groupId;
            
        } failure:^(NSDictionary *data) {
            
        } view:nil];
    }
}

- (void)emLogin {
    BOOL isAutoLogin = [EMClient sharedClient].options.isAutoLogin;
    if (!isAutoLogin) {
        MyConfig *config = [MyConfig shared];
        NSString *emName = [NSString stringWithFormat:@"EMName%@",config.userId];
        EMError *error = [[EMClient sharedClient] loginWithUsername:emName password:@"111111"];
        if (!error)
        {
            NSLog(@"登录成功");
            [[EMClient sharedClient] removeDelegate:self];
            [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
            [[EMClient sharedClient].options setIsAutoLogin:YES];
        }
    }
}

- (void)emLogout {
    //logout:YES：是否解除 device token 的绑定
    EMError *error = [[EMClient sharedClient] logout:YES];
    if (!error) {
        NSLog(@"退出成功");
    }
    /*
    退出登录分两种类型：主动退出登录和被动退出登录。
    
    主动退出登录：调用 SDK 的退出接口；
    被动退出登录：1. 正在登录的账号在另一台设备上登录；2. 正在登录的账号被从服务器端删除。
     */
}

- (void)autoLoginDidCompleteWithError:(EMError *)aError {
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
}

- (void)connectionStateDidChange:(EMConnectionState)aConnectionState {
    NSLog(@"环信链接状态（0：已链接；1：未链接）： %d",aConnectionState);
}

//接到普通消息
- (void)messagesDidReceive:(NSArray *)aMessages {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGEDIDRECEIVE object:nil];
}

#pragma mark - 登录
- (void)presentLogin {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginNavigationController" bundle:[NSBundle mainBundle]];
    [self.window.rootViewController presentViewController:storyboard.instantiateInitialViewController animated:YES completion:^{
        
    }];
}

- (void)registerSuccess:(NSNotification *)notification {
    [self emRegister];
}

- (void)loginSuccess:(NSNotification *)notification {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = storyboard.instantiateInitialViewController;
    [self.window makeKeyAndVisible];
    
    [self emLogin];
}

- (void)logoutSuccess:(NSNotification *)notification {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginNavigationController" bundle:[NSBundle mainBundle]];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = storyboard.instantiateInitialViewController;
    [self.window makeKeyAndVisible];
    
    MyConfig *config = [MyConfig shared];
    [config clearLogin];
    [self emLogout];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_REGISTER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LOGOUT object:nil];
}

@end
