//
//  NSView+YJSuperExt.m
//  WeChatPlugin
//
//  Created by YJHou on 2017/6/20.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import "NSView+YJSuperExt.h"

@implementation NSView (YJSuperExt)

- (void)addSafeSubviews:(NSArray *)subViews{
    for (NSView *subView in subViews) {
        if ([subView isKindOfClass:[NSView class]]) {
            [self addSubview:subView];
        }else{
#if DEBUG
            NSLog(@"%@ is not a View", subView);
#endif
        }
    }
}

@end
