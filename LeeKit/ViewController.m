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

@interface ViewController ()

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
//    [banner showImagesWithUrls:@[[NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/pic/item/8435e5dde71190ef4d91e30fc51b9d16fcfa60f3.jpg"],[NSURL URLWithString:@"http://a.hiphotos.baidu.com/image/pic/item/f31fbe096b63f62493a948d38c44ebf81b4ca36e.jpg"]] loadMethod:^(NSURL *url, UIImageView *imgView) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSData *data = [NSData dataWithContentsOfURL:url];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                imgView.image = [UIImage imageWithData:data];
//            });
//
//        });
//    }];
    [banner showImages:@[[UIImage imageNamed:@"c.jpg"]]];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
