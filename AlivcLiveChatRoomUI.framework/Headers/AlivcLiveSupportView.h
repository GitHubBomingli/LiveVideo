//
//  AlivcLiveSupportView.h
//  AlivcLiveVideo
//
//  Created by LYZ on 16/7/6.
//  Copyright © 2016年 Alivc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlivcLiveSupportView : UIView


/**
 *  点赞动画填充颜色 default:随机色
 */
@property (nonatomic, strong) UIColor *supportColor;


/**
 *  点赞图片 default:心形图案
 */
@property (nonatomic, strong) UIImage *supportImage;


- (void)alivcSupportAnimateInView:(UIView *)view;

@end
