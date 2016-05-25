//
//  MGAACEncoder.h
//  MeiguangLive
//
//  Created by 范茂羽 on 16/5/25.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGAACEncoder : NSObject

-(BOOL)encoderAAC:(CMSampleBufferRef)sampleBuffer aacData:(char*)aacData aacLen:(int*)aacLen;

@end
