//
//  UIView+Tools.h
//  JeeSea
//
//  Created by 范茂羽 on 15/8/27.
//  Copyright (c) 2015年 范茂羽. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Tools)

@property (nonatomic, assign)CGFloat x;
@property (nonatomic, assign)CGFloat y;
@property (nonatomic, assign)CGFloat width;
@property (nonatomic, assign)CGFloat height;
@property (nonatomic, assign)CGFloat centerX;
@property (nonatomic, assign)CGFloat centerY;
@property (nonatomic, assign) CGSize size;


@property (nonatomic, assign) CGFloat   bottom;
@property (nonatomic, assign) CGFloat   right;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;

//得到圆角遮罩图层
+(CAShapeLayer*)maskForType:(UIRectCorner)type rect:(CGRect)rect;

//找到视图对应的控制器
-(UIViewController*)viewController;

@end
