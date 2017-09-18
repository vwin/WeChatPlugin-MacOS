//
//  NSObject+WeChatHook.m
//  WeChatPlugin
//
//  Created by YJHou on 2017/6/20.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import "NSObject+WeChatHook.h"
#import "WeChatPlugin.h"
#import "WeChatPluginConfig.h"
#import "YJRemoteControlController.h"
#import "YJAutoReplyWindowController.h"
#import "YJRemoteControlWindowController.h"
#import "WCXMLParser.h"
#import "WCAutoReplyModel.h"
#import "WCRemoteControlModel.h"
#import "WCTools.h"

/** 自动回复窗口的关联 key */
static char kYJAutoReplyWindowControllerKey;
/** 远程控制窗口的关联 key */
static char kYJRemoteControlWindowControllerKey;

/** 保存撤销的内容 */
//static char const *const kAutoSavePreventRevokeKey = "kAutoSavePreventRevokeKey";

/** 定时器 */
static char const *const kTimerKey = "kTimerKey";

@interface NSObject ()

@property (nonatomic, strong) NSTimer *timer; /**< 限制规定时间内请求次数 */

@end

@implementation NSObject (WeChatHook)

+ (void)hookWeChat{
    // 微信撤回消息
    yj_hookInstanceMethod(objc_getClass("MessageService"), @selector(onRevokeMsg:), [self class], @selector(hook_onRevokeMsg:));
    // 微信消息同步
    yj_hookInstanceMethod(objc_getClass("MessageService"), @selector(OnSyncBatchAddMsgs:isFirstSync:), [self class], @selector(hook_OnSyncBatchAddMsgs:isFirstSync:));
    // 微信多开
    yj_hookClassMethod(objc_getClass("CUtility"), @selector(HasWechatInstance), [self class], @selector(hook_HasWechatInstance));
    // 注入菜单
    [self _setUp];
    [self replaceAboutFilePathMethod];
}

+ (void)_setUp{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addAssistantMenuItem];
    });
}

#pragma mark -  菜单栏添加 menuItem
+ (void)addAssistantMenuItem {
    // 1.消息防撤回
    NSMenuItem *preventRevokeItem = [[NSMenuItem alloc] initWithTitle:START_PREVENTREVOKE action:@selector(mainMenuClickAction:) keyEquivalent:@"t"];
    preventRevokeItem.state = [[WeChatPluginConfig sharedInstance] preventRevokeEnable];
    preventRevokeItem.tag = 101;
    
    // 2.自动回复
    NSMenuItem *autoReplyItem = [[NSMenuItem alloc] initWithTitle:START_AUTO_REPLY action:@selector(mainMenuClickAction:) keyEquivalent:@"k"];
    autoReplyItem.tag = 102;
    
    // 3.登录新微信
    NSMenuItem *newWeChatItem = [[NSMenuItem alloc] initWithTitle:START_NEW_WECHAT action:@selector(mainMenuClickAction:) keyEquivalent:@"N"];
    newWeChatItem.tag = 103;
    
    // 4.远程控制
    NSMenuItem *commandItem = [[NSMenuItem alloc] initWithTitle:REMORT_CONTROL_MAC action:@selector(mainMenuClickAction:) keyEquivalent:@"C"];
    commandItem.tag = 104;
    
    NSMenu *subMenu = [[NSMenu alloc] initWithTitle:WECHAT_PLUGIN_MENU_TITLE];
    [subMenu addItem:preventRevokeItem];
    [subMenu addItem:autoReplyItem];
    [subMenu addItem:commandItem];
    [subMenu addItem:newWeChatItem];
    
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setTitle:WECHAT_PLUGIN_MENU_TITLE];
    [menuItem setSubmenu:subMenu];
    
    [[[NSApplication sharedApplication] mainMenu] addItem:menuItem];
}

- (void)mainMenuClickAction:(NSMenuItem *)item {
    
    if (item.tag == 101) { // 防撤回
        
        item.state = !item.state;
        [[WeChatPluginConfig sharedInstance] setPreventRevokeEnable:item.state];
        
    }else if (item.tag == 102){ // 自动回复
        
        WeChat *wechat = [objc_getClass("WeChat") sharedInstance];
        YJAutoReplyWindowController *autoReplyWC = objc_getAssociatedObject(wechat, &kYJAutoReplyWindowControllerKey);
        
        if (!autoReplyWC) {
            autoReplyWC = [[YJAutoReplyWindowController alloc] initWithWindowNibName:@"YJAutoReplyWindowController"];
            objc_setAssociatedObject(wechat, &kYJAutoReplyWindowControllerKey, autoReplyWC, OBJC_ASSOCIATION_RETAIN);
        }
        
        [autoReplyWC showWindow:autoReplyWC];
        [autoReplyWC.window center];
        [autoReplyWC.window makeKeyWindow];

    }else if (item.tag == 103){ // 登录新微信
        
        [YJRemoteControlController executeShellCommand:@"open -n /Applications/WeChat.app"];

    }else if (item.tag == 104){ // 远程控制
        
        WeChat *wechat = [objc_getClass("WeChat") sharedInstance];
        YJRemoteControlWindowController *remoteControlWC = objc_getAssociatedObject(wechat, &kYJRemoteControlWindowControllerKey);
        
        if (!remoteControlWC) {
            remoteControlWC = [[YJRemoteControlWindowController alloc] initWithWindowNibName:@"YJRemoteControlWindowController"];
            objc_setAssociatedObject(wechat, &kYJRemoteControlWindowControllerKey, remoteControlWC, OBJC_ASSOCIATION_RETAIN);
        }
        
        [remoteControlWC showWindow:remoteControlWC];
        [remoteControlWC.window center];
        [remoteControlWC.window makeKeyWindow];
        
    }
}

#pragma mark - hook 方法

#pragma mark - hook 微信撤回消息方法
- (void)hook_onRevokeMsg:(id)msg {
    
    if (msg && [[WeChatPluginConfig sharedInstance] preventRevokeEnable]) {
        
        NSString *msgContent = [msg substringFromIndex:[msg rangeOfString:@"<sysmsg"].location];
        
        // xml 转 dict
        NSError *error;
        NSDictionary *msgDict = [WCXMLParser dictionaryForXMLString:msgContent error:&error];
        
        if (!error && msgDict && msgDict[@"sysmsg"] && msgDict[@"sysmsg"][@"revokemsg"]) {
            
            NSString *newmsgid = msgDict[@"sysmsg"][@"revokemsg"][@"newmsgid"][@"text"];
            
            NSString *session =  msgDict[@"sysmsg"][@"revokemsg"][@"session"][@"text"];
            
            // 获取原始的撤回提示消息
            MessageService *msgService = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MessageService")];
            MessageData *revokeMsgData = [msgService GetMsgData:session svrId:[newmsgid integerValue]];
            
            // 获取自己的联系人信息
            ContactStorage *contactStorage = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("ContactStorage")];
            WCContactData *selfContact = [contactStorage GetSelfContact];
            
            NSString *newMsgContent = kINTERCEPT_A_MESSAGE;
            NSString *replyContent = @"";
            // 判断是否是自己发起撤回
            if ([selfContact.m_nsUsrName isEqualToString:revokeMsgData.fromUsrName]) { // 自己撤回的
                if (revokeMsgData.messageType == 1) { // 判断是否为文本消息
                    newMsgContent = [NSString stringWithFormat:@"@%@%@", kREVOKE_YOUSELF_A_MESSAGE, revokeMsgData.msgContent];
                }
            } else {
                if (![revokeMsgData.msgPushContent isEqualToString:@""]) {
                    replyContent = revokeMsgData.msgPushContent;
                    newMsgContent = [NSString stringWithFormat:@"%@%@", kREVOKE_A_MESSAGE, replyContent];
                } else if (revokeMsgData.messageType == 1) {
                    NSRange range = [revokeMsgData.msgContent rangeOfString:@":\n"];
                    NSString *content = [revokeMsgData.msgContent substringFromIndex:range.location + range.length];
                    if (range.length > 0) {
                        replyContent = content;
                        newMsgContent = [NSString stringWithFormat:@"%@%@", kREVOKE_A_MESSAGE, replyContent];
                    }
                }
            }
            
            MessageData *newMsgData = ({
                MessageData *msg = [[objc_getClass("MessageData") alloc] initWithMsgType:0x2710];
                [msg setFromUsrName:revokeMsgData.toUsrName];
                [msg setToUsrName:revokeMsgData.fromUsrName];
                [msg setMsgStatus:4];
                [msg setMsgContent:newMsgContent];
                [msg setMsgCreateTime:revokeMsgData.msgCreateTime];
                [msg setMesLocalID:[revokeMsgData mesLocalID]];
                
                msg;
            });
            
            // 单聊自动发回撤销开启 toUsrName 他人发给聊天室的
            if ([WeChatPluginConfig sharedInstance].replyPreventRevokeEnable && ![newMsgData.toUsrName containsString:@"@chatroom"] && replyContent != nil) {
                
                [self _autoRandomSendTextMessageWithNsUsrName:selfContact.m_nsUsrName toUsrName:newMsgData.toUsrName msgContent:replyContent];
                
            }else{ // 添加本地撤回消息
                [msgService AddLocalMsg:session msgData:newMsgData];
            }
            return;
        }
    }
    
    // 调用微信内部方法
    [self hook_onRevokeMsg:msg];
}

#pragma mark - hook 微信消息同步
- (void)hook_OnSyncBatchAddMsgs:(NSArray *)msgs isFirstSync:(BOOL)arg2 {
    
    // 调用微信内部的消息同步方法
    [self hook_OnSyncBatchAddMsgs:msgs isFirstSync:arg2];
    
    [msgs enumerateObjectsUsingBlock:^(AddMsg *addMsg, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *now = [NSDate date];
        NSTimeInterval nowSecond = now.timeIntervalSince1970;
        if (nowSecond - addMsg.createTime > 180) { // 若是3分钟前的消息，则不进行自动回复与远程控制
            return;
        }
        
        // 1.自动回复
        [self autoReplyWithMsg:addMsg];
        
        ContactStorage *contactStorage = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("ContactStorage")];
        WCContactData *selfContact = [contactStorage GetSelfContact];
        if ([addMsg.fromUserName.string isEqualToString:selfContact.m_nsUsrName] &&
            [addMsg.toUserName.string isEqualToString:selfContact.m_nsUsrName]) {
            [self remoteControlWithMsg:addMsg];
        }
    }];
}

#pragma mark - hook 微信是否已启动
+ (BOOL)hook_HasWechatInstance {
    return NO;
}

#pragma mark - Support
/** 自动回复消息 */
- (void)autoReplyWithMsg:(AddMsg *)addMsg {
    
    if (addMsg.msgType != 1 && addMsg.msgType != 3) return;
    
    ContactStorage *contactStorage = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("ContactStorage")];
    WCContactData *msgContact = [contactStorage GetContact:addMsg.fromUserName.string];
    // 1.公众号消息
    if (msgContact.m_uiFriendScene == 0 && ![addMsg.fromUserName.string containsString:@"@chatroom"]) { return;}
    
    // 2.非公众号
    WCContactData *selfContact = [contactStorage GetSelfContact];
    
    NSArray *autoReplyModels = [[WeChatPluginConfig sharedInstance] autoReplyModels];
    [autoReplyModels enumerateObjectsUsingBlock:^(WCAutoReplyModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 1. 自动回复是否开启
        if (!model.replyEnable) return ;
        
        // 2.自动回复的内容是否有
        if (!model.replyContent || model.replyContent.length == 0) return;

        // 3.聊天室自动回复开启状态
        if ([addMsg.fromUserName.string containsString:@"@chatroom"] && !model.replyGroupEnable) return;
        
        NSString *msgContent = addMsg.content.string;
        
        // 5.截取聊天室聊天内容
        if ([addMsg.fromUserName.string containsString:@"@chatroom"]) {
            NSRange range = [msgContent rangeOfString:@":\n"];
            if (range.length != 0) {
                msgContent = [msgContent substringFromIndex:range.location + range.length];
            }
        }
        
        // 6.自动回复内容
        NSArray *replyArray = [model.replyContent componentsSeparatedByString:@"||"];
        NSString *randomReplyContent = [replyArray objectAtIndex:(arc4random() % replyArray.count)];
        NSString *m_nsUsrName = selfContact.m_nsUsrName;
        NSString *toUsrName = addMsg.fromUserName.string;
        
        // 7.没有回复内容自动停止
        if (randomReplyContent == nil || randomReplyContent.length == 0) { return;}
        
        if (model.enableRegex) {
            NSString *regex = model.keyword;
            
            BOOL isContainsString = [regex containsString:msgContent];
            
            if (isContainsString && randomReplyContent.length > 0) {
                
                [self _autoRandomSendTextMessageWithNsUsrName:m_nsUsrName toUsrName:toUsrName msgContent:randomReplyContent];
            }
        } else {
            
            NSArray * keyWordArray = [model.keyword componentsSeparatedByString:@"||"];
            
            [keyWordArray enumerateObjectsUsingBlock:^(NSString *keyword, NSUInteger idx, BOOL * _Nonnull stop) {
                if (([keyword isEqualToString:@"*"] || [msgContent isEqualToString:keyword]) && randomReplyContent.length > 0) {
                    
                    [self _autoRandomSendTextMessageWithNsUsrName:m_nsUsrName toUsrName:toUsrName msgContent:randomReplyContent];
                }
            }];
        }
    }];
}

/** 远程控制 */
- (void)remoteControlWithMsg:(AddMsg *)addMsg {
    if (addMsg.msgType == 1 || addMsg.msgType == 3) {
        [YJRemoteControlController executeRemoteControlCommandWithMessage:addMsg.content.string];
    }
}

#pragma mark - 自动发送消息
- (void)_autoRandomSendTextMessageWithNsUsrName:(id)nsUsrName toUsrName:(id)toUsrName msgContent:(id)msgContent{
    
    MessageService *service = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MessageService")];
    // 随机延时发送
    NSTimeInterval delayInSeconds = ([WeChatPluginConfig sharedInstance].replyRandomDelayEnable)?((arc4random() % 31) * 0.10):0; // 随机延时范围是0s~2s
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [service SendTextMessage:nsUsrName toUsrName:toUsrName msgText:msgContent atUserList:nil];
    });
}

- (void)disenableAutoReply:(NSTimer *)timer{

}

#pragma mark - Setter && Getter
- (NSTimer *)timer{
    
    NSTimer *timer = objc_getAssociatedObject(self, kTimerKey);
    
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(disenableAutoReply:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
    
    return timer;
}

- (void)setTimer:(NSTimer *)timer{
    
    objc_setAssociatedObject(self, kTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Support
+ (void)replaceAboutFilePathMethod {
    yj_hookInstanceMethod(objc_getClass("JTStatisticManager"), @selector(statFilePath), [self class], @selector(hook_statFilePath));
    yj_hookClassMethod(objc_getClass("CUtility"), @selector(getFreeDiskSpace), [self class], @selector(hook_getFreeDiskSpace));
    yj_hookClassMethod(objc_getClass("MemoryMappedKV"), @selector(mappedKVPathWithID:), [self class], @selector(hook_mappedKVPathWithID:));
    yj_hookClassMethod(objc_getClass("PathUtility"), @selector(getSysDocumentPath), [self class], @selector(hook_getSysDocumentPath));
    yj_hookClassMethod(objc_getClass("PathUtility"), @selector(getSysLibraryPath), [self class], @selector(hook_getSysLibraryPath));
    yj_hookClassMethod(objc_getClass("PathUtility"), @selector(getSysCachePath), [self class], @selector(hook_getSysCachePath));
}

- (id)hook_statFilePath {
    NSString *filePath = [self hook_statFilePath];
    NSString *newCachePath = [NSObject realFilePathWithOriginFilePath:filePath originKeyword:@"/Documents"];
    if (newCachePath) {
        return newCachePath;
    } else {
        return filePath;
    }
}

/** 可利用磁盘空间 */
+ (unsigned long long)hook_getFreeDiskSpace {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(0x9, 0x1, 0x1) firstObject];
    if (documentPath.length == 0) {
        return [self hook_getFreeDiskSpace];
    }
    
    NSString *newDocumentPath = [self realFilePathWithOriginFilePath:documentPath originKeyword:@"/Documents"];
    if (newDocumentPath.length > 0) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *dict = [fileManager attributesOfFileSystemForPath:newDocumentPath error:nil];
        if (dict) {
            NSNumber *freeSize = [dict objectForKey:NSFileSystemFreeSize];
            unsigned long long freeSieValue = [freeSize unsignedLongLongValue];
            return freeSieValue;
        }
    }
    return [self hook_getFreeDiskSpace];
}

+ (id)hook_mappedKVPathWithID:(id)arg1 {
    NSString *mappedKVPath = [self hook_mappedKVPathWithID:arg1];
    NSString *newMappedKVPath = [self realFilePathWithOriginFilePath:mappedKVPath originKeyword:@"/Documents/MMappedKV"];
    if (newMappedKVPath) {
        return newMappedKVPath;
    } else {
        return mappedKVPath;
    }
}

+ (id)hook_getSysDocumentPath {
    NSString *sysDocumentPath = [self hook_getSysDocumentPath];
    NSString *newSysDocumentPath = [self realFilePathWithOriginFilePath:sysDocumentPath originKeyword:@"/Library/Application Support"];
    if (newSysDocumentPath) {
        return newSysDocumentPath;
    } else {
        return sysDocumentPath;
    }
}

+ (id)hook_getSysLibraryPath {
    NSString *libraryPath = [self hook_getSysLibraryPath];
    NSString *newLibraryPath = [self realFilePathWithOriginFilePath:libraryPath originKeyword:@"/Library"];
    if (newLibraryPath) {
        return newLibraryPath;
    } else {
        return libraryPath;
    }
}

+ (id)hook_getSysCachePath {
    NSString *cachePath = [self hook_getSysCachePath];
    NSString *newCachePath = [self realFilePathWithOriginFilePath:cachePath originKeyword:@"/Library/Caches"];
    if (newCachePath) {
        return newCachePath;
    } else {
        return cachePath;
    }
}

+ (id)realFilePathWithOriginFilePath:(NSString *)filePath originKeyword:(NSString *)keyword {
    NSRange range = [filePath rangeOfString:keyword];
    if (range.length > 0) {
        NSMutableString *newFilePath = [filePath mutableCopy];
        NSString *subString = [NSString stringWithFormat:@"/Library/Containers/com.tencent.xinWeChat/Data%@",keyword];
        [newFilePath replaceCharactersInRange:range withString:subString];
        return newFilePath;
    } else {
        return nil;
    }
}
@end
