//
//  InputView.m
//  ZYHandleImage
//
//  Created by zhangyi on 16/12/29.
//  Copyright © 2016年 zhangyi. All rights reserved.
//

#import "InputView.h"

@interface InputView () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField           * midTextField;

@property (strong, nonatomic) SureInputBlock        sureInputBlock;

@end

@implementation InputView

- (instancetype)initWithSubView:(UIView *)subView sureBlock:(SureInputBlock)sureInputBlock
{
    self = [super init];
    if (self) {
        self.sureInputBlock = sureInputBlock;
        [subView addSubview:self];
        [self initializeUserInterface];
    }
    return self;
}


- (void)initializeUserInterface
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self addGestureRecognizer:tapGesture];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    _midTextField = ({
        UITextField * textField = [[UITextField alloc] init];
        textField.delegate = self;
        textField.adjustsFontSizeToFitWidth = YES;
        textField.returnKeyType = UIReturnKeyDone;
        [textField becomeFirstResponder];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.textColor = [UIColor whiteColor];
        textField.font = [UIFont boldSystemFontOfSize:35];
        [self addSubview:textField];
        textField;
    });
    
    [_midTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.right.equalTo(@-30);
        make.height.equalTo(@50);
        make.centerY.equalTo(self);
    }];
    
}

#pragma mark -- gesture
- (void)tapGesture
{
    [self removeFromSuperview];
}

#pragma mark -- <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        if (self.sureInputBlock) {
            self.sureInputBlock(textField.text);
        }
    }
    [self removeFromSuperview];
    return NO;
}

@end
