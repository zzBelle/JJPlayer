//
//  JJResourceLoader.m
//  JJPlayer
//
//  Created by 十月 on 2018/2/2.
//  Copyright © 2018年 Belle. All rights reserved.
//

#import "JJResourceLoader.h"

@implementation JJResourceLoader
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"%@",loadingRequest);
    //下载资源
    NSData *data = [NSData dataWithContentsOfFile:@"" options:NSDataReadingMappedIfSafe error:nil];
    
    //把资源传递给外界 （资源的组织者--> 播放器）
    loadingRequest.contentInformationRequest.contentType = @"public.mp3";
    loadingRequest.contentInformationRequest.contentLength = 4702459;
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long requestLength = loadingRequest.dataRequest.requestedLength;
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    [loadingRequest.dataRequest respondWithData:subData];
    
    return YES;
}

@end
