//
//  JSONSerializationTests.m
//  JSONSerializationTests
//
//  Created by Avigit Saha on 2015-05-06.
//  Copyright (c) 2015 Avigit Saha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Person.h"

@interface JSONSerializationTests : XCTestCase

@end

@implementation JSONSerializationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testDeserialization
{
	// Json to Object
	Person *person = [[Person alloc] init];
	person.name = @"Avigit";
	Company *company1 = [[Company alloc] initWithName:@"GB" address:@"Research Dr"];
	Company *company2 = [[Company alloc] initWithName:@"iQmetrix" address:@"Cornowall St"];
	person.company = @[company1, company2];
	person.favColors = @[@"Blue", @"Black", @"Yellow"];
	NSString *json = [person JSONString];
	NSLog(@"%@", json);
	
	Person *person2 = [[Person alloc] initWithJSONData:[json dataUsingEncoding:NSUTF8StringEncoding]];
	XCTAssertTrue([person isEqual:person2]);
	
	// Json to array
	json = @"[\"Blue\", \"Yellow\"]";
	
	NSArray *array = [NSObject arrayOfClass:nil JSONData:[json dataUsingEncoding:NSUTF8StringEncoding]];
	XCTAssertTrue(([array[0] isEqualToString:@"Blue"] && [array[1] isEqualToString:@"Yellow"]));
	
	person2.name = @"No Name";
	array = @[person, person2];
	json = [array JSONString];
	NSLog(@"%@", json);
	NSArray *resultArray = [NSObject arrayOfClass:[Person class] JSONData:[json dataUsingEncoding:NSUTF8StringEncoding]];
	
	XCTAssertTrue([array isEqualToArray:resultArray]);
	XCTAssertTrue(([array[0] isEqual:person] && [array[1] isEqual:person2]));
}

@end
