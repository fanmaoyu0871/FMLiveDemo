//
//  UIImage+Tools.h
//  YiDaJian
//
//  Created by 范茂羽 on 16/5/4.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tools)
-(UIImage*)getSubImage:(CGRect)rect;
-(UIImage*)scaleToSize:(CGSize)size;
@end
