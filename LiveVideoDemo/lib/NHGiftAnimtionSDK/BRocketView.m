//
//  BRocketView.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/28.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "BRocketView.h"

@implementation BRocketView

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
        self = [[NSBundle mainBundle] loadNibNamed:@"BRocketView" owner:self options:nil].lastObject;
        self.frame = frame;
        
        [self config];
    }
    return self;
}

- (void)config {
    NSTimeInterval time = self.animationDuration ? self.animationDuration : 5;
    
    self.fireImageView.animationImages = self.sourcesFire;
    
    self.fireImageView.animationDuration = 1;
    
    self.fireImageView.animationRepeatCount = time;
    
    [self.fireImageView startAnimating];
    
    
    self.smokeImageView.animationImages = self.sourcesSmoke;
    
    self.smokeImageView.animationDuration = 1;
    
    self.smokeImageView.animationRepeatCount = 1;
    
    [self.smokeImageView startAnimating];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

- (NSMutableArray *)sourcesFire {
    if (!_sourcesFire) {
        _sourcesFire = [NSMutableArray array];
        
        for (NSInteger i = 1; i <= 6; i ++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"resource.bundle/rocket-fire-%ld.png",i]];
            [_sourcesFire addObject:image];
        }
        
    }
    
    return _sourcesFire;
}

- (NSMutableArray *)sourcesSmoke {
    if (!_sourcesSmoke) {
        _sourcesSmoke = [NSMutableArray array];
        
        for (NSInteger i = 1; i <= 13; i ++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"resource.bundle/rocket-smoke-%ld.png",i]];
            [_sourcesSmoke addObject:image];
        }
        
    }
    
    return _sourcesSmoke;
}

@end
