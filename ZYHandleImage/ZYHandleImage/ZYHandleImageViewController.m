//
//  ZYHandleImageViewController.m
//  ZYHandleImage
//
//  Created by zhangyi on 16/12/23.
//  Copyright © 2016年 zhangyi. All rights reserved.
//

#import "ZYHandleImageViewController.h"
#import "UIImage+Category.h"
#import "UIView+Category.h"

#import "InputView.h"

@interface ZYHandleImageViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImage                   * sourceImage;
@property (strong, nonatomic) HandleImageBlock          imageBlock;

@property (strong, nonatomic) UIImageView               * baseImageView;

@property (strong, nonatomic) UIView                    * currentView;
@property (assign, nonatomic) CGPoint                   prevPoint;

@property (strong, nonatomic) UIButton                  * moveButton;

@property (strong, nonatomic) InputView                 * inputView;

@end

@implementation ZYHandleImageViewController

- (instancetype)initWithSourceImage:(UIImage *)image handleImageBlock:(HandleImageBlock)imageBlock
{
    self = [super init];
    if (self) {
        _sourceImage = image;
        _imageBlock = imageBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeUserInterface];
}



#pragma mark -- initialize
- (void)initializeUserInterface
{
    self.view.backgroundColor = [UIColor blackColor];
    _baseImageView = ({
        UIImageView * imageView = [[UIImageView alloc] initWithImage:_sourceImage];
        imageView.userInteractionEnabled = YES;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageView];
        imageView;
    });

    CGSize newImageSize = _sourceImage.size;
    newImageSize = CGSizeMake(NOW_SCR_W - 60, (NOW_SCR_W - 60) / newImageSize.width * newImageSize.height);
    
    
    [_baseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(NOW_SCR_W - 60, NOW_SCR_H - 100));
        make.center.equalTo(self.view);
    }];
    
    UITapGestureRecognizer  * sourceGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sourceImageViewTapGesture:)];
    [_baseImageView addGestureRecognizer:sourceGesture];
    
    //创建顶部取消，确定按钮
    [self createTopOptionButton];
    
    [self createBottomButton];
}

#pragma mark -- button pressed

/**
 取消修改
 */
- (void)cancelButtonPressed:(UIButton *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/**
 确定修改

 */
- (void)sureButtonPressed:(UIButton *)sender
{
    //如果currentView的subviews等于1 说明操作按钮（删除和移动）是隐藏的 大于1时说明未隐藏
    if (_currentView.subviews.count > 1) {
        [self sourceImageViewTapGesture:nil];
    }
    
    //延迟调用截图，如果不延迟，view界面未刷新，操作按钮还存在
    [self performSelector:@selector(sure) withObject:nil afterDelay:0.001];
}


- (void)sure
{
    if (self.imageBlock) {
        UIImage * newImage = [_baseImageView convertViewToImage];
        self.imageBlock(newImage);
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/**
 旋转图片

 */
- (void)rotateImageViewButtonPressed:(UIButton *)sender
{
    UIImage * newImage = [UIImage image:_baseImageView.image rotation:UIImageOrientationLeft];
    
    CGSize newImageSize = newImage.size;
    newImageSize = CGSizeMake(NOW_SCR_W - 60, (NOW_SCR_W - 60) / newImageSize.width * newImageSize.height);
    
    [_baseImageView updateConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(newImageSize);
    }];
    _baseImageView.image = newImage;
}


/**
 添加文字

 */
- (void)addWordsButtonPressed:(UIButton *)sender
{
    weakify(self);
    InputView * inputView = [[InputView alloc] initWithSubView:self.view sureBlock:^(NSString *text) {
        UILabel * label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = text;
        label.adjustsFontSizeToFitWidth = YES;
        [weakSelf.baseImageView addSubview:label];
        
        // 设置文字属性 要和label的一致
        NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:20]};
        
        //计算文字的宽，但是不能超过最大宽度   设置adjustsFontSizeToFitWidth为yes 自动调节字体大小适应label
        CGSize textSize = [text boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
        CGFloat label_W = textSize.width + 20;
        if (label_W > NOW_SCR_W - 100) {
            label_W = NOW_SCR_W - 100;
        }
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(label_W);
            make.height.equalTo(@30);
            make.center.equalTo(weakSelf.baseImageView);
        }];
        [self performSelector:@selector(createTextImageViewWithView:) withObject:label afterDelay:0.01];
    }];
    
}


/**
 将label转为图片 方便放大缩小

 @param view 创建的label
 */
- (void)createTextImageViewWithView:(UIView *)view
{
    UIView * textView = [[UIView alloc] init];
    [_baseImageView addSubview:textView];
    _currentView = textView;
    
    UIImage * newImage = [view screenshot];
    [view removeFromSuperview];
    
    CGSize imageSize = newImage.size;
    
    NSLog(@"imageSize -- %f -- %f",imageSize.width,imageSize.height);
    
    textView.bounds = CGRectMake(0, 0, imageSize.width + 60, imageSize.height + 60);
    textView.center = CGPointMake(_baseImageView.frame.size.width/2, _baseImageView.frame.size.height/2);
    
    UIImageView * newImageView = [[UIImageView alloc] initWithImage:newImage];
    newImageView.userInteractionEnabled = YES;
    [textView addSubview:newImageView];
    
    newImageView.frame = CGRectMake(30, 30, imageSize.width, imageSize.height);
    
    UITapGestureRecognizer * baseTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(baseImageViewTapGesture:)];
    [newImageView addGestureRecognizer:baseTapGesture];
    
    UIPanGestureRecognizer * basePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(baseImageViewPan:)];
    [newImageView addGestureRecognizer:basePan];
    
    [self createOptionButton];
}


/**
 打码
 
 嵌套处理，外部一个blurryView，包含了打码的view和删除移动按钮
 
 */
- (void)addBlurryButtonPressed:(UIButton *)sender
{
    UIView * blurryView = [[UIView alloc] init];
    [_baseImageView addSubview:blurryView];
    
    if (_currentView) {
        [self sourceImageViewTapGesture:nil];
    }
    _currentView = blurryView;
    
    int randomNum = (int)arc4random() % 20;
    
    CGFloat imageCenterX = _baseImageView.frame.size.width / 2.0 + randomNum;
    CGFloat imageCenterY = _baseImageView.frame.size.height / 2.0 + randomNum;
    
    blurryView.bounds = CGRectMake(0, 0, 120, 120);
    blurryView.center = CGPointMake(imageCenterX, imageCenterY);
    
    UIImageView * newImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"单身你"]];
    newImageView.userInteractionEnabled = YES;
    [blurryView addSubview:newImageView];

    newImageView.frame = CGRectMake(30, 30, CGRectGetMaxX(_currentView.bounds) -60, CGRectGetMaxY(_currentView.bounds) - 60);
    
    UITapGestureRecognizer * baseTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(baseImageViewTapGesture:)];
    [newImageView addGestureRecognizer:baseTapGesture];
    
    UIPanGestureRecognizer * basePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(baseImageViewPan:)];
    [newImageView addGestureRecognizer:basePan];
    
    [self createOptionButton];
    
}


/**
 点空白处收起操作按钮（删除和移动）

 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UIView * view in _currentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
  
}

/**
 打码或添加文字删除

 */
- (void)deleteButtonPressed:(UIButton *)sender
{
    [_currentView removeFromSuperview];
}


#pragma mark -- gesture
- (void)sourceImageViewTapGesture:(UITapGestureRecognizer *)tapGesture
{
    for (UIView * view in _currentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
}

/**
 baseImageView单击手势

 */
- (void)baseImageViewTapGesture:(UITapGestureRecognizer *)tapGesture
{
    if (_currentView.subviews.count > 1) {
        [self sourceImageViewTapGesture:nil];
    }
    _currentView = tapGesture.view.superview;
    [_baseImageView bringSubviewToFront:_currentView];

    if (_currentView.subviews.count < 2) {
        [self createOptionButton];
    }
}


/**
 baseImageView拖动手势

 */
- (void)baseImageViewPan:(UIPanGestureRecognizer *)gesture
{
    CGPoint point = [gesture translationInView:_baseImageView];
    
    gesture.view.superview.center = CGPointMake(gesture.view.superview.center.x + point.x, gesture.view.superview.center.y + point.y);
    
    [gesture setTranslation:CGPointMake(0, 0) inView:_baseImageView];
    
    if (_currentView.subviews.count > 1) {
        [self sourceImageViewTapGesture:nil];
    }
    
    _currentView = gesture.view.superview;
    if (_currentView.subviews.count < 2) {
        [self createOptionButton];
    }
}


#pragma mark -- <UIGestureRecognizerDelegate>
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}


/**
 拖动手势

 */
- (void)panGestureDetected:(UIPanGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = [recognizer state];
    
    CGFloat baseChange = 0.0;
    
    if (state == UIGestureRecognizerStateBegan) {
        self.prevPoint = [recognizer locationInView:_currentView];
        baseChange = _currentView.bounds.size.width - self.prevPoint.x;
        
    }else if (state == UIGestureRecognizerStateChanged){
        //改变大小
        float wChange = 0.0;
        wChange = self.prevPoint.x + baseChange;
        if (wChange < 100) {
            wChange = 100;
        }
        
        float hChange = wChange / _currentView.bounds.size.width * _currentView.bounds.size.height;
        
        if (hChange < 80) {
            hChange = 80;
            wChange = hChange / _currentView.bounds.size.height * _currentView.bounds.size.width;
        }
        
        _currentView.bounds= CGRectMake(0, 0, wChange, hChange);
        //subviews[0] 打码表示图imageView
        _currentView.subviews[0].frame = CGRectMake(30, 30, CGRectGetMaxX(_currentView.bounds) -60, CGRectGetMaxY(_currentView.bounds) - 60);
        _moveButton.frame = CGRectMake(CGRectGetMaxX(_currentView.bounds) - 30, CGRectGetMaxY(_currentView.bounds) - 30, 30, 30);
 
        
        
        // 默认初始角度，触发点不在与视图中心点水平的位置上时需要计算初始角度大小
        CGFloat firstAngle = atan2(- _currentView.bounds.size.height / 2 - _currentView.bounds.origin.y,_currentView.bounds.size.width / 2 - _currentView.bounds.origin.x);
        
        // 计算旋转角度
        CGFloat slope = atan2([recognizer locationInView:_currentView.superview].y - _currentView.center.y, [recognizer locationInView:_currentView.superview].x - _currentView.center.x);
        
        _currentView.transform = CGAffineTransformMakeRotation(slope + firstAngle);

        [recognizer setTranslation:CGPointZero inView:_currentView];
        self.prevPoint = [recognizer locationOfTouch:0 inView:_currentView];

    }else if ([recognizer state] == UIGestureRecognizerStateEnded){
        self.prevPoint = [recognizer locationInView:_currentView];
        
    }
}

- (void)rotationGestureDetected:(UIRotationGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = [recognizer state];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
    {
        CGFloat rotation = [recognizer rotation];
        [_currentView setTransform:CGAffineTransformRotate(_currentView.transform, rotation)];
        [recognizer setRotation:0];
    }
}  

#pragma mark -- create view

/**
 创建顶部确定取消按钮
 */
- (void)createTopOptionButton
{
    UIButton * cancelButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    UIButton * sureButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(sureButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sureButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [self.view addSubview:sureButton];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(@10);
        make.size.equalTo(CGSizeMake(80, 30));
    }];
    
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        make.right.equalTo(@-10);
        make.size.equalTo(CGSizeMake(80, 30));
    }];

}


/**
 创建地步按钮
 */
- (void)createBottomButton
{
    NSArray * bottomTitleArray = [NSArray arrayWithObjects:@"旋转",@"文字",@"打码", nil];
    CGFloat margin = 20;
    CGFloat button_W = 70;
    
    CGFloat buttonMargin = (NOW_SCR_W - margin * 2 - button_W)/2.0;
    
    for (int i = 0; i < bottomTitleArray.count; i ++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        [button setTitle:bottomTitleArray[i] forState:UIControlStateNormal];
        [self.view addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(margin + buttonMargin * i);
            make.bottom.equalTo(@-10);
            make.size.equalTo(CGSizeMake(button_W, 30));
        }];
        
        if (i == 0) {
            [button addTarget:self action:@selector(rotateImageViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }else if ( i == 1){
            [button addTarget:self action:@selector(addWordsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [button addTarget:self action:@selector(addBlurryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}


/**
 创建操作按钮，删除和移动
 
 按钮只设置了背景颜色，用时可换成图标
 
 */
- (void)createOptionButton
{
    //删除
    UIButton * deleteBut = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBut.backgroundColor = [UIColor redColor];
    [deleteBut addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_currentView addSubview:deleteBut];

    [deleteBut mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(30, 30));
        make.top.left.equalTo(@0);
    }];
    
    //移动
    UIButton * removeBut = [UIButton buttonWithType:UIButtonTypeCustom];
    removeBut.backgroundColor = [UIColor redColor];
    [_currentView addSubview:removeBut];
    _moveButton = removeBut;

    removeBut.frame = CGRectMake(CGRectGetMaxX(_currentView.bounds) - 30, CGRectGetMaxY(_currentView.bounds) - 30, 30, 30);

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
    [panGestureRecognizer setDelegate:self];
    [removeBut addGestureRecognizer:panGestureRecognizer];
}





@end
