//
//  YJAutoReplyWindowController.h
//  WeChatPlugin
//
//  Created by YJHou on 2017/7/9.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WCAutoReplyModel;
@interface YJAutoReplyWindowController : NSWindowController

@property (nonatomic, copy) WCAutoReplyModel *model;

@end
