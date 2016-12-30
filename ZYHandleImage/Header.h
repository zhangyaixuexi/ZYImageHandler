//
//  Header.h
//  ZYHandleImage
//
//  Created by zhangyi on 16/12/23.
//  Copyright © 2016年 zhangyi. All rights reserved.
//

#ifndef Header_h
#define Header_h

#define MAS_SHORTHAND
// 只要添加了这个宏，equalTo就等价于mas_equalTo
#define MAS_SHORTHAND_GLOBALS
// 这个头文件一定要放在上面两个宏的后面

#import <Masonry.h>
#import "AppDelegate.h"

#define NOW_SCR_H [UIScreen mainScreen].bounds.size.height
#define NOW_SCR_W [UIScreen mainScreen].bounds.size.width

#define _window ((AppDelegate *)[UIApplication sharedApplication].delegate).window
#define weakify(var)   __weak typeof(var) weakSelf = var
#define strongify(var) __strong typeof(var) strongSelf = var



#endif /* Header_h */
