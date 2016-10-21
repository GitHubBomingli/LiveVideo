//
//  MyCertificationViewController.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/10.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "MyCertificationViewController.h"

@interface MyCertificationViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation MyCertificationViewController

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
    
    self.title = @"一键绑定";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
