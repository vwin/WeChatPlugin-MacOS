//
//  WCRemoteControlModel.m
//  WeChatPlugin
//
//  Created by YJHou on 2017/9/6.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import "WCRemoteControlModel.h"

@implementation WCRemoteControlModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.enable = [dict[@"enable"] boolValue];
        self.keyword = dict[@"keyword"];
        self.function = dict[@"function"];
        self.executeCommand = dict[@"executeCommand"];
    }
    return self;
}

- (NSDictionary *)dictionary {
    return @{@"enable": @(self.enable),
             @"keyword": self.keyword,
             @"function": self.function,
             @"executeCommand": self.executeCommand};
}

- (BOOL)hasEmptyKeywordOrExecuteCommand {
    return (self.keyword == nil || self.executeCommand == nil || [self.keyword isEqualToString:@""] || [self.executeCommand isEqualToString:@""]);
}

@end
