//
//  MGSocketManager.h
//  MeiguangLive
//
//  Created by 范茂羽 on 16/5/23.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/AsyncSocket.h>

typedef NS_ENUM(NSInteger, SocketOfflineType)
{
    SocketOfflineByServer,// 服务器掉线，默认为0
    SocketOfflineByUser,  // 用户主动cut
};

@interface MGSocketManager : NSObject

@property (nonatomic, strong) AsyncSocket    *socket;       // socket
@property (nonatomic, copy  ) NSString       *socketHost;   // socket的Host
@property (nonatomic, assign) UInt16         socketPort;    // socket的prot


+(instancetype)sharedManager;

// socket连接
-(void)socketConnectHost;

// 切断socket
-(void)cutOffSocket;

//发送数据
-(void)sendData:(NSData*)data timeout:(NSTimeInterval)timeout tag:(NSInteger)tag;

//接收数据
-(void)recvData:(NSTimeInterval)timeout tag:(NSInteger)tag;

@end
