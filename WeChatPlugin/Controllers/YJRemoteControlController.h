//
//  YJRemoteControlController.h
//  WeChatPlugin
//
//  Created by YJHou on 2017/7/9.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJRemoteControlController : NSObject

/**
 执行响应命令

 @param message 命令描述
 */
+ (void)executeRemoteControlCommandWithMessage:(NSString *)message;

/**
 执行shell命令

 @param cmd 命令
 */
+ (void)executeShellCommand:(NSString *)cmd;

@end
