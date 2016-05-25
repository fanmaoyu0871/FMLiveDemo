//
//  NSString+Tools.h
//  SanJing
//
//  Created by 范茂羽 on 16/3/22.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Tools)

#pragma mark - md5加密
+(NSString *)md5:(NSString *)str;

+(NSString*)stringFromSeconds:(NSString*)seconds;

-(CGSize)sizeOfStringFont:(UIFont*)font baseSize:(CGSize)baseSize;

@end
