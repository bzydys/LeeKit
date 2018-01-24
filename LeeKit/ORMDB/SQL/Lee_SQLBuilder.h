//
//  Lee_SQLBuilder.h
//  LeeKit
//
//  Created by Lee on 2018/1/3.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lee_SQLBuilder : NSObject

@property(nonatomic, copy) NSString *sql;

@property(nonatomic, copy) __kindof Lee_SQLBuilder* (^table)(NSString *tableName);

@property(nonatomic, copy) __kindof Lee_SQLBuilder* (^wh)(BOOL isAdd, BOOL isOr, NSDictionary *params);

-(NSString *)build;


@end
