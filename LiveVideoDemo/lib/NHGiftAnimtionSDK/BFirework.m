//
//  BFirework.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/28.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "BFirework.h"

@implementation BFirework

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:@"BFirework" owner:self options:nil].lastObject;
        self.frame = frame;
        
        [self config];
    }
    return self;
}

- (void)config {
    NSTimeInterval time = self.animationDuration ? self.animationDuration : 0.4;
    
    self.firstImageView.animationImages = self.sources;
    
    self.firstImageView.animationDuration = time;
    
    self.firstImageView.animationRepeatCount = 1;
    
    [self.firstImageView startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.firstImageView stopAnimating];
        self.scendImageView.image = [UIImage imageNamed:@"resource.bundle/gift_fireworks_2.png"];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((time + 1)  * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

- (NSMutableArray *)sources {
    if (!_sources) {
        _sources = [NSMutableArray array];
        
        for (NSInteger i = 1; i <= 10; i ++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"resource.bundle/gift_fireworks_1_%ld.png",i]];
            [_sources addObject:image];
        }
        
    }
    
    return _sources;
}

@end
