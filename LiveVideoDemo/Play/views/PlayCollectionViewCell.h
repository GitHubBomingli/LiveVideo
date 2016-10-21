//
//  PlayCollectionViewCell.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/20.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayAnchorModel.h"
#import "UserModel.h"

@interface PlayCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;


@property (strong, nonatomic) IBOutlet UIView *bottomBackgroundView;

@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel *addressLabel;


@property (strong, nonatomic) IBOutlet UILabel *numLabel;

- (void)setAnchorModel:(PlayAnchorModel *)anchorModel;

@property (strong, nonatomic) UserModel *userModel;
@end
