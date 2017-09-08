//
//  YJRemoteControlController.m
//  WeChatPlugin
//
//  Created by YJHou on 2017/7/9.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import "YJRemoteControlController.h"
#import "WeChatPluginConfig.h"
#import "WCRemoteControlModel.h"

@implementation YJRemoteControlController

+ (void)executeRemoteControlCommandWithMessage:(NSString *)message {
    
    // 1.获取模型数组
    NSArray *remoteControlModels = [WeChatPluginConfig sharedInstance].remoteControlModels;
    
    [remoteControlModels enumerateObjectsUsingBlock:^(NSArray *subModels, NSUInteger index, BOOL * _Nonnull stop) {
        
        [subModels enumerateObjectsUsingBlock:^(WCRemoteControlModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if (model.enable && ![model.keyword isEqualToString:@""] && [message isEqualToString:model.keyword]) {
                if ([model.function isEqualToString:SCREEN_PROTECT] || [model.function isEqualToString:LOCK_SCREENT]) {
                    [self executeShellCommand:model.executeCommand];
                } else {
                    // 2.拼接相关参数，执行 AppleScript
                    NSString *command = [NSString stringWithFormat:@"%@ %@", YJRemoteControlAppleScript, model.executeCommand];
                    [self executeShellCommand:command];
                    // 3.有些程序在第一次时会无法关闭，需要再次关闭
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if ([model.function isEqualToString:QUIT_ALL_APP]) {
                            NSString *command = [NSString stringWithFormat:@"%@ %@",YJRemoteControlAppleScript, model.executeCommand];
                            [self executeShellCommand:command];
                        }
                    });
                }
            }
        }];
    }];
}


+ (void)executeShellCommand:(NSString *)cmd {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[@"-c", cmd]];
    [task launch];
}

@end
