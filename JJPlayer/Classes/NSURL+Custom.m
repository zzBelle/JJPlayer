//
//  NSURL+Custom.m
//  JJPlayer
//
//  Created by 十月 on 2018/2/2.
//  Copyright © 2018年 Belle. All rights reserved.
//

#import "NSURL+Custom.h"

@implementation NSURL (Custom)
- (NSURL *)jjUrl {
    //http:WWW
    //jj:WWW
    NSURLComponents *compents = [NSURLComponents componentsWithString:self.absoluteString];
    compents.scheme = @"JJ";
    return  compents.URL;
}
@end
