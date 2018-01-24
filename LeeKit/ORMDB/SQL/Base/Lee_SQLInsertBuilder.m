//
//  Lee_SQLInsertBuilder.m
//  LeeKit
//
//  Created by Lee on 2018/1/3.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "Lee_SQLInsertBuilder.h"

@implementation Lee_SQLInsertBuilder

-(Lee_SQLInsertBuilder *(^)(void))insert{
    return ^{
        self.sql = [self.sql stringByAppendingString:@"insert into "];
        return self;
    };
}

-(Lee_SQLInsertBuilder *(^)(NSDictionary *))colums{
    return ^(NSDictionary *params){
        if (params.count > 0) {
            self.sql = [self.sql stringByAppendingString:@"( "];
            
            NSArray *keyArr = params.allKeys;
            NSString *keyString = [keyArr componentsJoinedByString:@","];
            self.sql = [self.sql stringByAppendingString:keyString];
            self.sql = [self.sql stringByAppendingString:@" ) values ( "];
            NSMutableArray *valueArr = [NSMutableArray array];
            for (NSString *key in keyArr) {
                [valueArr addObject:params[key]];
            }
            self.sql = [self.sql stringByAppendingString:[valueArr componentsJoinedByString:@","]];
            self.sql = [self.sql stringByAppendingString:@" ) "];
            
        }
        return self;
    };
}




@end
