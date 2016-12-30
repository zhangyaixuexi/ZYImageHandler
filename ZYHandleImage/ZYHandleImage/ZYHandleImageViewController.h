//
//  ZYHandleImageViewController.h
//  ZYHandleImage
//
//  Created by zhangyi on 16/12/23.
//  Copyright © 2016年 zhangyi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HandleImageBlock)(UIImage * newImage);

@interface ZYHandleImageViewController : UIViewController

- (instancetype)initWithSourceImage:(UIImage *)image handleImageBlock:(HandleImageBlock)imageBlock;

@end
