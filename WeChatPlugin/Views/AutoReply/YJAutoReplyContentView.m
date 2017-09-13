//
//  YJAutoReplyContentView.m
//  WeChatPlugin
//
//  Created by YJHou on 2017/7/9.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import "YJAutoReplyContentView.h"
#import "WCAutoReplyModel.h"
#import "NSView+YJSuperExt.h"

@interface YJAutoReplyContentView () <NSTextFieldDelegate>

@property (nonatomic, strong) NSTextField *keywordLabel;
@property (nonatomic, strong) NSTextField *keywordTextField;
@property (nonatomic, strong) NSTextField *autoReplyLabel;
@property (nonatomic, strong) NSTextField *autoReplyContentField;
@property (nonatomic, strong) NSButton *enableGroupReplyBtn;
@property (nonatomic, strong) NSButton *enableRegexBtn;

@end

@implementation YJAutoReplyContentView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    
    self.enableGroupReplyBtn = ({
        NSButton *btn = [NSButton checkboxWithTitle:@"开启群聊自动回复" target:self action:@selector(clickEnableGroupBtn:)];
        btn.frame = NSMakeRect(20, 15, 180, 20);
        
        btn;
    });
    
    self.enableRegexBtn = ({
        NSButton *btn = [NSButton checkboxWithTitle:@"开启模糊匹配" target:self action:@selector(clickEnableRegexBtn:)];
        btn.frame = NSMakeRect(235, 15, 400, 20);
        
        btn;
    });
    
    self.autoReplyContentField = ({
        NSTextField *textField = [[NSTextField alloc] init];
        textField.frame = NSMakeRect(20, CGRectGetMaxY(self.enableGroupReplyBtn.frame) + 15, 360, 200);
        textField.placeholderString = @"请输入自动回复的内容";
        textField.delegate = self;
        
        textField;
    });
    
    self.autoReplyLabel = ({
        NSTextField *label = [NSTextField labelWithString:@"自动回复:"];
        label.frame = NSMakeRect(20, CGRectGetMaxY(self.autoReplyContentField.frame) + 6, 350, 20);
        
        label;
    });
    
    self.keywordTextField = ({
        NSTextField *textField = [[NSTextField alloc] init];
        textField.frame = NSMakeRect(20, CGRectGetMaxY(self.autoReplyLabel.frame) + 6, 360, 60);
        textField.placeholderString = @"请输入关键字（ ‘*’ 为任何消息都回复，‘||’ 为匹配多个关键字）";
        textField.delegate = self;
        
        textField;
    });
    
    self.keywordLabel = ({
        NSTextField *label = [NSTextField labelWithString:@"关键字:"];
        label.frame = NSMakeRect(20, CGRectGetMaxY(self.keywordTextField.frame) + 6, 350, 20);
        
        label;
    });
    
    [self addSafeSubviews:@[
                            self.enableRegexBtn,
                            self.enableGroupReplyBtn,
                            self.autoReplyContentField,
                            self.autoReplyLabel,
                            self.keywordTextField,
                            self.keywordLabel
                            ]];
}

- (void)clickEnableRegexBtn:(NSButton *)btn {
    self.model.enableRegex = btn.state;
}

- (void)clickEnableGroupBtn:(NSButton *)btn {
    
    self.model.replyGroupEnable = btn.state;
    if (self.endEdit) self.endEdit();
}

- (void)viewDidMoveToSuperview {
    [super viewDidMoveToSuperview];
    self.layer.backgroundColor = [[NSColor windowBackgroundColor] CGColor];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[NSColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1.00] CGColor];
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
    [self.layer setNeedsDisplay];
}

- (void)setModel:(WCAutoReplyModel *)model {
    _model = model;
    self.keywordTextField.stringValue = model.keyword != nil ? model.keyword : @"";
    self.autoReplyContentField.stringValue = model.replyContent != nil ? model.replyContent : @"";
    self.enableGroupReplyBtn.state = model.replyGroupEnable;
    self.enableRegexBtn.state = model.enableRegex;
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    if (self.endEdit) { self.endEdit(); }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSControl *control = notification.object;
    if (control == self.keywordTextField) {
        self.model.keyword = self.keywordTextField.stringValue;
    } else if (control == self.autoReplyContentField) {
        self.model.replyContent = self.autoReplyContentField.stringValue;
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    
    BOOL result = NO;
    
    if (commandSelector == @selector(insertNewline:)) {
        [textView insertNewlineIgnoringFieldEditor:self];
        result = YES;
    } else if (commandSelector == @selector(insertTab:)) {
        if (control == self.keywordTextField) {
            [self.autoReplyContentField becomeFirstResponder];
        } else if (control == self.autoReplyContentField) {
            [self.keywordTextField becomeFirstResponder];
        }
    }
    
    return result;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

@end
