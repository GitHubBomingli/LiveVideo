//
//  MySetTableViewCell.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/9.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySetTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UILabel *subLabel;
@property (strong, nonatomic) IBOutlet UISwitch *mySwitch;
@end
