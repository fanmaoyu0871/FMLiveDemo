//
//  NSString+Tools.m
//  SanJing
//
//  Created by 范茂羽 on 16/3/22.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "NSString+Tools.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Tools)

//MD5加密
+(NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

-(CGSize)sizeOfStringFont:(UIFont*)font baseSize:(CGSize)baseSize
{
    return [self boundingRectWithSize:baseSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
}

+(NSString*)stringFromSeconds:(NSString*)seconds
{
    NSInteger sec = [seconds integerValue];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:sec];
    
    NSDateFormatter *fm = [[NSDateFormatter alloc]init];
    fm.dateFormat = @"yyyy.MM.dd";
    NSString *str = [fm stringFromDate:date];
    
    return str;
}

@end
