//
//  NSObject+JSON.h
//  JSONSerialization
//
//  Created by Avigit Saha on 2015-05-06.
//  Copyright (c) 2015 Avigit Saha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define iQDateFormat @"yyyy-MM-dd'T'HH:mm:ss.SSS"
#define iQTimeZone @"UTC"

@interface NSObject (JSON)

-(NSDictionary *)propertyDictionary;
-(NSString *)nameOfClass;

/**
 *  Init an object with json data
 *
 *  @param data JSON data in NSData format
 *
 *  @return return an instance of object populated with the json data
 */

- (instancetype)initWithJSONData:(NSData *)data;

/**
 *  It takes a JSON array and returns a NSArray object from the json data
 *
 *  @param objectClass Array will contain objects of this clas
 *  @param data        json data
 *
 *  @return returns a NSArray
 */
+ (NSArray *)arrayOfClass:(Class)className JSONData:(NSData *)data;

/**
 *  Converts an object into JSON data
 *
 *  @return json data in NSData format
 */
-(NSData *)JSONData;

/**
 *  Converts an object into JSON data
 *
 *  @return json string in NSString format
 */
-(NSString *)JSONString;
-(NSDictionary *)objectDictionary;

@end
