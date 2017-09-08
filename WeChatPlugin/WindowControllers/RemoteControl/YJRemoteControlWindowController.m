//
//  YJRemoteControlWindowController.m
//  WeChatPlugin
//
//  Created by YJHou on 2017/7/9.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import "YJRemoteControlWindowController.h"
#import "WeChatPluginConfig.h"
#import "YJRemoteControlCellView.h"

@interface YJRemoteControlWindowController () <NSWindowDelegate, NSTabViewDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTabView *tabView;
@property (nonatomic, strong) NSTableView *tableView;
@property (nonatomic, strong) NSArray *remoteControlModels;

@end

@implementation YJRemoteControlWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self setup];
    [self initSubviews];
}

- (void)initSubviews {
    
    CGFloat tabViewWidth = self.tabView.frame.size.width;
    CGFloat tabViewHeight = self.tabView.frame.size.height;
    
    self.tableView = ({
        NSTableView *tableView = [[NSTableView alloc] init];
        tableView.frame = NSMakeRect(50, 50, tabViewWidth, tabViewHeight);
        tableView.delegate = self;
        tableView.dataSource = self;
        NSTableColumn *column = [[NSTableColumn alloc] init];
        column.width = tabViewWidth - 100;
        [tableView addTableColumn:column];
        tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
        tableView.backgroundColor = [NSColor clearColor];
        
        tableView;
    });
    
    [self.tabView addSubview:self.tableView];
}

- (void)setup {
    self.window.contentView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [self.window.contentView.layer setNeedsDisplay];
    self.remoteControlModels = [[WeChatPluginConfig sharedInstance] remoteControlModels][0];
}

- (BOOL)windowShouldClose:(id)sender {
    [[WeChatPluginConfig sharedInstance] saveRemoteControlModelsToFile];
    return YES;
}

#pragma mark - NSTableViewDataSource && NSTableViewDelegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.remoteControlModels.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    YJRemoteControlCellView *cell = [[YJRemoteControlCellView alloc] init];
    cell.frame = NSMakeRect(0, 0, self.tabView.frame.size.width, 40);
    [cell setupWithData:self.remoteControlModels[row]];
    
    return cell;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 50;
}

#pragma mark - NSTabViewDelegate

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    NSInteger selectTabIndex = [tabViewItem.identifier integerValue];
    self.remoteControlModels = [[WeChatPluginConfig sharedInstance] remoteControlModels][selectTabIndex];
    [self.tableView reloadData];
}

#pragma mark - Lazy
//- (NSTabView *)tabView{
//    if (!_tabView) {
//        _tabView = [[NSTabView alloc] initWithFrame:CGRectMake(20, 42, 630, 445)];
//        
//        NSTabViewItem *item1 = [[NSTabViewItem alloc] init];
//        item1.label = @"MacBook";
//        item1.identifier = @0;
//        [_tabView addTabViewItem:item1];
//        
//        NSTabViewItem *item2 = [[NSTabViewItem alloc] init];
//        item2.label = @"App控制";
//        item2.identifier = @1;
//        [_tabView addTabViewItem:item2];
//        
//        NSTabViewItem *item3 = [[NSTabViewItem alloc] init];
//        item3.label = @"网易音乐";
//        item3.identifier = @2;
//        [_tabView addTabViewItem:item3];
//        
//        _tabView.delegate = self;
//    }
//    return _tabView;
//}


@end
