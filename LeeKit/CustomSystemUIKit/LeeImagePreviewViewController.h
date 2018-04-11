//
//  LeeImagePreviewViewController.h
//  LeeKit
//
//  Created by Lee on 2018/3/20.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeeImagePreviewView.h"


/**
 *  图片预览控件，主要功能由内部自带的 LeeImagePreviewView 提供，由于以 viewController 的形式存在，所以适用于那种在单独界面里展示图片，或者需要从某张目标图片的位置以动画的形式放大进入预览界面的场景。
 *
 *  使用方式：
 *
 *  1. 使用 init 方法初始化
 *  2. 添加 imagePreviewView 的 delegate
 *  3. 分两种查看方式：
 *      1. 如果是左右 push 进入新界面查看图片，则直接按普通 UIViewController 的方式 push 即可；
 *      2. 如果需要从指定图片位置以动画的形式放大进入预览，则调用 startPreviewFromRectInScreen:，传入一个 rect 即可开始预览，这种模式下会创建一个独立的 UIWindow 用于显示 LeeImagePreviewViewController，所以可以达到盖住当前界面所有元素（包括顶部状态栏）的效果。
 *
 *  @see LeeImagePreviewView
 */

@interface LeeImagePreviewViewController : UIViewController

@property(nonatomic, strong, readonly) LeeImagePreviewView *imagePreviewView;
@property(nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;

@end
