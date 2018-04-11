//
//  ViewController.m
//  LeeKit
//
//  Created by Lee on 2017/12/14.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import "ViewController.h"
#import "Lee_SQLSelectBuilder.h"
#import "Lee_SQLInsertBuilder.h"
#import "InfiniteBanner.h"
#import "InfiniteConfiguration.h"
#import "RedView.h"
#import "ModalView.h"
#import "TagView.h"
#import "LeeUITextField.h"
#import "LeeGridView.h"
#import "UIColor+Lee.h"
#import "LeeTips.h"
#import "LeeMarqueeLabel.h"
#import "LeeButton.h"
#import "LeeModalPresentationViewController.h"
#import "LeeAlertViewController.h"
#import "LeeFloatLayout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SecondViewController.h"
@interface ViewController ()<CAAnimationDelegate>
{
    ModalView *_modal;
    UILabel *_lbl;
    NSTimer *_timer;
    UIView *_conta;
    LeeFloatLayout *_lay;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    InfiniteBanner *banner = [[InfiniteBanner alloc] init];
//    banner.frame = CGRectMake(0, 0, self.view.frame.size.width, 180);
//    [self.view addSubview:banner];
//    InfiniteConfiguration *config = [InfiniteConfiguration new];
//    config.pageSelectColor = [UIColor redColor];
//    config.pageUnselectColor = [UIColor blueColor];
//    config.direction = PageControllDirectionRight;
//    config.duration = 2;
//    banner.config = config;
//    [banner showImages:@[[UIImage imageNamed:@"c.jpg"]]];
//    RedView *v = [[RedView alloc] init];
//    v.frame = CGRectMake(75, 0, 300, 667);
//    v.backgroundColor = [UIColor redColor];
//
//    UIView *bv = [[UIView alloc] init];
//    bv.frame = CGRectMake(20, 50, 335, 70);
//    bv.backgroundColor = [UIColor yellowColor];
//    [v addSubview:bv];
//
//    ModalView *modal = [[ModalView alloc] initWithCtrl:self contentView:v];
//    [modal setStyle:ModalStyleRight];
//    _modal = modal;
//
//    self.navigationController.navigationBar.translucent = NO;
//    self.extendedLayoutIncludesOpaqueBars = YES;
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    TagView *tag = [[TagView alloc] initWithTitles:@[@"cc",@"dsadsad",@"a",@"sdadas",@"dsaddsadsadadadadsad",@"ffsdfs"]];
//    tag.frame = CGRectMake(0, 50, 375, 100000);
//    tag.backgroundColor = [UIColor blueColor];
//    [self.view addSubview:tag];
//
//    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(20, 400, 330, 35)];
////    tf.borderStyle = UITextBorderStyleRoundedRect;
//    tf.placeholder = @"hh";
//    [self.view addSubview:tf];
//    tf.maximumTextLength = 10;
//    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(20, 200, 80, 50)];
//    testView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:testView];
//    CAShapeLayer *layer = [CAShapeLayer new];
//    layer.path = [UIBezierPath lee_bezierPathWithRoundedRect:testView.frame cornerRadiusArray:@[@4,@8,@10,@6] lineWidth:0].CGPath;
//    testView.layer.mask = layer;
    // Do any additional setup after loading the view, typically from a nib.
    
//    LeeGridView *grid = [[LeeGridView alloc] initWithColumn:3 rowHeight:50];
//    grid.shouldSeparatorDashed = YES;
//    grid.separatorWidth = 1;
//    grid.separatorColor = [UIColor redColor];
//    grid.frame = CGRectMake(0, 64, self.view.bounds.size.width, 200);
//    [self.view addSubview:grid];
//    
//    for (NSUInteger i = 0; i < 20; i++) {
//        UILabel *lbl = [[UILabel alloc] init];
//        lbl.font = [UIFont systemFontOfSize:13];
//        lbl.backgroundColor = [UIColor lee_randomColor];
//        [grid addSubview:lbl];
//    }
    
//    LeeButton *btn = [[LeeButton alloc] initWithFrame:CGRectMake(9, 300, 340, 50)];
//    [self.view addSubview:btn];
//    btn.backgroundColor = [UIColor blueColor];
//    btn.selectedBackgroundColor = [UIColor redColor];
//    [btn setTitle:@"wo ai ni" forState: UIControlStateNormal];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [btn sizeToFit];
//    UIView *conta = [[UIView alloc] initWithFrame:CGRectMake(9, 300, 150, 50)];
//    conta.backgroundColor = [UIColor redColor];
//    conta.clipsToBounds = YES;
//    [self.view addSubview:conta];
//    _conta = conta;
//    UILabel *l = [[UILabel alloc] initWithFrame:conta.bounds];
//    l.text = @"我爱爱爱i我爱i我爱i我爱i我爱i我爱i";
//    l.numberOfLines = 0;
//    l.backgroundColor = [UIColor redColor];
//    [conta addSubview:l];
////    [l sizeToFit];
//    _lbl = l;
//    _lbl.clipsToBounds = YES;
//
    
//    LeeButton *btn = [[LeeButton alloc] init];
//    btn.backgroundColor = [UIColor lightGrayColor];
//    [btn setTitle:@"hehe" forState:UIControlStateNormal];
//    btn.frame = CGRectMake(20, 400, 50, 30);
//    [self.view addSubview:btn];
////    btn.adjustsImageWhenHighlighted = YES;
//    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
//
//    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(20, 460, 200, 30)];
//    tf.borderStyle = UITextBorderStyleLine;
//    [self.view addSubview:tf];
    
    LeeFloatLayout *lay = [[LeeFloatLayout alloc] initWithFrame:CGRectMake(0, 300, 375, 100)];
    lay.backgroundColor = [UIColor redColor];
    lay.itemMargin = UIEdgeInsetsMake(0, 2.5, 5, 2.5);
    lay.contentMode = UIViewContentModeRight;
    lay.padding = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.view addSubview:lay];
    _lay = lay;
    
    NSArray<NSString *> *titleArray = @[@"hehe", @"hdhsahdhsad",@"dsdada",@"i love"];
    for (NSUInteger i = 0; i < titleArray.count; i++) {
        LeeButton *btn = [[LeeButton alloc] init];
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor lightGrayColor];
        btn.contentEdgeInsets = UIEdgeInsetsMake(6, 20, 6, 20);
        [lay addSubview:btn];
    }
    
    [lay sizeToFit];
    

    
}

- (BOOL)shouldAutorotate{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)click{
    NSLog(@"----------");
}

-(void)viewWillLayoutSubviews{
    NSLog(@"------");
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (!flag) {
        [NSThread sleepForTimeInterval:1];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [_modal showModalAnimate:YES];
//    [LeeTips showSucceed:@"我爱你"];
//    LeeModalPresentationViewController *vc = [[LeeModalPresentationViewController alloc] init];
//    vc.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
//    LeeUITextField *tf = [[LeeUITextField alloc] initWithFrame:CGRectMake(20, 20, 260, 40)];
//    tf.borderStyle = UITextBorderStyleRoundedRect;
//    tf.placeholder = @"dsadsad";
//    [vc.contentView addSubview:tf];
//    vc.contentView.backgroundColor = [UIColor redColor];
//    vc.animationStyle = LeeModalPresentationAnimationStyleTopInBottomOut;
//    [vc showWithAnimated:YES completion:nil];
//    LeeAlertViewController *alert = [LeeAlertViewController alertControllerWithTitle:@"hehe" message:@"ewewqe" preferredStyle:LeeAlertControllerStyleAlert];
//    [alert addAction:[LeeAlertAction actionWithTitle:@"comfirm" style:LeeAlertActionStyleDefault handler:^(LeeAlertAction *action) {
//        [alert hideWithAnimated:YES];
//    }]];
//    [alert showWithAnimated:YES];
//    [self showEmptyViewWithText:@"wewe" detailText:@"dsadsadsadsad" buttonTitle:@"hehe" buttonAction:nil];
    [self.navigationController pushViewController:[SecondViewController new] animated:YES];
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
