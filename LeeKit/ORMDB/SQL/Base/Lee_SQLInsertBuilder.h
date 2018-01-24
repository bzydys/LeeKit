//
//  Lee_SQLInsertBuilder.h
//  LeeKit
//
//  Created by Lee on 2018/1/3.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "Lee_SQLBuilder.h"

@interface Lee_SQLInsertBuilder : Lee_SQLBuilder

@property(nonatomic, copy) Lee_SQLInsertBuilder* (^insert)(void);

@property(nonatomic, copy) Lee_SQLInsertBuilder* (^colums)(NSDictionary *params);

@end
