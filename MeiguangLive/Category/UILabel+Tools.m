//
//  UILabel+Tools.m
//  YiDaJian
//
//  Created by 范茂羽 on 16/4/5.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "UILabel+Tools.h"

@implementation UILabel (Tools)
+(UILabel*)labelWithFontName:(NSString*)fontName fontSize:(CGFloat)fontSize fontColor:(UIColor*)fontColor text:(NSString*)text
{
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont fontWithName:fontName size:fontSize];
    label.textColor = fontColor;
    label.text = text;
    [label sizeToFit];
    return label;
}

+(UILabel*)mainLabelWithSize:(CGFloat)size textColor:(UIColor*)textColor text:(NSString*)text
{
   return  [UILabel labelWithFontName:Theme_MainFont fontSize:size fontColor:textColor text:text];
}

+ (UILabel *)labelWithFontSize:(float)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:fontSize];
    return label;
}

+ (CGSize)sizeWithText:(NSString *)text fontSize:(float)fontSize {
    if (text == nil) {
        return CGSizeZero;
    }
    UILabel *label = [UILabel labelWithFontSize:fontSize];
    label.text = text;
    [label sizeToFit];
    return label.size;
}
@end
