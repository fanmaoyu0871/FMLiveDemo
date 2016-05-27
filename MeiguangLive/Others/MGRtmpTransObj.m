//
//  MGRtmpTransObj.m
//  MeiguangLive
//
//  Created by 范茂羽 on 16/5/26.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "MGRtmpTransObj.h"
#import "RtmpWrapper.h"

@implementation MGRtmpTransObj
{
    RtmpWrapper *_rtmp;
}

-(instancetype)initWithUrl:(NSString*)urlStr
{
    self = [super init];
    if (self) {
        _rtmp = [[RtmpWrapper alloc] init];
        [_rtmp openWithURL:urlStr enableWrite:YES];
    }
    return self;
}


-(void)SendToRTMPSrv:(NSData*)data type:(uint8_t)type timestamp:(uint32_t)timestamp
{
    //    PackHeader *ph = (PackHeader*)malloc(sizeof(PackHeader));
    //    ph->mark = 1;
    //    ph->head_len = sizeof(PackHeader);
    //    ph->data_len = (unsigned int)data.length;
    //    ph->timestamp = 0;
    //    ph->type = PT_LIVE_VIDEO;
    //    ph->nums = 1;
    //    ph->index = 0;
    //    memset(ph->ratention, 0, sizeof(ph->ratention));
    //    memset(ph->key, 0, sizeof(ph->key));
    //
    //    uint8_t *buffer = (uint8_t*)malloc(sizeof(PackHeader) + data.length);
    //    memcpy(buffer, ph, sizeof(PackHeader));
    //    memcpy(buffer+sizeof(PackHeader), data.bytes, data.length);
    //    free(ph);
    //    free(buffer);
    
    
    NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[data bytes] length:[data length] freeWhenDone:NO];
    [_rtmp write:chunk type:type timestamp:timestamp];
}


-(void)stopnTrans
{
    [_rtmp close];
}
@end
