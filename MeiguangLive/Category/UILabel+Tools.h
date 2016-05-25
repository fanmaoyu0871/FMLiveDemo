//
//  UILabel+Tools.h
//  YiDaJian
//
//  Created by 范茂羽 on 16/4/5.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Tools)

+(UILabel*)labelWithFontName:(NSString*)fontName fontSize:(CGFloat)fontSize fontColor:(UIColor*)fontColor text:(NSString*)text;

+(UILabel*)mainLabelWithSize:(CGFloat)size textColor:(UIColor*)textColor text:(NSString*)text;

+ (CGSize)sizeWithText:(NSString *)text fontSize:(float )fontSize;

@end
