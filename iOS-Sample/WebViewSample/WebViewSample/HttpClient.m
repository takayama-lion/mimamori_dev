//
//  Http.m
//  JojoTown
//
//  Created by Hiroyuki Takayama on 2014/10/29.
//  Copyright (c) 2014年 SYON Communications. All rights reserved.
//

#import "HttpClient.h"
#import "FBNetworkReachability.h"

@implementation HttpClient

//************************************************************//
// public method
//************************************************************//
/**
 * http request (json)
 */
+ (void)requestJson:(NSString *)url Response:(void (^)(NSDictionary *responseData))setResponse
{
//    NSLog(@"----url=[%@]", url);
    // リクエスト設定
    NSMutableURLRequest *request = [self requestUrl:url httpMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *dictionary = [self responseEdit:data response:response error:error url:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                setResponse(dictionary);
            }
        });

    }];
}
/**
 * http post request (json)
 */
+ (void)postRequestJson:(NSString *)url param:(NSString *)param Response:(void (^)(NSDictionary *responseData))setResponse
{
//    NSLog(@"----url=[%@]", url);
    // パラメータ設定
    NSString *postString = [NSString stringWithFormat:@"%@", param];
    // リクエスト設定
    NSMutableURLRequest *request = [self requestUrl:url httpMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *dictionary = [self responseEdit:data response:response error:error url:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                setResponse(dictionary);
            }
        });
        
    }];
    
}
/**
 * sync http request (json)
 */
+ (NSDictionary *)syncRequestJson:(NSString *)url
{
    // リクエスト設定
    NSMutableURLRequest *request = [self requestUrl:url httpMethod:@"GET"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    return [self responseEdit:data response:response error:error url:url];
    
}
/**
 * NSMutableURLRequest setting
 */
+ (NSMutableURLRequest *)requestUrl:(NSString *)url httpMethod:(NSString *)httpMethod
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:httpMethod];
    [request setURL:[NSURL URLWithString:url]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:30];
    [request setHTTPShouldHandleCookies:FALSE];
    
    return request;
}
/**
 * data http request (NSData)
 */
+ (void)requestData:(NSString *)url Response:(void (^)(NSData *data))setResponse
{
//    NSLog(@"----url=[%@]3", url);
    
    FBNetworkReachabilityConnectionMode mode =
    [FBNetworkReachability sharedInstance].connectionMode;
    if (mode == FBNetworkReachableNon) {
        @autoreleasepool {
            setResponse(nil);
        }
    }
    
    NSURLRequest *_request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSData *responseData = nil;
        if (error) {
            // エラー処理を行う。
            if (error.code == -1003) {
                NSLog(@"not found hostname. targetURL=%@", url);
            } else if (error.code == -1019) {
                NSLog(@"auth error. reason=%@", error);
            } else {
                NSLog(@"unknown error occurred. reason = %@", error);
            }
            
            
        } else {
            NSInteger httpStatusCode = ((NSHTTPURLResponse *)response).statusCode;
//            NSLog(@"status code=[%zd]", httpStatusCode);
            if (httpStatusCode == HTTP_STATUS_NOT_FOUND) {
                NSLog(@"404 NOT FOUND ERROR. targetURL=%@", url);
                
                
            } else {
//                NSLog(@"statusCode = %zd", ((NSHTTPURLResponse *)response).statusCode);
                responseData = [data copy];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                setResponse(responseData);
            }
        });
        
    }];
}
/**
 * data http request (NSData)
 */
+ (NSData *)requestData:(NSString *)url
{
    // リクエスト設定
    NSMutableURLRequest *request = [self requestUrl:url httpMethod:@"GET"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    FBNetworkReachabilityConnectionMode mode =
    [FBNetworkReachability sharedInstance].connectionMode;
    if (mode == FBNetworkReachableNon) {
        return nil;
    }
    
    if (error) {
        // エラー処理を行う。
        if (error.code == -1003) {
            NSLog(@"not found hostname. targetURL=%@", url);
        } else if (error.code == -1019) {
            NSLog(@"auth error. reason=%@", error);
        } else {
            NSLog(@"unknown error occurred. reason = %@", error);
        }
        data = nil;
        
    } else {
        NSInteger httpStatusCode = ((NSHTTPURLResponse *)response).statusCode;
        //        NSLog(@"status code=[%zd](post)", httpStatusCode);
        if (httpStatusCode == HTTP_STATUS_NOT_FOUND) {
            NSLog(@"404 NOT FOUND ERROR. targetURL=%@", url);
            data = nil;
            
        }
    }

    
    return data;
}

//************************************************************//
// private method
//************************************************************//
/**
 * response data edit
 */
+ (NSDictionary *)responseEdit:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error url:(NSString *)url
{
    FBNetworkReachabilityConnectionMode mode =
    [FBNetworkReachability sharedInstance].connectionMode;
    if (mode == FBNetworkReachableNon) {
        @autoreleasepool {
            NSDictionary *response = @{HTTP_SYS_STATUS:@"0"};
            return response;
        }
    }
    
    NSDictionary *dictionary;
    if (error) {
        // エラー処理を行う。
        if (error.code == -1003) {
            NSLog(@"not found hostname. targetURL=%@", url);
        } else if (error.code == -1019) {
            NSLog(@"auth error. reason=%@", error);
        } else {
            NSLog(@"unknown error occurred. reason = %@", error);
        }
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                      STATUS_SYSTEM_ERROR, HTTP_SYS_STATUS,
                      error, HTTP_SYS_ERROR,
                      nil];
    
    } else {
        NSInteger httpStatusCode = ((NSHTTPURLResponse *)response).statusCode;
//        NSLog(@"status code=[%zd](post)", httpStatusCode);
        if (httpStatusCode == HTTP_STATUS_NOT_FOUND) {
            NSLog(@"404 NOT FOUND ERROR. targetURL=%@", url);
            dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                          STATUS_HTTP_ERROR, HTTP_SYS_STATUS,
                          [NSString stringWithFormat:@"%zd", httpStatusCode], HTTP_SYS_ERROR,
                          nil];
            
        } else {
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                          STATUS_OK, HTTP_SYS_STATUS,
                          [jsonDictionary copy], HTTP_RESPONSE,
                          nil];
            jsonDictionary = nil;
        }
    }
    return dictionary;
}
@end
