//
//  LoginViewController.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/8.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "LoginViewController.h"
#import <MBProgressHUD.h>
#import "MyConfig.h"
#import "MemberManager.h"
#import "MemberModel.h"
#import "Network.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchLoginBtn:(UIButton *)sender {
    [self.nameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
//    MemberModel *memberModel = [[MemberModel alloc] init];
//    
//    MemberManager *memberManager = [[MemberManager alloc] init];
//    NSArray *members = [memberManager getMemberWhereName:self.nameTextField.text];
//    
//    if (members.count > 0) {
//        memberModel = members.firstObject;
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"用户名不存在" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//        return;
//    }
//    
//    if ( ! [self.passwordTextField.text isEqualToString:memberModel.password]) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"密码错误" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//        return ;
//    }
    
    Network *network = [[Network alloc] init];
    [network networkWithAction:@"login" params:@{@"userName":self.nameTextField.text,@"userPassword":self.passwordTextField.text} success:^(NSDictionary *data) {
        MyConfig *config = [MyConfig shared];
        config.userName = self.nameTextField.text;
        config.userPassword = self.passwordTextField.text;
        config.userId = data[@"userId"];
        config.userEMName = ![data[@"userEMName"] isKindOfClass:[NSNull class]] ? data[@"userEMName"] : @"";
        config.userGroupId = ![data[@"userGroupId"] isKindOfClass:[NSNull class]] ? data[@"userGroupId"] : @"";
        config.userIsLiveing = @"0";
        config.isLogin = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOGIN_SUCCESS object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSDictionary *data) {
        NSString *message = nil;
        NSInteger status = [data[@"status"] integerValue];
        if (status == 500) {
            message = @"连不上服务器，请检查您的网络";
        } else {
            message = @"登录失败，请稍后再试";
        }
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"失败" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alerView show];
    } view:self.navigationController.view];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    [self.nameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

@end
