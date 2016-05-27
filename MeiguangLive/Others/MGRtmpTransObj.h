//
//  MGRtmpTransObj.h
//  MeiguangLive
//
//  Created by 范茂羽 on 16/5/26.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGRtmpTransObj : NSObject

-(instancetype)initWithUrl:(NSString*)urlStr;

-(void)SendToRTMPSrv:(NSData*)data type:(uint8_t)type timestamp:(uint32_t)timestamp;

-(void)stopnTrans;

@end
