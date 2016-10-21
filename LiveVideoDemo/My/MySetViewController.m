//
//  MySetViewController.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/9.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "MySetViewController.h"
#import "MySetTableViewCell.h"

@interface MySetViewController ()

@property (strong, nonatomic) NSMutableArray *sources;

@property (strong, nonatomic) IBOutlet UIButton *logoutBtn;
@end

@implementation MySetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.sources.count != 0) {
        [self.tableView reloadData];
    }
}

- (NSMutableArray *)sources {
    if (!_sources) {
        _sources = [NSMutableArray arrayWithObjects:@[@"账号与安全"],@[@"黑名单",@"短视频权限",@"开播提醒",@"未关注人私信"],@[@"清理缓存"],@[@"帮助和反馈",@"关于我们",@"网络诊断"], nil];
    }
    return _sources;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)touchLogoutBtn:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOGOUT object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sources[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MySetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MySetTableViewCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = self.sources[indexPath.section][indexPath.row];
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        cell.subLabel.text = @"3.3M";
    }
    
    if (indexPath.section == 1 && indexPath.row == 3) {
        cell.mySwitch.hidden = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

@end
