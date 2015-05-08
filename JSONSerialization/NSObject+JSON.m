//
//  NSObject+JSON.m
//  JSONSerialization
//
//  Created by Avigit Saha on 2015-05-06.
//  Copyright (c) 2015 Avigit Saha. All rights reserved.
//

#import "NSObject+JSON.h"

@implementation NSObject (JSON)

#pragma mark - Init Methods
- (instancetype)initWithJSONData:(NSData *)data{
	return [NSObject objectOfClass:[self class] fromJSONData:data];
}

+ (NSArray *)arrayOfClass:(Class)className JSONData:(NSData *)data {
	return [NSObject objectOfClass:className fromJSONData:data];
}


#pragma mark - JSONData to Object
+ (id)objectOfClass:(Class)objectClass fromJSONData:(NSData *)jsonData {
	NSError *error;
	id newObject = nil;
	id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
	
	// If jsonObject is a top-level object already
	if([jsonObject isKindOfClass:[NSDictionary class]]) {
		newObject = [NSObject objectOfClass:objectClass fromJSON:jsonObject];
	}
	// Else it is an array of objects
	else if([jsonObject isKindOfClass:[NSArray class]]){
		newObject = [NSObject arrayOfType:objectClass array:jsonObject];
	}
	
	return newObject;
}


#pragma mark - Dictionary to Object
+(id)objectOfClass:(Class)objectClass fromJSON:(NSDictionary *)dict {
	if([NSStringFromClass(objectClass) isEqualToString:@"NSDictionary"]){
		return dict;
	}
	
	id newObject = [[objectClass alloc] init];
	NSDictionary *mapDictionary = [newObject propertyDictionary];
	
	for (NSString *key in [dict allKeys]) {
		
		NSString *propertyName = [mapDictionary objectForKey:[[[key substringToIndex:1] lowercaseString] stringByAppendingString:[key substringFromIndex:1]]];
		
		if (!propertyName) {
			continue;
		}
		
		// If it's null, set to nil and continue
		if ([dict objectForKey:key] == [NSNull null]) {
			[newObject setValue:nil forKey:propertyName];
			continue;
		}
		
		// If it's a Dictionary, make into object
		if ([[dict objectForKey:key] isKindOfClass:[NSDictionary class]]) {
			//id newObjectProperty = [newObject valueForKey:propertyName];
			NSString *propertyType = [newObject classOfPropertyNamed:propertyName];
			id nestedObj = [NSObject objectOfClass:NSClassFromString(propertyType) fromJSON:[dict objectForKey:key]];
			[newObject setValue:nestedObj forKey:propertyName];
		}
		
		// If it's an array, check for each object in array -> make into object/id
		else if ([[dict objectForKey:key] isKindOfClass:[NSArray class]]) {
			NSArray *nestedArray = [dict objectForKey:key];
			NSString *propertyType = [newObject valueForKeyPath:[NSString stringWithFormat:@"propertyArrayMap.%@", propertyName]];
			NSArray *arrayOfObjects = [NSObject arrayOfType:NSClassFromString(propertyType) array:nestedArray];
			[newObject setValue:arrayOfObjects forKey:propertyName];
		}
		
		// Add to property name, because it is a type already
		else {
			objc_property_t property = class_getProperty([newObject class], [propertyName UTF8String]);
			
			if (property) {
				NSString *classType = [newObject typeFromProperty:property];
				
				// check if NSDate or not
				if ([classType isEqualToString:@"T@\"NSDate\""]) {
					NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
					[formatter setDateFormat:iQDateFormat];
					[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:iQTimeZone]];
					[newObject setValue:[formatter dateFromString:[dict objectForKey:key]] forKey:propertyName];
				}
				else {
					[newObject setValue:[dict objectForKey:key] forKey:propertyName];
				}
			}
		}
	}
	
	return newObject;
}

+ (NSArray*)arrayOfType:(Class)objectClass array:(NSArray*)arrayOfObjects
{
	NSMutableArray *returnArray = [@[] mutableCopy];
	
	for (NSInteger i = 0; i < arrayOfObjects.count; i++) {
		
		if (objectClass != nil && [arrayOfObjects[i] isKindOfClass:[NSDictionary class]]) {
			[returnArray addObject:[NSObject objectOfClass:objectClass fromJSON:arrayOfObjects[i]]];
		} else {
			[returnArray addObject:arrayOfObjects[i]];
		}
	}
	
	return returnArray;
}

-(NSString *)classOfPropertyNamed:(NSString *)propName {
	objc_property_t property = class_getProperty([self class], [propName UTF8String]);
	
	const char *attributes = property_getAttributes(property);
	char buffer[1 + strlen(attributes)];
	strcpy(buffer, attributes);
	char *state = buffer, *attribute;
	while ((attribute = strsep(&state, ",")) != NULL) {
		if (attribute[0] == 'T' && attribute[1] != '@') {
			// it's a C primitive type:
			/*
			 if you want a list of what will be returned for these primitives, search online for
			 "objective-c" "Property Attribute Description Examples"
			 apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.*/
			NSString *typeName = [[NSString alloc] initWithData:[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] encoding:NSUTF8StringEncoding];
			return typeName;
		}
		else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
			// it's an ObjC id type:
			return @"id";
		}
		else if (attribute[0] == 'T' && attribute[1] == '@') {
			// it's another ObjC object type:
			NSData *data = [NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4];
			NSString *className = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			return className;
		}
	}
	
	return @"";
}

-(NSString *)nameOfClass {
	return [NSString stringWithUTF8String:class_getName([self class])];
}

-(NSDictionary *)propertyDictionary {
	// Add properties of Self
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	unsigned count;
	objc_property_t *properties = class_copyPropertyList([self class], &count);
	for (NSInteger i = 0; i < count; i++) {
		NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
		[dict setObject:key forKey:key];
	}
	
	free(properties);
	
	// Add all superclass properties of Self as well, until it hits NSObject
	NSString *superClassName = [[self superclass] nameOfClass];
	if (![superClassName isEqualToString:@"NSObject"]) {
		for (NSString *property in [[[self superclass] propertyDictionary] allKeys]) {
			[dict setObject:property forKey:property];
		}
	}
	
	// Return the Dict
	return dict;
}

-(NSString *)typeFromProperty:(objc_property_t)property {
	return [[NSString stringWithUTF8String:property_getAttributes(property)] componentsSeparatedByString:@","][0];
}


#pragma mark - Get Property Array Map
// This returns an associated property Dictionary for objects
// You should make an object contain a dictionary in init
// that contains a map for each array and what it contains:
//
// {"arrayPropertyName":"TypeOfObjectYouWantInArray"}
//
// To Set this object in each init method, do something like this:
//
// [myObject setValue:@"TypeOfObjectYouWantInArray" forKeyPath:@"propertyArrayMap.arrayPropertyName"]
//
-(NSMutableDictionary *)getPropertyArrayMap {
	if (objc_getAssociatedObject(self, @"propertyArrayMap")==nil) {
		objc_setAssociatedObject(self,@"propertyArrayMap",[[NSMutableDictionary alloc] init],OBJC_ASSOCIATION_RETAIN);
	}
	return (NSMutableDictionary *)objc_getAssociatedObject(self, @"propertyArrayMap");
}


#pragma mark - Object to Data/String/etc.

-(NSDictionary *)objectDictionary {
	NSMutableDictionary *objectDict = [@{} mutableCopy];
	for (NSString *key in [[self propertyDictionary] allKeys]) {
		[objectDict setValue:[self valueForKey:key] forKey:key];
	}
	return objectDict;
}

-(NSData *)JSONData{
	id dict = [NSObject jsonDataObjects:self];
	return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
}

-(NSString *)JSONString{
	id dict = [NSObject jsonDataObjects:self];
	NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
	return [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
}

+ (id)jsonDataObjects:(id)obj {
	id returnProperties = nil;
	if([obj isKindOfClass:[NSArray class]]) {
		NSInteger length =[(NSArray*)obj count];
		returnProperties = [NSMutableArray arrayWithCapacity:length];
		for(NSInteger i = 0; i < length; i++){
			[returnProperties addObject:[NSObject dictionaryWithPropertiesOfObject:[(NSArray*)obj objectAtIndex:i]]];
		}
	}
	else {
		returnProperties = [NSObject dictionaryWithPropertiesOfObject:obj];
		
	}
	
	return returnProperties;
}

+(NSDictionary *)dictionaryWithPropertiesOfObject:(id)obj
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	NSMutableArray *propertiesArray = [NSObject propertiesArrayFromObject:obj];
	
	for (NSInteger i = 0; i < propertiesArray.count; i++) {
		NSString *key = propertiesArray[i];
		
		if (![obj valueForKey:key]) {
			continue;
		}
		
		if ([[obj valueForKey:key] isKindOfClass:[NSArray class]]) {
			[dict setObject:[self arrayForObject:[obj valueForKey:key]] forKey:key];
		}
		else if ([[obj valueForKey:key] isKindOfClass:[NSDate class]]){
			[dict setObject:[self dateForObject:[obj valueForKey:key]] forKey:key];
		}
		else if ([self isSystemObject:obj key:key]) {
			[dict setObject:[obj valueForKey:key] forKey:key];
		}
		else if ([[obj valueForKey:key] isKindOfClass:[NSData class]]){
			[dict setObject:[[obj valueForKey:key] base64EncodedStringWithOptions:0] forKey:key];
		}
		else {
			[dict setObject:[self dictionaryWithPropertiesOfObject:[obj valueForKey:key]] forKey:key];
		}
	}
	
	return [NSDictionary dictionaryWithDictionary:dict];
}

+(NSMutableArray *)propertiesArrayFromObject:(id)obj {
	
	NSMutableArray *props = [NSMutableArray array];
	
	if (!obj) {
		return props;
	}
	
	unsigned count;
	objc_property_t *properties = class_copyPropertyList([obj class], &count);
	for (NSInteger i = 0; i < count; i++) {
		[props addObject:[NSString stringWithUTF8String:property_getName(properties[i])]];
	}
	
	free(properties);
	
	NSString *superClassName = [[obj superclass] nameOfClass];
	if (![superClassName isEqualToString:@"NSObject"]) {
		[props addObjectsFromArray:[NSObject propertiesArrayFromObject:[[NSClassFromString(superClassName) alloc] init]]];
	}
	
	return props;
}

-(BOOL)isSystemObject:(id)obj key:(NSString *)key{
	if ([[obj valueForKey:key] isKindOfClass:[NSString class]] || [[obj valueForKey:key] isKindOfClass:[NSNumber class]] || [[obj valueForKey:key] isKindOfClass:[NSDictionary class]]) {
		return YES;
	}
	
	return NO;
}

-(BOOL)isSystemObject:(id)obj{
	if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSDictionary class]]) {
		return YES;
	}
	
	return NO;
}

+(NSArray *)arrayForObject:(id)obj{
	NSArray *ContentArray = (NSArray *)obj;
	NSMutableArray *objectsArray = [[NSMutableArray alloc] init];
	for (NSInteger ii = 0; ii < ContentArray.count; ii++) {
		if ([ContentArray[ii] isKindOfClass:[NSArray class]]) {
			[objectsArray addObject:[self arrayForObject:[ContentArray objectAtIndex:ii]]];
		}
		else if ([ContentArray[ii] isKindOfClass:[NSDate class]]){
			[objectsArray addObject:[self dateForObject:[ContentArray objectAtIndex:ii]]];
		}
		else if ([self isSystemObject:[ContentArray objectAtIndex:ii]]) {
			[objectsArray addObject:[ContentArray objectAtIndex:ii]];
		}
		else {
			[objectsArray addObject:[self dictionaryWithPropertiesOfObject:[ContentArray objectAtIndex:ii]]];
		}
		
	}
	
	return objectsArray;
}


+(NSString *)dateForObject:(id)obj{
	NSDate *date = (NSDate *)obj;
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:iQDateFormat];
	[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:iQTimeZone]];
	return [formatter stringFromDate:date];
}

@end
