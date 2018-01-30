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

@interface ViewController ()
{
    ModalView *_modal;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    InfiniteBanner *banner = [[InfiniteBanner alloc] init];
    banner.frame = CGRectMake(0, 0, self.view.frame.size.width, 180);
    [self.view addSubview:banner];
    InfiniteConfiguration *config = [InfiniteConfiguration new];
    config.pageSelectColor = [UIColor redColor];
    config.pageUnselectColor = [UIColor blueColor];
    config.direction = PageControllDirectionRight;
    config.duration = 2;
    banner.config = config;
    [banner showImages:@[[UIImage imageNamed:@"c.jpg"]]];
    RedView *v = [[RedView alloc] init];
    v.frame = CGRectMake(75, 0, 300, 667);
    v.backgroundColor = [UIColor redColor];
    
    UIView *bv = [[UIView alloc] init];
    bv.frame = CGRectMake(20, 50, 335, 70);
    bv.backgroundColor = [UIColor yellowColor];
    [v addSubview:bv];
    
    ModalView *modal = [[ModalView alloc] initWithCtrl:self contentView:v];
    [modal setStyle:ModalStyleRight];
    _modal = modal;
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_modal showModalAnimate:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
