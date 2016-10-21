//
//  BheartFlowerView.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/12.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BheartFlowerView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *animationImageView;

@property (strong, nonatomic) IBOutlet UIImageView *numImageView;

@property (strong, nonatomic) NSMutableArray *sources;

@property (assign, nonatomic) NSTimeInterval animationDuration;

@end
