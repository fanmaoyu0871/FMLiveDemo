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

+(int)packRTMPAACHeader:(uint8_t*)outBuf
{
    int nBufIndex = 0;
    
    // 8bit 22khz	µÕÀƒŒª:1001
    //	szBuf[nBufIndex++] = (char)0xA9;
    
    // 8bit 44khz	µÕÀƒŒª:1101
    //	szBuf[nBufIndex++] = 0xAD;
    
    // 16bit 22khz	µÕÀƒŒª:1011
    //	szBuf[nBufIndex++] = 0xAB;
    
    // 16bit 44khz	µÕÀƒŒª:1111
    outBuf[nBufIndex++] = 0xAF;
    
    outBuf[nBufIndex++] = 0x00;				// AAC sequence header
    
    // AudioSpecificConfig.
    // 22khz	µÕ»˝Œª:011,
    // 	szBuf[nBufIndex++] = 0x13;
    //  szBuf[nBufIndex++] = (char)0x90;	// ∏ﬂ“ªŒª:1	Ω”◊≈ÀƒŒª:0010	µÕ»˝Œª:000
    
    // 	// 44khz	µÕ»˝Œª:010,
    outBuf[nBufIndex++] = 0x12;
    outBuf[nBufIndex++] = (char)0x10;		// ∏ﬂ“ªŒª:0	Ω”◊≈ÀƒŒª:0010	µÕ»˝Œª:000
    
    return nBufIndex;
}

+(int)packRTMPAACBody:(uint8_t*)dataBuf dataSize:(size_t)dataSize outBuf:(uint8_t*)outBuf
{
    int nBufIndex = 0;
    
    // 8bit 22khz	µÕÀƒŒª:1001
    //	szBuf[nBufIndex++] = (char)0xA9;
    
    // 8bit 44khz	µÕÀƒŒª:1101
    //	szBuf[nBufIndex++] = 0xAD;
    
    // 16bit 22khz	µÕÀƒŒª:1011
    //	szBuf[nBufIndex++] = 0xAB;
    
    // 16bit 44khz	µÕÀƒŒª:1111
    outBuf[nBufIndex++] = 0xAF;
    
    outBuf[nBufIndex++] = 0x01;				// AAC raw
    
    memcpy(outBuf + nBufIndex, dataBuf, dataSize);
    
    return nBufIndex + dataSize;
}

@end
