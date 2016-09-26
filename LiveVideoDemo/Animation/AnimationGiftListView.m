//
//  AnimationGiftListView.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/26.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "AnimationGiftListView.h"
#import "AnimationGiftIconView.h"

@implementation AnimationGiftListView
{
    NSInteger _selectedIndex;
    
    AnimationGiftIconView *preGiftView;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithHeight:(CGFloat)height
{
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:@"AnimationGiftListView" owner:self options:nil].lastObject;
        self.height = height;
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.height, [UIScreen mainScreen].bounds.size.width, self.height);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self setScroll];
        
        [self hide];
    }
    return self;
}

- (void)setScroll {
    CGFloat width = (self.height - 30) / 2 / 1.25;
    CGFloat height = width * 1.25;
    for (NSInteger row = 0; row != 2; row ++) {
        for (NSInteger col = 0; col != 16; col ++) {
            AnimationGiftIconView *giftView = [[AnimationGiftIconView alloc] initWithFrame:CGRectMake(col * width, row * height, width, height)];
            [self.scrollView addSubview:giftView];
            giftView.tag = row * 16 + col;
            
            giftView.selectGift = ^(NSInteger selectedIndex) {
                _selectedIndex = selectedIndex;
                
                preGiftView.backgroundColor = [UIColor clearColor];
                preGiftView = giftView;
                preGiftView.backgroundColor = [UIColor colorWithRed:0.000 green:0.895 blue:1.000 alpha:1.000];
                
            };
        }
    }
    self.scrollView.contentSize = CGSizeMake(width * 16, height * 2);
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (AnimationGiftIconView *giftView in self.scrollView.subviews) {
        if (giftView.frame.size.height != (self.height - 30) / 2) {
            CGRect frame = giftView.frame;
            frame.size.height = (self.height - 30) / 2;
            giftView.frame = frame;
        }
    }
}

- (IBAction)touchSendBtn:(UIButton *)sender {
    if (preGiftView != nil) {
        NSLog(@"%ld",_selectedIndex);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    
    self.pageC.currentPage = page;
}

- (void)show {
    [UIView animateWithDuration:0.4 animations:^{
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.height, [UIScreen mainScreen].bounds.size.width, self.height);
        self.hidden = NO;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.4 animations:^{
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, self.height);
        self.hidden = YES;
    }];
}


@end
