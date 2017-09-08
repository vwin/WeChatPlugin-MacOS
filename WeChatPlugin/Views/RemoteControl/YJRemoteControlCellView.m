//
//  YJRemoteControlCellView.m
//  WeChatPlugin
//
//  Created by YJHou on 2017/7/9.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import "YJRemoteControlCellView.h"
#import "WCRemoteControlModel.h"

@interface YJRemoteControlCellView () <NSTextFieldDelegate>

@property (nonatomic, strong) NSButton *selectBtn;
@property (nonatomic, strong) NSTextField *textField;
@property (nonatomic, strong) WCRemoteControlModel *model;

@end

@implementation YJRemoteControlCellView

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
        btn.frame = NSMakeRect(50, 10, 150, 30);
        
        btn;
    });
    
    self.textField = ({
        NSTextField *v = [[NSTextField alloc] init];
        v.frame = NSMakeRect(200, 10, 250, 30);
        v.placeholderString = @"请输入匹配的关键词";
        v.layer.cornerRadius = 10;
        v.layer.masksToBounds = YES;
        [v.layer setNeedsDisplay];
        v.editable = YES;
        v.delegate = self;
        
        v;
    });
    
    [self addSubview:self.selectBtn];
    [self addSubview:self.textField];
}

- (void)clickSelectBtn:(NSButton *)btn {
    self.model.enable = btn.state;
}

- (void)setupWithData:(id)data {
    WCRemoteControlModel *model = data;
    self.model = model;
    self.selectBtn.title = model.function;
    self.selectBtn.state = model.enable;
    self.textField.stringValue = model.keyword;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    NSString *string = control.stringValue;
    self.model.keyword = string;
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
