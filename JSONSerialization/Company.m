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

- (BOOL)isEqual:(Company*)company
{
	if (![_name isEqualToString:company.name]) {
		return NO;
	}
	
	if (![_address isEqualToString:company.address]) {
		return NO;
	}
	return YES;
}

@end
