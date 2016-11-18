//
//  LocalNotification.m
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/18.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "LocalNotification.h"
#import <UIKit/UIKit.h>

@implementation LocalNotification

/**
 * send Local Message
 */
+ (void)sendLocalMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}
@end
