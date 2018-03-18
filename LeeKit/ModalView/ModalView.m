//
//  ModalView.m
//  LeeKit
//
//  Created by Lee on 2018/1/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "ModalView.h"

@interface ModalView()
{
    UIView *_backgroudView;
    UIViewController *_ctrl;
    UIView<ModalContentProtocol> *_contentView;
    CGRect originRect;
    CGRect transformRect;
}

@end

@implementation ModalView

-(instancetype)initWithCtrl:(UIViewController *)ctrl contentView:(UIView<ModalContentProtocol> *)contentView{
    if (self = [super init]) {
        _ctrl = ctrl;
        _contentView = contentView;
        [self initUI];
        self.style = ModalStyleTop;
    }
    return self;
}

-(void)showModalAnimate:(BOOL)animate{
    if (!_backgroudView.superview) {
        
        if ([_contentView isFullScreen] && _ctrl.navigationController) {
            [_ctrl.navigationController.view addSubview:_backgroudView];
            [_ctrl.navigationController.view addSubview:_contentView];
        }else{
            [_ctrl.view addSubview:_backgroudView];
            [_ctrl.view addSubview:_contentView];
        }
        
        if (animate) {
            [UIView animateWithDuration:0.35 animations:^{
                _backgroudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
                CGRect rect = originRect;
                _contentView.frame = rect;
            } completion:^(BOOL finished) {
                
            }];
        }else{
            _backgroudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            CGRect rect = originRect;
            _contentView.frame = rect;
        }
    }
    
}

-(void)shrinkModalAnimate:(BOOL)animate{
    if (animate) {
        [UIView animateWithDuration:0.35 animations:^{
            _backgroudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            CGRect rect = transformRect;
            _contentView.frame = rect;
        } completion:^(BOOL finished) {
            [_contentView removeFromSuperview];
            [_backgroudView removeFromSuperview];
        }];
    }else{
        [_contentView removeFromSuperview];
        [_backgroudView removeFromSuperview];
    }
}

#pragma mark - setter & getter
-(void)setStyle:(ModalStyle)style{
    _style = style;
    CGRect rect = originRect;
    switch (style) {
        case ModalStyleTop:
            rect.size.height = 0;
            _contentView.frame = rect;
            break;
            
        case ModalStyleLeft:
            rect.size.width = 0;
            _contentView.frame = rect;
            break;
            
        case ModalStyleRight:
            rect.size.width = 0;
            rect.origin.x = [UIScreen mainScreen].bounds.size.width;
            _contentView.frame = rect;
            break;
        case ModalStyleBottom:
            rect.size.height = 0;
            rect.origin.y = [UIScreen mainScreen].bounds.size.height;
            _contentView.frame = rect;
            break;
            
        default:
            break;
    }
    transformRect = _contentView.frame;
    
}

#pragma mark - privateMethod
-(void)initUI{
    
    _backgroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _backgroudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [_backgroudView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView)]];
    _contentView.clipsToBounds = YES;
    originRect = _contentView.frame;

}

-(void)tapBgView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didModalClicked)]) {
        [self.delegate didModalClicked];
    }else{
        [self shrinkModalAnimate:YES];
    }
    
}

@end
