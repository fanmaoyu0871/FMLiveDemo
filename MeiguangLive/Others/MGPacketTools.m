//
//  MGPacketTools.m
//  MeiguangLive
//
//  Created by 范茂羽 on 16/5/23.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "MGPacketTools.h"


@implementation MGPacketTools

+(int)packRTMPVideoHeaderSpsBuf:(const uint8_t*)spsBuf spsSize:(size_t)spsSize ppsBuf:(const uint8_t*)ppsBuf ppsSize:(size_t)ppsSize outBuf:(uint8_t*)outBuf
{
    uint8_t szBuf[MAX_BUFFSIZE] = {0};
    
    int nBufIndex = 0;
    
    szBuf[nBufIndex++] = 0x17;				// 1:keyframe  7:AVC
    szBuf[nBufIndex++] = 0x00;				// AVC sequence header
    
    szBuf[nBufIndex++] = 0x00;
    szBuf[nBufIndex++] = 0x00;
    szBuf[nBufIndex++] = 0x00;				// fill in 0;
    
    // AVCDecoderConfigurationRecord.
    szBuf[nBufIndex++] = 0x01;				// configurationVersion
    szBuf[nBufIndex++] = spsBuf[1]; // AVCProfileIndication
    szBuf[nBufIndex++] = spsBuf[2]; // profile_compatibility
    szBuf[nBufIndex++] = spsBuf[3]; // AVCLevelIndication
    szBuf[nBufIndex++] = (char)0xff;		// lengthSizeMinusOne
    
    // sps nums
    szBuf[nBufIndex++] = (char)0xE1;		//	&0x1f
    // sps data length
    szBuf[nBufIndex++] = spsSize>>8;
    szBuf[nBufIndex++] = spsSize & 0xff;
    // sps data
    memcpy(&szBuf[nBufIndex], spsBuf, spsSize);
    nBufIndex= nBufIndex + (int)spsSize;
    
    // pps nums
    szBuf[nBufIndex++] = 0x01;				//&0x1f
    // pps data length
    szBuf[nBufIndex++] = ppsSize>>8;
    szBuf[nBufIndex++] = ppsSize & 0xff;
    // sps data
    memcpy(&szBuf[nBufIndex], ppsBuf, ppsSize);
    nBufIndex= nBufIndex + (int)ppsSize;
    
    memcpy(outBuf, szBuf, nBufIndex);

    return nBufIndex;
}

+(void)packRTMPVideoBodyDataBuf:(const char*)dataBuf dataSize:(size_t)dataSize isKeyframe:(BOOL)isKeyframe outBuf:(uint8_t*)outBuf
{
    int nBufLen = 0;
    uint8_t szBuf[MAX_BUFFSIZE] = {0};

    if(isKeyframe) {
        szBuf[nBufLen++] = 0x17;	// 1:Iframe  7:AVC
    } else {
        szBuf[nBufLen++] = 0x27;	// 2:Pframe  7:AVC
    }
    
    szBuf[nBufLen++] = 0x01;		// AVC NALU
    szBuf[nBufLen++] = 0x00;
    szBuf[nBufLen++] = 0x00;
    szBuf[nBufLen++] = 0x00;
    
    // NALU size
    szBuf[nBufLen++] = dataSize>>24;
    szBuf[nBufLen++] = dataSize>>16;
    szBuf[nBufLen++] = dataSize>>8;
    szBuf[nBufLen++] = dataSize & 0xff;
    
    // NALU data
    memcpy(outBuf, szBuf, nBufLen);
    
    memcpy(outBuf+nBufLen, dataBuf, (int)dataSize);
    
}

@end
