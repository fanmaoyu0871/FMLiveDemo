//
//  MGRecordVC.m
//  MeiguangLive
//
//  Created by 范茂羽 on 16/5/8.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "MGRecordVC.h"
#import "MGCompressH264Object.h"
#import "MGPacketTools.h"
#import "RtmpWrapper.h"
#import "MGAACEncoder.h"

@interface MGRecordVC ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, VTPCompressionSessionDelegate, MGCompressH264ObjectDelegate>
{
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_videoDevice;
    AVCaptureDevice *_audioDevice;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureDeviceInput *_audioInput;
    
    AVCaptureVideoDataOutput *_videoOutput;
    AVCaptureAudioDataOutput *_audioOutput;

    AVCaptureVideoPreviewLayer *_captureVideoPreviewLayer;
    
    VTPCompressionSession *_compressionSession;
    
    MGCompressH264Object *_compressH264Obj; //转换264类
        
    RtmpWrapper *_rtmp; // rtmp
    
    MGAACEncoder *_aacEncoder;
    
    BOOL isFirstSPS;
    BOOL isFirstPPS;
}

@end

@implementation MGRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //配置网络(两条线:rtmp / 直播室)
    BOOL ret = [self initRtmpChannel];
    if(!ret)
    {
        NSLog(@"初始化rtmp线路失败");
    }
    
//    [self initLiveChannel];
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (!(authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied))
    {
        [self setupAVCapture];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:nil message:@"请在iPhone的\"设置-隐私－相机\"选项中，允许\"美光直播\"访问你的相机" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
        [av show];
    }

}

#pragma mark - 配置rtmp线路
-(BOOL)initRtmpChannel
{
    _rtmp = [[RtmpWrapper alloc] init];
    BOOL ret = [_rtmp openWithURL:@"rtmp://video-center.alivecdn.com/test/cam10?vhost=ms.jeesea.com" enableWrite:YES];
    return ret;
}

#pragma mark - 配置直播室线路
-(void)initLiveChannel
{
    [MGSocketManager sharedManager].socketHost = @"";
    [MGSocketManager sharedManager].socketPort = 1935;
    
    [[MGSocketManager sharedManager]socketConnectHost];
    
}

#pragma mark - 初始化摄像头
-(void)setupAVCapture
{
    [self initSession];
    
    _compressH264Obj = [[MGCompressH264Object alloc]init];
    
    [_captureSession beginConfiguration];
    
    [self initVideo];
    [self initAudio];
    [self addPreviewLayer];
    [self initCoder];
    
    [_captureSession commitConfiguration];
    
    //开启会话-->注意,不等于开始录制
    [_captureSession startRunning];
}

#pragma mark - 初始化编码器
-(void)initCoder
{
    NSError *error = nil;
    _compressionSession = [[VTPCompressionSession alloc]initWithWidth:ScreenWidth height:ScreenHeight codec:kCMVideoCodecType_H264 error:&error];
    if(error)
    {
        NSLog(@"init coder failed!");
        return;
    }
    [_compressionSession setDelegate:self queue:NULL];
    
    // Set the properties
//    [_compressionSession setValue:[NSNumber numberWithInt:ScreenWidth*ScreenHeight*7.5] forProperty:AVVideoAverageBitRateKey error:nil];
//    [_compressionSession setValue:[NSNumber numberWithInt:100] forProperty:AVVideoMaxKeyFrameIntervalKey error:nil];
    [_compressionSession setValue:AVVideoProfileLevelH264BaselineAutoLevel forProperty:AVVideoProfileLevelKey error:nil];
//    [_compressionSession setValue:AVVideoProfileLevelH264HighAutoLevel forProperty:AVVideoProfileLevelKey error:nil];
    [_compressionSession setValue:[NSNumber numberWithBool:YES] forProperty:(__bridge NSString *)kVTCompressionPropertyKey_RealTime error:nil];
//    [_compressionSession setValue:[NSNumber numberWithBool:NO] forProperty:(__bridge NSString *)kVTCompressionPropertyKey_AllowFrameReordering error:nil];
//    [_compressionSession setValue:[NSNumber numberWithInt:240] forProperty:(__bridge NSString *)kVTCompressionPropertyKey_MaxKeyFrameInterval error:nil];
    
    [_compressionSession prepare];
    
}

//编码成功的回调
#pragma mark - VTPCompressionSessionDelegate
- (void)videoCompressionSession:(VTPCompressionSession *)compressionSession didEncodeSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //转换h264流
   [_compressH264Obj compressH264:sampleBuffer delegate:self];
}

#pragma mark - MGCompressH264ObjectDelegate
-(void)gotPacket:(NSData*)data type:(uint8_t)type timestamp:(uint32_t)timestamp
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
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    
    NSUInteger chunkSize = 1024;
    NSUInteger offset = 0;
    

    NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
    NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[data bytes] length:[data length]
                                   freeWhenDone:NO];
    offset += thisChunkSize;
    
    // Write new chunk to rtmp server
    NSLog(@"send length = %ld", [_rtmp write:chunk type:type timestamp:timestamp]);
    
}


#pragma mark - 初始化音频设备
- (void)initAudio
{
    NSError *audioError;
    // 添加一个音频输入设备
    _audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //  音频输入对象
    _audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:_audioDevice error:&audioError];
    if (audioError) {
        NSLog(@"取得录音设备时出错 ------ %@",audioError);
        return;
    }
    if ([_captureSession canAddInput:_audioInput]) {
        [_captureSession addInput:_audioInput];
    }
    
    //添加音频输出
    _audioOutput = [[AVCaptureAudioDataOutput alloc]init];
    const char *audioQueueName = "audioQueue";
    dispatch_queue_t audioQueue = dispatch_queue_create(audioQueueName, DISPATCH_QUEUE_PRIORITY_DEFAULT);
    [_audioOutput setSampleBufferDelegate:self queue:audioQueue];
    if ([_captureSession canAddOutput:_audioOutput]) {
        [_captureSession addOutput:_audioOutput];
    }
}

#pragma mark - 添加视频预览层
- (void)addPreviewLayer
{
    
    [self.view layoutIfNeeded];
    
    // 通过会话 (AVCaptureSession) 创建预览层
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _captureVideoPreviewLayer.frame = self.view.layer.bounds;

    //有时候需要拍摄完整屏幕大小的时候可以修改这个
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // 如果预览图层和视频方向不一致,可以修改这个
    
    // 显示在视图表面的图层
    [self.view.layer addSublayer:_captureVideoPreviewLayer];

}



#pragma mark - 初始化视频设备
-(void)initVideo
{
    
    // 获取摄像头输入设备， 创建 AVCaptureDeviceInput 对象
    /* MediaType
     AVF_EXPORT NSString *const AVMediaTypeVideo                 NS_AVAILABLE(10_7, 4_0);       //视频
     AVF_EXPORT NSString *const AVMediaTypeAudio                 NS_AVAILABLE(10_7, 4_0);       //音频
     AVF_EXPORT NSString *const AVMediaTypeText                  NS_AVAILABLE(10_7, 4_0);
     AVF_EXPORT NSString *const AVMediaTypeClosedCaption         NS_AVAILABLE(10_7, 4_0);
     AVF_EXPORT NSString *const AVMediaTypeSubtitle              NS_AVAILABLE(10_7, 4_0);
     AVF_EXPORT NSString *const AVMediaTypeTimecode              NS_AVAILABLE(10_7, 4_0);
     AVF_EXPORT NSString *const AVMediaTypeMetadata              NS_AVAILABLE(10_8, 6_0);
     AVF_EXPORT NSString *const AVMediaTypeMuxed                 NS_AVAILABLE(10_7, 4_0);
     */
    
    /* AVCaptureDevicePosition
     typedef NS_ENUM(NSInteger, AVCaptureDevicePosition) {
     AVCaptureDevicePositionUnspecified         = 0,
     AVCaptureDevicePositionBack                = 1,            //后置摄像头
     AVCaptureDevicePositionFront               = 2             //前置摄像头
     } NS_AVAILABLE(10_7, 4_0) __TVOS_PROHIBITED;
     */
    _videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
    
  
    //添加视频输入
    NSError *videoError;
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&videoError];
    if (videoError) {
        NSLog(@"---- 取得摄像头设备时出错 ------ %@",videoError);
        return;
    }
    
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    
    //添加视频输出
    [self addMovieOutput];
}

#pragma mark - 设置视频输出
- (void)addMovieOutput
{
    // 拍摄视频输出对象
    // 初始化输出设备对象，用户获取输出数据
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    const char *videoQueueName = "vedioQueue";
    dispatch_queue_t videoQueue = dispatch_queue_create(videoQueueName, DISPATCH_QUEUE_PRIORITY_DEFAULT);
    [_videoOutput setSampleBufferDelegate:self queue:videoQueue];
    [_videoOutput setVideoSettings:@{(NSString*)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]}];
    
    if ([_captureSession canAddOutput:_videoOutput]) {
        [_captureSession addOutput:_videoOutput];
        AVCaptureConnection *captureConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        
        //设置视频旋转方向
        /*
         typedef NS_ENUM(NSInteger, AVCaptureVideoOrientation) {
         AVCaptureVideoOrientationPortrait           = 1,
         AVCaptureVideoOrientationPortraitUpsideDown = 2,
         AVCaptureVideoOrientationLandscapeRight     = 3,
         AVCaptureVideoOrientationLandscapeLeft      = 4,
         } NS_AVAILABLE(10_7, 4_0) __TVOS_PROHIBITED;
         */
        //        if ([captureConnection isVideoOrientationSupported]) {
        //            [captureConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        //        }
        
        // 视频稳定设置
        if ([captureConnection isVideoStabilizationSupported]) {
            captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        
        captureConnection.videoScaleAndCropFactor = captureConnection.videoMaxScaleAndCropFactor;
    }
    
}


#pragma mark 获取摄像头-->前/后
- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for ( AVCaptureDevice *device in devices ) {
        if ( device.position == position ) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark - 初始化会话
-(void)initSession
{
    _captureSession = [[AVCaptureSession alloc] init];
    //设置视频分辨率
    /*  通常支持如下格式
     (
     AVAssetExportPresetLowQuality,
     AVAssetExportPreset960x540,
     AVAssetExportPreset640x480,
     AVAssetExportPresetMediumQuality,
     AVAssetExportPreset1920x1080,
     AVAssetExportPreset1280x720,
     AVAssetExportPresetHighestQuality,
     AVAssetExportPresetAppleM4A
     )
     */
    //注意,这个地方设置的模式/分辨率大小将影响你后面拍摄照片/视频的大小,
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate && AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    //视频编码
    if(captureOutput == _videoOutput)
    {
        [_compressionSession encodeSampleBuffer:sampleBuffer forceKeyframe:NO];
        
    }
    //音频编码
    else if (captureOutput == _audioOutput)
    {
//        char szBuf[4096];
//        int  nSize = sizeof(szBuf);
//        if([_aacEncoder encoderAAC:sampleBuffer aacData:szBuf aacLen:&nSize])
//        {
//            
//        }
    }
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
