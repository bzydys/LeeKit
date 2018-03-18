//
//  LeePopupMenuView.m
//  LeeKit
//
//  Created by Lee on 2018/3/14.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "LeePopupMenuView.h"
#import "LeeButton.h"
#import "CALayer+Lee.h"
#import "UIButton+Lee.h"
#import "UIControl+Lee.h"


@interface LeePopupMenuItem ()

@property(nonatomic, strong, readwrite) LeeButton *button;
@end

@interface LeePopupMenuView ()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) NSMutableArray<CALayer *> *itemSeparatorLayers;
@end

@interface LeePopupMenuView (UIAppearance)

- (void)updateAppearanceForPopupMenuView;
@end

@implementation LeePopupMenuView

- (void)setItems:(NSArray<LeePopupMenuItem *> *)items {
    _items = items;
    self.itemSections = @[_items];
}

- (void)setItemSections:(NSArray<NSArray<LeePopupMenuItem *> *> *)itemSections {
    _itemSections = itemSections;
    [self configureItems];
}

- (BOOL)shouldShowSeparatorAtRow:(NSInteger)row rowCount:(NSInteger)rowCount inSection:(NSInteger)section sectionCount:(NSInteger)sectionCount {
    return (!self.shouldShowSectionSeparatorOnly && self.shouldShowItemSeparator && row < rowCount - 1) || (self.shouldShowSectionSeparatorOnly && row == rowCount - 1 && section < sectionCount - 1);
}


- (void)configureItems {
    NSInteger globalItemIndex = 0;
    
    // 移除所有 item
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
        NSArray<LeePopupMenuItem *> *items = self.itemSections[section];
        for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
            LeePopupMenuItem *item = items[row];
            item.button.titleLabel.font = self.itemTitleFont;
            item.button.highlightedBackgroundColor = self.itemHighlightedBackgroundColor;
            item.button.imageEdgeInsets = UIEdgeInsetsMake(0, -self.imageMarginRight, 0, self.imageMarginRight);
            item.button.contentEdgeInsets = UIEdgeInsetsMake(0, self.padding.left - item.button.imageEdgeInsets.left, 0, self.padding.right);
            [self.scrollView addSubview:item.button];
            
            // 配置分隔线，注意每一个 section 里的最后一行是不显示分隔线的
            BOOL shouldShowSeparatorAtRow = [self shouldShowSeparatorAtRow:row rowCount:rowCount inSection:section sectionCount:sectionCount];
            if (globalItemIndex < self.itemSeparatorLayers.count) {
                CALayer *separatorLayer = self.itemSeparatorLayers[globalItemIndex];
                if (shouldShowSeparatorAtRow) {
                    separatorLayer.hidden = NO;
                    separatorLayer.backgroundColor = self.separatorColor.CGColor;
                } else {
                    separatorLayer.hidden = YES;
                }
            } else if (shouldShowSeparatorAtRow) {
                CALayer *separatorLayer = [CALayer layer];
                [separatorLayer lee_removeDefaultAnimations];
                separatorLayer.backgroundColor = self.separatorColor.CGColor;
                [self.scrollView.layer addSublayer:separatorLayer];
                [self.itemSeparatorLayers addObject:separatorLayer];
            }
            
            globalItemIndex++;
        }
    }
}

#pragma mark - (UISubclassingHooks)

- (void)didInitialized {
    [super didInitialized];
    self.contentEdgeInsets = UIEdgeInsetsZero;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.contentView addSubview:self.scrollView];
    
    self.itemSeparatorLayers = [[NSMutableArray alloc] init];
    
    [self updateAppearanceForPopupMenuView];
}

- (CGSize)sizeThatFitsInContentView:(CGSize)size {
    CGFloat height = self.padding.top + self.padding.bottom;
    for (NSArray<LeePopupMenuItem *> *section in self.itemSections) {
        height += section.count * self.itemHeight;
    }
    size.height = fmin(height, size.height);
    return size;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.contentView.bounds;
    
    CGFloat minY = self.padding.top;
    CGFloat contentWidth = CGRectGetWidth(self.scrollView.bounds);
    NSInteger separatorIndex = 0;
    for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
        NSArray<LeePopupMenuItem *> *items = self.itemSections[section];
        for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
            LeeButton *button = items[row].button;
            button.frame = CGRectMake(0, minY, contentWidth, self.itemHeight);
            minY = CGRectGetMaxY(button.frame);
            
            BOOL shouldShowSeparatorAtRow = [self shouldShowSeparatorAtRow:row rowCount:rowCount inSection:section sectionCount:sectionCount];
            if (shouldShowSeparatorAtRow) {
                self.itemSeparatorLayers[separatorIndex].frame = CGRectMake(self.separatorInset.left, minY - 1 + self.separatorInset.top - self.separatorInset.bottom, contentWidth - self.separatorInset.left - self.separatorInset.right, 1);
                separatorIndex++;
            }
        }
    }
    minY += self.padding.bottom;
    self.scrollView.contentSize = CGSizeMake(contentWidth, minY);
}


@end

@implementation LeePopupMenuView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearanceForPopupMenuView];
    });
}

+ (void)setDefaultAppearanceForPopupMenuView {
    LeePopupMenuView *appearance = [LeePopupMenuView appearance];
    appearance.separatorColor = [UIColor colorWithRed:222/255.0 green:224/255.0 blue:226/255.0 alpha:1];
    appearance.itemTitleFont = [UIFont systemFontOfSize:16];
    appearance.itemHighlightedBackgroundColor = [UIColor colorWithRed:238/255.0 green:239/255.0 blue:241/255.0 alpha:1];
    appearance.padding = UIEdgeInsetsMake([LeePopupContainerView appearance].cornerRadius / 2.0, 16, [LeePopupContainerView appearance].cornerRadius / 2.0, 16);
    appearance.itemHeight = 44;
    appearance.imageMarginRight = 6;
    appearance.separatorInset = UIEdgeInsetsZero;
}

- (void)updateAppearanceForPopupMenuView {
    LeePopupMenuView *appearance = [LeePopupMenuView appearance];
    self.separatorColor = appearance.separatorColor;
    self.itemTitleFont = appearance.itemTitleFont;
    self.itemHighlightedBackgroundColor = appearance.itemHighlightedBackgroundColor;
    self.padding = appearance.padding;
    self.itemHeight = appearance.itemHeight;
    self.imageMarginRight = appearance.imageMarginRight;
    self.separatorInset = appearance.separatorInset;
}

@end

@implementation LeePopupMenuItem

+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title handler:(void (^)(void))handler {
    LeePopupMenuItem *item = [[LeePopupMenuItem alloc] init];
    item.image = image;
    item.title = title;
    item.handler = handler;
    
    LeeButton *button = [[LeeButton alloc] init];
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.lee_automaticallyAdjustTouchHighlightedInScrollView = YES;
    [button addTarget:item action:@selector(handleButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    item.button = button;
    return item;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.button setImage:image forState:UIControlStateNormal];
}

- (void)handleButtonEvent:(id)sender {
    if (self.handler) {
        self.handler();
    }
}

@end
