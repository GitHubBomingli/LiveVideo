//
//  ALivcLiveSession.h
//  LiveCapture
//
//  Created by yly on 16/3/2.
//  Copyright © 2016年 Alibaba Video Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AlivcLConfiguration.h"

@protocol AlivcLiveSessionDelegate;

@interface AlivcLiveSession : NSObject

@property (nonatomic, assign) BOOL enableSkin;
@property (nonatomic, assign) AVCaptureTorchMode torchMode;
@property (nonatomic, assign) AVCaptureDevicePosition devicePosition;
@property (nonatomic, weak) id<AlivcLiveSessionDelegate> delegate;

+ (NSString *)alivcLiveVideoVersion;

- (instancetype)initWithConfiguration:(AlivcLConfiguration *)configuration;

- (UIView *)previewView;

- (void)alivcLiveVideoStartPreview;
- (void)alivcLiveVideoStopPreview;

- (void)alivcLiveVideoRotateCamera;
- (void)alivcLiveVideoFocusAtAdjustedPoint:(CGPoint)point autoFocus:(BOOL)autoFocus;
- (void)alivcLiveVideoZoomCamera:(CGFloat)zoom;

/**
 *更新live配置，可以更新码率和帧率，但是只能在connectServer之前调用
 */
- (void)alivcLiveVideoUpdateConfiguration:(void(^)(AlivcLConfiguration *configuration))block;

- (void)alivcLiveVideoConnectServer;
- (void)alivcLiveVideoConnectServerWithURL:(NSString *)url;

- (void)alivcLiveVideoDisconnectServer;

- (AlivcLDebugInfo *)dumpDebugInfo;

- (NSInteger)alivcLiveVideoBitRate;
@end


@protocol AlivcLiveSessionDelegate <NSObject>

@optional
/**
 * 推流连接错误
 */
- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session error:(NSError *)error;

/**
 * 网络很慢，已经不建议直播
 */
- (void)alivcLiveVideoLiveSessionNetworkSlow:(AlivcLiveSession *)session;


@required
/**
 * 推流连接成功
 */
- (void)alivcLiveVideoLiveSessionConnectSuccess:(AlivcLiveSession *)session;


/**
 * 音频设备打开失败
 */
- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session OpenAudioError:(NSError *)error;

/**
 * 视频设备打开失败
 */
- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session OpenVideoError:(NSError *)error;

/**
 * 音频编码打开失败
 */
- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session EncodeAudioError:(NSError *)error;

/**
 * 视频编码打开失败
 */
- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session EncodeVideoError:(NSError *)error;



@end