//
//  Utils.m
//  SanJing
//
//  Created by 范茂羽 on 16/3/16.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (UIColor *)RGBHEXWithRGBValue:(NSInteger)rgbValue {
    CGFloat red = (CGFloat)((rgbValue & 0xFF0000) >> 16) / 255.0;
    CGFloat green = (CGFloat)((rgbValue & 0x00FF00) >> 8) / 255.0;
    CGFloat blue = (CGFloat)(rgbValue & 0x0000FF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

+ (void)delayWithDuration:(NSTimeInterval)time DoSomeThingBlock:(DelayBlock)delayBlock {
    dispatch_time_t delytime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
    dispatch_after(delytime, dispatch_get_main_queue(), ^{
        delayBlock();
    });
}


#pragma 正则匹配用户姓名,20位的中文或英文
+ (BOOL)checkUserName : (NSString *) userName startNum:(NSInteger)start endNum:(NSInteger)end
{
    NSString *pattern = [NSString stringWithFormat:@"^[a-zA-Z一-龥]{%ld,%ld}", start, end];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:userName];
    return isMatch;
    
}

@end
