//
//  LeeVisualEffectView.h
//  LeeKit
//
//  Created by Lee on 2018/3/18.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LeeUIVisualEffectViewStyle) {
    LeeUIVisualEffectViewStyleExtraLight,
    LeeUIVisualEffectViewStyleLight,
    LeeUIVisualEffectViewStyleDark
};

@interface LeeVisualEffectView : UIView

@property(nonatomic,assign,readonly) LeeUIVisualEffectViewStyle style;

- (instancetype)initWithStyle:(LeeUIVisualEffectViewStyle)style;

@end
