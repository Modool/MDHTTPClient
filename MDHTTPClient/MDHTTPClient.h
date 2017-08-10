//
//  MDHTTPClient.h
//  MDHTTPClient
//
//  Created by Jave on 2017/8/10.
//  Copyright © 2017年 markejave. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for MDHttpClient.
FOUNDATION_EXPORT double MDHttpClientVersionNumber;

//! Project version string for MDHttpClient.
FOUNDATION_EXPORT const unsigned char MDHttpClientVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MDHttpClient/PublicHeader.h>

#import <AFNetworking/AFNetworking.h>
#import <MDHTTPClient/NSObject+MDSerialization.h>

extern NSString * const MDHTTPMethodGET;

extern NSString * const MDHTTPMethodPOST;

extern NSString * const MDHTTPMethodPUT;

extern NSString * const MDHTTPMethodDELETE;

extern NSString * const MDHTTPMethodHEAD;

extern NSString * const MDHTTPMethodPATCH;


@interface MDHTTPClient : AFHTTPSessionManager

@property (nonatomic, copy  , readonly) NSString *token;

+ (instancetype)unauthenticatedClientWithURL:(NSURL *)URL;

+ (instancetype)authenticatedClientWithURL:(NSURL *)URL token:(NSString *)token;

- (NSURLSessionDataTask *)taskWithURLString:(NSString *)URLString
                                 HTTPMethod:(NSString *)HTTPMethod
                                 parameters:(id)parameters
                        parsedResponseBlock:(id(^)(id result))parsedResponseBlock
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)taskWithURLString:(NSString *)URLString
                                 HTTPMethod:(NSString *)HTTPMethod
                                   HTTPBody:(id)HTTPBody
                            queryParameters:(id)queryParameters
                        parsedResponseBlock:(id(^)(id result))parsedResponseBlock
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)taskWithURLString:(NSString *)URLString
                                 HTTPMethod:(NSString *)HTTPMethod
                                 parameters:(id)parameters
                                resultClass:(Class)resultClass
                                    keyPath:(NSString *)keyPath
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)taskWithURLString:(NSString *)URLString
                                 HTTPMethod:(NSString *)HTTPMethod
                                   HTTPBody:(id)HTTPBody
                            queryParameters:(id)queryParameters
                                resultClass:(Class)resultClass
                                    keyPath:(NSString *)keyPath
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure;

- (id)filterSuccessResponse:(NSURLSessionDataTask *)task responseObject:(id)responseObject error:(NSError **)error;
- (NSError *)filterFailureResponse:(NSURLSessionDataTask *)task responseObject:(id)responseObject error:(NSError *)error;

@end
