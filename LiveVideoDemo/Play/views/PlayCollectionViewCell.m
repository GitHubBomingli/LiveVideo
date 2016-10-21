//
//  PlayCollectionViewCell.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/20.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "PlayCollectionViewCell.h"

@implementation PlayCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _bottomBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
}

- (void)setAnchorModel:(PlayAnchorModel *)anchorModel {
    
    _backgroundImageView.image = [UIImage imageNamed:anchorModel.anchorIcon];
    
    _iconImageView.image = [UIImage imageNamed:anchorModel.anchorIcon];
    
    _nameLabel.text = anchorModel.anchorName;
    
    _addressLabel.text = anchorModel.anchorAddress;
    
    _numLabel.text = anchorModel.anchorViewNum;
}

- (void)setUserModel:(UserModel *)userModel {
    _userModel = userModel;
    
    _backgroundImageView.image = [UIImage imageNamed:userModel.userIcon];
    
    _iconImageView.image = [UIImage imageNamed:userModel.userIcon];
    
    _nameLabel.text = userModel.userName;
    
    _addressLabel.text = userModel.userAddress;
    
    _numLabel.text = userModel.userViewNum;
}

@end
