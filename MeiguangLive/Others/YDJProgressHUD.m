//
//  YDJProgressHUD.m
//  YiDaJian
//
//  Created by 范茂羽 on 16/4/12.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "YDJProgressHUD.h"

@implementation YDJProgressHUD

+(void)showTextToast:(NSString*)text onView:(UIView*)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2.0f];
}

+(MBProgressHUD*)showAnimationTextToast:(NSString*)text onView:(UIView*)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

+(void)showSystemIndicator:(BOOL)isShow
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = isShow;
}

+(void)showDefaultProgress:(UIView*)view
{
    [MBProgressHUD showHUDAddedTo:view animated:YES];
}

+(void)hideDefaultProgress:(UIView*)view
{
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}

+(void)showCustomProgress:(UIView*)customView inView:(UIView*)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = customView;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2.0f];
}

@end
