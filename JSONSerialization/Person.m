//
//  Person.m
//  JSONSerialization
//
//  Created by Avigit Saha on 2015-05-06.
//  Copyright (c) 2015 Avigit Saha. All rights reserved.
//

#import "Person.h"

@implementation Person

- (id)init
{
	if (self = [super init]) {
		[self setValue:@"Company" forKeyPath:@"propertyArrayMap.company"];
		[self setValue:@"NSString" forKeyPath:@"propertyArrayMap.favColors"];
	}
	
	return self;
}

- (BOOL)isEqual:(Person*)person
{
	if (![self.name isEqualToString:person.name]) {
		return NO;
	}
	
	for (int i = 0; i < _company.count; i++) {
		Company *company = _company[i];
		if (![company isEqual:person.company[i]]) {
			return  NO;
		}
	}
	
	if (![_company isEqualToArray:person.company]) {
		return NO;
	}
	
	if (![_favColors isEqualToArray:person.favColors]) {
		return NO;
	}
	
	return YES;
}

@end
