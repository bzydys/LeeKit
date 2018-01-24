//
//  Lee_SQLSelectBuilder.h
//  LeeKit
//
//  Created by Lee on 2018/1/3.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "Lee_SQLBuilder.h"
@interface Lee_SQLSelectBuilder : Lee_SQLBuilder

@property(nonatomic, copy)Lee_SQLSelectBuilder* (^select)(void);

@property(nonatomic, copy)Lee_SQLSelectBuilder* (^all)(void);

@property(nonatomic, copy) Lee_SQLSelectBuilder* (^from)(void);

@property(nonatomic, copy) Lee_SQLSelectBuilder* (^orderBy)(NSString *key, BOOL isDesc);

@end
