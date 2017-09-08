//
//  NSView+YJSuperExt.h
//  WeChatPlugin
//
//  Created by YJHou on 2017/6/20.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (YJSuperExt)

/**
 add subViews to self

 @param subViews subView instance array
 */
- (void)addSafeSubviews:(NSArray *)subViews;

@end
