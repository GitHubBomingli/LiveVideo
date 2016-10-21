//
//  InputView.m
//  LaoWL
//
//  Created by 伯明利 on 16/7/5.
//  Copyright © 2016年 LC. All rights reserved.
//

#import "InputView.h"

@interface InputView ()

@end

@implementation InputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.image = [UIImage imageNamed:@"chat_bottom_bg"];
        
        UIButton *soundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        soundBtn.frame = CGRectMake(0, 0, 10, 44);
        
        UIImageView *textFieldBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(soundBtn.frame),                                                           0,kScreenWidth - 85,30)];
        [self addSubview:textFieldBackImageView];
        textFieldBackImageView.userInteractionEnabled = YES;
        textFieldBackImageView.center = CGPointMake(textFieldBackImageView.center.x, self.frame.size.height / 2);
        textFieldBackImageView.image = [UIImage imageNamed:@"chat_bottom_textfield"];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0,0,textFieldBackImageView.frame.size.width - 10,textFieldBackImageView.frame.size.height)];
        textField.placeholder = @"编辑您要发送的内容";
        textField.textColor = [UIColor blackColor];
        textField.font = [UIFont systemFontOfSize:13];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textFieldBackImageView addSubview:textField];
        self.textField = textField;
        textField.center = CGPointMake(textFieldBackImageView.frame.size.width / 2,
                                       textFieldBackImageView.frame.size.height / 2);
        textField.returnKeyType = UIReturnKeySend;
        
        //当输入框没有内容的时候 return键自动设置位不能点击的状态
        textField.enablesReturnKeyAutomatically = YES;
        textField.layer.cornerRadius = 5;
        textField.layer.borderColor = [UIColor colorWithRed:243/255.f green:243/255.f blue:243/255.f alpha:1].CGColor;
        textField.delegate = self;
        textField.backgroundColor = [UIColor whiteColor];
        
        _btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [self addSubview:_btn];
        [_btn setTitle:@"发送" forState:UIControlStateNormal];
        _btn.layer.cornerRadius = 5;
        _btn.layer.borderWidth = 1;
        [self sendButtonCanNotTouch];
        [_btn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
        
        _btn.frame = CGRectMake(kScreenWidth - 70, 7, 60, 30);
        _btn.center = CGPointMake(kScreenWidth - 85 + 95 / 2, self.frame.size.height / 2);
        
        _inputModel = InputModelText;//默认为文字输入
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doaction) name:UITextFieldTextDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

/**
 *  是否在输入状态
 */
- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if ([_delegate respondsToSelector:@selector(inputView:willShowKeyboardHeight:time:)]) {
        [_delegate inputView:self willShowKeyboardHeight:keyboardRect.size.height time:[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if ([_delegate respondsToSelector:@selector(willHideKeyboardWithInputView:time:)]) {
        [_delegate willHideKeyboardWithInputView:self time:[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]];
    }
}
- (void)doaction {
    if ([_delegate respondsToSelector:@selector(whetherDengLv)]) {
        [_delegate whetherDengLv];
    }
    
    if ([_textField.text length] == 0) {
        [self sendButtonCanNotTouch];
    } else {
        if ([_textField.text length] > 150) {
            [self sendButtonCanNotTouch];
        } else {
            [self sendButtonCanTouch];
        }
    }
    
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(inputView:text:)]) {
        [_delegate inputView:self text:textField.text];
    }
    return YES;
}
- (void)sendAction {
    [self sendButtonCanNotTouch];
    if ([_delegate respondsToSelector:@selector(inputView:text:)]) {
        [_delegate inputView:self text:_textField.text];
    }
}
- (void)sendButtonCanTouch {
    _btn.enabled = YES;
    _btn.backgroundColor = [UIColor colorWithRed:0.000 green:0.502 blue:1.000 alpha:1.000];
    _btn.layer.borderColor = [UIColor whiteColor].CGColor;
    [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
- (void)sendButtonCanNotTouch {
    _btn.enabled = NO;
    _btn.layer.borderColor = [UIColor colorWithWhite:0.800 alpha:1.000].CGColor;
    _btn.backgroundColor = [UIColor whiteColor];
    [_btn setTitleColor:[UIColor colorWithWhite:0.800 alpha:1.000] forState:UIControlStateNormal];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
