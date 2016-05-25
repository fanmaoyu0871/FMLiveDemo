//
//  UIView+Tools.m
//  JeeSea
//
//  Created by 范茂羽 on 15/8/27.
//  Copyright (c) 2015年 范茂羽. All rights reserved.
//

#import "UIView+Tools.h"

@implementation UIView (Tools)

-(void)setSize:(CGSize)size{
    self.width      = size.width;
    self.height     = size.height;
}

-(CGSize)size{
    return CGSizeMake(self.width, self.height);
}

-(void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

-(CGFloat)x
{
    return self.frame.origin.x;
}

-(void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

-(CGFloat)y
{
    return self.frame.origin.y;
}

-(void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

-(CGFloat)width
{
    return self.frame.size.width;
}

-(void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

-(CGFloat)height
{
    return self.frame.size.height;
}

-(void)setCenterX:(CGFloat)centerX
{
    CGPoint center =self.center;
    center.x = centerX;
    self.center = center;
}

-(CGFloat)centerX
{
    return self.center.x;
}

-(void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

-(CGFloat)centerY
{
    return self.center.y;
}

-(void)setOrigin:(CGPoint)origin{
    self.x          = origin.x;
    self.y          = origin.y;
}

-(void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

-(void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}


-(CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

-(CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left {
    self.frame = CGRectMake(left, self.top, self.width, self.height);
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top {
    self.frame = CGRectMake(self.left, top, self.width, self.height);
}

-(UIViewController*)viewController
{
    for(UIView *next = self.superview; next; next = next.superview)
    {
        UIResponder *responder = [next nextResponder];
        if([responder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController*)responder;
        }
    }
    
    return nil;
}

+(CAShapeLayer*)maskForType:(UIRectCorner)type rect:(CGRect)rect
{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.backgroundColor = [UIColor blackColor].CGColor;
    layer.path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:type cornerRadii:CGSizeMake(5, 5)].CGPath;
    
    return layer;
}



@end
