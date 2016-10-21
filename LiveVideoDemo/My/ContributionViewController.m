//
//  ContributionViewController.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/9.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "ContributionViewController.h"

@interface ContributionViewController ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;

@property (strong, nonatomic) IBOutlet UIButton *dayBtn;

@property (strong, nonatomic) IBOutlet UIButton *allBtn;

@end

@implementation ContributionViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"贡献榜";
    self.dayBtn.selected = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)touchDayBtn:(UIButton *)sender {
    self.dayBtn.selected = YES;
    self.allBtn.selected = NO;
    self.leftConstraint.constant = 0;
}

- (IBAction)touchAllBtn:(UIButton *)sender {
    self.dayBtn.selected = NO;
    self.allBtn.selected = YES;
    self.leftConstraint.constant = kScreenWidth / 2.f;
}


@end
