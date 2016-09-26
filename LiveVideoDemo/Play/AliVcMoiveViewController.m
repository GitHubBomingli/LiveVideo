//
//  TBMoiveViewController.m
//  PlayerTest
//
//  Created by shiping chen on 15/9/25.
//  Copyright © 2015年 shiping chen. All rights reserved.
//

#import "AliVcMoiveViewController.h"

#import <AliyunPlayerSDK/AliVcMediaPlayer.h>

#import <MediaPlayer/MediaPlayer.h>

#import <AVFoundation/AVAudioSession.h>
#import "Reachability.h"

#import "AnimationView.h"

typedef NS_ENUM(NSInteger, GestureType){
    GestureTypeOfNone = 0,
    GestureTypeOfVolume,
    GestureTypeOfBrightness,
    GestureTypeOfProgress,
};

static const CGFloat iPhoneScreenPortraitWidth = 320.f;

@interface TBMoiveViewController ()
{
    NSURL*  mSourceURL;
    NSTimer* mTimer;
    NSTimer* mSeekTimer;
    BOOL replay;
    BOOL bSeeking;
    Reachability *conn;
}

#define VolumeStep 0.02f
#define BrightnessStep 0.02f
#define MovieProgressStep 5.0f

@property (nonatomic, strong) AliVcMediaPlayer* mPlayer;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *mPlayerView;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UISlider *playSlider;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UILabel *playTimeLabel;
@property (nonatomic, strong) UILabel *remainTimeLaber;
@property (nonatomic, strong) UIButton *seekForwardButton;
@property (nonatomic, strong) UIButton *seekBackwardButton;
@property (nonatomic, strong) UIView *activityBackgroundView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) Reachability *conn;

@property (nonatomic,assign)NSTimeInterval currentPlayPos;
@property (nonatomic,assign)CGFloat systemBrightness;
@property (nonatomic,assign)GestureType gestureType;
@property (nonatomic,assign)CGPoint originalLocation;
@property (nonatomic,strong)UIImageView *brightnessView;
@property (nonatomic,strong)UIProgressView *brightnessProgress;
@property (nonatomic,strong)UIView *progressTimeView;
@property (nonatomic,strong)UIImageView *prgForwardView;
@property (nonatomic,strong)UIImageView *prgBackwardView;
@property (nonatomic,strong)UILabel *progressTimeLable;
@property (nonatomic,assign)CGFloat progressValue;

/**
 *  聊天、动画等视图
 */
@property (nonatomic, strong) AnimationView *animationView;

@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation TBMoiveViewController
@synthesize mPlayer;
@synthesize topBar;
@synthesize mPlayerView;
@synthesize bottomBar;
@synthesize playSlider;
@synthesize playBtn;
@synthesize volumeView;
@synthesize doneBtn;
@synthesize playTimeLabel;
@synthesize remainTimeLaber;
@synthesize seekBackwardButton;
@synthesize seekForwardButton;
@synthesize activityBackgroundView;
@synthesize activityIndicator;

@synthesize barColor;
@synthesize barHeight;
@synthesize seekTimeSpan;
@synthesize timeRemainingDecrements;
@synthesize fadeDelay;
@synthesize conn;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    self.view.backgroundColor = [UIColor blackColor];
    barHeight = 0.f;
    barColor = [UIColor colorWithRed:0.000 green:0.892 blue:1.000 alpha:1.000];
    fadeDelay = 5.0f;
    timeRemainingDecrements = YES;
    seekTimeSpan = 10000;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [self PlayMoive];
    
    
    //add network notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
    self.conn = [Reachability reachabilityForInternetConnection];
    [self.conn startNotifier];
    
    
    [self.view addSubview:self.backBtn];
    
    [self.view addSubview:self.animationView];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
}

- (AnimationView *)animationView {
    if (_animationView == nil) {

        _animationView = [[AnimationView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _animationView.backgroundColor = [UIColor clearColor];
        [_animationView.backBtn addTarget:self action:@selector(DonePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
        rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        [_animationView addGestureRecognizer:rightSwipe];
    }
    return _animationView;
}

- (UIButton *)backBtn {
    if (_backBtn == nil) {
        _backBtn = [[UIButton alloc] init];
        _backBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 38, [UIScreen mainScreen].bounds.size.height - 38, 30, 30);
        [_backBtn setTitle:@"╳" forState:UIControlStateNormal];
        [_backBtn setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _backBtn.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.6];
        _backBtn.titleLabel.shadowOffset = CGSizeMake(1.f, 1.f);
        [_backBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        _backBtn.layer.cornerRadius = 15;
        _backBtn.layer.masksToBounds = YES;
        [_backBtn addTarget:self action:@selector(DonePressed:) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.hidden = YES;
    }
    return _backBtn;
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

- (void)networkStateChange
{
    //网络流判断网络状态
    if (mSourceURL && ![mSourceURL isFileURL]) {
        [self checkNetworkState];
    }
}

- (void)checkNetworkState
{
    // 1.检测wifi状态
    Reachability *wifi = [Reachability reachabilityForLocalWiFi];
    
    // 2.检测手机是否能上网络(WIFI\3G\2.5G)
    Reachability *conn = [Reachability reachabilityForInternetConnection];
    
    // 3.判断网络状态
    if ([wifi currentReachabilityStatus] != NotReachable) { // 有wifi
        NSLog(@"有wifi");
        
    } else if ([conn currentReachabilityStatus] != NotReachable) { // 没有使用wifi, 使用手机自带网络进行上网
        NSLog(@"使用手机自带网络进行上网");
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                        message:@"没有wifi连接，是否重新连接播放"
//                                                       delegate:self
//                                              cancelButtonTitle:@"取消"
//                                              otherButtonTitles:@"重新连接",nil];
//        
//        [alert show];
//        
//        if (mPlayer) {
//            [mPlayer stop];
//        }
        
    } else { // 没有网络
        
        NSLog(@"没有网络");
    }
}


- (void)becomeActive{
    [self EnterForeGroundPlayVideo_live_pause];
}

- (void)resignActive{
    [self EnterBackGroundPauseVideo_live_pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) SetMoiveSource:(NSURL*)url
{
    mSourceURL = [url copy];
}

- (void) PlayMoive
{
    if(mSourceURL == nil)
        return;
    
    //new the player
    mPlayer = [[AliVcMediaPlayer alloc] init];
    
    //add player controls
    [self setupControls];
    
    //create player, and  set the show view
    [mPlayer create:mPlayerView];
    
    //register notifications
    [self addPlayerObserver];
    
    mPlayer.mediaType = MediaType_AUTO;
    mPlayer.timeout = 25000;
    mPlayer.dropBufferDuration = 8000;
    
    //timer to update player progress
    mTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(UpdatePrg:) userInfo:nil repeats:YES];
    mSeekTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(SeekTimer:) userInfo:nil repeats:YES];
    [mTimer fire];
    [mSeekTimer fire];
    
    replay = NO;
    bSeeking = NO;
    
    //prepare and play the video
    AliVcMovieErrorCode err = [mPlayer prepareToPlay:mSourceURL];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"preprare failed,error code is %d",(int)err);
        return;
    }
    
    err = [mPlayer play];
    if(err != ALIVC_SUCCESS) {
        NSLog(@"play failed,error code is %d",(int)err);
        return;
    }
    
    [self performSelector:@selector(hideControls:) withObject:nil afterDelay:fadeDelay];
    
    [self showLoadingIndicators];
}

- (void) setupControls
{
    //视频显示区域
    mPlayerView = [[UIView alloc] init];
    mPlayerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mPlayerView];
    
    //顶部栏
    topBar = [[UIView alloc] init];
    topBar.backgroundColor = barColor;
    topBar.alpha = 1.0f;
    [self.view addSubview:topBar];
    
    //底部区域栏
    bottomBar = [[UIView alloc] init];
    bottomBar.backgroundColor = barColor;
    bottomBar.alpha = 1.0f;
    [self.view addSubview:bottomBar];
    
    //顶部栏退出按钮
    doneBtn = [[UIButton alloc] init];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    [doneBtn setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake(1.f, 1.f);
    [doneBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
    [doneBtn addTarget:self action:@selector(DonePressed:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:doneBtn];
    
    //顶部栏播放进度slider
    playSlider = [[UISlider alloc] init];
    playSlider.value = 0.f;
    playSlider.continuous = YES;
    [playSlider addTarget:self action:@selector(durationSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [playSlider addTarget:self action:@selector(durationSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [playSlider addTarget:self action:@selector(durationSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
//    [topBar addSubview:playSlider];
    [bottomBar addSubview:playSlider];
    
    //播放时间
    playTimeLabel = [[UILabel alloc] init];
    playTimeLabel.backgroundColor = [UIColor clearColor];
    playTimeLabel.font = [UIFont systemFontOfSize:12.f];
    playTimeLabel.textColor = [UIColor lightTextColor];
    playTimeLabel.textAlignment = NSTextAlignmentRight;
    playTimeLabel.text = @"00:00:00";
    playTimeLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    playTimeLabel.layer.shadowRadius = 1.f;
    playTimeLabel.layer.shadowOffset = CGSizeMake(1.f, 1.f);
    playTimeLabel.layer.shadowOpacity = 0.8f;
//    [topBar addSubview:playTimeLabel];
    [bottomBar addSubview:playTimeLabel];
    
    //剩余时间
    remainTimeLaber = [[UILabel alloc] init];
    remainTimeLaber.backgroundColor = [UIColor clearColor];
    remainTimeLaber.font = [UIFont systemFontOfSize:12.f];
    remainTimeLaber.textColor = [UIColor lightTextColor];
    remainTimeLaber.textAlignment = NSTextAlignmentLeft;
    remainTimeLaber.text = @"00:00:00";
    remainTimeLaber.layer.shadowColor = [UIColor blackColor].CGColor;
    remainTimeLaber.layer.shadowRadius = 1.f;
    remainTimeLaber.layer.shadowOffset = CGSizeMake(1.f, 1.f);
    remainTimeLaber.layer.shadowOpacity = 0.8f;
//    [topBar addSubview:remainTimeLaber];
    [bottomBar addSubview:remainTimeLaber];
    
    //底部播放按钮
    playBtn = [[UIButton alloc] init];
    [playBtn setImage:[UIImage imageNamed:@"moviePause.png"] forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@"moviePlay.png"] forState:UIControlStateSelected];
    [playBtn setSelected:NO];
    playBtn.hidden = NO;
    [playBtn addTarget:self action:@selector(playPausePressed:) forControlEvents:UIControlEventTouchDown];
    [bottomBar addSubview:playBtn];
    
//    //底部音量控制slider
//    volumeView = [[MPVolumeView alloc] init];
//    [volumeView setShowsRouteButton:NO];
//    [volumeView setShowsVolumeSlider:YES];
//    [bottomBar addSubview:volumeView];
    
//    //底部快进按钮
//    seekForwardButton = [[UIButton alloc] init];
//    [seekForwardButton setImage:[UIImage imageNamed:@"movieForward.png"] forState:UIControlStateNormal];
//    [seekForwardButton setImage:[UIImage imageNamed:@"movieForwardSelected.png"] forState:UIControlStateSelected];
//    [seekForwardButton addTarget:self action:@selector(seekForwardPressed:) forControlEvents:UIControlEventTouchUpInside];
//    //seekForwardButton.enabled = NO;
//    seekForwardButton.hidden = NO;
//    [bottomBar addSubview:seekForwardButton];
    
    //底部快退按钮
//    seekBackwardButton = [[UIButton alloc] init];
//    [seekBackwardButton setImage:[UIImage imageNamed:@"movieBackward.png"] forState:UIControlStateNormal];
//    [seekBackwardButton setImage:[UIImage imageNamed:@"movieBackwardSelected.png"] forState:UIControlStateSelected];
//    [seekBackwardButton addTarget:self action:@selector(seekBackwardPressed:) forControlEvents:UIControlEventTouchUpInside];
//    //seekBackwardButton.enabled = NO;
//    seekBackwardButton.hidden = NO;
//    [bottomBar addSubview:seekBackwardButton];
    
    //缓冲指示
    activityBackgroundView = [[UIView alloc] init];
    [activityBackgroundView setBackgroundColor:[UIColor clearColor]];
    activityBackgroundView.alpha = 0.f;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.alpha = 0.f;
    activityIndicator.hidesWhenStopped = YES;
    
    //亮度调节图标
    _brightnessView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2, self.view.frame.size.height/2, 125, 125)];
    _brightnessView.image = [UIImage imageNamed:@"video_brightness_bg.png"];
    _brightnessProgress = [[UIProgressView alloc]initWithFrame:CGRectMake(_brightnessView.frame.size.width/2, _brightnessView.frame.size.height/2-30, 80, 10)];
    _brightnessProgress.trackImage = [UIImage imageNamed:@"video_num_bg.png"];
    _brightnessProgress.progressImage = [UIImage imageNamed:@"video_num_front.png"];
    _brightnessProgress.progress = [UIScreen mainScreen].brightness;
    [_brightnessView addSubview:_brightnessProgress];
    [self.view addSubview:_brightnessView];
    _brightnessView.alpha = 0;
    
    //手势进度控制
    _progressTimeView = [[UIView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2-100, self.view.bounds.size.height/2-30, 200, 30)];
    _prgForwardView = [[UIImageView alloc]initWithFrame:CGRectMake(82,5,36,30)];
    _prgForwardView.image = [UIImage imageNamed:@"movieForward.png"];
    _prgBackwardView = [[UIImageView alloc]initWithFrame:CGRectMake(82,5,36,30)];
    _prgBackwardView.image = [UIImage imageNamed:@"movieBackward.png"];
    
    _progressTimeView.backgroundColor = [UIColor clearColor];
    _progressTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 200, 60)];
    _progressTimeLable.textAlignment = NSTextAlignmentCenter;
    _progressTimeLable.textColor = [UIColor whiteColor];
    _progressTimeLable.backgroundColor = [UIColor clearColor];
    _progressTimeLable.font = [UIFont systemFontOfSize:25];
    _progressTimeLable.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    _progressTimeLable.shadowOffset = CGSizeMake(1.0, 1.0);
    [_progressTimeView addSubview:_progressTimeLable];
    [_progressTimeView addSubview:_prgForwardView];
    [_progressTimeView addSubview:_prgBackwardView];
    _prgForwardView.hidden = YES;
    _prgBackwardView.hidden = YES;
    _progressTimeView.hidden = YES;
    [self.view addSubview:_progressTimeView];
    
    [self adjustLayoutsubViews];
}

- (void)showLoadingIndicators {
    [self.view addSubview:activityBackgroundView];
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    [UIView animateWithDuration:0.2f animations:^{
        activityBackgroundView.alpha = 1.f;
        activityIndicator.alpha = 1.f;
    }];
}

- (void)hideLoadingIndicators {
    [UIView animateWithDuration:0.2f delay:0.0 options:0 animations:^{
        self.activityBackgroundView.alpha = 0.0f;
        self.activityIndicator.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.activityBackgroundView removeFromSuperview];
        [self.activityIndicator removeFromSuperview];
    }];
}

- (void)DonePressed:(UIButton *)button {
    [mTimer invalidate];
    mTimer = nil;
    
//    [seekBackwardButton setSelected:NO];
//    [seekForwardButton setSelected:NO];
    [mSeekTimer invalidate];
    mSeekTimer = nil;
    
    if(mPlayer != nil)
        [mPlayer destroy];
    
    [self removePlayerObserver];
    
    mPlayer = nil;
    mSourceURL = nil;

    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)seekForwardPressed:(UIButton *)button {
//    //[mPlayer seekTo:mPlayer.currentPosition+seekTimeSpan];
//    button.selected = !button.selected;
//    self.seekBackwardButton.selected = NO;
//    if (button.selected) {
//        [self showControls:nil];
//    }
//    else {
//        [self performSelector:@selector(hideControls:) withObject:nil afterDelay:fadeDelay];
//    }
//}

//- (void)seekBackwardPressed:(UIButton *)button {
//    //[mPlayer seekTo:mPlayer.currentPosition-seekTimeSpan];
//    button.selected = !button.selected;
//    self.seekForwardButton.selected = NO;
//    if (button.selected) {
//        [self showControls:nil];
//    }
//    else {
//        [self performSelector:@selector(hideControls:) withObject:nil afterDelay:fadeDelay];
//    }
//}

- (float)iOSVersion {
    static float version = 0.f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [[[UIDevice currentDevice] systemVersion] floatValue];
    });
    return version;
}

- (void)adjustLayoutsubViews {
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    float iosVersion = [self iOSVersion];
    if(iosVersion < 8.0) {
        if(UIDeviceOrientationIsLandscape(orientation) || orientation == UIDeviceOrientationUnknown ||
           orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown) {
            //landscape assume  width > height
            if(width<height) {
                CGFloat temp = width;
                width = height;
                height = temp;
            }
        }
    }
    
    mPlayerView.frame = CGRectMake(0,0,width,height);
    
    //when change the view size, need to reset the view to the play.
    mPlayer.view = mPlayerView;
    
    double pos = mPlayer.currentPosition; 
    
    CGFloat paddingFromBezel = width <= iPhoneScreenPortraitWidth ? 10.f : 20.f;
    CGFloat paddingBetweenButtons = width <= iPhoneScreenPortraitWidth ? 10.f : 30.f;
    CGFloat paddingBetweenLabelsAndSlider = 10.f;
    CGFloat playWidth = 18.f;
    CGFloat playHeight = 22.f;
    CGFloat labelWidth = 60.f;
    CGFloat sliderHeight = 34.f;
    
    topBar.frame = CGRectMake(0, 0, width, barHeight);
    doneBtn.frame = CGRectMake(paddingFromBezel, 0, 40.f, barHeight);
    playTimeLabel.frame = CGRectMake(doneBtn.frame.origin.x + doneBtn.frame.size.width + paddingBetweenButtons, 0, labelWidth, barHeight);
    remainTimeLaber.frame = CGRectMake(width - paddingFromBezel-labelWidth,0,labelWidth,barHeight);
    
    CGFloat timeRemainingX = remainTimeLaber.frame.origin.x;
    CGFloat timeElapsedX = playTimeLabel.frame.origin.x;
    CGFloat sliderWidth = ((timeRemainingX - paddingBetweenLabelsAndSlider) - (timeElapsedX + remainTimeLaber.frame.size.width + paddingBetweenLabelsAndSlider));
    playSlider.frame = CGRectMake(timeElapsedX + remainTimeLaber.frame.size.width + paddingBetweenLabelsAndSlider, barHeight/2 - sliderHeight/2, sliderWidth, sliderHeight);
    
    CGFloat bottomHeight = barHeight;
    bottomBar.frame = CGRectMake(0, height - bottomHeight, width, bottomHeight);
//    playBtn.frame = CGRectMake(width/2-playWidth/2, bottomHeight/2 - playHeight/2, playWidth, playHeight);
    playBtn.frame = CGRectMake(paddingFromBezel, 0, 40.f, barHeight);
    CGFloat seekWidth = 36.f;
    CGFloat seekHeight = 20.f;
    CGFloat paddingBetweenPlaybackButtons = width <= iPhoneScreenPortraitWidth ? 20.f : 30.f;
    
//    seekForwardButton.frame = CGRectMake(playBtn.frame.origin.x + playBtn.frame.size.width + paddingBetweenPlaybackButtons, barHeight/2 - seekHeight/2 + 1.f, seekWidth, seekHeight);
//    seekBackwardButton.frame = CGRectMake(playBtn.frame.origin.x - paddingBetweenPlaybackButtons - seekWidth, barHeight/2 - seekHeight/2 + 1.f, seekWidth, seekHeight);
    
//    //hide volume view in iPhone's portrait orientation
//    if (width <= iPhoneScreenPortraitWidth) {
//        volumeView.alpha = 0.f;
//    } else {
//        volumeView.alpha = 1.f;
//        CGFloat volumeHeight = 20.f;
//        CGFloat volumeWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 210.f : 80.f;
//        volumeView.frame = CGRectMake(paddingFromBezel, barHeight/2 - volumeHeight/2, volumeWidth, volumeHeight);
//    }
    
    _brightnessView.frame = CGRectMake(width/2-63, height/2-63, 125, 125);
    _brightnessProgress.frame = CGRectMake(25, 100, 80, 10);
    
    _progressTimeView.frame = CGRectMake(width/2-100, height/2-15, 200, 30);
    
    activityBackgroundView.frame = CGRectMake(0,barHeight,width,height-barHeight*2);
    activityIndicator.frame = CGRectMake(0,barHeight,width,height-barHeight*2);
}

-(void) EnterBackGroundPauseVideo_live_pause
{
    if(mPlayer) {
        [mPlayer pause];
    }
    
    [UIScreen mainScreen].brightness = _systemBrightness;
}

-(void) EnterForeGroundPlayVideo_live_pause
{
    if(mPlayer) {
        [mPlayer play];
        
        [self showControls:nil];
        [playBtn setSelected:NO];
    }
    
    [UIScreen mainScreen].brightness = _brightnessProgress.progress;
}

-(void) EnterBackGroundPauseVideo_live_restart
{
    if(mPlayer) {
        if (mPlayer.duration<=0) {
            [mPlayer stop];
        }
        else {
            _currentPlayPos = mPlayer.currentPosition;
            [mPlayer pause];
        }
    }
    
    [UIScreen mainScreen].brightness = _systemBrightness;
}

-(void) EnterForeGroundPlayVideo_live_restart
{
    if(mPlayer) {
        if (mPlayer.duration<=0) {
            [mPlayer prepareToPlay:mSourceURL];
            [mPlayer play];
            [self showLoadingIndicators];
        }
        else {
            [mPlayer play];
            [mPlayer seekTo:_currentPlayPos];
        }
        
        [self showControls:nil];
        [playBtn setSelected:NO];
    }
    
    [UIScreen mainScreen].brightness = _brightnessProgress.progress;
}

-(void)replay
{
    [mPlayer prepareToPlay:mSourceURL];
    replay = NO;
    bSeeking = NO;
    [mPlayer play];
    [playBtn setSelected:NO];
}

- (void)playPausePressed:(UIButton *)button {
    
    if(playBtn.selected) {
        if(replay) {
            [mPlayer prepareToPlay:mSourceURL];
            replay = NO;
            bSeeking = NO;
        }
        
        [mPlayer play];
        [playBtn setSelected:NO];
    }
    else {
        [mPlayer pause];
        [playBtn setSelected:YES];
    }
    [self performSelector:@selector(hideControls:) withObject:nil afterDelay:fadeDelay];
}

- (void)durationSliderTouchBegan:(UISlider *)slider {
    bSeeking = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControls:) object:nil];
}

- (void)durationSliderTouchEnded:(UISlider *)slider {
    [mPlayer seekTo:playSlider.value];
    [self performSelector:@selector(hideControls:) withObject:nil afterDelay:fadeDelay];
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    currentTime = currentTime / 1000.0;
    totalTime = totalTime / 1000.0;
    double minutesElapsed = floor(fmod(currentTime/ 60.0,60.0));
    double secondsElapsed = floor(fmod(currentTime,60.0));
    double hourElapsed = floor(currentTime/ 3600.0);
    
    playTimeLabel.text = [NSString stringWithFormat:@"%02.0f:%02.0f:%02.0f", hourElapsed,minutesElapsed, secondsElapsed];
    
    double minutesRemaining;
    double secondsRemaining;
    double hourRemaining;
    if (timeRemainingDecrements) {
        hourRemaining = floor((totalTime - currentTime)/ 3600.0);
        minutesRemaining = floor(fmod((totalTime - currentTime)/ 60.0,60.0));
        secondsRemaining = floor(fmod((totalTime - currentTime),60.0));
    } else {
        minutesRemaining = floor(fmod(totalTime/ 60.0,60.0));
        secondsRemaining = floor(fmod(totalTime,60.0));
        hourRemaining = floor(totalTime/ 3600.0);
    }
    remainTimeLaber.text = timeRemainingDecrements ? [NSString stringWithFormat:@"-%02.0f:%02.0f:%02.0f", hourRemaining,minutesRemaining, secondsRemaining] : [NSString stringWithFormat:@"%02.0f:%02.0f:%02.0f", hourRemaining,minutesRemaining, secondsRemaining];
}

-(void)SeekTimer:(NSTimer *)timer {
    
//    if(mPlayer) {
//        if(seekForwardButton.selected)
//            [mPlayer seekTo:mPlayer.currentPosition+seekTimeSpan];
//        if(seekBackwardButton.selected)
//            [mPlayer seekTo:mPlayer.currentPosition-seekTimeSpan];
//    }
}

#define PROP_DOUBLE_VIDEO_DECODE_FRAMES_PER_SECOND  10001
#define PROP_DOUBLE_VIDEO_OUTPUT_FRAMES_PER_SECOND  10002

#define FFP_PROP_DOUBLE_OPEN_FORMAT_TIME                 18001
#define FFP_PROP_DOUBLE_FIND_STREAM_TIME                 18002
#define FFP_PROP_DOUBLE_OPEN_STREAM_TIME                 18003
#define FFP_PROP_DOUBLE_1st_VFRAME_SHOW_TIME             18004
#define FFP_PROP_DOUBLE_1st_AFRAME_SHOW_TIME             18005
#define FFP_PROP_DOUBLE_1st_VPKT_GET_TIME                18006
#define FFP_PROP_DOUBLE_1st_APKT_GET_TIME                18007
#define FFP_PROP_DOUBLE_1st_VDECODE_TIME                 18008
#define FFP_PROP_DOUBLE_1st_ADECODE_TIME                 18009
#define FFP_PROP_DOUBLE_DECODE_TYPE                 	 18010

#define FFP_PROP_DOUBLE_LIVE_DISCARD_DURATION            18011
#define FFP_PROP_DOUBLE_LIVE_DISCARD_CNT                 18012
#define FFP_PROP_DOUBLE_DISCARD_VFRAME_CNT               18013

#define FFP_PROP_DOUBLE_RTMP_OPEN_DURATION               18040
#define FFP_PROP_DOUBLE_RTMP_OPEN_RTYCNT                 18041
#define FFP_PROP_DOUBLE_RTMP_NEGOTIATION_DURATION        18042
#define FFP_PROP_DOUBLE_HTTP_OPEN_DURATION               18060
#define FFP_PROP_DOUBLE_HTTP_OPEN_RTYCNT                 18061
#define FFP_PROP_DOUBLE_HTTP_REDIRECT_CNT                18062
#define FFP_PROP_DOUBLE_TCP_CONNECT_TIME                 18080
#define FFP_PROP_DOUBLE_TCP_DNS_TIME                     18081

//decode type
#define     FFP_PROPV_DECODER_UNKNOWN                   0
#define     FFP_PROPV_DECODER_AVCODEC                   1
#define     FFP_PROPV_DECODER_MEDIACODEC                2
#define     FFP_PROPV_DECODER_VIDEOTOOLBOX              3

#define FFP_PROP_INT64_VIDEO_CACHED_DURATION            20005
#define FFP_PROP_INT64_AUDIO_CACHED_DURATION            20006
#define FFP_PROP_INT64_VIDEO_CACHED_BYTES               20007
#define FFP_PROP_INT64_AUDIO_CACHED_BYTES               20008
#define FFP_PROP_INT64_VIDEO_CACHED_PACKETS             20009
#define FFP_PROP_INT64_AUDIO_CACHED_PACKETS             20010

-(void) testInfo
{
    if (mPlayer == nil) {
        return;
    }
    
    double video_decode_fps = [mPlayer getPropertyDouble:PROP_DOUBLE_VIDEO_DECODE_FRAMES_PER_SECOND defaultValue:0];
    double video_render_fps = [mPlayer getPropertyDouble:PROP_DOUBLE_VIDEO_OUTPUT_FRAMES_PER_SECOND defaultValue:0];
    printf("video_decode_fps is %lf, video_render_fps is %lf\n",video_decode_fps,video_render_fps);
    
    return;
    
    double open_format_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_OPEN_FORMAT_TIME defaultValue:0];
    double find_stream_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_FIND_STREAM_TIME defaultValue:0];
    double open_stream_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_OPEN_STREAM_TIME defaultValue:0];
    printf("open_format_time is %lf, find_stream_time is %lf, open_stream_time is %lf\n",open_format_time,find_stream_time,open_stream_time);
    
    double video_first_decode_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_1st_VDECODE_TIME defaultValue:0];
    double video_first_get_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_1st_VPKT_GET_TIME defaultValue:0];
    double video_first_show_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_1st_VFRAME_SHOW_TIME defaultValue:0];
    printf("video_first_decode_time is %lf, video_first_get_time is %lf, video_first_show_time is %lf\n",video_first_decode_time,video_first_get_time,video_first_show_time);
    
    double audio_first_decode_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_1st_ADECODE_TIME defaultValue:0];
    double audio_first_get_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_1st_APKT_GET_TIME defaultValue:0];
    double audio_first_show_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_1st_AFRAME_SHOW_TIME defaultValue:0];
    double video_decode_type = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_DECODE_TYPE defaultValue:0];
    printf("audio_first_decode_time is %lf, audio_first_get_time is %lf, audio_first_show_time is %lf,video_decode_type is %lf\n",audio_first_decode_time,audio_first_get_time,audio_first_show_time,video_decode_type);
    
    double rtmp_open_duration = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_RTMP_OPEN_DURATION defaultValue:0];
    double rtmp_open_retry_count = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_RTMP_OPEN_RTYCNT defaultValue:0];
    double rtmp_negotiation_duration = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_RTMP_NEGOTIATION_DURATION defaultValue:0];
    printf("rtmp_open_duration is %lf, rtmp_open_retry_count is %lf, rtmp_negotiation_duration is %lf\n",rtmp_open_duration,rtmp_open_retry_count,rtmp_negotiation_duration);
    
    double http_open_duration = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_HTTP_OPEN_DURATION defaultValue:0];
    double http_open_retry_count = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_HTTP_OPEN_RTYCNT defaultValue:0];
    double http_redirect_count = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_HTTP_REDIRECT_CNT defaultValue:0];
    printf("http_open_duration is %lf, http_open_retry_count is %lf, http_redirect_count is %lf\n",http_open_duration,http_open_retry_count,http_redirect_count);
    
    double tcp_connect_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_TCP_CONNECT_TIME defaultValue:0];
    double tcp_dns_time = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_TCP_DNS_TIME defaultValue:0];
    printf("tcp_connect_time is %lf, tcp_dns_time is %lf\n",tcp_connect_time,tcp_dns_time);
    
    int64_t video_cached_duration = [mPlayer getPropertyLong:FFP_PROP_INT64_VIDEO_CACHED_DURATION defaultValue:0];
    int64_t video_cached_bytes = [mPlayer getPropertyLong:FFP_PROP_INT64_VIDEO_CACHED_BYTES defaultValue:0];
    int64_t video_cached_packets = [mPlayer getPropertyLong:FFP_PROP_INT64_VIDEO_CACHED_PACKETS defaultValue:0];
    printf("video_cached_duration is %lld, video_cached_bytes is %lld, video_cached_packets is %lld\n",video_cached_duration,video_cached_bytes,video_cached_packets);
    
    int64_t audio_cached_duration = [mPlayer getPropertyLong:FFP_PROP_INT64_AUDIO_CACHED_DURATION defaultValue:0];
    int64_t audio_cached_bytes = [mPlayer getPropertyLong:FFP_PROP_INT64_AUDIO_CACHED_BYTES defaultValue:0];
    int64_t audio_cached_packets = [mPlayer getPropertyLong:FFP_PROP_INT64_AUDIO_CACHED_PACKETS defaultValue:0];
    printf("audio_cached_duration is %lld, audio_cached_bytes is %lld, audio_cached_packets is %lld\n",audio_cached_duration,audio_cached_bytes,audio_cached_packets);
    
    double drop_frame_count = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_LIVE_DISCARD_CNT defaultValue:0];
    double drop_v_frame_count = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_DISCARD_VFRAME_CNT defaultValue:0];
    double drop_frame_duration = [mPlayer getPropertyDouble:FFP_PROP_DOUBLE_LIVE_DISCARD_DURATION defaultValue:0];
    printf("drop_frame_count is %lf, drop_v_frame_count is %lf, drop_frame_duration is %lf\n",drop_frame_count,drop_v_frame_count,drop_frame_duration);
}


-(void)UpdatePrg:(NSTimer *)timer{
    
    //[self testInfo];
    
    //when seeking, do not update the slider
    if(bSeeking)
        return;
    
    playSlider.value = mPlayer.currentPosition;
    
    double currentTime = floor(playSlider.value);
    double totalTime = floor(mPlayer.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}

- (void)showControls:(void(^)(void))completion {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControls:) object:nil];
    [bottomBar setNeedsDisplay];
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        bottomBar.alpha = 1.f;
        topBar.alpha = 1.f;
    } completion:^(BOOL finished) {
        if (completion)
            completion();
        [self performSelector:@selector(hideControls:) withObject:nil afterDelay:fadeDelay];
    }];
}

- (void)hideControls:(void(^)(void))completion {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControls:) object:nil];
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        bottomBar.alpha = 0.f;
        topBar.alpha = 0.f;
    } completion:^(BOOL finished) {
        if (completion)
            completion();
    }];
}

//recieve prepared notification
- (void)OnVideoPrepared:(NSNotification *)notification {
    
    NSTimeInterval duration = mPlayer.duration;
    playSlider.maximumValue = duration;
    playSlider.value = mPlayer.currentPosition;
    
    [self hideLoadingIndicators];
    
    if(duration == 0){
//        seekForwardButton.hidden = YES;
//        seekBackwardButton.hidden = YES;
        playBtn.hidden = YES;
        playSlider.hidden = YES;
        playTimeLabel.hidden = YES;
        remainTimeLaber.hidden = YES;
    }
}

//recieve error notification
- (void)OnVideoError:(NSNotification *)notification {
    replay = YES;
    [playBtn setSelected:YES];
    [self showControls:nil];
    
//    [seekBackwardButton setSelected:NO];
//    [seekForwardButton setSelected:NO];
//    [self hideLoadingIndicators];
    
    NSString* error_msg = @"未知错误";
    AliVcMovieErrorCode error_code = mPlayer.errorCode;
    
    switch (error_code) {
        case ALIVC_ERR_FUNCTION_DENIED:
            error_msg = @"未授权";
            break;
        case ALIVC_ERR_ILLEGALSTATUS:
            error_msg = @"非法的播放流程";
            break;
        case ALIVC_ERR_INVALID_INPUTFILE:
            error_msg = @"无法打开";
            [self hideLoadingIndicators];
            break;
        case ALIVC_ERR_NO_INPUTFILE:
            error_msg = @"无输入文件";
            [self hideLoadingIndicators];
            break;
        case ALIVC_ERR_NO_NETWORK:
            error_msg = @"网络连接失败";
            break;
        case ALIVC_ERR_NO_SUPPORT_CODEC:
            error_msg = @"不支持的视频编码格式";
            [self hideLoadingIndicators];
            break;
        case ALIVC_ERR_NO_VIEW:
            error_msg = @"无显示窗口";
            [self hideLoadingIndicators];
            break;
        case ALIVC_ERR_NO_MEMORY:
            error_msg = @"内存不足";
            break;
        case ALIVC_ERR_UNKOWN:
            error_msg = @"未知错误";
            break;
        default:
            break;
    }
    
    //NSLog(error_msg);
    
    //the error message is important when error_cdoe > 500
    if(error_code > 500 || error_code == ALIVC_ERR_FUNCTION_DENIED) {
        
        [mPlayer reset];
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"播放器错误" message:error_msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alter show];
        return;
    }
    
    if(error_code == ALIVC_ERR_NO_NETWORK) {
        
        [mPlayer pause];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                        message:error_msg
                                                       delegate:self
                                              cancelButtonTitle:@"等待"
                                              otherButtonTitles:@"重新连接",nil];
        
        [alert show];
    }
        
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //[self showLoadingIndicators];
    
    if (buttonIndex == 0) {
        [mPlayer play];
    }
    //reconnect
    else if(buttonIndex == 1) {
        [mPlayer stop];
        [self showLoadingIndicators];
        replay = YES;
        [self replay];
    }
}

//recieve finish notification
- (void)OnVideoFinish:(NSNotification *)notification {
    replay = YES;
    [playBtn setSelected:YES];
    [self showControls:nil];
    
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"播放完成" message:@"播放完成" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alter show];
    
//    [seekBackwardButton setSelected:NO];
//    [seekForwardButton setSelected:NO];
}

//recieve seek finish notification
- (void)OnSeekDone:(NSNotification *)notification {
    bSeeking = NO;
}

//recieve start cache notification
- (void)OnStartCache:(NSNotification *)notification {
    [self showLoadingIndicators];
}

//recieve end cache notification
- (void)OnEndCache:(NSNotification *)notification {
    [self hideLoadingIndicators];
}

-(void)addPlayerObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoPrepared:)
                                                 name:AliVcMediaPlayerLoadDidPreparedNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoError:)
                                                 name:AliVcMediaPlayerPlaybackErrorNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnVideoFinish:)
                                                 name:AliVcMediaPlayerPlaybackDidFinishNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnSeekDone:)
                                                 name:AliVcMediaPlayerSeekingDidFinishNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnStartCache:)
                                                 name:AliVcMediaPlayerStartCachingNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnEndCache:)
                                                 name:AliVcMediaPlayerEndCachingNotification object:mPlayer];
}

-(void)removePlayerObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerLoadDidPreparedNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerPlaybackErrorNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerPlaybackDidFinishNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerSeekingDidFinishNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerStartCachingNotification object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliVcMediaPlayerEndCachingNotification object:mPlayer];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self adjustLayoutsubViews];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    _originalLocation = CGPointZero;
    _progressValue = 0;
   // _ProgressBeginToMove = _movieProgressSlider.value;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_gestureType == GestureTypeOfNone ) {
        [self showControls:nil];
    }else if (_gestureType == GestureTypeOfProgress){
        _gestureType = GestureTypeOfNone;
        _progressTimeView.hidden = YES;
        
        [mPlayer seekTo:mPlayer.currentPosition+_progressValue*1000];
        
        _progressValue = 0;
//    }else if (_gestureType == GestureTypeOfVolume) {
//        [bottomBar addSubview:volumeView];
//        _gestureType = GestureTypeOfNone;
    }
    else {
        _progressValue = 0;
        _gestureType = GestureTypeOfNone;
        _progressTimeView.hidden = YES;
        if (_brightnessView.alpha) {
            [UIView animateWithDuration:1 animations:^{
                _brightnessView.alpha = 0;
            }];
        }
    }
}

- (void)volumeAdd:(CGFloat)step{
    [MPMusicPlayerController applicationMusicPlayer].volume += step;
}

- (void)viewWillAppear:(BOOL)animated{
    _systemBrightness = [UIScreen mainScreen].brightness;
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIScreen mainScreen].brightness = _systemBrightness;
}

- (void)brightnessAdd:(CGFloat)step{
    [UIScreen mainScreen].brightness += step;
    _brightnessProgress.progress = [UIScreen mainScreen].brightness;
}

//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    [super touchesMoved:touches withEvent:event];
////    UITouch *touch = [touches anyObject];
////    CGPoint currentLocation = [touch locationInView:self.view];
////    CGFloat offset_x = currentLocation.x - _originalLocation.x;
////    CGFloat offset_y = currentLocation.y - _originalLocation.y;
////    if (CGPointEqualToPoint(_originalLocation,CGPointZero)) {
////        _originalLocation = currentLocation;
////        return;
////    }
////    _originalLocation = currentLocation;
////    
////    CGFloat width = self.view.frame.size.width;
////    CGFloat height = self.view.frame.size.height;
////    
////    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
////    float iosVersion = [self iOSVersion];
////    if(iosVersion < 8.0) {
////        if(UIDeviceOrientationIsLandscape(orientation) || orientation == UIDeviceOrientationUnknown ||
////           orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown) {
////            //landscape assume  width > height
////            if(width<height) {
////                CGFloat temp = width;
////                width = height;
////                height = temp;
////            }
////        }
////    }
////    
////    if (_gestureType == GestureTypeOfNone) {
////        if ((currentLocation.x > width*0.8) && (ABS(offset_x) <= ABS(offset_y))) {
////            _gestureType = GestureTypeOfVolume;
//////            [volumeView removeFromSuperview];
////        }else if ((currentLocation.x < width*0.2) && (ABS(offset_x) <= ABS(offset_y))) {
////            _gestureType = GestureTypeOfBrightness;
////        }else if ((ABS(offset_x) > ABS(offset_y))) {
////            _gestureType = GestureTypeOfProgress;
////            _progressTimeView.hidden = NO;
////        }
////    }
////    if ((_gestureType == GestureTypeOfProgress) && (ABS(offset_x) > ABS(offset_y))) {
////        if (offset_x > 0) {
////            //NSLog(@"横向向右");
////            _progressValue += 1;
////            _prgBackwardView.hidden = YES;
////            _prgForwardView.hidden = NO;
////        }else{
////            //NSLog(@"横向向左");
////            _progressValue -= 1;
////            _prgBackwardView.hidden = NO;
////            _prgForwardView.hidden = YES;
////        }
////        _progressTimeLable.text = [NSString stringWithFormat:@"[%@ %ds]",_progressValue < 0? @"":@"+",(int)_progressValue];
////        
////    }else if ((_gestureType == GestureTypeOfVolume) && (currentLocation.x > width*0.8) && (ABS(offset_x) <= ABS(offset_y))){
////        if (offset_y > 0){
////            //NSLog(@"右竖向向下");
////            [self volumeAdd:-VolumeStep];
////        }else{
////            //NSLog(@"右竖向向上");
////            [self volumeAdd:VolumeStep];
////        }
////    }else if ((_gestureType == GestureTypeOfBrightness) && (currentLocation.x < width*0.2) && (ABS(offset_x) <= ABS(offset_y))){
////        if (offset_y > 0) {
////            //NSLog(@"左竖向向下");
////            _brightnessView.alpha = 1;
////            [self brightnessAdd:-BrightnessStep];
////        }else{
////            //NSLog(@"左竖向向下");
////            _brightnessView.alpha = 1;
////            [self brightnessAdd:BrightnessStep];
////        }
////    }
//}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void) dealloc
{
    topBar = nil;
    bottomBar = nil;
    playBtn = nil;
    doneBtn = nil;
//    seekForwardButton = nil;
//    seekBackwardButton = nil;
    playSlider = nil;
    playTimeLabel = nil;
    remainTimeLaber = nil;
//    volumeView = nil;
    
   _brightnessView = nil;
   _brightnessProgress = nil;
   _progressTimeView = nil;
   _prgForwardView = nil;
   _prgBackwardView = nil;
   _progressTimeLable = nil;
    
    [self.conn stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
