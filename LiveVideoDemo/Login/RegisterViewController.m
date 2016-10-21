//
//  RegisterViewController.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/8.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "RegisterViewController.h"
#import <MBProgressHUD.h>
#import "MyConfig.h"
#import "MemberManager.h"
#import "MemberModel.h"
#import "Network.h"

@interface RegisterViewController ()

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) IBOutlet UIButton *registerBtn;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchRegisterBtn:(UIButton *)sender {
    [self.nameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    if ([self.nameTextField.text isEqualToString:@""] || !self.nameTextField.text) {
        return ;
    }
    if ([self.passwordTextField.text isEqualToString:@""] || !self.passwordTextField.text) {
        return ;
    }
    
    
    //本地数据库
//    MemberModel *memberModel = [[MemberModel alloc] init];
//    memberModel.name = self.nameTextField.text;
//    memberModel.password = self.passwordTextField.text;
//    
//    MemberManager *memberManager = [[MemberManager alloc] init];
//    NSInteger code = [memberManager insertMember:memberModel];
//    if (code == 0) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"失败" message:@"注册失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//        return;
//    } else if (code == 2) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"失败" message:@"用户名重复" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//        return ;
//    }
    
    Network *network = [[Network alloc] init];
    [network networkWithAction:@"register" params:@{@"userName":self.nameTextField.text,@"userPassword":self.passwordTextField.text} success:^(NSDictionary *data) {
        MyConfig *config = [MyConfig shared];
        config.userName = self.nameTextField.text;
        config.userPassword = self.passwordTextField.text;
        config.userId = data[@"userId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REGISTER_SUCCESS object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSDictionary *data) {
        NSString *message = nil;
        NSInteger status = [data[@"status"] integerValue];
        if (status == 500) {
            message = @"连不上服务器，请检查您的网络";
        } else if (status == 2) {
            message = @"用户名重复，请重新注册";
        } else {
            message = @"注册失败，请稍后再试";
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
