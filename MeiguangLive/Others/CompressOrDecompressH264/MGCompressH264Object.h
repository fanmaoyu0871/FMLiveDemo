//
//  MGCompressH264Object.h
//  MeiguangLive
//
//  Created by 范茂羽 on 16/5/19.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MGCompressH264ObjectDelegate <NSObject>

-(void)gotPacket:(NSData*)data type:(uint8_t)type timestamp:(uint32_t)timestamp;

@end

@interface MGCompressH264Object : NSObject

-(void)compressH264:(CMSampleBufferRef)sampleBuffer delegate:(id<MGCompressH264ObjectDelegate>)delegate;

@end
