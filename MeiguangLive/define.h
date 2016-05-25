//
//  define.h
//  MeiguangLive
//
//  Created by 范茂羽 on 16/5/19.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#ifndef define_h
#define define_h

typedef struct tag_PackHeader
{
    unsigned int mark;			// 标识/** byte 4 */
    unsigned int head_len;		// 头长度 /** byte 4 */
    unsigned int data_len;		// data数据长度 /** byte 4 */
    long long timestamp;		// 时间戳 /** byte 8 */
    unsigned char type;			// 类型 /** byte 1 */
    unsigned int nums;			// 片段数 /** byte 4 */
    unsigned int index;			// 片段序号 /** byte 4 */
    unsigned char ratention[8]; 	// 保留字段 /** byte 8 */
    unsigned char key[32];		// Key, Md5加密 /** byte 32 */
}PackHeader;

typedef enum tag_PackType
{
    PT_NULL = 0x00,
    PT_HEART,					// 心跳包
    PT_LIVE_START,				// 开启直播
    PT_LIVE_STOP,				// 停止直播
    PT_LIVE_PAUSE,				// 暂停直播
    PT_LIVE_VIDEO,				// 直播者的视频流
    PT_LIVE_AUDIO,				// 直播者的音频流
    PT_LIVE_TEXT,				// 直播者的文本命令
    PT_WATCH_ENTER = 0x80,		// 进入直播间
    PT_WATCH_LEAVE,				// 离开直播间
    PT_WATCH_VIDEO,				// 观看者的视频流
    PT_WATCH_AUDIO,				// 观看者的音频流
    PT_WATCH_TEXT,				// 观察者的文本命令
    PT_WATCH_GIFT				// 发送礼物
} PackType;


#endif /* define_h */
