//
//  UIViewController+Lee.h
//  LeeKit
//
//  Created by Lee on 2018/3/8.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Lee)

/**
 *  当前 viewController 是否是被以 present 的方式显示的，是则返回 YES，否则返回 NO
 *  @warning 对于被放在 UINavigationController 里显示的 UIViewController，如果 self 是 self.navigationController 的第一个 viewController，则如果 self.navigationController 是被 present 起来的，那么 self.lee_isPresented = self.navigationController.lee_isPresented = YES。利用这个特性，可以方便地给 navigationController 的第一个界面的左上角添加关闭按钮。
 */
- (BOOL)lee_isPresented;

@end
