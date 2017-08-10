//
//  MDHttpClient.m
//  MDHttpClient
//
//  Created by Jave on 2017/8/10.
//  Copyright © 2017年 markejave. All rights reserved.
//

#import "NSObject+MDSerialization.h"

NSString * const MDHTTPClientErrorDomain = @"com.MDHTTPClient.error.domain";
const NSUInteger MDHTTPClientErrorCodeFailed = 0;

@implementation NSObject (MDSerialization)

- (id)filterNullObject{
    if ([self isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return self;
}

- (id)modelOfClass:(Class)class error:(NSError **)error;{
    *error = [NSError errorWithDomain:MDHTTPClientErrorDomain code:MDHTTPClientErrorCodeFailed userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unable parsed for class: %@.", class]}];
    
    return nil;
}

- (id)modelsOfClass:(Class)class error:(NSError **)error;{
    *error = [NSError errorWithDomain:MDHTTPClientErrorDomain code:MDHTTPClientErrorCodeFailed userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unable parsed for class: %@.", class]}];
    
    return nil;
}

@end

@implementation NSDictionary (MDSerialization)

- (id)filterNullObject;{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    for (NSString *key in [self allKeys]) {
        id value = self[key];
        
        if (value != [NSNull null]) {
            id filterObject = [value filterNullObject];
            if (filterObject) {
                results[key] = filterObject;
            }
        }
    }
    return results;
}

- (id)modelOfClass:(Class)class error:(NSError **)error;{
    if (!class) {
        *error = [NSError errorWithDomain:MDHTTPClientErrorDomain code:MDHTTPClientErrorCodeFailed userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unable parsed for class: %@, cause to class is nil.", class]}];
    }
    return nil;
}

@end

@implementation NSArray (MDSerialization)

- (id)filterNullObject;{
    NSMutableArray *results = [NSMutableArray array];
    for (id item in self) {
        if (item != [NSNull null]) {
            id filterObject = [item filterNullObject];
            if (filterObject) {
                [results addObject:filterObject];
            }
        }
    }
    return results;
}

- (id)modelsOfClass:(Class)class error:(NSError **)error;{
    if (!class) {
        *error = [NSError errorWithDomain:MDHTTPClientErrorDomain code:MDHTTPClientErrorCodeFailed userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unable parsed for class: %@, cause to class is nil.", class]}];
    }
    return nil;
}

@end

@implementation NSDictionary (JSONSerializing)

- (NSData *)JSONData;{
    return [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
}
- (NSData *)JSONDataWithOptions:(NSJSONWritingOptions)options error:(NSError **)error;{
    return [NSJSONSerialization dataWithJSONObject:self options:options error:error];
}
- (NSString *)JSONString;{
    return [[NSString alloc] initWithData:[self JSONData] encoding:NSUTF8StringEncoding];
}

- (NSString *)JSONStringWithOptions:(NSJSONWritingOptions)options error:(NSError **)error;{
    return [[NSString alloc] initWithData:[self JSONDataWithOptions:options error:error] encoding:NSUTF8StringEncoding];
}

@end

@implementation NSArray (JSONSerializing)

- (NSData *)JSONData;{
    return [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSData *)JSONDataWithOptions:(NSJSONWritingOptions)options error:(NSError **)error;{
    return [NSJSONSerialization dataWithJSONObject:self options:options error:error];
}

- (NSString *)JSONString;{
    return [[NSString alloc] initWithData:[self JSONData] encoding:NSUTF8StringEncoding];
}

- (NSString *)JSONStringWithOptions:(NSJSONWritingOptions)options error:(NSError **)error;{
    return [[NSString alloc] initWithData:[self JSONDataWithOptions:options error:error] encoding:NSUTF8StringEncoding];
}

@end

@implementation NSString (JSONDeserializing)

- (id)objectFromJSONString;{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] objectFromJSONData];
}

- (id)objectFromJSONStringWithParseOptions:(NSJSONReadingOptions)options;{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] objectFromJSONDataWithParseOptions:options];
}

- (id)objectFromJSONStringWithParseOptions:(NSJSONReadingOptions)options error:(NSError **)error;{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] objectFromJSONDataWithParseOptions:options error:error];
}

- (id)mutableObjectFromJSONString;{
    return [[self objectFromJSONString] mutableCopy];
}

- (id)mutableObjectFromJSONStringWithParseOptions:(NSJSONReadingOptions)options;{
    return [[self objectFromJSONStringWithParseOptions:options] mutableCopy];
}

- (id)mutableObjectFromJSONStringWithParseOptions:(NSJSONReadingOptions)options error:(NSError **)error;{
    return [[self objectFromJSONStringWithParseOptions:options] mutableCopy];
}

@end

@implementation NSData (JSONDeserializing)
// The NSData MUST be UTF8 encoded JSON.
- (id)objectFromJSONData;{
    return [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:nil];
}

- (id)objectFromJSONDataWithParseOptions:(NSJSONReadingOptions)options;{
    return [NSJSONSerialization JSONObjectWithData:self options:options error:nil];
}

- (id)objectFromJSONDataWithParseOptions:(NSJSONReadingOptions)options error:(NSError **)error;{
    return [NSJSONSerialization JSONObjectWithData:self options:options error:error];
}

- (id)mutableObjectFromJSONData;{
    return [[self objectFromJSONData] mutableCopy];
}

- (id)mutableObjectFromJSONDataWithParseOptions:(NSJSONReadingOptions)options;{
    return [[self objectFromJSONDataWithParseOptions:options] mutableCopy];
}

- (id)mutableObjectFromJSONDataWithParseOptions:(NSJSONReadingOptions)options error:(NSError **)error;{
    return [[self objectFromJSONDataWithParseOptions:options error:error] mutableCopy];
}

@end
