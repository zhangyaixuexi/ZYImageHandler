//
//  InputView.h
//  ZYHandleImage
//
//  Created by zhangyi on 16/12/29.
//  Copyright © 2016年 zhangyi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SureInputBlock)(NSString * text);

@interface InputView : UIView

- (instancetype)initWithSubView:(UIView *)subView sureBlock:(SureInputBlock)sureInputBlock;

@end
