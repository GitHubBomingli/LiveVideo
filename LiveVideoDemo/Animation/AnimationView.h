//
//  AnimationView.h
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/26.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimationHeaderScrollView.h"

typedef enum : NSUInteger {
    KAnimationTypePlay,
    KAnimationTypeLive,
} KAnimationType;
@interface AnimationView : UIView

@property (strong, nonatomic) AnimationHeaderScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) IBOutlet UIButton *backBtn;

@property (strong, nonatomic) IBOutlet UIButton *siXinBtn;
@property (strong, nonatomic) IBOutlet UIButton *commentBtn;
@property (strong, nonatomic) IBOutlet UITableView *commentTable;
@property (strong, nonatomic) IBOutlet UIButton *giftBtn;

@property (strong, nonatomic) IBOutlet UIButton *cameraBtn;

@property (strong, nonatomic) IBOutlet UIButton *meiYanBtn;

@property (assign, nonatomic) KAnimationType type;

@property (copy, nonatomic) void(^privateMessageCallback)();

@property (copy, nonatomic) NSString *groupId;

@end
