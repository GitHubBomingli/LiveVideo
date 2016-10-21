//
//  MyTableViewController.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/20.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "MyTableViewController.h"
#import "MyTableViewCell.h"
#import "MyConfig.h"
#import "MySetViewController.h"
#import "ContributionViewController.h"
#import "MyDayTableViewController.h"
#import "MyIncomeAccountViewController.h"
#import "MyGradeViewController.h"
#import "MyCertificationViewController.h"
#import "PrivateMessageViewController.h"

@interface MyTableViewController ()

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) PrivateMessageViewController *messageVC;

@property (strong, nonatomic) NSMutableArray *sources;

@end

@implementation MyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.nameLabel.text = [MyConfig shared].userName;
    
    if (self.sources.count != 0) {
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (NSMutableArray *)sources {
    if (!_sources) {
        _sources = [NSMutableArray arrayWithObjects:@[@"贡献榜",@"我的一天",@"收益",@"账户"],@[@"等级",@"实名认证"],@[@"设置"], nil];
    }
    return _sources;
}

- (PrivateMessageViewController *)messageVC {
    if (!_messageVC) {
        _messageVC = [[PrivateMessageViewController alloc] init];
    }
    return _messageVC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)privateMessage:(UIButton *)sender {
    [self.navigationController pushViewController:self.messageVC animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sources[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTableViewCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = self.sources[indexPath.section][indexPath.row];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        cell.subLabel.text = @"3级";
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MySetViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:storyboard.instantiateInitialViewController animated:YES];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            ContributionViewController *contribution = [[ContributionViewController alloc] init];
            [self.navigationController pushViewController:contribution animated:YES];
         }
        if (indexPath.row == 1) {
            MyDayTableViewController *myDay = [[MyDayTableViewController alloc] init];
            [self.navigationController pushViewController:myDay animated:YES];
        }
        if (indexPath.row == 2) {
            MyIncomeAccountViewController *incom = [[MyIncomeAccountViewController alloc] init];
            incom.title = @"我的收益";
            [self.navigationController pushViewController:incom animated:YES];
        }
        if (indexPath.row == 3) {
            MyIncomeAccountViewController *incom = [[MyIncomeAccountViewController alloc] init];
            incom.title = @"我的账户";
            [self.navigationController pushViewController:incom animated:YES];
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            MyGradeViewController *grade = [[MyGradeViewController alloc] init];
            [self.navigationController pushViewController:grade animated:YES];
        }
        if (indexPath.row == 1) {
            MyCertificationViewController *certification = [[MyCertificationViewController alloc] init];
            [self.navigationController pushViewController:certification animated:YES];
        }
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
