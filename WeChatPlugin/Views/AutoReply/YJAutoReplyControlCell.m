//
//  YJAutoReplyControlCell.m
//  WeChatPlugin
//
//  Created by YJHou on 2017/7/9.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import "YJAutoReplyControlCell.h"
#import "WCAutoReplyModel.h"
#import "NSView+YJSuperExt.h"

@interface YJAutoReplyControlCell ()

@property (nonatomic, strong) NSButton *selectBtn;
@property (nonatomic, strong) NSTextField *keywordLabel;
@property (nonatomic, strong) NSTextField *replyContentLabel;
@property (nonatomic, strong) NSBox *bottomLine;

@end

@implementation YJAutoReplyControlCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    self.selectBtn = ({
        NSButton *btn = [NSButton checkboxWithTitle:@"" target:self action:@selector(clickSelectBtn:)];
        btn.frame = NSMakeRect(5, 15, 20, 20);
        
        btn;
    });
    
    self.keywordLabel = ({
        NSTextField *label = [NSTextField labelWithString:@""];
        label.placeholderString = @"关键字";
        [[label cell] setLineBreakMode:NSLineBreakByCharWrapping];
        [[label cell] setTruncatesLastVisibleLine:YES];
        label.font = [NSFont systemFontOfSize:10];
        label.frame = NSMakeRect(30, 30, 160, 15);
        
        label;
    });
    
    self.replyContentLabel = ({
        NSTextField *label = [NSTextField labelWithString:@""];
        label.placeholderString = @"回复内容";
        [[label cell] setLineBreakMode:NSLineBreakByCharWrapping];
        [[label cell] setTruncatesLastVisibleLine:YES];
        label.frame = NSMakeRect(30, 10, 160, 15);
        
        label;
    });
    
    self.bottomLine = ({
        NSBox *v = [[NSBox alloc] init];
        v.boxType = NSBoxSeparator;
        v.frame = NSMakeRect(0, 0, 200, 1);
        
        v;
    });
    
    [self addSafeSubviews:@[self.selectBtn,
                        self.keywordLabel,
                        self.replyContentLabel,
                        self.bottomLine]];
}

- (void)clickSelectBtn:(NSButton *)btn {
    self.model.replyEnable = btn.state;
}

- (void)setModel:(WCAutoReplyModel *)model {
    _model = model;
    
    if (model.keyword == nil && model.replyContent == nil) return;
    
    self.selectBtn.state = model.replyEnable;
    self.keywordLabel.stringValue = model.keyword != nil ? model.keyword : @"";
    self.replyContentLabel.stringValue = model.replyContent != nil ? model.replyContent : @"";
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
