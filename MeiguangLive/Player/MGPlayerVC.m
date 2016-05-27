//
//  MGPlayerVC.m
//  MeiguangLive
//
//  Created by 范茂羽 on 16/5/26.
//  Copyright © 2016年 范茂羽. All rights reserved.
//

#import "MGPlayerVC.h"
#import "Vitamio.h"

@interface MGPlayerVC ()<VMediaPlayerDelegate>

@end

@implementation MGPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *videoUrl = @"rtmp://ms.jeesea.com/meiguang/I10001_ST2_t1464255593435";
    
    VMediaPlayer *mMPayer = [VMediaPlayer sharedInstance];
    [mMPayer setupPlayerWithCarrierView:self.view withDelegate:self];
    
    [mMPayer setDataSource:[NSURL URLWithString:videoUrl] header:nil];

    [mMPayer prepareAsync];
    
}



- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    [player start];
}


- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
    [player reset];
}


- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
