//
//  BFirework.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/28.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFirework : UIView

@property (strong, nonatomic) IBOutlet UIImageView *firstImageView;
@property (strong, nonatomic) IBOutlet UIImageView *scendImageView;

@property (strong, nonatomic) NSMutableArray *sources;

@property (assign, nonatomic) NSTimeInterval animationDuration;
@end
