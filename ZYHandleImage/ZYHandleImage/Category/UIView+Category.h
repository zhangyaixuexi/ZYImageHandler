//
//  UIView+Category.h
//  BookClub
//
//  Created by 李祖建 on 15/11/27.
//  Copyright © 2015年 LittleBitch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Category)

//界面转换图片（截图）

-(UIImage *)convertViewToImage;

- (UIImage *)screenshotWithRect:(CGRect)rect;

- (UIImage *)screenshot;

@end
