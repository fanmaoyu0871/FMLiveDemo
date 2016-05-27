//
//  MGAACEncoder.m
//  MeiguangLive
//
//  Created by 范茂羽 on 16/5/25.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "MGAACEncoder.h"

FILE *ppsFile = NULL;

@implementation MGAACEncoder
{
    AudioConverterRef m_converter;
    
    __weak id<MGAACEncoderDelegate> _delegate;
}

-(instancetype)initWithDelegate:(id<MGAACEncoderDelegate>)delegate
{
    if(self = [super init])
    {
        _delegate = delegate;
        
    }
    
    return self;
}


-(BOOL)createAudioConvert:(CMSampleBufferRef)sampleBuffer { //根据输入样本初始化一个编码转换器
    if (m_converter != nil)
    {
        return TRUE;
    }
    AudioStreamBasicDescription inputFormat = *(CMAudioFormatDescriptionGetStreamBasicDescription(CMSampleBufferGetFormatDescription(sampleBuffer))); // 输入音频格式
    AudioStreamBasicDescription outputFormat; // 这里开始是输出音频格式
    memset(&outputFormat, 0, sizeof(outputFormat));
    outputFormat.mSampleRate       = inputFormat.mSampleRate; // 采样率保持一致
    outputFormat.mFormatID         = kAudioFormatMPEG4AAC;    // AAC编码
    outputFormat.mChannelsPerFrame = 2;
    outputFormat.mFramesPerPacket  = 1024;                    // AAC一帧是1024个字节
    
    AudioClassDescription *desc = [self getAudioClassDescriptionWithType:kAudioFormatMPEG4AAC fromManufacturer:kAppleSoftwareAudioCodecManufacturer];
    if (AudioConverterNewSpecific(&inputFormat, &outputFormat, 1, desc, &m_converter) != noErr)
    {
        NSLog(@"AudioConverterNewSpecific failed");
        return NO;
    }
    
    UInt32 ulBitRate = 64000;
    UInt32 ulSize = sizeof(ulBitRate);
    AudioConverterSetProperty(m_converter, kAudioConverterEncodeBitRate, ulSize, &ulBitRate);
    
    return YES;
}
-(BOOL)encoderAAC:(CMSampleBufferRef)sampleBuffer aacData:(char*)aacData aacLen:(int*)aacLen { // 编码PCM成AAC
    //创建aac编码器
    if ([self createAudioConvert:sampleBuffer] != YES)
    {
        return NO;
    }

    //得到pcm数据
    CMBlockBufferRef blockBuffer = nil;
    AudioBufferList  inBufferList;
    if (CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &inBufferList, sizeof(inBufferList), NULL, NULL, 0, &blockBuffer) != noErr)
    {
        NSLog(@"CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer failed");
        return NO;
    }
    
    // 编码
    // 初始化一个输出缓冲列表
    AudioBufferList outBufferList;
    outBufferList.mNumberBuffers              = 1;
    outBufferList.mBuffers[0].mNumberChannels = 2;
    outBufferList.mBuffers[0].mDataByteSize   = *aacLen; // 设置缓冲区大小
    outBufferList.mBuffers[0].mData           = aacData; // 设置AAC缓冲区
    UInt32 outputDataPacketSize               = 1;
    if (AudioConverterFillComplexBuffer(m_converter, inputDataProc, &inBufferList, &outputDataPacketSize, &outBufferList, NULL) != noErr)
    {
        NSLog(@"AudioConverterFillComplexBuffer failed");
        return NO;
    }
    
    *aacLen = outBufferList.mBuffers[0].mDataByteSize; //设置编码后的AAC大小
    
    if([_delegate respondsToSelector:@selector(didFinishedAACEncoder:aacSize:)])
    {
        [_delegate didFinishedAACEncoder:outBufferList.mBuffers[0].mData aacSize:*aacLen];
        //test
//        [self writeFile:outBufferList.mBuffers[0].mData size:*aacLen];
    }
    
    CFRelease(blockBuffer);
    return YES;
}
-(AudioClassDescription*)getAudioClassDescriptionWithType:(UInt32)type fromManufacturer:(UInt32)manufacturer { // 获得相应的编码器
    static AudioClassDescription audioDesc;
    
    UInt32 encoderSpecifier = type, size = 0;
    OSStatus status;
    
    memset(&audioDesc, 0, sizeof(audioDesc));
    status = AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders, sizeof(encoderSpecifier), &encoderSpecifier, &size);
    if (status)
    {
        return nil;
    }
    
    uint32_t count = size / sizeof(AudioClassDescription);
    AudioClassDescription descs[count];
    status = AudioFormatGetProperty(kAudioFormatProperty_Encoders, sizeof(encoderSpecifier), &encoderSpecifier, &size, descs);
    for (uint32_t i = 0; i < count; i++)
    {
        if ((type == descs[i].mSubType) && (manufacturer == descs[i].mManufacturer))
        {
            memcpy(&audioDesc, &descs[i], sizeof(audioDesc));
            break;
        }
    }
    return &audioDesc;
}

//test
-(void)writeFile:(uint8_t*)buf size:(size_t)bufSize
{
    const char *aacfile = [[NSString stringWithFormat:@"%@/tmp/audio.aac", NSHomeDirectory()] UTF8String];
    ppsFile = fopen(aacfile, "a+");

    int adtsLength = 7;
    char *packet = (char *)malloc(sizeof(char) * adtsLength);
    // Variables Recycled by addADTStoPacket
    int profile = 2;  //AAC LC
    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
    int freqIdx = 4;  //44KHz
    int chanCfg = 2;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
    NSUInteger fullLength = 7+bufSize;
    // fill in ADTS data
    packet[0] = (char)0xFF;	// 11111111  	= syncword
    packet[1] = (char)0xF1;	// 1111 0 00 1  = syncword MPEG-4 Layer CRC
    packet[2] = (char)(((profile-1)<<6) + (freqIdx<<2) +(chanCfg>>2));
    packet[3] = (char)(((chanCfg&3)<<6) + (fullLength>>11));
    packet[4] = (char)((fullLength&0x7FF) >> 3);
    packet[5] = (char)(((fullLength&7)<<5) + 0x1F);
    packet[6] = (char)0xFC;
    
    fwrite(packet, 1, 7, ppsFile);
    free(packet);
    
    fwrite(buf, 1, bufSize, ppsFile);
    fclose(ppsFile);
}

OSStatus inputDataProc(AudioConverterRef inConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData,AudioStreamPacketDescription **outDataPacketDescription, void *inUserData) { //<span style="font-family: Arial, Helvetica, sans-serif;">AudioConverterFillComplexBuffer 编码过程中，会要求这个函数来填充输入数据，也就是原始PCM数据</span>
    AudioBufferList bufferList = *(AudioBufferList*)inUserData;
    ioData->mBuffers[0].mNumberChannels = 1;
    ioData->mBuffers[0].mData           = bufferList.mBuffers[0].mData;
    ioData->mBuffers[0].mDataByteSize   = bufferList.mBuffers[0].mDataByteSize;
    return noErr;
}

@end
