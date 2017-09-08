//
//  WCTools.h
//  WeChatPlugin
//
//  Created by YJHou on 2017/8/16.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface WCTools : NSObject

void yj_hookClassMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector);


void yj_hookInstanceMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector);

@end
