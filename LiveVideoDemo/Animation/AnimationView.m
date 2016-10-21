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
#import "BRocketView.h"
#import "InputView.h"
#import "EMClient.h"
#import "LiveChatTableViewCell.h"
#import "BheartFlowerView.h"


#define NHBounds [UIScreen mainScreen].bounds.size
@interface AnimationView ()<InputViewDelegate,EMChatManagerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) InputView *inputView;

@property (nonatomic, strong) NSMutableDictionary *messageExt;

@property (nonatomic, strong) EMConversation *conversation;

@property (nonatomic, strong) NSMutableArray *messages;

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
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//        [self addGestureRecognizer:tap];
        
        [self tableDelegate];
        
        [self chatDelegate];
        
    }
    return self;
}

#pragma mark - Get Set

- (UIView *)inputView {
    if (!_inputView) {
        _inputView = [[InputView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 49)];
        _inputView.delegate = self;
        _inputView.inputModel = InputModelText;
        [self addSubview:_inputView];
    }
    return _inputView;
}

- (NSMutableDictionary *)messageExt {
    if (!_messageExt) {
        _messageExt = [NSMutableDictionary dictionary];
    }
    return _messageExt;
}

- (EMConversation *)conversation {
    if (!_conversation) {
        _conversation = [[EMClient sharedClient].chatManager getConversation:self.groupId type:EMConversationTypeGroupChat createIfNotExist:YES];
    }
    return _conversation;
}

- (NSMutableArray *)messages {
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}

- (AnimationGiftListView *)giftListView {
    if (_giftListView == nil) {
        CGFloat height = kScreenWidth / 4.f * 1.25 * 2 + 30;
        _giftListView = [[AnimationGiftListView alloc] initWithHeight:height];
        __weak typeof(self) blockSelf = self;
        _giftListView.sendCallback = ^(NSInteger giftIndex) {
            
            [blockSelf sendCmdMessageWithGift:giftIndex];
        };
    }
    return _giftListView;
}

- (void)setType:(KAnimationType)type {
    _type = type;
    
    if (self.type == KAnimationTypePlay) {
        self.cameraBtn.hidden = YES;
        self.meiYanBtn.hidden = YES;
        self.giftBtn.hidden = NO;
    } else {
        self.cameraBtn.hidden = NO;
        self.meiYanBtn.hidden = NO;
        self.giftBtn.hidden = YES;
    }
}

#pragma mark - Action

- (void)tap:(UIGestureRecognizer *)sender {
    
    if (self.commentBtn.hidden) {
        
        if (self.type == KAnimationTypePlay) {
            self.giftBtn.hidden = NO;
            self.backBtn.hidden = NO;
            self.commentBtn.hidden = NO;
            self.siXinBtn.hidden = NO;
            self.commentTable.hidden = NO;
            self.cameraBtn.hidden = YES;
            self.meiYanBtn.hidden = YES;
        } else {
            self.giftBtn.hidden = YES;
            self.backBtn.hidden = NO;
            self.commentBtn.hidden = NO;
            self.siXinBtn.hidden = NO;
            self.commentTable.hidden = NO;
            self.cameraBtn.hidden = NO;
            self.meiYanBtn.hidden = NO;
        }
        
        [self.giftListView hide];
    }
    
    [self.inputView.textField resignFirstResponder];
    self.inputView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 49);
}
- (IBAction)sendMessage:(UIButton *)sender {
    
    [self.inputView.textField becomeFirstResponder];
    
    self.inputView.frame = CGRectMake(0, kScreenHeight - 49, kScreenWidth, 49);
}

- (IBAction)giftBtn:(UIButton *)sender {
    [self.giftListView show];
    
    sender.hidden = YES;
    self.backBtn.hidden = YES;
    self.commentBtn.hidden = YES;
    self.siXinBtn.hidden = YES;
    self.commentTable.hidden = YES;
    
}

- (IBAction)privateMessage:(UIButton *)sender {
    if (_privateMessageCallback) {
        _privateMessageCallback();
    }
}

- (IBAction)addConcern:(UIButton *)sender {
    self.headerWidth.constant -= 30;
    sender.enabled = NO;
    
    [self.scrollView removeFromSuperview];
    self.scrollView = [[AnimationHeaderScrollView alloc] initWithFrame:CGRectMake(self.headerView.frame.size.width + self.headerView.frame.origin.x + 8 - 30, 16, self.frame.size.width - (self.headerView.frame.size.width + self.headerView.frame.origin.x + 8) + 30, 38)];
    [self addSubview:self.scrollView];
}

#pragma mark - InputView Delegate
- (void)inputView:(InputView *)inputView willShowKeyboardHeight:(CGFloat)height time:(NSNumber *)time {
    
}
- (void)willHideKeyboardWithInputView:(InputView *)inputView time:(NSNumber *)time {
    
}
- (void)inputView:(InputView *)inputView text:(NSString *)text {
    inputView.textField.text = @"";
    
    
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    //生成Message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.conversation.conversationId from:from to:self.conversation.conversationId body:body ext:self.messageExt];
    message.chatType = EMChatTypeGroupChat;// 设置为群聊消息
    
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
        
    } completion:^(EMMessage *message, EMError *error) {
        
    }];
    
    NSInteger count = self.messages.count;
    [self.messages addObject:message];
    [self.commentTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [self.commentTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.messages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - 聊天
- (void)chatDelegate {
    //移除消息回调
    [[EMClient sharedClient].chatManager removeDelegate:self];
    
    //注册消息回调
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
}
//接到普通消息
- (void)messagesDidReceive:(NSArray *)aMessages {
    EMMessage *message = aMessages.lastObject;
    if (message.chatType == EMChatTypeGroupChat) {
        NSInteger count = self.messages.count;
        [self.messages addObject:aMessages.lastObject];
        [self.commentTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.commentTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.messages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
//接到透传消息
- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages {
    for (EMMessage *message in aCmdMessages) {
        EMCmdMessageBody *body = (EMCmdMessageBody *)message.body;
        [self giftAnimationWithTag:[body.action integerValue]];
    }
}
//发送透传消息，用于礼物
- (void)sendCmdMessageWithGift:(NSInteger)giftIndex {
    
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:[NSString stringWithFormat:@"%ld",giftIndex]];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.conversation.conversationId from:from to:self.conversation.conversationId body:body ext:self.messageExt];
    message.chatType = EMChatTypeGroupChat;// 设置为群聊消息
    
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
        
    } completion:^(EMMessage *message, EMError *error) {
        [self giftAnimationWithTag:giftIndex];
    }];
}


#pragma mark - Table View

- (void)tableDelegate {
    self.commentTable.delegate = self;
    self.commentTable.dataSource = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LiveChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveChatTableViewCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"LiveChatTableViewCell" owner:self options:nil].lastObject;
    }
    
    NSString *contentString = nil;
    EMMessage *message = self.messages[indexPath.row];
    
    EMMessageBody *msgBody = message.body;
    switch (msgBody.type) {
        case EMMessageBodyTypeText:
        {
            // 收到的文字消息
            EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
            
            contentString = [NSString stringWithFormat:@"%@：%@",message.from,textBody.text];
        }
            break;
        default:
            break;
    }
    
    cell.chatLabel.text = contentString;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *contentString = nil;
    EMMessage *message = self.messages[indexPath.row];
    
    EMMessageBody *msgBody = message.body;
    switch (msgBody.type) {
        case EMMessageBodyTypeText:
        {
            // 收到的文字消息
            EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
            
            contentString = [NSString stringWithFormat:@"%@：%@",message.from,textBody.text];
        }
            break;
        default:
            break;
    }
    return [contentString boundingRectWithSize:CGSizeMake(kScreenWidth - 96, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil].size.height + 8;
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
        case 2:
            [self porscheAction];
            break;
        case 3:
            [self fireworksGift];
            break;
        case 4:
            [self heartFlowerAction];
            break;
        case 5:
            [self fighterAction];
            break;
        case 6:
            [self meteorGift];
            break;
        case 7:
            [self rocketGift];
            break;
        case 8:
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
//1314
- (void)heartFlowerAction {
    BheartFlowerView *heartFlower = [[BheartFlowerView alloc] initWithFrame:self.bounds];
    [self addSubview:heartFlower];
}
//钻石
- (void)meteorGift {
    BMeteorView *meteor = [[BMeteorView alloc] initWithFrame:self.bounds];
    meteor.animationDuration = 4;
    [self addSubview:meteor];
}
//烟花
- (void)fireworksGift {
    BFirework *firework = [[BFirework alloc] initWithFrame:self.bounds];
    firework.animationDuration = 0.4;
    [self addSubview:firework];
}

- (void)rocketGift {
    BRocketView *rocketView = [[BRocketView alloc] initWithFrame:self.bounds];
    [self addSubview:rocketView];
    
    [UIView animateWithDuration:1 animations:^{
        CGRect frame = self.bounds;
        frame.origin.y -= 64;
        rocketView.frame = frame;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = self.bounds;
            frame.origin.y -= 1000;
            rocketView.frame = frame;
        }];
    });
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    [self tap:nil];
}
@end
