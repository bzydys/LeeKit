//
//  TagConfig.m
//  LeeKit
//
//  Created by Lee on 2018/2/20.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "TagConfig.h"


@implementation TagConfig

-(instancetype)init{
    if (self = [super init]) {
        self.flexable = YES;
        self.inset = UIEdgeInsetsMake(5, 5, 5, 5);
        self.cornerRadius = 4;
    }
    return self;
}
-(CGFloat)maxHeight{
    if (!_maxHeight) {
        _maxHeight = 200;
    }
    return _maxHeight;
}

-(CGFloat)maxItemHeight{
    if (!_maxItemHeight) {
        _maxItemHeight = 44;
    }
    return _maxItemHeight;
}

-(CGFloat)itemSpace{
    if (!_itemSpace) {
        _itemSpace = 5;
    }
    return _itemSpace;
}

-(UIColor *)normalBackgroundColor{
    if (!_normalBackgroundColor) {
        _normalBackgroundColor = [UIColor lightGrayColor];
    }
    return _normalBackgroundColor;
}

-(UIColor *)selectedBackgroundColor{
    if (!_selectedBackgroundColor) {
        _selectedBackgroundColor = [UIColor lightGrayColor];
    }
    return _selectedBackgroundColor;
}

-(UIColor *)normalTitleColor{
    if (!_normalTitleColor) {
        _normalTitleColor = [UIColor blackColor];
    }
    return _normalTitleColor;
}

-(UIColor *)selectedTitleColor{
    if (!_selectedTitleColor) {
        _selectedTitleColor = [UIColor blackColor];
    }
    return _selectedTitleColor;
}

@end
