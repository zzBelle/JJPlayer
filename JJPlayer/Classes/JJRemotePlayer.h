//
//  JJRemotePlayer.h
//  JJPlayer
//
//  Created by 十月 on 2018/1/30.
//  Copyright © 2018年 Belle. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JJRemoteAudioPlayerState) {
    JJRemoteAudioPlayerStateUnknow  = 0,
    JJRemoteAudioPlayerStateLoading = 1,
    JJRemoteAudioPlayerStatePlaying = 2,
    JJRemoteAudioPlayerStateStopped = 3,
    JJRemoteAudioPlayerStatePause = 4,
    JJRemoteAudioPlayerStateFailed = 5
};

@interface JJRemotePlayer : NSObject
+ (instancetype)shareInstance;

- (void)playerWithUrl:(NSURL *)url isCache:(BOOL)isCache;

- (void)pause;

- (void)resume;

- (void)stop;

- (void)seekWithTimeInterval:(NSTimeInterval)timerInterval;

- (void)seekToProgress:(float)progress;

@property (nonatomic, assign) float rate;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) float volume;
@property (nonatomic, weak, readonly) NSURL *url;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) float progress;
@property (nonatomic, assign, readonly) float loadProgress;

@property (nonatomic, assign, readonly) JJRemoteAudioPlayerState state;
@end
