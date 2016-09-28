//
//  AnimationView.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/26.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "AnimationView.h"
#import "AnimationGiftListView.h"

#import "NHHeader.h"
#import "NHCarViews.h"
#import "NHPlaneViews.h"
#import "BMeteorView.h"
#import "BFirework.h"

#define NHBounds [UIScreen mainScreen].bounds.size
@interface AnimationView ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *headerWidth;

@property (strong, nonatomic) AnimationGiftListView *giftListView;

@property (nonatomic, weak) NHPresentFlower *flower;
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
        __weak typeof(self) blockSelf = self;
        _giftListView.sendCallback = ^(NSInteger giftIndex) {
//            [blockSelf tap:nil];
            
            [blockSelf giftAnimationWithTag:giftIndex];
        };
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

#pragma mark - Gift Animation

- (void)giftAnimationWithTag:(NSInteger)tag {
    switch (tag) {
        case 0:
            [self flowerA];
            break;
        case 1:
            [self flowerB];
            break;
        case 12:
            [self porscheAction];
            break;
        case 13:
            [self fireworksGift];
            break;
        case 15:
            [self fighterAction];
            break;
        case 16:
            [self meteorGift];
            break;
        case 18:
            [self planeAction];
            break;
            
        default:
            break;
    }
}

- (void)addFlowerView{
    NHPresentFlower *flower = [[NHPresentFlower alloc] initWithFrame:CGRectMake(0, 200, self.bounds.size.width, 50)presentFlowerEffect:NHSendEffectShake];
    flower.autoHiddenTime = 5;
    [self addSubview:flower];
    _flower = flower;
}
/**
 *  鲜花1
 */
- (void)flowerA {
    if (_flower == nil) {
        [self addFlowerView];
    }else{
        _flower.effect = NHSendEffectSpring;
        _flower.scaleValue = @[@4.2,@3.5,@1.2,@3.8,@3.3,@3.0,@2.0,@1.0];
        [_flower continuePresentFlowers];
    }
}
/**
 *  鲜花2
 */
- (void)flowerB {
    if (_flower == nil) {
        [self addFlowerView];
    }else{
        _flower.effect = NHSendEffectShake;
        _flower.scaleValue = @[@4.2,@3.5,@1.2,@3.8,@3.3,@3.0,@2.0,@1.0];
        [_flower continuePresentFlowers];
    }
}

//保时捷
- (void)porscheAction {
    NHCarViews *car = [NHCarViews loadCarViewWithPoint:CGPointZero];
    
    //数组中放CGRect数据，CGRect的x和y分别作为控制点的x和y，CGRect的width和height作为结束点的x和y
    //方法如下：数组内的每个元素代码一个控制点和结束点
    NSMutableArray *pointArrs = [[NSMutableArray alloc] init];
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 2;
    [pointArrs addObject:NSStringFromCGRect(CGRectMake(width, 300, width, 300))];
    //    pointArrs addObject:...添加更多的CGRect
    car.curveControlAndEndPoints = pointArrs;
    
    [car addAnimationsMoveToPoint:CGPointMake(0, 100) endPoint:CGPointMake(self.bounds.size.width +166, 500)];
    [self addSubview:car];
}

//歼灭者
- (void)fighterAction {
    NHFighterView *fighter = [NHFighterView loadFighterViewWithPoint:CGPointMake(10, 100)];
    //fighter.curveControlAndEndPoints 用法同carView一样
    [fighter addAnimationsMoveToPoint:CGPointMake(self.bounds.size.width, 60) endPoint:CGPointMake( -500, 600)];
    [self addSubview:fighter];
    
}

//客机
- (void)planeAction {
    NHPlaneViews *plane = [NHPlaneViews loadPlaneViewWithPoint:CGPointMake(NHBounds.width + 232, 0)];
    //plane.curveControlAndEndPoints 用法同carView一样
    
    [plane addAnimationsMoveToPoint:CGPointMake(NHBounds.width, 100) endPoint:CGPointMake(-500, 410)];
    [self addSubview:plane];
}
//钻石
- (void)meteorGift {
    BMeteorView *meteor = [[BMeteorView alloc] initWithFrame:self.bounds];
    meteor.animationDuration = 4;
    [self addSubview:meteor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [meteor removeFromSuperview];
    });
}
//烟花
- (void)fireworksGift {
    BFirework *firework = [[BFirework alloc] initWithFrame:self.bounds];
    firework.animationDuration = 0.4;
    [self addSubview:firework];
}
@end
