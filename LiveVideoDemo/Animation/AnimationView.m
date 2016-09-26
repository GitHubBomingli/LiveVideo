//
//  AnimationView.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/26.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "AnimationView.h"
#import "AnimationGiftListView.h"

@interface AnimationView ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *headerWidth;

@property (strong, nonatomic) AnimationGiftListView *giftListView;
@end

@implementation AnimationView

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
        self = [[NSBundle mainBundle] loadNibNamed:@"AnimationView" owner:self options:nil].lastObject;
        self.frame = frame;
        
        self.scrollView = [[AnimationHeaderScrollView alloc] initWithFrame:CGRectMake(self.headerView.frame.size.width + self.headerView.frame.origin.x + 8, 16, self.frame.size.width - (self.headerView.frame.size.width + self.headerView.frame.origin.x + 8), 38)];
        [self addSubview:self.scrollView];
        
        [self addSubview:self.giftListView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (AnimationGiftListView *)giftListView {
    if (_giftListView == nil) {
        CGFloat height = [UIScreen mainScreen].bounds.size.width / 4.f * 1.25 * 2 + 30;
        _giftListView = [[AnimationGiftListView alloc] initWithHeight:height];
    }
    return _giftListView;
}

- (void)tap:(UIGestureRecognizer *)sender {
    if (self.commentBtn.hidden) {
        self.giftBtn.hidden = NO;
        self.backBtn.hidden = NO;
        self.commentBtn.hidden = NO;
        self.siXinBtn.hidden = NO;
        self.commentTable.hidden = NO;
        
        [self.giftListView hide];
    }
}

- (IBAction)giftBtn:(UIButton *)sender {
    [self.giftListView show];
    
    sender.hidden = YES;
    self.backBtn.hidden = YES;
    self.commentBtn.hidden = YES;
    self.siXinBtn.hidden = YES;
    self.commentTable.hidden = YES;
    
}


- (IBAction)addConcern:(UIButton *)sender {
    self.headerWidth.constant -= 30;
    sender.enabled = NO;
    
    [self.scrollView removeFromSuperview];
    self.scrollView = [[AnimationHeaderScrollView alloc] initWithFrame:CGRectMake(self.headerView.frame.size.width + self.headerView.frame.origin.x + 8 - 30, 16, self.frame.size.width - (self.headerView.frame.size.width + self.headerView.frame.origin.x + 8) + 30, 38)];
    [self addSubview:self.scrollView];
}
@end
