//
//  BMeteorView.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/28.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "BMeteorView.h"

@interface BMeteorView ()

@property (strong, nonatomic) IBOutlet UIImageView *meteorImageView;

@property (strong, nonatomic) NSMutableArray *sources;
@end

@implementation BMeteorView

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
        self = [[NSBundle mainBundle] loadNibNamed:@"BMeteorView" owner:self options:nil].lastObject;
        self.frame = frame;
        
        [self config];
    }
    return self;
}

- (void)config {
    
    self.meteorImageView.animationImages = self.sources;
    
    self.meteorImageView.animationDuration = self.animationDuration ? self.animationDuration : 4;
    
    self.meteorImageView.animationRepeatCount = 1;
    
    [self.meteorImageView startAnimating];
}

- (NSMutableArray *)sources {
    if (!_sources) {
        _sources = [NSMutableArray array];
        
        for (NSInteger i = 1; i <= 14; i ++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"resource.bundle/meteor_%.2ld.png",i]];
            [_sources addObject:image];
        }
        for (NSInteger i = 1; i <= 27; i ++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"resource.bundle/meteor_after_%.2ld.png",i]];
            [_sources addObject:image];
        }
        UIImage *image = [UIImage imageNamed:@"resource.bundle/meteor_blink.png"];
        [_sources addObject:image];
    }
    
    return _sources;
}

@end
