//
//  Utils.h
//  SanJing
//
//  Created by 范茂羽 on 16/3/16.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DelayBlock)();

@interface Utils : NSObject

#pragma mark - 16进制颜色
///16进制颜色
+ (UIColor *)RGBHEXWithRGBValue:(NSInteger )rgbValue;

#pragma mark - 主线程停留
///主线程停留
+ (void)delayWithDuration:(NSTimeInterval)time DoSomeThingBlock:(DelayBlock)delayBlock;


#pragma 正则匹配用户姓名,20位的中文或英文
+ (BOOL)checkUserName : (NSString *) userName startNum:(NSInteger)start endNum:(NSInteger)end;

@end
