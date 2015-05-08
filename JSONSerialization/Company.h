//
//  Company.h
//  JSONSerialization
//
//  Created by Avigit Saha on 2015-05-07.
//  Copyright (c) 2015 Avigit Saha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Company : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;

- (instancetype)initWithName:(NSString*)name address:(NSString*)address;

@end
