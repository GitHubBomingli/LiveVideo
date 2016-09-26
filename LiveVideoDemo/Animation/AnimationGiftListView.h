//
//  AnimationGiftListView.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/26.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnimationGiftListView : UIView<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageC;
@property (strong, nonatomic) IBOutlet UIButton *chongzhiBtn;
@property (strong, nonatomic) IBOutlet UIButton *sendBtn;

@property (assign, nonatomic) CGFloat height;

- (instancetype)initWithHeight:(CGFloat)height;

- (void)show;

- (void)hide;
@end
