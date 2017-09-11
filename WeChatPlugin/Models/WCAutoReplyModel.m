//
//  WCAutoReplyModel.m
//  WeChatPlugin
//
//  Created by YJHou on 2017/9/6.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import "WCAutoReplyModel.h"

@implementation WCAutoReplyModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.keyword = dict[@"keyword"];
        self.replyContent = dict[@"replyContent"];

        self.replyEnable = [dict[@"replyEnable"] boolValue];
        self.replyGroupEnable = [dict[@"replyGroupEnable"] boolValue];
        self.enableRegex = [dict[@"enableRegex"] boolValue];
    }
    return self;
}

- (NSDictionary *)dictionary {
    
    return @{@"replyEnable": @(self.replyEnable),
             @"keyword": self.keyword,
             @"replyContent": self.replyContent,
             @"replyGroupEnable": @(self.replyGroupEnable),
             @"enableRegex": @(self.enableRegex)
             };
}

- (BOOL)hasEmptyKeywordOrReplyContent {
    return (self.keyword == nil || self.replyContent == nil || [self.keyword isEqualToString:@""] || [self.replyContent isEqualToString:@""]);
}


@end
