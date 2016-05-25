//
//  MGPacketTools.h
//  MeiguangLive
//
//  Created by 范茂羽 on 16/5/23.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGPacketTools : NSObject

#pragma mark - 封装rtmp 视频头
+(int)packRTMPVideoHeaderSpsBuf:(const uint8_t*)spsBuf spsSize:(size_t)spsSize ppsBuf:(const uint8_t*)ppsBuf ppsSize:(size_t)ppsSize outBuf:(uint8_t*)outBuf;

#pragma mark - 封装rtmp 视频体
+(void)packRTMPVideoBodyDataBuf:(const char*)dataBuf dataSize:(size_t)dataSize isKeyframe:(BOOL)isKeyframe outBuf:(uint8_t*)outBuf;

@end
