//
//  main.c
//  WeChatPlugin
//
//  Created by YJHou on 2017/6/20.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+WeChatHook.h"

static void __attribute__((constructor)) initialize(void) {
    
    [NSObject hookWeChat];
    
}
