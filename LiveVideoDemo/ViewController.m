//
//  ViewController.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/9/20.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "ViewController.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "LLGroupManager.h"
#import "MyConfig.h"
#import "AnimationView.h"
#import "PrivateMessageViewController.h"

@interface ViewController ()

@property (nonatomic, strong) CTCallCenter *callCenter;

/**
 *  聊天、动画等视图
 */
@property (nonatomic, strong) AnimationView *animationView;

@property (strong, nonatomic) LLGroupManager *groupManager;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *startBtnHeight;

@property (strong, nonatomic) IBOutlet UIButton *startBtn;

@property (strong, nonatomic) IBOutlet UIButton *backBtn;

/**
 *  美颜
 */
@property (strong, nonatomic) IBOutlet UIButton *meiyanBtn;

@property (strong, nonatomic) PrivateMessageViewController *messageVC;
@end

@implementation ViewController
{
    AlivcLiveSession *_liveSession;
    NSString *_url;
    NSTimer *_timer;
    
    NSFileHandle *_handle;
    AVCaptureDevicePosition _currentPosition;
    NSUInteger _last;
    NSMutableArray *_logArray;
    
    CGFloat _lastPinchDistance;
    
    BOOL _isCTCallStateDisconnected;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.tabBarController.tabBar.hidden = YES;
    
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeUpdate) userInfo:nil repeats:YES];
//    [self testPushCapture];
    //美颜
    [_liveSession setEnableSkin:self.meiyanBtn.isSelected];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.tabBarController.tabBar.hidden = NO;
}

- (PrivateMessageViewController *)messageVC {
    if (!_messageVC) {
        _messageVC = [[PrivateMessageViewController alloc] init];
    }
    return _messageVC;
}

- (AnimationView *)animationView {
    if (_animationView == nil) {
        
        _animationView = [[AnimationView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _animationView.backgroundColor = [UIColor clearColor];
        _animationView.type = KAnimationTypeLive;
        _animationView.groupId = [MyConfig shared].userGroupId;
        [_animationView.backBtn addTarget:self action:@selector(TouchEndBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_animationView.cameraBtn addTarget:self action:@selector(cameraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_animationView.meiYanBtn addTarget:self action:@selector(skinButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        __block typeof(self) blockSelf = self;
        _animationView.privateMessageCallback = ^() {
            [blockSelf.navigationController pushViewController:blockSelf.messageVC animated:YES];
        };
        
        UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
        rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        [_animationView addGestureRecognizer:rightSwipe];
        
        [self rightSwipe:nil];
    }
    return _animationView;
}

- (void)rightSwipe:(UISwipeGestureRecognizer *)sender {
    [UIView animateWithDuration:0.4 animations:^{
        self.animationView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    } completion:^(BOOL finished) {
        self.backBtn.hidden = NO;
    }];
}

- (void)leftSwipe:(UISwipeGestureRecognizer *)sender {
    [UIView animateWithDuration:0.4 animations:^{
        self.animationView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    } completion:^(BOOL finished) {
        self.backBtn.hidden = YES;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.animationView];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    
    _url = @"rtmp://video-center.alivecdn.com/app-name/video-name?vhost=live.lovcreate.com";
    
    _logArray = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:gesture];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.view addGestureRecognizer:pinch];
    
//
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"log.txt"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    _handle = [NSFileHandle fileHandleForWritingAtPath:path];
    
     _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeUpdate) userInfo:nil repeats:YES];
    [self testPushCapture];
}
- (void)timeUpdate{
    AlivcLDebugInfo *i = [_liveSession dumpDebugInfo];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:i.connectStatusChangeTime];
    
    NSMutableString *msg = [[NSMutableString alloc] init];
    [msg appendFormat:@"CycleDelay(%0.2fms)\n",i.cycleDelay];
    [msg appendFormat:@"bitrate(%zd) buffercount(%zd)\n",[_liveSession alivcLiveVideoBitRate] ,_liveSession.dumpDebugInfo.localBufferVideoCount];
    [msg appendFormat:@" efc(%zd) pfc(%zd)\n",i.encodeFrameCount, i.pushFrameCount];
    [msg appendFormat:@"%0.2ffps %0.2fKB/s %0.2fKB/s\n", i.fps,i.encodeSpeed, i.speed/1024];
    [msg appendFormat:@"%lluB pushSize(%lluB) status(%zd) %@",i.localBufferSize, i.pushSize, i.connectStatus, date];
    [msg appendFormat:@" %0.2fms\n",i.localDelay];
    [msg appendFormat:@"video_pts:%zd\naudio_pts:%zd\n", i.currentVideoPTS,i.currentAudioPTS];
    
    NSLog(@"%@", msg);
    
//    _textView.text = msg;
    
    
    
    [_logArray addObject:msg];
    
    //    NSLog(@"%@", i.eventArray);
    
    
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:self.view];
    CGPoint percentPoint = CGPointZero;
    percentPoint.x = point.x / CGRectGetWidth(self.view.bounds);
    percentPoint.y = point.y / CGRectGetHeight(self.view.bounds);
    [_liveSession alivcLiveVideoFocusAtAdjustedPoint:percentPoint autoFocus:YES];
    
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gesture {
    
    if (_currentPosition == AVCaptureDevicePositionFront) {
        return;
    }
    
    if (gesture.numberOfTouches != 2) {
        return;
    }
    CGPoint p1 = [gesture locationOfTouch:0 inView:self.view];
    CGPoint p2 = [gesture locationOfTouch:1 inView:self.view];
    CGFloat dx = (p2.x - p1.x);
    CGFloat dy = (p2.y - p1.y);
    CGFloat dist = sqrt(dx*dx + dy*dy);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _lastPinchDistance = dist;
    }
    
    CGFloat change = dist - _lastPinchDistance;
    //    change = change / (CGRectGetWidth(self.view.bounds) * 0.5) * 2.0;
    //
    [_liveSession alivcLiveVideoZoomCamera:(change / 1000 )];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)appResignActive{
    [self destroySession];
    
    // 监听电话
    _callCenter = [[CTCallCenter alloc] init];
    _isCTCallStateDisconnected = NO;
    _callCenter.callEventHandler = ^(CTCall* call) {
        if ([call.callState isEqualToString:CTCallStateDisconnected])
        {
            _isCTCallStateDisconnected = YES;
        }
        else if([call.callState isEqualToString:CTCallStateConnected])
            
        {
            _callCenter = nil;
        }
    };
    
    _startBtnHeight.constant = 49;
    _startBtn.hidden = NO;
    [self rightSwipe:nil];
}

- (void)appBecomeActive{
    
    if (_isCTCallStateDisconnected) {
        sleep(2);
    }
    
    [self testPushCapture];
    
    //美颜
    [_liveSession setEnableSkin:self.meiyanBtn.isSelected];
    
}

- (void)testPushCapture{
    if (_liveSession) {
        return ;
    }
    //    _url = @"rtmp://192.168.30.69/live/movie";
    
    //    _url = @"rtmp://push.lss.qupai.me/qupai-live/qupai-live-wyj99?auth_key=4466400545-0-0-1d54a5911b70caccfce6983bced975e8";
    
    AlivcLConfiguration *configuration = [[AlivcLConfiguration alloc] init];
    configuration.url = _url;
    configuration.videoMaxBitRate = 1500 * 1000;
    configuration.videoBitRate = 600 * 1000;
    configuration.videoMinBitRate = 400 * 1000;
    configuration.audioBitRate = 64 * 1000;
    configuration.videoSize = CGSizeMake(360, 640);// 横屏状态宽高不需要互换
    configuration.fps = 20;
    configuration.preset = AVCaptureSessionPresetiFrame1280x720;
    configuration.screenOrientation = NO;
    if (_currentPosition) {
        configuration.position = _currentPosition;
    } else {
        configuration.position = AVCaptureDevicePositionFront;
        _currentPosition = AVCaptureDevicePositionFront;
    }
    
    _liveSession = [[AlivcLiveSession alloc] initWithConfiguration:configuration];
    _liveSession.delegate = self;
    
    [_liveSession alivcLiveVideoStartPreview];
    
    [_liveSession alivcLiveVideoUpdateConfiguration:^(AlivcLConfiguration *configuration) {
        configuration.videoMaxBitRate = 1500 * 1000;
        configuration.videoBitRate = 600 * 1000;
        configuration.videoMinBitRate = 400 * 1000;
        configuration.audioBitRate = 64 * 1000;
        configuration.fps = 20;
    }];
//    [_liveSession alivcLiveVideoConnectServer];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view insertSubview:[_liveSession previewView] atIndex:0];
    });
    
}

- (void)destroySession {
    
    [_liveSession alivcLiveVideoDisconnectServer];
    
    [_liveSession alivcLiveVideoStopPreview];
//    [_liveSession.previewView removeFromSuperview];
    
//    _liveSession = nil;
}


- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session error:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *msg = [NSString stringWithFormat:@"%zd %@",error.code, error.localizedDescription];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Live Error" message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"重新连接", nil];
        alertView.delegate = self;
        [alertView show];
    });
}

- (void)alivcLiveVideoLiveSessionConnectSuccess:(AlivcLiveSession *)session {
    
    NSLog(@"connect success!");
}

- (void)alivcLiveVideoLiveSessionNetworkSlow:(AlivcLiveSession *)session{
    dispatch_async(dispatch_get_main_queue(), ^{
//        _textView.text = @"网络很差，不建议直播";
        NSLog(@"网络很差，不建议直播");
    });
}

- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session OpenAudioError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"麦克风获取失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    });
}

- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session OpenVideoError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"摄像头获取失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    });
}

- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session EncodeAudioError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"音频编码初始化失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    });
    
}

- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session EncodeVideoError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"视频编码初始化失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [_liveSession alivcLiveVideoConnectServer];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (LLGroupManager *)groupManager {
    if (!_groupManager) {
        _groupManager = [[LLGroupManager alloc] init];
    }
    return _groupManager;
}

#pragma mark - Touch or Action
//开始直播
- (IBAction)touchStartLiveVideoBtn:(UIButton *)sender {
    //开始直播
    [_liveSession alivcLiveVideoConnectServer];
    
    [self startChat];
    
    [UIView animateWithDuration:1 animations:^{
        _startBtnHeight.constant = 0;
    } completion:^(BOOL finished) {
        _startBtn.hidden = YES;
    }];
    
    [self leftSwipe:nil];
}
//结束直播
- (IBAction)TouchEndBtn:(UIButton *)sender {
    
    //销毁群组
    //    [self.groupManager destroyGroupWith:@""];
    //退出群组
    [self.groupManager leaveGroupWith:GROUPID];
    
    
    [_liveSession alivcLiveVideoDisconnectServer];
    
    [self destroySession];
    [_timer invalidate];
    _timer = nil;
    
    _startBtnHeight.constant = 49;

    _startBtn.hidden = NO;
    
    self.navigationController.navigationBar.hidden = NO;
    
    self.navigationController.tabBarController.selectedIndex = 0;
    
    MyConfig *config = [MyConfig shared];
    Network *network = [[Network alloc] init];
    [network networkWithAction:@"uploadLiveState" params:@{@"userId":config.userId,@"userIsLiveing":@"0"} success:^(NSDictionary *data) {
    } failure:^(NSDictionary *data) {
    } view:nil];
    config.userIsLiveing = @"0";
}

//前后摄像头
- (void)cameraButtonClick:(UIButton *)button {
    button.selected = !button.isSelected;
    _liveSession.devicePosition = button.isSelected ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    _currentPosition = _liveSession.devicePosition;
}
//美颜
- (void)skinButtonClick:(UIButton *)button {
    button.selected = !button.isSelected;
    [_liveSession setEnableSkin:button.isSelected];
}
- (IBAction)flashButtonClick:(UIButton *)button {
    button.selected = !button.isSelected;
    _liveSession.torchMode = button.isSelected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
}

#pragma mark - 聊天
- (void)startChat {
    
    MyConfig *config = [MyConfig shared];
    
    Network *network = [[Network alloc] init];
    [network networkWithAction:@"uploadLiveState" params:@{@"userId":config.userId,@"userIsLiveing":@"1"} success:^(NSDictionary *data) {
    } failure:^(NSDictionary *data) {
    } view:nil];
    config.userIsLiveing = @"1";
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_handle closeFile];
}

@end
