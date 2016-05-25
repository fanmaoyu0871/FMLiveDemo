//
//  YDJProgressHUD.h
//  YiDaJian
//
//  Created by 范茂羽 on 16/4/12.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDJProgressHUD : NSObject

+(void)showTextToast:(NSString*)text onView:(UIView*)view;

+(MBProgressHUD*)showAnimationTextToast:(NSString*)text onView:(UIView*)view;

+(void)showSystemIndicator:(BOOL)isShow;

+(void)showDefaultProgress:(UIView*)view;
+(void)hideDefaultProgress:(UIView*)view;

+(void)showCustomProgress:(UIView*)customView inView:(UIView*)view;

@end
