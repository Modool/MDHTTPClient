//
//  MDHTTPClient.m
//  MDHTTPClient
//
//  Created by Jave on 2017/8/10.
//  Copyright © 2017年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MDSerialization)

- (id)filterNullObject;

@end

@interface NSDictionary (MDSerialization)

- (id)modelOfClass:(Class)class error:(NSError **)error;

@end

@interface NSArray (MDSerialization)

- (id)modelsOfClass:(Class)class error:(NSError **)error;

@end

@interface NSDictionary (JSONSerializing)
- (NSData *)JSONData;
- (NSData *)JSONDataWithOptions:(NSJSONWritingOptions)options error:(NSError **)error;
- (NSString *)JSONString;
- (NSString *)JSONStringWithOptions:(NSJSONWritingOptions)options error:(NSError **)error;
@end

@interface NSArray (JSONSerializing)

- (NSData *)JSONData;
- (NSData *)JSONDataWithOptions:(NSJSONWritingOptions)options error:(NSError **)error;
- (NSString *)JSONString;
- (NSString *)JSONStringWithOptions:(NSJSONWritingOptions)options error:(NSError **)error;

@end

@interface NSString (JSONDeserializing)

- (id)objectFromJSONString;
- (id)objectFromJSONStringWithParseOptions:(NSJSONReadingOptions)options;
- (id)objectFromJSONStringWithParseOptions:(NSJSONReadingOptions)options error:(NSError **)error;
- (id)mutableObjectFromJSONString;
- (id)mutableObjectFromJSONStringWithParseOptions:(NSJSONReadingOptions)options;
- (id)mutableObjectFromJSONStringWithParseOptions:(NSJSONReadingOptions)options error:(NSError **)error;

@end

@interface NSData (JSONDeserializing)

// The NSData MUST be UTF8 encoded JSON.
- (id)objectFromJSONData;
- (id)objectFromJSONDataWithParseOptions:(NSJSONReadingOptions)options;
- (id)objectFromJSONDataWithParseOptions:(NSJSONReadingOptions)options error:(NSError **)error;
- (id)mutableObjectFromJSONData;
- (id)mutableObjectFromJSONDataWithParseOptions:(NSJSONReadingOptions)options;
- (id)mutableObjectFromJSONDataWithParseOptions:(NSJSONReadingOptions)options error:(NSError **)error;

@end
