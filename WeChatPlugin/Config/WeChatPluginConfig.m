//
//  WeChatPluginConfig.m
//  WeChatPlugin
//
//  Created by YJHou on 2017/7/9.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import "WeChatPluginConfig.h"
#import "WCAutoReplyModel.h"
#import "WCRemoteControlModel.h"

@implementation WeChatPluginConfig

#pragma mark - 单例
+ (instancetype)sharedInstance{
    static WeChatPluginConfig *__instance__ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance__ = [[WeChatPluginConfig alloc] init];
    });
    return __instance__;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _preventRevokeEnable = [[NSUserDefaults standardUserDefaults] boolForKey:YJPreventRevokeEnableKey];
        _replyPreventRevokeEnable = [[NSUserDefaults standardUserDefaults] boolForKey:YJReplyPreventRevokeEnableKey];
        _replyRandomDelayEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kYJReplyRandomDelayEnableKey];
    }
    return self;
}

- (void)saveAutoReplyModelsToFile{
    
    NSMutableArray *needSaveModels = [NSMutableArray array];
    [_autoReplyModels enumerateObjectsUsingBlock:^(WCAutoReplyModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (model.hasEmptyKeywordOrReplyContent) {
            model.replyEnable = NO;
            model.replyGroupEnable = NO;
            model.enableRegex = NO;
        }
        model.replyContent = model.replyContent == nil ? @"" : model.replyContent;
        model.keyword = model.keyword == nil ? @"" : model.keyword;
        [needSaveModels addObject:model.dictionary];
    }];
    [needSaveModels writeToFile:YJAutoReplyModelsFilePath atomically:YES];
}

- (void)saveRemoteControlModelsToFile {
    
    NSMutableArray *needSaveModels = [NSMutableArray array];
    [_remoteControlModels enumerateObjectsUsingBlock:^(NSArray *subModels, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *newSubModels = [NSMutableArray array];
        [subModels enumerateObjectsUsingBlock:^(WCRemoteControlModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [newSubModels addObject:obj.dictionary];
        }];
        [needSaveModels addObject:newSubModels];
    }];
    [needSaveModels writeToFile:YJRemoteControlModelsFilePath atomically:YES];
}

#pragma mark - Setter
- (void)setPreventRevokeEnable:(BOOL)preventRevokeEnable {
    
    _preventRevokeEnable = preventRevokeEnable;
    
    // 保存状态
    [[NSUserDefaults standardUserDefaults] setBool:preventRevokeEnable forKey:YJPreventRevokeEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setReplyPreventRevokeEnable:(BOOL)replyPreventRevokeEnable{
    
    _replyPreventRevokeEnable = replyPreventRevokeEnable;
    
    // 保存状态
    [[NSUserDefaults standardUserDefaults] setBool:replyPreventRevokeEnable forKey:YJReplyPreventRevokeEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setReplyRandomDelayEnable:(BOOL)replyRandomDelayEnable{
    
    _replyRandomDelayEnable = replyRandomDelayEnable;
    
    // 保存状态
    [[NSUserDefaults standardUserDefaults] setBool:replyRandomDelayEnable forKey:kYJReplyRandomDelayEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Getter
- (NSArray *)autoReplyModels {
    if (!_autoReplyModels) {
        _autoReplyModels = ({
            NSArray *originModels = [NSArray arrayWithContentsOfFile:YJAutoReplyModelsFilePath];
            NSMutableArray *newModels = [NSMutableArray array];
            [originModels enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
                WCAutoReplyModel *model = [[WCAutoReplyModel alloc] initWithDict:dict];
                [newModels addObject:model];
            }];
            newModels;
        });
    }
    return _autoReplyModels;
}

- (NSArray *)remoteControlModels {
    if (!_remoteControlModels) {
        
        _remoteControlModels = ({
            NSArray *originModels = [NSArray arrayWithContentsOfFile:YJRemoteControlModelsFilePath];
            NSMutableArray *newRemoteControlModels = [NSMutableArray array];
            [originModels enumerateObjectsUsingBlock:^(NSArray *subModels, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableArray *newSubModels = [NSMutableArray array];
                [subModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    WCRemoteControlModel *model = [[WCRemoteControlModel alloc] initWithDict:obj];
                    [newSubModels addObject:model];
                }];
                [newRemoteControlModels addObject:newSubModels];
            }];
            
            newRemoteControlModels;
        });
    }
    return _remoteControlModels;
}

@end
