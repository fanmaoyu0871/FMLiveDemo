//
//  MGSocketManager.m
//  MeiguangLive
//
//  Created by 范茂羽 on 16/5/23.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "MGSocketManager.h"


@implementation MGSocketManager

+(instancetype)sharedManager
{
    static MGSocketManager *manager;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        manager = [[self alloc]init];
    });
    
    return manager;
}

// socket连接
-(void)socketConnectHost{
    
    self.socket    = [[AsyncSocket alloc] initWithDelegate:self];
    
    NSError *error = nil;
    
    [self.socket connectToHost:self.socketHost onPort:self.socketPort withTimeout:3 error:&error];
    
}

// 切断socket
-(void)cutOffSocket{
    
    self.socket.userData = SocketOfflineByUser;// 声明是由用户主动切断
        
    [self.socket disconnect];
}

//发送数据
-(void)sendData:(NSData*)data timeout:(NSTimeInterval)timeout tag:(NSInteger)tag
{
    [self.socket writeData:data withTimeout:timeout tag:tag];
}

//接收数据
-(void)recvData:(NSTimeInterval)timeout tag:(NSInteger)tag
{
    [self.socket readDataWithTimeout:timeout tag:tag];
}



#pragma mark - AsyncSocketDelegate
//连接成功代理
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"tcp 连接成功");
}

//掉线代理
-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"sorry the connect is failure %ld",sock.userData);
    if (sock.userData == SocketOfflineByServer) {
        // 服务器掉线，重连
        [self socketConnectHost];
    }
    else if (sock.userData == SocketOfflineByUser) {
        // 如果由用户断开，不进行重连
        return;
    }
    
}

//发送数据代理
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"已发送数据");
}

//接手数据代理
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"已接收数据");
}

@end
