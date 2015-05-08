//
//  Company.m
//  JSONSerialization
//
//  Created by Avigit Saha on 2015-05-07.
//  Copyright (c) 2015 Avigit Saha. All rights reserved.
//

#import "Company.h"

@implementation Company

- (instancetype)initWithName:(NSString*)name address:(NSString*)address
{
	if (self = [super init]) {
		self.name = name;
		self.address = address;
	}
	
	return self;
}

@end
