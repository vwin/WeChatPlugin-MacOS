//
//  WCRemoteControlModel.h
//  WeChatPlugin
//
//  Created by YJHou on 2017/9/6.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCRemoteControlModel : NSObject

@property (nonatomic, copy) NSString *keyword;          /**< 远程控制关键字 */
@property (nonatomic, copy) NSString *function;         /**< 功能描述 */
@property (nonatomic, copy) NSString *executeCommand;   /**< 执行命令 */

@property (nonatomic, assign) BOOL enable;              /**< 远程控制是否可用 */

- (instancetype)initWithDict:(NSDictionary *)dict;

- (NSDictionary *)dictionary;

- (BOOL)hasEmptyKeywordOrExecuteCommand;

@end
