//
//  BheartFlowerView.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/12.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "BheartFlowerView.h"

@implementation BheartFlowerView

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
        self = [[NSBundle mainBundle] loadNibNamed:@"BheartFlowerView" owner:self options:nil].lastObject;
        self.frame = frame;
        
        [self config];
    }
    return self;
}

- (void)config {
    NSTimeInterval time = self.animationDuration ? self.animationDuration : 0.6;
    
    self.numImageView.image = [UIImage imageNamed:@"resource.bundle/1314-num.png"];
    self.numImageView.hidden = YES;
    self.animationImageView.animationImages = self.sources;
    self.animationImageView.animationDuration = time;
    self.animationImageView.animationRepeatCount = 1;
    [self.animationImageView startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((time - 0.1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.numImageView.hidden = NO;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.animationImageView stopAnimating];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((time + 0.4) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
    
}
- (NSMutableArray *)sources {
    if (!_sources) {
        _sources = [NSMutableArray array];
        
        for (NSInteger i = 1; i <= 5; i ++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"resource.bundle/1314-%ld.png",i]];
            [_sources addObject:image];
        }
        UIImage *image1 = [UIImage imageNamed:@"resource.bundle/1314-light.png"];
        [_sources addObject:image1];
        
    }
    
    return _sources;
}
@end
