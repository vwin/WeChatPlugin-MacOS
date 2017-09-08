//
//  WCAutoReplyModel.h
//  WeChatPlugin
//
//  Created by YJHou on 2017/9/6.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCAutoReplyModel : NSObject

@property (nonatomic, copy) NSString *keyword;              /**< 自动回复关键字 */
@property (nonatomic, copy) NSString *replyContent;         /**< 自动回复内容 */

@property (nonatomic, assign) BOOL replyGroupEnable;        /**< 群聊自动回复是否开启 */
@property (nonatomic, assign) BOOL replyEnable;             /**< 是否开启自动回复 */

- (instancetype)initWithDict:(NSDictionary *)dict;

- (NSDictionary *)dictionary;

- (BOOL)hasEmptyKeywordOrReplyContent;

@end
