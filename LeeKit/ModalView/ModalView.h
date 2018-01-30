//
//  ModalView.h
//  LeeKit
//
//  Created by Lee on 2018/1/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalContentProtocol.h"

typedef NS_ENUM(NSInteger, ModalStyle){
    ModalStyleLeft = 0,
    ModalStyleRight,
    ModalStyleTop,
    ModalStyleBottom
};

@protocol ModalViewDelegate<NSObject>

@optional
-(void)didModalClicked;

@end


@interface ModalView : NSObject

@property(nonatomic, assign) ModalStyle style;

@property(nonatomic, weak) id<ModalViewDelegate> delegate;

/**
 Modal对象

 @param ctrl 控制器容器
 @param contentView 内容
 @return 对象
 */
-(instancetype)initWithCtrl:(UIViewController *)ctrl contentView:(UIView<ModalContentProtocol> *)contentView;


/**
 显示modal

 @param animate 是否动画
 */
-(void)showModalAnimate:(BOOL)animate;


/**
 关闭modal

 @param animate 是否动画
 */
-(void)shrinkModalAnimate:(BOOL)animate;

@end
