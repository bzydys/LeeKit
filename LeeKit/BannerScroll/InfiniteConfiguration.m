//
//  InfiniteConfiguration.m
//  LeeKit
//
//  Created by Lee on 2018/1/22.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "InfiniteConfiguration.h"

@implementation InfiniteConfiguration

-(instancetype)init{
    if (self = [super init]) {
        self.infinite = YES;
        self.showLoadingView = NO;
        self.duration = 5.0;
        self.direction = PageControllDirectionCenter;
    }
    return self;
}

@end
