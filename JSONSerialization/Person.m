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

@end
