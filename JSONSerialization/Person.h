//
//  Person.h
//  JSONSerialization
//
//  Created by Avigit Saha on 2015-05-06.
//  Copyright (c) 2015 Avigit Saha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Company.h"

@interface Person : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *company;
@property (nonatomic, strong) NSArray *favColors;

@end
