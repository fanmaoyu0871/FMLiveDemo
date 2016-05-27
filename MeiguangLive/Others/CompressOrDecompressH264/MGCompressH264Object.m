//
//  MGCompressH264Object.m
//  MeiguangLive
//
//  Created by 范茂羽 on 16/5/19.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "MGCompressH264Object.h"
#import "MGPacketTools.h"
#import "rtmp.h"

@interface MGCompressH264Object ()
{
    BOOL isNotFirst; //这个用来判断pps／sps只用传一次
    NSTimeInterval _ppsTime;
    BOOL isVideoFirst;
}
@end

@implementation MGCompressH264Object

-(void)compressH264:(CMSampleBufferRef)sampleBuffer delegate:(id<MGCompressH264ObjectDelegate>)delegate
{
    if (!CMSampleBufferDataIsReady(sampleBuffer))
    {
        NSLog(@"didCompressH264 data is not ready ");
        return;
    }
    
    // Check if we have got a key frame first
    bool keyframe = !CFDictionaryContainsKey( (CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), kCMSampleAttachmentKey_NotSync);
    
    if (keyframe && !isNotFirst)
    {
        //拿到sps,pps
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        
        // Found sps
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0);

        if (statusCode == noErr)
        {
            // Found sps and now check for pps
            size_t pparameterSetSize, pparameterSetCount;
            const uint8_t *pparameterSet;
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0);
            
            if (statusCode == noErr)
            {
                // Found pps
                int      bufSize = 0;
                uint8_t *headerBuf;
                headerBuf = (uint8_t*)malloc(MAX_BUFFSIZE);
                memset((uint8_t*)headerBuf, 0, MAX_BUFFSIZE);

                bufSize  = [MGPacketTools packRTMPVideoHeaderSpsBuf:sparameterSet spsSize:sparameterSetSize ppsBuf:pparameterSet ppsSize:pparameterSetSize outBuf:headerBuf];
                
                if([delegate respondsToSelector:@selector(transH264:type:timestamp:)])
                {
                    //发送sps + pps
                    NSData *data = [[NSData alloc]initWithBytes:headerBuf length:bufSize];
                    _ppsTime = [NSDate timeIntervalSinceReferenceDate];
                    [delegate transH264:data type:RTMP_PACKET_TYPE_VIDEO timestamp:0];
                    
                    //修改chunk size
//                    uint32_t chunkSize = 1024;
//                    [delegate transH264:[NSData dataWithBytes:&chunkSize length:4] type:RTMP_PACKET_TYPE_CHUNK_SIZE timestamp:0];
//                    isNotFirst = YES;
                }
                free(headerBuf);
            }
        }
    }
    
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t len, totalLength;
    char *dataPointer;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &len, &totalLength, &dataPointer);
    if (statusCodeRet == noErr) {
        
        size_t bufferOffset = 0;
        static const int AVCCHeaderLength = 4;
        
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            
            //先读4个字节长度
            // Read the NAL unit length
            uint32_t NALUnitLength = 0;
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);
            bufferOffset += AVCCHeaderLength;
            
            // Convert the length value from Big-endian to Little-endian
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            
            //视频数据封包
            if([delegate respondsToSelector:@selector(transH264:type:timestamp:)])
            {
                //读数据到tmpBuf
                char *tmpBuf = (char *)malloc(NALUnitLength);
                memset((char *)tmpBuf, 0, sizeof(tmpBuf));
                memcpy(tmpBuf, dataPointer+bufferOffset, NALUnitLength);
                bufferOffset += NALUnitLength;
                
                //判断I帧、P帧
                BOOL isKeyframe = NO;
                if(NALUnitLength > 1)
                {
                    uint8_t ch = tmpBuf[0];
                    
                    if( (ch & 0x1F) == 0x05 || (ch & 0x1F) == 0x06) // I帧
                    {
                        isKeyframe = YES;
                    }
                    else if ( (ch & 0x1F) == 0x01 ) // P帧
                    {
                        isKeyframe = NO;
                    }
//                    else                            //其它帧直接丢弃
//                    {
//                        if(headerBuf != NULL)
//                        {
//                            free(headerBuf);
//                        }
//                        free(tmpBuf);
//                        return;
//                    }
                }
                
                int bodyLenth = NALUnitLength + 9/*固定的*/;
                uint8_t *bodyBuf = (uint8_t *)malloc(bodyLenth);
                memset((uint8_t *)bodyBuf, 0, bodyLenth);
                [MGPacketTools packRTMPVideoBodyDataBuf:tmpBuf dataSize:NALUnitLength isKeyframe:isKeyframe outBuf:bodyBuf];
                
                NSData *data = [[NSData alloc]initWithBytes:bodyBuf length:bodyLenth];
                
                NSTimeInterval timestamp = 0;
                if(isVideoFirst)
                {
                    timestamp = [NSDate timeIntervalSinceReferenceDate]-_ppsTime;
                }
                else
                {
                    timestamp = 0;
                    isVideoFirst = YES;
                }
                [delegate transH264:data type:RTMP_PACKET_TYPE_VIDEO timestamp:timestamp];

                
                free(tmpBuf);
                free(bodyBuf);
            }
        }
    }
}


@end
