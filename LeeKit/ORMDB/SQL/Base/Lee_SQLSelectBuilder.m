//
//  Lee_SQLSelectBuilder.m
//  LeeKit
//
//  Created by Lee on 2018/1/3.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "Lee_SQLSelectBuilder.h"

@implementation Lee_SQLSelectBuilder

-(Lee_SQLSelectBuilder *(^)(void))select{
    return ^{
        self.sql = [self.sql stringByAppendingString:@"select "];
        return self;
    };
}

-(Lee_SQLSelectBuilder *(^)(void))all{
    return ^{
        self.sql = [self.sql stringByAppendingString:@"* "];
        return self;
    };
}

-(Lee_SQLSelectBuilder *(^)(void))from{
    return ^{
        self.sql = [self.sql stringByAppendingString:@"from "];
        return self;
    };
}

-(Lee_SQLSelectBuilder *(^)(NSString *, BOOL))orderBy{
    return ^(NSString *key, BOOL isDesc){
        self.sql = [self.sql stringByAppendingString:@"order by "];
        self.sql = [self.sql stringByAppendingString:key];
        self.sql = [self.sql stringByAppendingString:@" "];
        self.sql = [self.sql stringByAppendingString:isDesc?@"desc ":@"asc "];
        return self;
    };
}


@end
