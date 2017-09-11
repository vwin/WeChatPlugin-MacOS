//
//  WeChatPlugin.h
//  WeChatPlugin
//
//  Created by YJHou on 2017/6/20.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for WeChatPlugin.
FOUNDATION_EXPORT double WeChatPluginVersionNumber;

//! Project version string for WeChatPlugin.
FOUNDATION_EXPORT const unsigned char WeChatPluginVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <WeChatPlugin/PublicHeader.h>

#pragma mark - 微信原始的部分类与方法
@interface MMMainWindowController : NSObject
- (void)onAuthOK;
- (void)onLogOut;
@end

@interface MessageService : NSObject

/**
 撤回消息的方法

 @param arg1 参数
 */
- (void)onRevokeMsg:(id)arg1;

/**
 消息同步方法

 @param arg1 同步内容
 @param arg2 是否是第一次同步
 */
- (void)OnSyncBatchAddMsgs:(NSArray *)arg1 isFirstSync:(BOOL)arg2;
- (id)SendTextMessage:(id)arg1 toUsrName:(id)arg2 msgText:(id)arg3 atUserList:(id)arg4;
- (id)GetMsgData:(id)arg1 svrId:(long)arg2;
- (void)AddLocalMsg:(id)arg1 msgData:(id)arg2;
@end

@interface MMServiceCenter : NSObject

+ (id)defaultCenter;
- (id)getService:(Class)arg1;

@end

@interface SKBuiltinString_t : NSObject
@property(retain, nonatomic, setter=SetString:) NSString *string; // @synthesize string;
@end

@interface AddMsg : NSObject
@property(retain, nonatomic, setter=SetContent:) SKBuiltinString_t *content; // @synthesize content;
@property(retain, nonatomic, setter=SetFromUserName:) SKBuiltinString_t *fromUserName; // @synthesize fromUserName;
@property(nonatomic, setter=SetMsgType:) int msgType; // @synthesize msgType;
@property(retain, nonatomic, setter=SetToUserName:) SKBuiltinString_t *toUserName; // @synthesize toUserName;
@property (nonatomic, assign) unsigned int createTime;
@end

@interface WeChat : NSObject
+ (id)sharedInstance;
@end

@interface ContactStorage : NSObject
- (id)GetSelfContact;
- (id)GetContact:(id)arg1;
@end

@interface WCContactData : NSObject
@property(retain, nonatomic) NSString *m_nsUsrName; // @synthesize m_nsUsrName;
@property(nonatomic) unsigned int m_uiFriendScene;  // @synthesize m_uiFriendScene;
@end

@interface MessageData : NSObject

- (id)initWithMsgType:(long long)arg1;
@property(retain, nonatomic) NSString *fromUsrName;
@property(retain, nonatomic) NSString *toUsrName;
@property(retain, nonatomic) NSString *msgContent;
@property(retain, nonatomic) NSString *msgPushContent;
@property(nonatomic) int messageType;
@property(nonatomic) int msgStatus;
@property(nonatomic) int msgCreateTime;
@property(nonatomic) int mesLocalID;
@end

@interface CUtility : NSObject

/**
 是否已经开启微信

 @return 开启一个返回 YES
 */
+ (BOOL)HasWechatInstance;
+ (unsigned long long)getFreeDiskSpace;
@end

@interface PathUtility : NSObject
+ (id)getSysCachePath;
+ (id)getSysDocumentPath;
+ (id)getSysLibraryPath;
@end

@interface MemoryMappedKV : NSObject
+ (id)mappedKVPathWithID:(id)arg1;
@end

@interface JTStatisticManager : NSObject
@property(retain, nonatomic) NSString *statFilePath;
@end
