//
//  AnimationGiftIconView.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/26.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "AnimationGiftIconView.h"

@implementation AnimationGiftIconView
{
    CGRect superFrame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    superFrame = frame;
    self = [super initWithFrame:frame];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:@"AnimationGiftIconView" owner:self options:nil].lastObject;
        self.frame = frame;
        NSLog(@"%f",self.frame.size.height);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tap:(UIGestureRecognizer *)sender {
    if (_selectGift) {
        _selectGift(self.tag);
    }
}

@end
