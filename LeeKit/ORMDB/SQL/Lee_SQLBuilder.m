//
//  Lee_SQLBuilder.m
//  LeeKit
//
//  Created by Lee on 2018/1/3.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "Lee_SQLBuilder.h"

@implementation Lee_SQLBuilder

-(instancetype)init{
    if (self = [super init]) {
        self.sql = @"";
    }
    return self;
}

-(__kindof Lee_SQLBuilder *(^)(NSString *))table{
    return ^(NSString *tableName){
        self.sql = [[self.sql stringByAppendingString:tableName] stringByAppendingString:@" "];
        return self;
        
    };
}


-(__kindof Lee_SQLBuilder *(^)(BOOL, BOOL, NSDictionary *))wh{
    return ^(BOOL isAdd, BOOL isOr, NSDictionary *params){
        self.sql = [self.sql stringByAppendingString:@"where "];
        NSInteger index = 0;
        for (NSString *key in params.allKeys) {
            self.sql = [[self.sql stringByAppendingString:key] stringByAppendingString:@" "];
            self.sql = [self.sql stringByAppendingString:@"= "];
            self.sql = [[self.sql stringByAppendingString:params[key]] stringByAppendingString:@" "];
            index++;
            if (index < params.count) {
                if (isAdd) {
                    self.sql = [self.sql stringByAppendingString:@"and "];
                }
                if (isOr) {
                    self.sql = [self.sql stringByAppendingString:@"or "];
                }
                
            }
        }
        return self;
    };
}

-(NSString *)build{
    self.sql = [self.sql stringByAppendingString:@";"];
    return self.sql;
}

@end
