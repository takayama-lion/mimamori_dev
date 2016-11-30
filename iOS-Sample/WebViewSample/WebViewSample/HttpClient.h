//
//  Http.h
//  JojoTown
//
//  Created by Hiroyuki Takayama on 2014/10/29.
//  Copyright (c) 2014年 SYON Communications. All rights reserved.
//

#import <Foundation/Foundation.h>

// key name
#define HTTP_SYS_STATUS @"system_status"
#define HTTP_SYS_ERROR  @"system_error"
#define HTTP_RESPONSE   @"response"

// http status
#define STATUS_OK                @"200"
#define STATUS_HTTP_ERROR        @"400"
#define STATUS_SYSTEM_ERROR      @"500"

#define API_STATUS_OK            @"200"

#define HTTP_STATUS_NOT_FOUND    404
#define HTTP_STATUS_NOT_MODIFIED 304

@interface HttpClient : NSObject

/**
 * http request (json)
 */
+ (void)requestJson:(NSString *)url Response:(void (^)(NSDictionary *responseData))setResponse;
/**
 * http post request (json)
 */
+ (void)postRequestJson:(NSString *)url param:(NSString *)param Response:(void (^)(NSDictionary *responseData))setResponse;
/**
 * sync http request (json)
 */
+ (NSDictionary *)syncRequestJson:(NSString *)url;
/**
 * data http request (NSData)
 */
+ (void)requestData:(NSString *)url Response:(void (^)(NSData *data))setResponse;
/**
 * data http request (NSData)
 */
+ (NSData *)requestData:(NSString *)url;
@end
