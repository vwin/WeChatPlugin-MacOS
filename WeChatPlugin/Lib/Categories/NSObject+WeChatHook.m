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

@implementation NSObject (WeChatHook)

+ (void)hookWeChat{
    // 微信撤回消息
    yj_hookInstanceMethod(objc_getClass("MessageService"), @selector(onRevokeMsg:), [self class], @selector(hook_onRevokeMsg:));
    // 微信消息同步
    yj_hookInstanceMethod(objc_getClass("MessageService"), @selector(OnSyncBatchAddMsgs:isFirstSync:), [self class], @selector(hook_OnSyncBatchAddMsgs:isFirstSync:));
    // 微信多开
    yj_hookClassMethod(objc_getClass("CUtility"), @selector(HasWechatInstance), [self class], @selector(hook_HasWechatInstance));
    // 注入菜单
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
                [self preventRevokeAutoReplyWith:msgService selfContact:selfContact messageData:newMsgData sendContent:replyContent];
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
    
    MessageService *service = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MessageService")];
    ContactStorage *contactStorage = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("ContactStorage")];
    WCContactData *selfContact = [contactStorage GetSelfContact];
    
    NSArray *autoReplyModels = [[WeChatPluginConfig sharedInstance] autoReplyModels];
    
    [autoReplyModels enumerateObjectsUsingBlock:^(WCAutoReplyModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!model.replyEnable) return ;
        if ([addMsg.fromUserName.string containsString:@"@chatroom"] && !model.replyGroupEnable) return;
        
        NSString *msgContent = addMsg.content.string;
        
        if ([addMsg.fromUserName.string containsString:@"@chatroom"]) {
            NSRange range = [msgContent rangeOfString:@":\n"];
            if (range.length != 0) {
                msgContent = [msgContent substringFromIndex:range.location + range.length];
            }
        }
        NSArray * keyWordArray = [model.keyword componentsSeparatedByString:@"||"];
        [keyWordArray enumerateObjectsUsingBlock:^(NSString *keyword, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([keyword isEqualToString:@"*"] || [msgContent isEqualToString:keyword]) {
                [service SendTextMessage:selfContact.m_nsUsrName toUsrName:addMsg.fromUserName.string msgText:model.replyContent atUserList:nil];
            }
        }];
        
    }];
}

- (void)preventRevokeAutoReplyWith:(MessageService *)msgService selfContact:(WCContactData *)selfContact messageData:(MessageData *)messageData sendContent:(NSString *)sendContent{
    
    // 1是文本 3是
//    if (messageData.messageType != 1 && messageData.messageType != 3) {return;}
    
    // 2.发送
    [msgService SendTextMessage:selfContact.m_nsUsrName toUsrName:messageData.toUsrName msgText:sendContent atUserList:nil];
}

/** 远程控制 */
- (void)remoteControlWithMsg:(AddMsg *)addMsg {
    if (addMsg.msgType == 1 || addMsg.msgType == 3) {
        [YJRemoteControlController executeRemoteControlCommandWithMessage:addMsg.content.string];
    }
}

@end
