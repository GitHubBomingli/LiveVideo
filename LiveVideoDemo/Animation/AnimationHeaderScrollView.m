//
//  AnimationHeaderScrollView.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/26.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "AnimationHeaderScrollView.h"


@implementation AnimationHeaderScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    
    for (NSInteger i = 0; i != 20; i ++) {
        AnimationHeaderIconView *iconView = [[NSBundle mainBundle] loadNibNamed:@"AnimationHeaderIconView" owner:self options:nil].lastObject;
        iconView.frame = CGRectMake(i * 38, 0, 38, 38);
        iconView.headerImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon%ld",i % 4]];
        [self addSubview:iconView];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        for (NSInteger i = 0; i != 20; i ++) {
            AnimationHeaderIconView *iconView = [[NSBundle mainBundle] loadNibNamed:@"AnimationHeaderIconView" owner:self options:nil].lastObject;
            iconView.frame = CGRectMake(i * 38, 0, 38, 38);
            iconView.headerImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon%ld",i % 4]];
            iconView.backgroundColor = [UIColor clearColor];
            
            [self addSubview:iconView];
        }
        self.backgroundColor = [UIColor clearColor];
        self.contentSize = CGSizeMake(38 * 20, 38);
    }
    return self;
}

@end
