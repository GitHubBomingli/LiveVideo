//
//  BRocketView.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/28.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRocketView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *fireImageView;
@property (strong, nonatomic) IBOutlet UIImageView *smokeImageView;

@property (strong, nonatomic) NSMutableArray *sourcesFire;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraint;

@property (strong, nonatomic) NSMutableArray *sourcesSmoke;

@property (assign, nonatomic) NSTimeInterval animationDuration;
@end
