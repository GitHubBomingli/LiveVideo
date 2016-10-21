//
//  BaseTabBarController.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/20.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "BaseTabBarController.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置统一样式
    UITabBarItem* barItem = [UITabBarItem appearance];
    
    NSMutableDictionary* norDic = @{}.mutableCopy;
    norDic[NSForegroundColorAttributeName] = [UIColor lightGrayColor];
    [barItem setTitleTextAttributes:norDic forState:UIControlStateNormal];
    
    NSMutableDictionary* selDic = @{}.mutableCopy;
    selDic[NSFontAttributeName] = norDic[NSFontAttributeName];
    selDic[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [barItem setTitleTextAttributes:selDic forState:UIControlStateSelected];
    
    
    self.tabBar.tintColor = [UIColor whiteColor];
    
    UITabBarItem *liveItem = self.tabBar.items[1];
    liveItem.image = [[UIImage imageNamed:@"tab_Live"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    liveItem.selectedImage = [[UIImage imageNamed:@"tab_Live"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
