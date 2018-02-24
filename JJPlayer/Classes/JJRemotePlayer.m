//
//  JJRemotePlayer.m
//  JJPlayer
//
//  Created by 十月 on 2018/1/30.
//  Copyright © 2018年 Belle. All rights reserved.
//

#import "JJRemotePlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "JJResourceLoader.h"
#import "NSURL+Custom.h"

@interface JJRemotePlayer (){
    BOOL _isUserPause;
}
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) JJResourceLoader *loader;
@end

@implementation JJRemotePlayer

static JJRemotePlayer *_shareInstance;

+ (instancetype)shareInstance {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [[self alloc] init];

        });
    }
    return _shareInstance;
}


//- (void)playerWithUrl:(NSURL *)url {
- (void)playerWithUrl:(NSURL *)url isCache:(BOOL)isCache {


    if ([url isEqual:self.url]) {
        if (self.state == JJRemoteAudioPlayerStateLoading)  {
            return;
        }
        if (self.state == JJRemoteAudioPlayerStatePlaying) {
            return;
        }
        if (self.state ==JJRemoteAudioPlayerStatePause) {
            [self resume];//继续
            return;
        }
    }
    
    self.url = url; 
    //    创建播放对象

    NSURL *resultUrl = url;
    if (isCache) {
        resultUrl = [url jjUrl];//需要缓存
    }
    //  1.资源请求
    //  AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    AVURLAsset *asset = [AVURLAsset assetWithURL:resultUrl];
    if (self.player.currentItem) {
        [self clearObserver];
    }
    self.loader = [JJResourceLoader new];
    //需要自定义协议
    [asset.resourceLoader setDelegate:self.loader queue:dispatch_get_main_queue()];
    //  2.资源组织 AVPlayerItem中有一个状态 如果资源的组织者告诉监听的资源已经组织完成才可以播放
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playInterrupt)     name:AVPlayerItemPlaybackStalledNotification  object:nil];
    //  3.资源播放
    self.player = [AVPlayer playerWithPlayerItem:item];
//    一般不是直接调用的
//    [player play];
}

- (void)pause {
    [self.player pause];
    if (self.player) {
        _isUserPause = YES;
        self.state = JJRemoteAudioPlayerStatePause;

    }
}

- (void)resume {
    [self.player play];
    if (self.player.rate != 0.0) {
        _isUserPause = NO;
        self.state = JJRemoteAudioPlayerStatePlaying;
    }
}

- (void)stop {
    [self.player pause];
    [self clearObserver];
    self.player = nil;
    _isUserPause = YES;

    self.state = JJRemoteAudioPlayerStateStopped;
}

- (void)seekWithTimeInterval:(NSTimeInterval)timerInterval {
    //(CMTime)是影片时间   --> 转换成秒
//    CMTimeGetSeconds(<#CMTime time#>)
    //秒 --> 影片时间
//    CMTimeMake(<#int64_t value#>, <#int32_t timescale#>)
//    1.获取当前的播放时间 + 15 放到CMTime中
    NSTimeInterval sec = CMTimeGetSeconds(self.player.currentItem.currentTime) + timerInterval;
    
    [self.player seekToTime:CMTimeMakeWithSeconds(sec, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"代表确定加载改时间段的资源");
        }else {
            NSLog(@"取消加载该时间段的资源");
        }
    }];
}

- (void)seekToProgress:(float)progress {
    NSTimeInterval sec = CMTimeGetSeconds(self.player.currentItem.duration) * progress;
    [self.player seekToTime:CMTimeMakeWithSeconds(sec, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"代表确定加载改时间段的资源");
        }else {
            NSLog(@"取消加载该时间段的资源");
        }
    }];
}


- (void)setRate:(float)rate {
    self.player.rate = rate;
}

- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

- (void)setVolume:(float)volume {
    if (volume > 0.0) {
        self.muted = NO;
    }
    [self.player setVolume:volume];
}

- (void)setUrl:(NSURL *)url {
    if ([url isEqual:self.url]) {
        //播放器已经存在 暂停-> 恢复
    }
}

- (void)setState:(JJRemoteAudioPlayerState)state {
    _state = state;
}


- (float)rate {
    return self.player.rate;
}

- (BOOL)muted {
    return self.player.muted;
}

- (float)volume {
    return self.player.volume;
}

- (NSTimeInterval)duration {
    
    NSTimeInterval totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
    if (isnan(totalTime)) {
        return 0.0;
    }
    return totalTime;
}

- (NSTimeInterval)currentTime {
    NSTimeInterval currentTime =CMTimeGetSeconds(self.player.currentItem.currentTime);
    if (isnan(currentTime)) {
        return 0.0;
    }
    return currentTime;
}


- (float)progress {
    if (self.duration == 0.0) {
        return 0;
    }
    
    return self.currentTime / self.duration;
}

- (float)loadProgress {
    if (self.duration == 0.0) {
        return 0;
    }
    //CMTimeRangeValue 时间区间
    CMTimeRange range = [self.player.currentItem.loadedTimeRanges.lastObject CMTimeRangeValue];
    CMTime loadTime = CMTimeAdd(range.start, range.duration);
    NSTimeInterval loadTimeSec = CMTimeGetSeconds(loadTime);
    return (loadTimeSec / self.duration);
}

- (void)playInterrupt {
    NSLog(@"被打断");
    self.state = JJRemoteAudioPlayerStatePause;//暂停

}

- (void)playEnd {
    NSLog(@"播放完成");
    self.state = JJRemoteAudioPlayerStateStopped;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
       AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        
        switch (status) {
            case AVPlayerItemStatusUnknown:
                NSLog(@"不做处理，可能是资源无效");
                self.state = JJRemoteAudioPlayerStateFailed;
                break;
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"资源已经准备好 可以播放");
//                [self.player play];
                [self resume];
                break;
            case AVPlayerItemStatusFailed:
                NSLog(@"资源加载失败");
                 self.state = JJRemoteAudioPlayerStateFailed;
                break;
                
            default:
                break;
        }
    }
    
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        BOOL playbackLikelyToKeepUp = [change[NSKeyValueChangeNewKey] boolValue ];
        if (playbackLikelyToKeepUp) {
            NSLog(@"可以播放了加载好了");
//            是否需要自动播放 不能确定的
//            手动暂停 优先级最高 > 自动播放
            if (!_isUserPause ) {
                [self resume];
            }
            
        }
        NSLog(@"资源正在加载");
        self.state = JJRemoteAudioPlayerStateLoading;
    }
}

- (void)clearObserver {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
