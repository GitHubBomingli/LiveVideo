//
//  InputView.h
//  LaoWL
//
//  Created by 伯明利 on 16/7/5.
//  Copyright © 2016年 LC. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "UIImage+Addition.h"
//#import "NSString+Addition.h"
#import <AVFoundation/AVFoundation.h>
//#import "UIImage+Addition.h"
#import "MBProgressHUD.h"


typedef NS_ENUM(NSInteger, InputModel){
    InputModelText = 0,
    InputModelVoice
};

typedef NS_ENUM(NSInteger, RecorderType){
    RecorderTypeStart = 0,
    RecorderTypeStop,
    RecorderTypeCancel
};

@class InputView;
@protocol InputViewDelegate <NSObject>
@optional
/**
 *  即将显示键盘时调用
 *
 *  @param inputView 当前输入框view
 *  @param height    键盘高度
 *  @param time      弹出时间
 */
- (void)inputView:(InputView *)inputView willShowKeyboardHeight:(CGFloat)height time:(NSNumber *)time;
- (void)whetherDengLv;
/**
 *  即将隐藏键盘时调用
 *
 *  @param inputView 当前输入框view
 *  @param time      弹出时间
 */
- (void)willHideKeyboardWithInputView:(InputView *)inputView time:(NSNumber *)time;
/**
 *  点击return键时调用
 *
 *  @param inputView 当前输入框view
 *  @param text      输入的聊天内容(非空)
 */
- (void)inputView:(InputView *)inputView text:(NSString *)text;

-(void)inputView:(InputView*)inputView type:(RecorderType)type;

@end
@interface InputView : UIImageView <UITextFieldDelegate>

@property (nonatomic,weak) id<InputViewDelegate> delegate;
@property (nonatomic) InputModel inputModel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *btn;

@end
