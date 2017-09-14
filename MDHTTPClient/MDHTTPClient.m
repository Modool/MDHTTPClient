//
//  MDHTTPClient.m
//  MDHTTPClient
//
//  Created by Jave on 2017/8/10.
//  Copyright © 2017年 markejave. All rights reserved.
//

#import "MDHTTPClient.h"
#import "NSObject+MDSerialization.h"

NSString * const MDHTTPMethodGET        = @"GET";

NSString * const MDHTTPMethodPOST       = @"POST";

NSString * const MDHTTPMethodPUT        = @"PUT";

NSString * const MDHTTPMethodDELETE     = @"DELETE";

NSString * const MDHTTPMethodHEAD       = @"HEAD";

NSString * const MDHTTPMethodPATCH      = @"PATCH";

NSString * const MDHTTPClientAuthorizeURLString = @"validateMachineNumber";

@interface MDHTTPClient ()

@property (nonatomic, copy) NSString *token;

@end

@implementation MDHTTPClient

+ (instancetype)unauthenticatedClientWithURL:(NSURL *)URL {
    NSParameterAssert(URL != nil);
    MDHTTPClient *client = [[[self class] alloc] initWithURL:URL];
    return client;
}

+ (instancetype)authenticatedClientWithURL:(NSURL *)URL token:(NSString *)token {
    NSParameterAssert(URL != nil);
    NSParameterAssert(token != nil);
    MDHTTPClient *client = [[[self class] alloc] initWithURL:URL];
    client.token = token;
    return client;
}

- (id)initWithURL:(NSURL *)URL {
    NSParameterAssert(URL != nil);
    self = [self initWithBaseURL:URL];
    if (self) {
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    }
    return self;
}

#pragma mark Class Properties

- (id)filterSuccessResponse:(NSURLSessionDataTask *)task responseObject:(id)responseObject error:(NSError **)error{
    if ([responseObject isKindOfClass:[NSArray class]] || [responseObject isKindOfClass:[NSDictionary class]]) {
        responseObject =  [responseObject filterNullObject];
    }
    return responseObject;
}

- (NSError *)filterFailureResponse:(NSURLSessionDataTask *)task responseObject:(id)responseObject error:(NSError *)error{
    return error;
}

- (NSURLSessionDataTask *)dataTaskWithURLString:(NSString *)URLString
                                     HTTPMethod:(NSString *)method
                                       HTTPBody:(id)HTTPBody
                                queryParameters:(id)queryParameters
                                        success:(void (^)(NSURLSessionDataTask *, id))success
                                        failure:(void (^)(NSURLSessionDataTask *, NSError *, id))failure {
    
    NSError *serializationError = nil;
    NSMutableURLRequest *mutableRequest = [[self requestSerializer] requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:[self baseURL]] absoluteString] parameters:HTTPBody error:&serializationError];
    NSString *query = AFQueryStringFromParameters(queryParameters);
    if ([query length]) {
        mutableRequest.URL = [NSURL URLWithString:[[[mutableRequest URL] absoluteString] stringByAppendingFormat:[[mutableRequest URL] query] ? @"&%@" : @"?%@", query]];
    }
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError, nil);
            });
#pragma clang diagnostic pop
        }
        return nil;
    }
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:mutableRequest
                       completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                           if (error) {
                               if (failure) {
                                   failure(dataTask, responseObject, error);
                               }
                           } else {
                               if (success) {
                                   success(dataTask, responseObject);
                               }
                           }
                       }];
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *, id))failure {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError, nil);
            });
#pragma clang diagnostic pop
        }
        return nil;
    }
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request
                       completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                           if (error) {
                               if (failure) {
                                   failure(dataTask, error, responseObject);
                               }
                           } else {
                               if (success) {
                                   success(dataTask, responseObject);
                               }
                           }
                       }];
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)taskWithURLString:(NSString *)URLString
                                 HTTPMethod:(NSString *)HTTPMethod
                                   HTTPBody:(NSDictionary *)HTTPBody
                            queryParameters:(NSDictionary *)queryParameters
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure;{
    __weak __typeof(self) weak_self = self;
    NSURLSessionDataTask *dataTask = nil;
    if ([HTTPMethod isEqualToString:MDHTTPMethodPOST] || [HTTPMethod isEqualToString:MDHTTPMethodPUT]) {
        dataTask = [self dataTaskWithURLString:URLString HTTPMethod:HTTPMethod HTTPBody:HTTPBody queryParameters:queryParameters success:^(NSURLSessionDataTask * task, id responseObject){
            __strong __typeof(self) self = weak_self;
            NSError *error = nil;
            responseObject = [self filterSuccessResponse:task responseObject:responseObject error:&error];
            if (!error) {
                success(responseObject);
            } else {
                failure(error);
            }
        } failure:^(NSURLSessionDataTask * task, NSError *error, id responseObject){
            failure([self filterFailureResponse:task responseObject:responseObject error:error]);
        }];
    }
    if (dataTask) {
        NSLog(@"HTTP task : %@  \nrequest : %@ \nHTTPBody: %@ \nqueryParameters : \n%@", [dataTask description], [[dataTask currentRequest] description], HTTPBody, queryParameters);
    };
    return dataTask;
}

- (NSURLSessionDataTask *)taskWithURLString:(NSString *)URLString
                                 HTTPMethod:(NSString *)HTTPMethod
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure;{
    __weak __typeof(self) weak_self = self;
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:HTTPMethod URLString:URLString parameters:parameters success:^(NSURLSessionDataTask * task, id responseObject){
        __strong __typeof(self) self = weak_self;
        NSError *error = nil;
        responseObject = [self filterSuccessResponse:task responseObject:responseObject error:&error];
        if (!error) {
            success(responseObject);
        } else {
            failure(error);
        }
    } failure:^(NSURLSessionDataTask * task, NSError *error, id responseObject){
        failure([self filterFailureResponse:task responseObject:responseObject error:error]);
    }];
    if (dataTask) {
        NSLog(@"HTTP task : %@  \nrequest : %@ \nparameters : \n%@", [dataTask description], [[dataTask currentRequest] description], parameters);
    }
    return dataTask;
}

// undefine parse action
- (NSURLSessionDataTask *)taskWithURLString:(NSString *)URLString
                                 HTTPMethod:(NSString *)HTTPMethod
                                 parameters:(id)parameters
                        parsedResponseBlock:(id(^)(id result))parsedResponseBlock
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure{
    __weak __typeof(self) weak_self = self;
    return [self taskWithURLString:URLString HTTPMethod:HTTPMethod parameters:parameters success:^(id responseObject) {
        __strong __typeof(self) self = weak_self;
        if (success) {
            success([self parsedResponse:responseObject block:parsedResponseBlock]);
        }
    } failure:failure];
}

// undefine parse action
- (NSURLSessionDataTask *)taskWithURLString:(NSString *)URLString
                                 HTTPMethod:(NSString *)HTTPMethod
                                   HTTPBody:(id)HTTPBody
                            queryParameters:(id)queryParameters
                        parsedResponseBlock:(id(^)(id result))parsedResponseBlock
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure{
    __weak __typeof(self) weak_self = self;
    return [self taskWithURLString:URLString HTTPMethod:HTTPMethod HTTPBody:HTTPBody queryParameters:queryParameters success:^(id responseObject) {
        __strong __typeof(self) self = weak_self;
        if (success) {
            success([self parsedResponse:responseObject block:parsedResponseBlock]);
        }
    } failure:failure];
}

// array or dictionary parse action
- (NSURLSessionDataTask *)taskWithURLString:(NSString *)URLString
                                 HTTPMethod:(NSString *)HTTPMethod
                                 parameters:(id)parameters
                                resultClass:(Class)resultClass
                                    keyPath:(NSString *)keyPath
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure{
    __weak __typeof(self) weak_self = self;
    return [self taskWithURLString:URLString HTTPMethod:HTTPMethod parameters:parameters success:^(id responseObject) {
        __strong __typeof(self) self = weak_self;
        NSError *error = nil;
        responseObject = [self parsedResponseOfClass:resultClass keyPath:keyPath fromJSON:responseObject error:&error];
        if (!error) {
            if (success) {
                success(responseObject);
            }
        } else {
            if (failure) {
                failure(error);
            }
        }
    } failure:failure];
}

// array or dictionary parse action
- (NSURLSessionDataTask *)taskWithURLString:(NSString *)URLString
                                 HTTPMethod:(NSString *)HTTPMethod
                                   HTTPBody:(id)HTTPBody
                            queryParameters:(id)queryParameters
                                resultClass:(Class)resultClass
                                    keyPath:(NSString *)keyPath
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure{
    __weak __typeof(self) weak_self = self;
    return [self taskWithURLString:URLString HTTPMethod:HTTPMethod HTTPBody:HTTPBody queryParameters:queryParameters success:^(id responseObject) {
        __strong __typeof(self) self = weak_self;
        NSError *error = nil;
        responseObject = [self parsedResponseOfClass:resultClass keyPath:keyPath fromJSON:responseObject error:&error];
        if (!error) {
            if (success) {
                success(responseObject);
            }
        } else {
            if (failure) {
                failure(error);
            }
        }
    } failure:failure];
}

- (NSString *)stringValueFromObject:(id)value{
    if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
        return [value JSONString];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    } else if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else {
        return [value description];
    }
}

- (id)parsedResponse:(id)response block:(id(^)(id result))parsedResponseBlock{
    return parsedResponseBlock ? parsedResponseBlock(response) : response;
}

- (id)parsedResponseOfClass:(Class)resultClass keyPath:(NSString *)keyPath fromJSON:(id)responseObject error:(NSError **)error {
    id (^parseJSONDictionary)(NSDictionary *) = ^id (NSDictionary *JSONDictionary) {
        id (^adapteJOSNModel)(NSDictionary *JSONValue) = ^id (NSDictionary *JSONValue){
            id parsedObject = [JSONValue modelOfClass:resultClass error:error];
            if (parsedObject == nil) {
                // Don't treat "no class found" errors as real parsing failures.
                // In theory, this makes parsing code forward-compatible with
                // API additions.
                if (*error) {
                    NSLog(@"Parsed model failed : %@   \n JOSN : %@", *error, responseObject);
                }
                return nil;
            }
            return parsedObject;
        };
        id JSONValue = JSONDictionary;
        if ([JSONValue isKindOfClass:[NSDictionary class]] && [keyPath length]) {
            JSONValue = [JSONDictionary valueForKeyPath:keyPath];
        }
        if (resultClass == nil) {
            return JSONValue;
        }
        if (![JSONValue isKindOfClass:[NSArray class]]) {
            if (resultClass == [NSString class]) {
                return [self stringValueFromObject:JSONValue];
            }
            if (resultClass == [NSNumber class]) {
                return [[NSNumberFormatter new] numberFromString:[self stringValueFromObject:JSONValue]];
            }
            return adapteJOSNModel(JSONValue);
        } else{
            NSMutableArray *models = [NSMutableArray array];
            for (NSDictionary *subJSONValue in JSONValue) {
                if (![subJSONValue isKindOfClass:[NSDictionary class]]) {
                    return JSONValue;
                }
                [models addObject:adapteJOSNModel(subJSONValue)];
            }
            return models;
        }
    };
    
    if ([responseObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *models = [NSMutableArray array];
        for (NSDictionary *JSONDictionary in responseObject) {
            if (![JSONDictionary isKindOfClass:[NSDictionary class]]) {
                return responseObject;
            }
            [models addObject:parseJSONDictionary(JSONDictionary)];
        }
        return models;
    } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
        return parseJSONDictionary(responseObject);
    } else {
        return responseObject;
    }
}

@end
