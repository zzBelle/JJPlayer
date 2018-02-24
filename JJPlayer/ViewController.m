//
//  ViewController.m
//  JJPlayer
//
//  Created by 十月 on 2018/1/30.
//  Copyright © 2018年 Belle. All rights reserved.
//


#import "ViewController.h"
#import "JJRemotePlayer.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *costTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *loadSlider;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation ViewController
//http://audio.xmcdn.com/group22/M0B/60/85/wKgJM1g1g0ShoPalAJiI5nj3-yY200.m4a


- (void)viewDidLoad {
    [super viewDidLoad];
    [self timer];
}

- (NSTimer *)timer {
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}

- (void)update {
    
    self.costTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd",(int)[JJRemotePlayer shareInstance].currentTime / 60,(int)[JJRemotePlayer shareInstance].currentTime % 60 ];
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd",(int)[JJRemotePlayer shareInstance].duration / 60,(int)[JJRemotePlayer shareInstance].duration % 60];
    
    self.loadSlider.value = [JJRemotePlayer shareInstance].loadProgress;
    self.playSlider.value = [JJRemotePlayer shareInstance].progress;
    self.volumeSlider.value = [JJRemotePlayer shareInstance].volume;
    NSLog(@"%zd",[JJRemotePlayer shareInstance].state);
    
}

- (IBAction)play:(id)sender {
    //换成你需要的
    NSURL *url = [NSURL URLWithString:@"http://fs.w.kugou.com/201802241102/68b34d7f3172f4220f667ae6f1195569/G002/M08/0F/11/ooYBAFT7QiGAEG4tAEggADragcw473.mp3"];

    [[JJRemotePlayer shareInstance] playerWithUrl:url isCache:NO];
}

- (IBAction)pause:(id)sender {
    [[JJRemotePlayer shareInstance] pause];
    
}

- (IBAction)resume:(id)sender {
    [[JJRemotePlayer shareInstance] resume];
}

- (IBAction)stop:(id)sender {
    [[JJRemotePlayer shareInstance] stop];
}

- (IBAction)fasterPlay:(id)sender {
    [[JJRemotePlayer shareInstance] seekWithTimeInterval:15];
}


- (IBAction)progress:(UISlider *)sender {
    [[JJRemotePlayer shareInstance] seekToProgress:sender.value];
}

- (IBAction)doubleRate:(id)sender {
    [JJRemotePlayer shareInstance].rate = 2.0;
}

- (IBAction)volume:(UISlider *)sender {
    [JJRemotePlayer shareInstance].volume = sender.value;
}

- (IBAction)mute:(id)sender {
    [JJRemotePlayer shareInstance].muted =  ![JJRemotePlayer shareInstance].muted;
}

@end
