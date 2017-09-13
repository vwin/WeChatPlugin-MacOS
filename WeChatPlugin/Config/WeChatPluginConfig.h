//
//  WeChatPluginConfig.h
//  WeChatPlugin
//
//  Created by YJHou on 2017/7/9.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 防止撤销是否可用 */
static NSString *const YJPreventRevokeEnableKey = @"YJPreventRevokeEnableKey";

/** 单聊撤销自动发出是否可用 */
static NSString *const YJReplyPreventRevokeEnableKey = @"YJReplyPreventRevokeEnableKey";

/** 自动发出消息随机延时 */
static NSString *const kYJReplyRandomDelayEnableKey = @"kYJReplyRandomDelayEnableKey";

/** 自动回复保存地址 */
static NSString *const YJAutoReplyModelsFilePath = @"/Applications/WeChat.app/Contents/MacOS/WeChatPlugin.framework/Resources/YJAutoReplyModels.plist";
/** 远程控制的配置文件地址 */
static NSString * const YJRemoteControlModelsFilePath = @"/Applications/WeChat.app/Contents/MacOS/WeChatPlugin.framework/Resources/YJRemoteControlCommands.plist";

/** 执行 AppleScript */
static NSString * const YJRemoteControlAppleScript = @"osascript /Applications/WeChat.app/Contents/MacOS/WeChatPlugin.framework/Resources/YJRemoteControlScript.scpt";

#define LOCK_SCREENT @"锁屏"
#define SCREEN_PROTECT @"屏幕保护"
#define QUIT_ALL_APP @"退出所有程序"

#pragma mark - Function
#define WECHAT_PLUGIN_MENU_TITLE @"微信小助手"
#define START_PREVENTREVOKE @"开启消息防撤回"
#define START_AUTO_REPLY @"自动回复设置"
#define START_NEW_WECHAT @"再登录一个微信"
#define REMORT_CONTROL_MAC @"远程控制Mac"

#define kINTERCEPT_A_MESSAGE @"拦截到一条非文本撤回消息"
#define kREVOKE_YOUSELF_A_MESSAGE @"拦截到你撤回了一条消息:内容如下\n"
#define kREVOKE_A_MESSAGE @"拦截到一条撤回消息:内容如下\n"

@interface WeChatPluginConfig : NSObject

/**
 单例

 @return 单例对象
 */
+ (instancetype)sharedInstance;

@property (nonatomic, assign) BOOL preventRevokeEnable;             /**< 防止撤销是否可用 */
@property (nonatomic, assign) BOOL replyPreventRevokeEnable;        /**< 撤销自动单聊发出是否可用 */
@property (nonatomic, assign) BOOL replyRandomDelayEnable;          /**< 自动发出消息随机延时 */

@property (nonatomic, strong) NSMutableArray *autoReplyModels;      /**< 自动回复数组 */
@property (nonatomic, strong) NSMutableArray *remoteControlModels;  /**< 远程控制数组 */

/**
 保存 自动回复
 */
- (void)saveAutoReplyModelsToFile;

/**
 保存 远程控制
 */
- (void)saveRemoteControlModelsToFile;


@end
