//
//  LocalNotification.h
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/18.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalNotification : NSObject

/**
 * send Local Message
 */
+ (void)sendLocalMessage:(NSString *)message;

@end
